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

import "os"
import "fmt"
import "flag"
import "regexp"
import "strings"

var display_all = flag.Bool("all", false, "Display all the environment variables as a list")
var filter_var = flag.String("var", "", "Display the value for a specific environment variable")
var verbose = flag.Bool("verbose", false, "Display extra information")

func main() {
    flag.Usage = func(){
        fmt.Println("Environment")
        fmt.Println("  http://cixtor.com/")
        fmt.Println("  https://github.com/cixtor/mamutools")
        fmt.Println("  http://en.wikipedia.org/wiki/Environment_variable")
        fmt.Println("Usage:")
        flag.PrintDefaults()
    }

    flag.Parse()

    r := regexp.MustCompile(`^([a-zA-Z_]+)=(.*)`)
    var envvars []string = os.Environ();
    var envvar_array = make(map[string]string)
    var longest_name int = 0

    for _, envvar_str := range envvars {
        var envvar_parts []string = r.FindStringSubmatch(envvar_str)

        if envvar_parts != nil {
            var envvar_name string = envvar_parts[1]
            var envvar_value string = envvar_parts[2]
            var envvar_length int = len(envvar_parts[1])

            envvar_array[envvar_name] = envvar_value
            if envvar_length > longest_name {
                longest_name = envvar_length
            }
        }
    }

    if *display_all {
        for envvar_name, envvar_value := range envvar_array {
            if envvar_name == "PATH" {
                var bin_paths []string = strings.Split(envvar_value, ":")
                var indent_spaces string = ""
                for i:=0; i<longest_name; i++ { indent_spaces += " " }

                fmt.Printf( "%*s = %s\n", longest_name, envvar_name, bin_paths[0] )
                for j, bin_path := range bin_paths {
                    if j == 0 { continue }
                    fmt.Printf( "%s   %s\n", indent_spaces, bin_path )
                }
            } else {
                fmt.Printf( "%*s = %s\n", longest_name, envvar_name, envvar_value )
            }
        }
    } else if *filter_var != "" {
        var envvar_name string = strings.ToUpper(*filter_var)
        if envvar_value, ok := envvar_array[envvar_name]; ok {
            if *verbose {
                fmt.Printf("%s=%s\n", envvar_name, envvar_value)
            } else {
                fmt.Printf("%s\n", envvar_value)
            }
        }
    } else {
        flag.Usage()
    }
}
