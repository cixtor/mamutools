/**
 * Environment
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://en.wikipedia.org/wiki/Environment_variable
 *
 * Environment variables are a set of dynamic named values that can affect the
 * way running processes will behave on a computer. They are part of the
 * operating environment in which a process runs.
 *
 * In all Unix and Unix-like systems, each process has its own separate set of
 * environment variables. By default, when a process is created, it inherits a
 * duplicate environment of its parent process, except for explicit changes made
 * by the parent when it creates the child. At the API level, these changes must
 * be done between running fork and exec. Alternatively, from command shells
 * such as bash, a user can change environment variables for a particular
 * command invocation by indirectly invoking it via env or using the
 * ENVIRONMENT_VARIABLE=VALUE <command> notation.
 *
 * Examples of environment variables include:
 * - PATH - a list of directory paths. When the user types a command without
 *   providing the full path, this list is checked to see whether it contains
 *   a path that leads to the command.
 * - HOME - indicate where a user's home directory is located in the file system.
 * - HOME/{.AppName} - for storing application settings.
 * - TERM - specifies the type of terminal emulator being used (e.g., vt100 or dumb).
 * - PS1 - specifies how the prompt is displayed in the Bourne shell and variants.
 * - MAIL - used to indicate where a user's mail is to be found.
 * - TEMP - location where processes can store temporary files
 */
package main

import (
	"flag"
	"fmt"
	"os"
	"regexp"
	"strings"
)

var displayAll = flag.Bool("list", false, "Display all the environment variables as a list")
var filterVar = flag.String("search", "", "Display the value for a specific environment variable")
var verbose = flag.Bool("verbose", false, "Display extra information")
var appendPath = flag.String("newpath", "", "Add a new binary path to the global environment variable")

func main() {
	flag.Usage = func() {
		fmt.Println("Environment")
		fmt.Println("  http://cixtor.com/")
		fmt.Println("  https://github.com/cixtor/mamutools")
		fmt.Println("  http://en.wikipedia.org/wiki/Environment_variable")
		fmt.Println("Usage:")
		flag.PrintDefaults()
	}

	flag.Parse()

	r := regexp.MustCompile(`^([a-zA-Z_]+)=(.*)`)
	envvarArr := make(map[string]string)
	envvars := os.Environ()
	var longestName int

	for _, envvarStr := range envvars {
		envvarParts := r.FindStringSubmatch(envvarStr)

		if envvarParts != nil {
			envvarName := envvarParts[1]
			envvarValue := envvarParts[2]
			envvarLength := len(envvarParts[1])

			envvarArr[envvarName] = envvarValue
			if envvarLength > longestName {
				longestName = envvarLength
			}
		}
	}

	if *displayAll {
		for envvarName, envvarValue := range envvarArr {
			if envvarName == "PATH" {
				var indentSpaces string
				binPaths := strings.Split(envvarValue, ":")
				for i := 0; i < longestName; i++ {
					indentSpaces += " "
				}

				fmt.Printf("%*s = %s\n", longestName, envvarName, binPaths[0])
				for j, binPath := range binPaths {
					if j == 0 {
						continue
					}
					fmt.Printf("%s   %s\n", indentSpaces, binPath)
				}
			} else {
				fmt.Printf("%*s = %s\n", longestName, envvarName, envvarValue)
			}
		}
	} else if *filterVar != "" {
		envvarName := strings.ToUpper(*filterVar)

		if envvarValue, ok := envvarArr[envvarName]; ok {
			if *verbose {
				if envvarName == "PATH" || envvarName == "LS_COLORS" {
					binPaths := strings.Split(envvarValue, ":")
					for _, binPath := range binPaths {
						if binPath != "" {
							fmt.Printf("%s\n", binPath)
						}
					}
				} else {
					fmt.Printf("%s=%s\n", envvarName, envvarValue)
				}
			} else {
				fmt.Printf("%s\n", envvarValue)
			}
		}
	} else if *appendPath != "" {
		bashrcPath := os.Getenv("HOME") + "/.bashrc"
		newPath := fmt.Sprintf("export PATH=\"$PATH:%s\"\n", *appendPath)

		f, err := os.OpenFile(bashrcPath, os.O_APPEND|os.O_WRONLY, 0600)
		if err != nil {
			panic(err)
		}

		defer f.Close()
		if _, err = f.WriteString(newPath); err == nil {
			fmt.Printf("Path added: %s\n", *appendPath)
			fmt.Printf("Update session: source ~/.bashrc\n")
		} else {
			panic(err)
		}
	} else {
		flag.Usage()
	}
}
