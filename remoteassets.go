/**
 * Remote Assets
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://en.wikipedia.org/wiki/Digital_asset
 *
 * List all the resources (assets) loaded in a specific page on a website.
 *
 * A digital asset is any item of text or media that has been formatted into a
 * binary source that includes the right to use it. A digital file without the
 * right to use it is not an asset. Digital assets are categorised in three major
 * groups which may be defined as textual content (digital assets), images (media
 * assets) and multimedia (media assets).
 */

package main

import (
    "os"
    "fmt"
    "flag"
    "net/url"
    "regexp"
    "strings"
    "net/http"
    "io/ioutil"
)

var remote_loc = flag.String("url", "", "Specify the remote location to scan")
var filetype = flag.String("filetype", "", "Specify the filetype to look in the remote location specified")
var resource = flag.String("resource", "", "Specify a group of filestypes to include in the scanning: images, javascript, styles")
var get_all = flag.Bool("all", false, "Show all the resources found in the site")
var colored = flag.Bool("colored", false, "Whether the information must be highlighted or not")
var verbose = flag.Bool("verbose", false, "Whether the request details must be printed or not")
var unique = flag.Bool("unique", false, "Whether the duplicated files will be counted or not")

func fail(message string) {
    flag.Usage()
    fmt.Printf("\nError: %s\n", message)
    os.Exit(1)
}

func print_colored(var_title string, var_value string) {
    if *colored {
        fmt.Printf( "\033[1;34m%s\033[0m: %s\n", var_title, var_value )
    } else {
        fmt.Printf( "%s: %s\n", var_title, var_value )
    }
}

func main() {
    flag.Usage = func(){
        fmt.Println("Remote Assets")
        fmt.Println("  http://cixtor.com/")
        fmt.Println("  https://github.com/cixtor/mamutools")
        fmt.Println("  http://en.wikipedia.org/wiki/Digital_asset")
        fmt.Println("Usage:")
        flag.PrintDefaults()
    }

    flag.Parse()

    *remote_loc = strings.TrimSpace(*remote_loc)
    if *remote_loc == "" {
        fail("Remote location not specified")
    }

    re := regexp.MustCompile(`^(http|https):\/\/`)
    var url_scheme []string = re.FindStringSubmatch(*remote_loc)
    if url_scheme == nil {
        *remote_loc = fmt.Sprintf("http://%s", *remote_loc)
    }

    location, err := url.Parse(*remote_loc)
    if err != nil {
        fail("URL malformation detected")
    }

    var filetypes []string
    var filetype_options = map[string][]string {
        "images": []string{ "gif", "jpg", "jpeg", "png", "svg" },
        "javascript": []string{ "js", "coffee" },
        "styles": []string{ "css", "sass", "less" },
    }

    if *get_all == true {
        for _, exts := range(filetype_options) {
            for _, ext := range(exts) {
                filetypes = append(filetypes, ext)
            }
        }
    } else if *filetype != "" {
        filetypes = append(filetypes, *filetype)
    } else if *resource != "" {
        switch *resource {
        case "images":
            filetypes = filetype_options[*resource]
        case "javascript":
            filetypes = filetype_options[*resource]
        case "styles":
            filetypes = filetype_options[*resource]
        }
    }

    if len(filetypes) == 0 {
        fail("Filetype list is empty")
    }

    var indentation string = ""
    if *verbose {
        indentation = "- "
        print_colored( "Hostname", location.Host )
        print_colored( "Target", *remote_loc )
        print_colored( "Extensions", strings.Join(filetypes, ", ") )
    }

    resp, err := http.Get(*remote_loc)
    if err != nil {
        fail("The site could not be scanned")
    }

    defer resp.Body.Close()
    body, err := ioutil.ReadAll(resp.Body)

    var find_base_path bool = true
    var content_clean string = strings.Replace( string(body), "\n", "", -1 )
    var lines []string = strings.Split(content_clean, ">")
    var unique_files = make(map[string]int)

    var file_ext_str string = strings.Join(filetypes, "|")
    file_ext_re := regexp.MustCompile(`(href|src)=['"]([a-zA-Z0-9=:\?\.\-\/_ ]+)\.(`+file_ext_str+`)['"]`)
    base_re := regexp.MustCompile(`<base href=['"]([a-zA-Z0-9:\.\-\/_ ]+)['"]`)

    for _, line := range(lines) {
        line = line + ">"

        if find_base_path && *verbose {
            var base_match []string = base_re.FindStringSubmatch(line)
            if base_match != nil {
                find_base_path = false
                print_colored( "Base path", base_match[1] )
                continue
            }
        }

        var file_match []string = file_ext_re.FindStringSubmatch(line)
        if file_match != nil {
            var file_path string = file_match[2] + "." + file_match[3]
            if count, ok := unique_files[file_path]; ok {
                unique_files[file_path] = count + 1
            } else {
                unique_files[file_path] = 1
            }

            if *unique != true {
                fmt.Printf("%s%s\n", indentation, file_path)
            }
        }
    }

    if *unique {
        for file_url, file_count := range(unique_files) {
            fmt.Printf( "(%d) %s\n", file_count, file_url )
        }
    }
}
