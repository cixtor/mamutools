/**
 * File Server
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://en.wikipedia.org/wiki/File_server
 *
 * A file server is a computer attached to a network that has the primary
 * purpose of providing a location for shared disk access, i.e. shared storage
 * of computer files (such as documents, sound files, photographs, movies,
 * images, databases, etc.) that can be accessed by the workstations that are
 * attached to the same computer network. The term server highlights the role of
 * the machine in the client–server scheme, where the clients are the
 * workstations using the storage.
 *
 * A file server is not intended to perform computational tasks, and does not
 * run programs on behalf of its clients. It is designed primarily to enable the
 * storage and retrieval of data while the computation is carried out by the
 * workstations.
 */

package main

import (
    "os"
    "fmt"
    "flag"
    "net/http"
    "regexp"
    "log"
)

var dir_path = flag.String("path", "./", "Set the directory path where the server will run")
var server_port = flag.String("port", "8080", "Set the port number where the server will run")

func main() {
    flag.Usage = func(){
        fmt.Println("File Server")
        fmt.Println("  http://cixtor.com/")
        fmt.Println("  https://github.com/cixtor/mamutools")
        fmt.Println("  http://en.wikipedia.org/wiki/File_server")
        fmt.Println("Usage:")
        flag.PrintDefaults()
    }

    flag.Parse()

    port_re := regexp.MustCompile(`^[0-9]{2,4}$`)
    var port_match []string = port_re.FindStringSubmatch(*server_port)

    if port_match == nil {
        flag.Usage()
        fmt.Printf("\nError. Invalid port number.\n")
        os.Exit(1)
    }

    http.Handle("/", http.FileServer(http.Dir(*dir_path)))
    err := http.ListenAndServe( ":" + *server_port, nil )

    if err != nil {
        flag.Usage()
        fmt.Println()
        log.Fatal(err)
    }
}
