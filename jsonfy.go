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
    "net/http"
    "io/ioutil"
    "encoding/json"
)

func usage(filename string) {
    fmt.Printf("JSON Prettify\n")
    fmt.Printf("  http://cixtor.com/\n")
    fmt.Printf("  https://github.com/cixtor/mamutools\n")
    fmt.Printf("  http://en.wikipedia.org/wiki/JSON\n")
    fmt.Printf("Usage:\n")
    fmt.Printf("  %s /local/filepath.json\n", filename)
    fmt.Printf("  %s http://example.com/remote/filepath.json\n", filename)
    os.Exit(2)
}

func get_remote_content(url string) ([]byte) {
    client := &http.Client{ }
    req, err1 := http.NewRequest("GET", url, nil)

    if err1 == nil {
        req.Header.Set("User-Agent", "Mozilla/5.0 (KHTML, like Gecko)")
        resp, err2 := client.Do(req)

        if err2 == nil {
            defer resp.Body.Close()
            body, _ := ioutil.ReadAll(resp.Body)
            return body
        }
    }

    return nil
}

func main() {
    if len(os.Args) <= 1 {
        usage(os.Args[0])
    }

    var content []byte
    var filepath string = os.Args[1]
    _, err1 := os.Stat(filepath)

    if err1 == nil {
        response, err2 := ioutil.ReadFile(filepath)

        if err2 != nil {
            fmt.Printf("Error reading file: %s\n", filepath)
            fmt.Printf("Backtrace: %s\n", err2)
            os.Exit(1)
        } else {
            content = response
        }
    } else {
        var response []byte = get_remote_content(filepath)
        content = response
    }

    var f interface { }
    err3 := json.Unmarshal(content, &f)

    if err3 != nil {
        fmt.Printf("Error formatting data: %s\n", err3)
        os.Exit(1)
    }

    result, err3 := json.MarshalIndent(f, "", "  ")
    os.Stdout.Write(result)
}
