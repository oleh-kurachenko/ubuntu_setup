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
var colorOk = color.New(color.FgGreen).Add(color.Bold)
var colorFail = color.New(color.FgRed).Add(color.Bold)

//
// TODO write docs
// TODO add verbosity option
//
//noinspection GoUnhandledErrorResult
func loggedExecute(command string) bool {
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

	colorOk.Println(" OK!")
	//log.Println("Stdout:\n" + string(stdout.Bytes()))
	return true
}

//
// TODO write docs
// TODO add verbosity option
//
func aptInstall(packageName string) bool {
	return loggedExecute("sudo apt-get install " + packageName + " -y")
}

//
// TODO write docs
// TODO add verbosity option
//
func aptAddRepository(repositoryName string) bool {
	return loggedExecute("sudo add-apt-repository " + repositoryName + " -y")
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

	// Dealing with apt repositories
	aptRepositories := parsed["apt-repositories"]
	if aptRepositories != nil {
		aptRepositoriesArray := aptRepositories.([]interface{})

		for _, packageName := range aptRepositoriesArray {
			aptAddRepository(packageName.(string))
		}
		if len(aptRepositoriesArray) > 0 {
			loggedExecute("sudo apt-get update -y")
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

	return true
}

func main() {
	if len(os.Args) < 2 {
		panic("Not enought arguments for temporary wrapper")
	}
	if os.Args[1] == "execute" {
		if loggedExecute(strings.Join(os.Args[2:], " ")) {
			os.Exit(0)
		} else {
			os.Exit(1)
		}
	} else if os.Args[1] == "apt_install"{
		if aptInstall(os.Args[2]) {
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
