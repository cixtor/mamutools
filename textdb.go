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
    "time"
)

var database = flag.String("db", ".", "Directory name where the flat files are stored")
var table_name = flag.String("table", "", "Table name where the data will be stored")
var force_creation = flag.Bool("force", false, "Force the creation of the database and table")

func main() {
    flag.Parse()

    use_database(*database, *force_creation)
    check_table(*database, *table_name, *force_creation)

    fmt.Printf( "Database name: %s\n", *database )
    fmt.Printf( "Table name: %s\n", *table_name )
}

func use_database( database string, force_creation bool ) {
    _, err := os.Stat(database)

    if err != nil {
        if force_creation {
            err = os.Mkdir(database, 0755)

            if err != nil {
                fmt.Printf("Can not create the database\n")
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

func check_table( database string, table_name string, force_creation bool ) {
    if table_name != "" {
        finfo, err := os.Stat(table_name)

        if err == nil {
            if finfo.IsDir() {
                fmt.Printf("Can not use a directory as a file\n")
                os.Exit(1)
            }
        } else if force_creation {
            create_db_table(database, table_name)
        } else {
            fmt.Printf("The table specified does not exists\n")
            os.Exit(1)
        }
    } else {
        fmt.Printf("The table name was not specified\n")
        os.Exit(1)
    }
}

func create_db_table( database string, table_name string ) {
    f, err := os.Create(table_name)
    defer f.Close()

    if err != nil {
        fmt.Printf("Error creating the table: %s\n", err)
        os.Exit(1)
    }

    var timestamp int64 = time.Now().Unix()

    _, err = f.WriteString("\n")
    _, err = f.WriteString(fmt.Sprintf( "-- database: %s\n", database ))
    _, err = f.WriteString(fmt.Sprintf( "-- table_name: %s\n", table_name ))
    _, err = f.WriteString(fmt.Sprintf( "-- table_columns: \n" ))
    _, err = f.WriteString(fmt.Sprintf( "-- auto_increment: 0\n" ))
    _, err = f.WriteString(fmt.Sprintf( "-- total_rows: 0\n" ))
    _, err = f.WriteString(fmt.Sprintf( "-- separator: ,\n" ))
    _, err = f.WriteString(fmt.Sprintf( "-- created_at: %d\n", timestamp ))
    _, err = f.WriteString(fmt.Sprintf( "-- updated_at: %d\n", timestamp ))
    _, err = f.WriteString("\n")

    if err != nil {
        fmt.Printf("Error writing into table: %s\n", err)
        os.Exit(1)
    }
}
