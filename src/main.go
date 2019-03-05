package main

/**
 * @file main.go
 * @copyright (C) 2019 by Oleh Kurachenko.
 * See LICENCE file at the root of repository
 * @author Oleh Kurachenko <oleh.kurachenko@gmail.com>
 * @date Created 2019-03-03
 *
 * @see Author's
 * <a href="gitlab.com/oleh.kurachenko">GitLab</a>
 * @see Author's
 * <a href="linkedin.com/in/oleh-kurachenko-6b025b111">LinkedIn</a>
 */

import (
	"bytes"
	"encoding/json"
	"flag"
	"github.com/fatih/color"
	"io/ioutil"
	"log"
	"os/exec"
)

var colorInfo = color.New(color.FgCyan)
var colorInfoH = color.New(color.FgCyan).Add(color.Bold)

var colorAction = color.New(color.FgBlue)
var colorActionH = color.New(color.FgBlue).Add(color.Bold)

var colorSuccess = color.New(color.FgGreen).Add(color.Bold)
var colorFail = color.New(color.FgRed).Add(color.Bold)

type ExecutionOptions struct {
	tmpDir string
	optDir string
	ubuntuVersion string
	isVerbose bool
}

//
// Execute bash command
//
//noinspection GoUnhandledErrorResult
func execute(command string, options ExecutionOptions) bool {
	cmd := exec.Command("bash", "-c", command)
	var stdout, stderr bytes.Buffer

	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	colorAction.Print(command + "...")

	err := cmd.Run()

	if err != nil {
		colorFail.Println(" Fail!")

		log.Println("Command execution failed with code " + err.Error(
			) + ": " + command)
		log.Println("  stdout:\n" + string(stdout.Bytes()))
		log.Println("  stderr:\n" + string(stderr.Bytes()))

		return false
	}

	colorSuccess.Println(" OK!")
	if options.isVerbose {
		log.Println("Stdout:\n" + string(stdout.Bytes()))
	}
	return true
}

//
// Install apt package
//
func aptInstall(packageName string, options ExecutionOptions) bool {
	return execute("sudo apt-get install " + packageName + " -y", options)
}

//
// Install deb package by downloading and launcign gdebi on it
//
//noinspection GoUnhandledErrorResult
func debInstall(packageName, packageURL string, options ExecutionOptions) bool {
	colorActionH.Println("Installing deb package " + packageName + "...")

	checkCmd := exec.Command("bash", "-c",
		"dpkg -l | grep " + packageName + " &>/dev/null")
	if checkCmd.Run() == nil {
		colorActionH.Print("Deb package " + packageName + ": ")
		colorSuccess.Println("already installed.")
		return true
	}

	installIsOk :=
		execute("wget '" + packageURL + "' -O '" + options.tmpDir +
			"/" + packageName + ".deb'", options) &&
		execute("sudo gdebi " + options.tmpDir + "/" + packageName +
			".deb --n", options)

	colorActionH.Print("Deb package " + packageName + ": ")

	if !installIsOk {
		colorFail.Println("Fail!")
		return false
	}
	colorSuccess.Println("Installed!")
	return true
}

//
// Install application distributed using tar by unachive it and launch
//
//noinspection GoUnhandledErrorResult
func tarInstall(
	applicationName,
	tarURL,
	tarExtension,
	executablePath string,
	options ExecutionOptions) bool {

	executableWaitTime := "15"

	colorActionH.Println("Installing application " + applicationName + "...")

	checkCmd := exec.Command("bash", "-c",
		"ls -l " + options.optDir + " | grep " + applicationName + " &>/dev" +
		"/null")
	if checkCmd.Run() == nil {
		colorActionH.Print("Application " + applicationName + ": ")
		colorSuccess.Println("already installed.")
		return true
	}

	tarDownloadPath := options.tmpDir + "/" + tarExtension + "." + tarExtension
	applicatoinDir := options.optDir + "/" + applicationName

	installIsOk :=
		execute("wget " + tarURL + " -O '" + tarDownloadPath + "'", options) &&
		execute("sudo mkdir '" + applicatoinDir + "'", options) &&
		execute("sudo tar -xf '" + tarDownloadPath + "' -C '" +
			applicatoinDir + "'", options) &&
		execute("timeout " + " " + executableWaitTime + " " +
			options.optDir + "/" + executablePath, options)

	colorActionH.Print("Application " + applicationName + ": ")

	if !installIsOk {
		colorFail.Println("Fail!")
		return false
	}
	colorSuccess.Println("Installed!")
	return true
}

