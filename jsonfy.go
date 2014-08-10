/**
 * JSON Prettify
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://en.wikipedia.org/wiki/JSON
 *
 * JSON or JavaScript Object Notation, is a text-based open standard designed
 * for human-readable data interchange. It is derived from the JavaScript
 * scripting language for representing simple data structures and associative
 * arrays, called objects. Despite its relationship to JavaScript, it is
 * language-independent, with parsers available for many languages.
 *
 * The JSON format was originally specified by Douglas Crockford, and is
 * described in RFC 4627. The official Internet media type for JSON is
 * application/json. The JSON filename extension is .json. The JSON format is
 * often used for serializing and transmitting structured data over a network
 * connection. It is used primarily to transmit data between a server and web
 * application, serving as an alternative to XML.
 */

package main

import (
    "os"
    "fmt"
    "bufio"
    "net/http"
    "io/ioutil"
    "encoding/json"
)

func usage() {
    fmt.Printf("JSON Prettify\n")
    fmt.Printf("  http://cixtor.com/\n")
    fmt.Printf("  https://github.com/cixtor/mamutools\n")
    fmt.Printf("  http://en.wikipedia.org/wiki/JSON\n")
    fmt.Printf("Usage:\n")
    fmt.Printf("  jsonfy -help\n")
    fmt.Printf("  jsonfy http://example.com/remote/filepath.json\n")
    fmt.Printf("  jsonfy /local/filepath.json\n")
    fmt.Printf("  cat filepath.json | jsonfy\n")
    os.Exit(2)
}

func main() {
    was_piped, content := read_content_from_pipe()

    if was_piped {
        print_json_data(content)
    } else {
        if len(os.Args) <= 1 || os.Args[1] == "-help" {
            usage()
        } else {
            is_file, content := read_content_from_file()

            if is_file {
                print_json_data(content)
            } else {
                is_remote, content := get_remote_content(os.Args[1])

                if is_remote {
                    print_json_data(content)
                }
            }
        }
    }

    fmt.Printf( "No JSON data found\n" )
    os.Exit(1)
}

func print_json_data( content []byte ) {
    var f interface { }
    err := json.Unmarshal(content, &f)

    if err == nil {
        result, _ := json.MarshalIndent(f, "", "  ")
        fmt.Printf( "%s\n", string(result) )
        os.Exit(0)
    } else {
        fmt.Printf( "Error formatting data: %s\n", err )
        os.Exit(1)
    }
}

func read_content_from_pipe() (bool, []byte) {
    pipe, err := os.Stdin.Stat()

    if err == nil {
        if pipe.Mode() & os.ModeNamedPipe == 0 {
            // No pipe detected.
        } else {
            reader := bufio.NewReader(os.Stdin)
            line, _, err := reader.ReadLine()

            if err == nil {
                return true, line
            }
        }
    }

    return false, nil
}

func read_content_from_file() (bool, []byte) {
    var filepath string = os.Args[1]
    _, err := os.Stat(filepath)

    if err == nil {
        response, err := ioutil.ReadFile(filepath)

        if err == nil {
            return true, response
        }
    }

    return false, nil
}

func get_remote_content( url string ) (bool, []byte) {
    client := &http.Client{ }
    req, err := http.NewRequest("GET", url, nil)

    if err == nil {
        req.Header.Set("User-Agent", "Mozilla/5.0 (KHTML, like Gecko)")
        resp, err := client.Do(req)

        if err == nil {
            defer resp.Body.Close()
            body, _ := ioutil.ReadAll(resp.Body)
            return true, body
        }
    }

    return false, nil
}
