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
	"github.com/fatih/color"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"strings"
)

var colorBeforeExecution = color.New(color.FgBlue)
var colorInfoH2 = color.New(color.FgBlue).Add(color.Bold)
var colorInfo = color.New(color.FgBlue)
var colorSuccess = color.New(color.FgGreen).Add(color.Bold)
var colorFail = color.New(color.FgRed).Add(color.Bold)

var tmpDir = "/tmp"
var optDir = "/opt"

//
// TODO write docs
// TODO add verbosity option
//
//noinspection GoUnhandledErrorResult
func execute(command string) bool {
	cmd := exec.Command("bash", "-c", command)
	var stdout, stderr bytes.Buffer

	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	colorBeforeExecution.Print(command + "...")

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
	//log.Println("Stdout:\n" + string(stdout.Bytes()))
	return true
}

//
// TODO write docs
// TODO add verbosity option
//
func aptInstall(packageName string) bool {
	return execute("sudo apt-get install " + packageName + " -y")
}

//noinspection GoUnhandledErrorResult
func debInstall(packageName, packageURL string) bool {
	colorInfoH2.Println("Installing deb package " + packageName + "...")

	checkCmd := exec.Command("bash", "-c",
		"dpkg -l | grep " + packageName + " &>/dev/null")
	if checkCmd.Run() == nil {
		colorInfoH2.Print("Deb package " + packageName + ": ")
		colorSuccess.Println("already installed.")
		return true
	}

	if !execute("wget " + packageURL + " -O '" + tmpDir +
		"/" + packageName + ".deb'") {
		return false
	}

	if !execute("sudo gdebi " + tmpDir +
		"/" + packageName + ".deb --n") {
		return false
	}

	colorInfoH2.Print("Deb package " + packageName + ": ")
	colorSuccess.Println("Installed!")
	return true
}

//noinspection GoUnhandledErrorResult
func tarInstall(
	applicationName,
	tarURL,
	tarExtension,
	executablePath string) bool {

	executableWaitTime := 15

	colorInfoH2.Println("Installing application " + applicationName + "...")

	checkCmd := exec.Command("bash", "-c",
		"ls -l " + optDir + " | grep " + applicationName + " &>/dev/null")
	if checkCmd.Run() == nil {
		colorInfoH2.Print("Application " + applicationName + ": ")
		colorSuccess.Println("already installed.")
		return true
	}

	tarDownloadPath := tmpDir +
		"/" + tarExtension + "." + tarExtension
	applicatoinDir := optDir +
		"/" + applicationName

	if !execute("wget " + tarURL + " -O '" + tarDownloadPath + "'") {
		return false
	}

	if !execute("sudo mkdir '" + applicatoinDir + "'") {
		return false
	}

	if !execute("sudo tar -xf '" + tarDownloadPath +
		"' -C '" + applicatoinDir + "'") {
		return false
	}

	execute("timeout " + " " + string(
		executableWaitTime) + " " +  optDir + "/" + executablePath)

	colorInfoH2.Print("Application " + applicationName + ": ")
	colorSuccess.Println("Installed!")
	return true
}

//
// TODO write docs
// TODO add verbosity option
//
func aptAddRepository(repositoryName string) bool {
	return execute("sudo add-apt-repository " + repositoryName + " -y")
}

//noinspection GoUnhandledErrorResult
func executeConfigsSet(name, path string) bool {
	colorBeforeExecution.Println("Execution configs set " + name + "...")
	colorBeforeExecution.Println("Configs file path: " + path)

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
			execute(commandName.(string))
		}
	}

	// Dealing with apt repositories
	aptRepositories := parsed["apt-repositories"]
	if aptRepositories != nil {
		aptRepositoriesArray := aptRepositories.([]interface{})

		for _, repositoryName := range aptRepositoriesArray {
			aptAddRepository(repositoryName.(string))
		}
		if len(aptRepositoriesArray) > 0 {
			execute("sudo apt-get update -y")
		}
	}

	// Dealing with apt packages
	aptPackages := parsed["apt-packages"]
	if aptPackages != nil {
		aptPackagesArray := aptPackages.([]interface{})

		for _, packageName := range aptPackagesArray {
			aptInstall(packageName.(string))
		}
	}

	// Dealing with deb packages
	depPackages := parsed["deb-packages"]
	if depPackages != nil {
		depPackagesArray := depPackages.([]interface{})

		for _, packageJSONData := range depPackagesArray {
			packageData := packageJSONData.(map[string]interface{})
			debInstall(packageData["name"].(string),
				packageData["url"].(string))
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
				appData["executable"].(string))
		}
	}

	// Dealing with post-install commands
	postInstallCommands := parsed["post-install-commands"]
	if postInstallCommands != nil {
		commands := postInstallCommands.([]interface{})

		for _, commandName := range commands {
			execute(commandName.(string))
		}
	}

	return true
}

func main() {
	if len(os.Args) < 2 {
		panic("Not enought arguments for temporary wrapper")
	}
	if os.Args[1] == "execute" {
		if execute(strings.Join(os.Args[2:], " ")) {
			os.Exit(0)
		} else {
			os.Exit(1)
		}
	} else if os.Args[1] == "configsset" {
		if executeConfigsSet(os.Args[2], os.Args[3]) {
			os.Exit(0)
		} else {
			os.Exit(1)
		}
	} else {
		panic("Unsupported temporary wrapper option")
	}
}
