/**
 * Text Database
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://en.wikipedia.org/wiki/Flat_file_database
 *
 * A flat file database describes any of various means to encode a database
 * model (most commonly a table) as a single file. A flat file can be a plain
 * text file or a binary file. There are usually no structural relationships
 * between the records.
 *
 * Plain text files usually contain one record per line,[2] There are different
 * conventions for depicting data. In comma-separated values and delimiter-
 * separated values files, fields can be separated by delimiters such as comma
 * or tab characters. In other cases, each field may have a fixed length; short
 * values may be padded with space characters. Extra formatting may be needed to
 * avoid delimiter collision. More complex solutions are markup languages and
 * programming languages.
 *
 * Typical examples of flat files are /etc/passwd and /etc/group on Unix-like
 * operating systems. Another example of a flat file is a name-and-address list
 * with the fields Name, Address, and Phone Number.
 */

package main

import (
    "os"
    "fmt"
    "flag"
)

var database = flag.String("db", ".", "Directory name where the flat files are stored")
var table_name = flag.String("table", "", "Table name where the data will be stored")
var force_creation = flag.Bool("force", false, "Force the creation of the database and table")

func main() {
    flag.Parse()

    use_database(*database, *force_creation)
    check_table(*table_name)

    fmt.Printf( "Database name: %s\n", *database )
    fmt.Printf( "Table name: %s\n", *table_name )
}

func use_database( database string, force_creation bool ) {
    _, err := os.Stat(database)

    if err != nil {
        if force_creation {
            err = os.Mkdir(database, 0755)

            if err != nil {
                fmt.Printf("Can not create the database")
                os.Exit(1)
            }
        } else {
            fmt.Printf("The database specified does not exists\n")
            os.Exit(1)
        }
    }

    err = os.Chdir(database)

    if err != nil {
        fmt.Printf("Error using the database specified\n")
        os.Exit(1)
    }
}

func check_table( table_name string ) {
    finfo, err := os.Stat(table_name)

    if err == nil {
        if finfo.IsDir() {
            fmt.Printf("Can not use a directory as a file\n")
            os.Exit(1)
        }
    } else {
        fmt.Printf("The table specified does not exists\n")
        os.Exit(1)
    }
}
