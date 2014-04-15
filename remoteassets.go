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
    "fmt"
    "flag"
    "net/url"
    "regexp"
)

var remote_loc = flag.String("url", "", "Specify the remote location to scan")
var filetype = flag.String("filetype", "", "Specify the filetype to look in the remote location specified")
var resource = flag.String("resource", "", "Specify a group of filestypes to include in the scanning: images, javascript, styles")
var scanby = flag.String("scanby", "", "Specify the type of scanning: tag, extension")

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

    re := regexp.MustCompile(`^(http|https):\/\/$`)
    var url_scheme []string = re.FindStringSubmatch(*remote_loc)
    if url_scheme == nil {
    	*remote_loc = fmt.Sprintf("http://%s", *remote_loc)
    }

    location, err := url.Parse(*remote_loc)
    if err != nil {
    	panic(err)
    }

    fmt.Printf("Hostname: %s\n", location.Host)
    fmt.Printf("Target: %s\n", *remote_loc)
    fmt.Printf("Scan-by: %s\n", *scanby)
    fmt.Printf("-----------\n" )
}
