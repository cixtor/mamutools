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
    "os"
    "fmt"
    "flag"
    "strings"
    "crypto/md5"
    "crypto/sha1"
    "encoding/base64"
    "net/url"
    "io"
)

var action = flag.String("action", "none", "String convertion that will be executed")
var text = flag.String("text", "", "Text string that will be processed")
var old_str = flag.String("old", "", "Text string that will be replaced")
var new_str = flag.String("new", "", "Text string that will replace the old one")

var replace = flag.Bool("replace", false, "Replace a text string with another")
var capitalize = flag.Bool("capitalize", false, "Convert a text string into a capitalized version of its words")
var uppercase = flag.Bool("uppercase", false, "Convert all the characters in a text string into their capital form")
var lowercase = flag.Bool("lowercase", false, "Convert all the characters in a text string into their lower form")
var hash_md5 = flag.Bool("md5", false, "Calculate the md5 hash of the string specified")
var hash_sha1 = flag.Bool("sha1", false, "Calculate the sha1 hash of the string specified")
var length = flag.Bool("length", false, "Returns the length of the string specified")
var base64_enc = flag.Bool("b64enc", false, "Encodes data with MIME base64")
var base64_dec = flag.Bool("b64dec", false, "Decodes data encoded with MIME base64")
var url_decode = flag.Bool("urldec", false, "Decodes URL-encoded string")

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

    if *action == "replace" || *replace == true {
        fmt.Printf( "%s\n", strings.Replace(*text, *old_str, *new_str, -1) )
        os.Exit(0)
    }

    if *action == "capitalize" || *capitalize == true {
        fmt.Printf( "%s\n", strings.Title(*text) )
        os.Exit(0)
    }

    if *action == "uppercase" || *uppercase == true {
        fmt.Printf( "%s\n", strings.ToUpper(*text) )
        os.Exit(0)
    }

    if *action == "lowercase" || *lowercase == true {
        fmt.Printf( "%s\n", strings.ToLower(*text) )
        os.Exit(0)
    }

    if *action == "md5" || *hash_md5 == true {
        hash := md5.New()
        io.WriteString(hash, *text)
        fmt.Printf("%x\n", hash.Sum(nil))
        os.Exit(0)
    }

    if *action == "sha1" || *hash_sha1 == true {
        hash := sha1.New()
        io.WriteString(hash, *text)
        fmt.Printf("%x\n", hash.Sum(nil))
        os.Exit(0)
    }

    if *action == "length" || *length == true {
        fmt.Printf("%d\n", len(*text))
        os.Exit(0)
    }

    if *action == "b64enc" || *base64_enc == true {
        fmt.Printf("%s\n", base64.StdEncoding.EncodeToString([]byte(*text)))
        os.Exit(0)
    }

    if *action == "b64dec" || *base64_dec == true {
        data, err := base64.StdEncoding.DecodeString(*text)
        if err != nil {
            fmt.Println("Error:", err)
            os.Exit(1)
        }
        fmt.Printf("%q\n", data)
        os.Exit(0)
    }

    if *action == "urldec" || *url_decode == true {
        result, err := url.QueryUnescape(*text)
        if err == nil {
            fmt.Printf("%s\n", result)
            os.Exit(0)
        } else {
            fmt.Printf("Error decoding url: %s\n", err)
            os.Exit(1)
        }
    }

    flag.Usage()
    fmt.Printf("Error. Action specified is not allowed\n")
    os.Exit(1)
}
