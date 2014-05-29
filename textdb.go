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
 * Plain text files usually contain one record per line. There are different
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
    "bufio"
    "regexp"
)

var database = flag.String("db", ".", "Directory name where the flat files are stored")
var table_name = flag.String("table", "", "Table name where the data will be stored")
var force_creation = flag.Bool("force", false, "Force the creation of the database and table")
var separator = flag.String("sep", ",", "Set the character that will act as the column separator")
var display_info = flag.Bool("info", false, "Display the information of the table")

func main() {
    flag.Usage = func() {
        fmt.Println("Text Database")
        fmt.Println("  http://cixtor.com/")
        fmt.Println("  https://github.com/cixtor/mamutools")
        fmt.Println("  http://en.wikipedia.org/wiki/Flat_file_database")
        fmt.Println("Usage:")
        flag.PrintDefaults()
    }

    flag.Parse()

    use_database()
    check_table()

    _, entries := read_database_table(*table_name)

    _ = display_table_info(entries)
}

func fail_and_usage( message string, display_usage bool ) {
    if display_usage {
        flag.Usage()
        fmt.Println()
    }

    fmt.Printf("%s\n", message)
    os.Exit(1)
}

func fail( message string ) {
    fail_and_usage( message, false )
}

func use_database() {
    _, err := os.Stat(*database)

    if err != nil {
        if *force_creation {
            err = os.Mkdir(*database, 0755)

            if err != nil {
                fail("Can not create the database")
            }
        } else {
            fail("The database specified does not exists")
        }
    }

    err = os.Chdir(*database)

    if err != nil {
        fail("Error using the database specified")
    }
}

func check_table() {
    if *table_name != "" {
        finfo, err := os.Stat(*table_name)

        if err == nil {
            if finfo.IsDir() {
                fail("Can not use a directory as a file")
            }
        } else if *force_creation {
            create_db_table()
        } else {
            fail("The table specified does not exists")
        }
    } else {
        fail_and_usage( "The table name was not specified", true )
    }
}

func create_db_table() {
    f, err := os.Create(*table_name)
    defer f.Close()

    if err != nil {
        fmt.Printf("Error creating the table: %s\n", err)
        os.Exit(1)
    }

    var timestamp int64 = time.Now().Unix()

    _, err = f.WriteString("\n")
    _, err = f.WriteString(fmt.Sprintf( "-- database: %s\n", *database ))
    _, err = f.WriteString(fmt.Sprintf( "-- table_name: %s\n", *table_name ))
    _, err = f.WriteString(fmt.Sprintf( "-- table_columns: \n" ))
    _, err = f.WriteString(fmt.Sprintf( "-- auto_increment: 0\n" ))
    _, err = f.WriteString(fmt.Sprintf( "-- total_rows: 0\n" ))
    _, err = f.WriteString(fmt.Sprintf( "-- separator: %s\n", *separator ))
    _, err = f.WriteString(fmt.Sprintf( "-- created_at: %d\n", timestamp ))
    _, err = f.WriteString(fmt.Sprintf( "-- updated_at: %d\n", timestamp ))
    _, err = f.WriteString("\n")

    if err != nil {
        fmt.Printf("Error writing into table: %s\n", err)
        os.Exit(1)
    }
}

func read_database_table( table_name string ) ( *os.File, []string ) {
    file, _ := os.Open(table_name)
    defer file.Close()

    var lines []string
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        lines = append(lines, scanner.Text())
    }

    return file, lines
}

func display_table_info( entries []string ) ( map[string]string ) {
    if *display_info {
        var attributes = make(map[string]string)
        var total_attrs int = 8
        var attr_counter int = 0
        re := regexp.MustCompile(`^-- ([a-z_]+): ([a-zA-Z0-9\-_\., ]+)`)

        fmt.Printf("Database Table Attributes:\n")

        for _, entry := range entries {
            var match []string = re.FindStringSubmatch(entry)

            if match != nil {
                attr_counter += 1
                attributes[match[1]] = match[2]
                fmt.Printf("- %s: %s\n", match[1], match[2])
            }

            if attr_counter >= total_attrs {
                break
            }
        }

        return attributes
    }

    return nil
}