//
// Add apt repository
//
func aptAddRepository(repositoryName string, options ExecutionOptions) bool {
	return execute("sudo add-apt-repository " + repositoryName + " -y", options)
}

//
// Execute config set from json file
//
//noinspection GoUnhandledErrorResult
func executeConfigsSet(name, path string, options ExecutionOptions) bool {
	colorInfoH.Println("Execution configs set " + name + "...")
	colorInfo.Println("Configs file path: " + path)

	data, err := ioutil.ReadFile(path)
	if err != nil {
		colorFail.Println("Configs set: Fail!")
		log.Println("Error while trying to open configs file: " + err.Error())
		return false
	}

	var parsed map[string]interface{}
	err = json.Unmarshal(data, &parsed)

	if err != nil {
		colorFail.Println("Configs set: Fail!")
		log.Println("Error while trying to parse configs file: " + err.Error())
		return false
	}

	// Dealing with pre-install commands
	preInstallCommands := parsed["pre-install-commands"]
	if preInstallCommands != nil {
		commands := preInstallCommands.([]interface{})

		for _, commandName := range commands {
			execute(commandName.(string), options)
		}
	}

	// Dealing with apt repositories
	aptRepositories := parsed["apt-repositories"]
	if aptRepositories != nil {
		aptRepositoriesArray := aptRepositories.([]interface{})

		for _, repositoryName := range aptRepositoriesArray {
			aptAddRepository(repositoryName.(string), options)
		}
		if len(aptRepositoriesArray) > 0 {
			execute("sudo apt-get update -y", options)
		}
	}

	// Dealing with apt packages
	aptPackages := parsed["apt-packages"]
	if aptPackages != nil {
		aptPackagesArray := aptPackages.([]interface{})

		for _, packageName := range aptPackagesArray {
			aptInstall(packageName.(string), options)
		}
	}

	// Dealing with deb packages
	depPackages := parsed["deb-packages"]
	if depPackages != nil {
		depPackagesArray := depPackages.([]interface{})

		for _, packageJSONData := range depPackagesArray {
			packageData := packageJSONData.(map[string]interface{})
			debInstall(packageData["name"].(string),
				packageData["url"].(string), options)
		}
	}

	// Dealing with tar applications
	tarApplications := parsed["tar-applications"]
	if tarApplications != nil {
		tarApplicationsArray := tarApplications.([]interface{})

		for _, appJSONData := range tarApplicationsArray {
			appData := appJSONData.(map[string]interface{})
			tarInstall(
				appData["name"].(string),
				appData["url"].(string),
				appData["extension"].(string),
				appData["executable"].(string),
				options)
		}
	}

	// Dealing with post-install commands
	postInstallCommands := parsed["post-install-commands"]
	if postInstallCommands != nil {
		commands := postInstallCommands.([]interface{})

		for _, commandName := range commands {
			execute(commandName.(string), options)
		}
	}

	colorInfoH.Print("Configs set " + name + ": ")
	colorSuccess.Println("Success!")
	return true
}

//noinspection GoUnhandledErrorResult
func main() {
	ubuntuVersion := flag.String("ubuntuVersion", "18LTS",
		"Version of Ubuntu. Possible values:\n" +
		" - 16LTS")

	verbose := flag.Bool("verbose", false, "Is verbose")

	flag.Parse()

	options := ExecutionOptions{
		"/tmp",
		"/opt",
		*ubuntuVersion,
		*verbose,
	}

	colorInfoH.Println("Configuration tool for Ubuntu")
	colorInfo.Print("   by ")
	colorInfoH.Println("Oleh Kurachenko")
	colorInfo.Println("e-mail  oleh.kurachenko@gmail.com")
	colorInfo.Println("GitLab  https://gitlab.com/oleh.kurachenko")
	colorInfo.Println("rate&CV http://www.linkedin.com/in/oleh-kurachenko-6b025b111")

	execute("sudo apt-get update --yes", options)
	execute("sudo apt-get upgrade --yes", options)
	execute("sudo apt-get autoremove --yes", options)

	for _, configset := range flag.Args() {
		executeConfigsSet(configset,
			"configsets/" + options.ubuntuVersion + "/" + configset + ".json", options)
	}

	if len(flag.Args()) > 0 {
		execute("sudo apt-get update --yes", options)
		execute("sudo apt-get upgrade --yes", options)
		execute("sudo apt-get autoremove --yes", options)
	}
}
