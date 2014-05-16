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
    "flag"
    "net/http"
)

var dir_path = flag.String("path", "./", "Set the directory path where the server will run")
var server_port = flag.String("port", "8080", "Set the port number where the server will run")

func main() {
    flag.Parse()

    http.Handle("/", http.FileServer(http.Dir(*dir_path)))
    http.ListenAndServe( ":" + *server_port, nil )
}
