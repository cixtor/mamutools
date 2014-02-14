/**
 * String Conversion
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://en.wikipedia.org/wiki/String_(computer_science)
 * http://en.wikipedia.org/wiki/String_functions
 *
 * In computer programming, a string is traditionally a sequence of characters,
 * either as a literal constant or as some kind of variable. The latter may
 * allow its elements to be mutated and/or the length changed, or it may be
 * fixed (after creation). A string is generally understood as a data type and
 * is often implemented as an array of bytes (or words) that stores a sequence
 * of elements, typically characters, using some character encoding. A string
 * may also denote more general arrays or other sequence (or list) data types
 * and structures.
 *
 * String functions are used in computer programming languages to manipulate a
 * string or query information about a string (some do both). Most programming
 * languages that have a string datatype will have some string functions
 * although there may be other low-level ways within each language to handle
 * strings directly. In object-oriented languages, string functions are often
 * implemented as properties and methods of string objects. In functional and
 * list-based languages a string is represented as a list (of character codes),
 * therefore all list-manipulation procedures could be considered string
 * functions. However such languages may implement a subset of explicit string-
 * specific functions as well.
 */

package main

import (
    "fmt"
    "flag"
    "strings"
)

var action = flag.String("action", "none", "String convertion that will be executed")
var text = flag.String("text", "", "Text string that will be processed")
var old_str = flag.String("old", "", "Text string that will be replaced")
var new_str = flag.String("new", "", "Text string that will replace the old one")

var replace = flag.Bool("replace", false, "Replace a text string with another")
var capitalize = flag.Bool("capitalize", false, "Convert a text string into a capitalized version of its words")
var uppercase = flag.Bool("uppercase", false, "Convert all the characters in a text string into their capital form")

func main() {
    flag.Usage = func(){
        fmt.Println("String Conversion")
        fmt.Println("  http://cixtor.com/")
        fmt.Println("  https://github.com/cixtor/mamutools")
        fmt.Println("  http://en.wikipedia.org/wiki/String_(computer_science)")
        fmt.Println("  http://en.wikipedia.org/wiki/String_functions")
        fmt.Println("Usage:")
        flag.PrintDefaults()
    }

    flag.Parse()

    if *replace == true {
        *action = "replace"
    }

    if *capitalize == true {
        *action = "capitalize"
    }

    if *uppercase == true {
        *action = "uppercase"
    }

    switch *action {
    case "replace":
        fmt.Printf( "%s\n", strings.Replace(*text, *old_str, *new_str, -1) )
    case "capitalize":
        fmt.Printf( "%s\n", strings.Title(*text) )
    case "uppercase":
        fmt.Printf( "%s\n", strings.ToUpper(*text) )
    }
}
