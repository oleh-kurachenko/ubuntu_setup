package main

import (
	"bytes"
	"github.com/fatih/color"
	"log"
	"os"
	"os/exec"
	"strings"
)

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

//
// TODO write docs
// TODO add verbosity option
//
func logged_execute(command string) bool {
	var color_before_execution = color.New(color.FgBlue)
	var color_ok = color.New(color.FgGreen).Add(color.Bold)
	var color_fail = color.New(color.FgRed).Add(color.Bold)

	command_parts := strings.Split(command, " ")

	cmd := exec.Command(command_parts[0], command_parts[1:]...)
	var stdout, stderr bytes.Buffer

	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	color_before_execution.Print(command + "...")

	err := cmd.Run()

	if err != nil {
		color_fail.Println(" Fail!")

		log.Println("Command execution failed with code " + err.Error(
			) + ": " + command)
		log.Println("  stdout:\n" + string(stdout.Bytes()))
		log.Println("  stderr:\n" + string(stderr.Bytes()))

		return false
	}

	color_ok.Println(" OK!")
	//log.Println("Stdout:\n" + string(stdout.Bytes()))
	return true
}

func main() {
	if len(os.Args) < 2 {
		panic("Not enought arguments for temporary wrapper")
	}
	if os.Args[1] == "execute" {
		if logged_execute(strings.Join(os.Args[2:], " ")) {
			os.Exit(0)
		} else {
			os.Exit(1)
		}
	} else {
		panic("Unsupported temporary wrapper option")
	}
}
