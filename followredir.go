/**
 * Follow Redirects
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 *
 * The HTTP response status code '301 Moved Permanently' and '302 Moved
 * Temporarily' are used for permanent redirection, meaning current links or
 * records using the URL that the 301/302 response is received for should be
 * updated to the new URL provided in the 'Location' field of the response. This
 * status code should be used with the location header.
 *
 * RFC 2616 (http://tools.ietf.org/html/rfc2616) states that:
 *   * If a client has link-editing capabilities, it should update all references to the Request URI.
 *   * The response is cachable.
 *   * Unless the request method was HEAD, the entity should contain a small hypertext note with a hyperlink to the new URI(s).
 *   * If the 301 status code is received in response to a request of any type other than GET or HEAD, the client must ask the user before redirecting.
 */

package main

import (
    "os"
    "fmt"
    "regexp"
    "net/http"
    "io/ioutil"
)

func follow_redirect(location string) {
    req, err1 := http.NewRequest("HEAD", location, nil)
    req.Header.Set("User-Agent", "Mozilla/5.0 (KHTML, like Gecko)")
    if err1 != nil {
        fmt.Printf("Error creating the request: %s\n", err1)
        os.Exit(1)
    }

    resp, err2 := http.DefaultTransport.RoundTrip(req)
    if err2 != nil {
        fmt.Printf("Error executing the request: %s\n", err2)
        os.Exit(1)
    }

    var redirection string = resp.Header.Get("Location")
    if redirection != "" {
        fix_location, _ := regexp.MatchString(`^\/`, redirection)

        if fix_location {
            r := regexp.MustCompile(`^(http|https):\/\/([^\/]+)`)
            var loc_scheme []string = r.FindStringSubmatch(location)
            var full_redirection string = loc_scheme[1] + "://" + loc_scheme[2] + redirection

            fmt.Printf("Relative (%s): %s\n", redirection, full_redirection)
            redirection = full_redirection
        }

        fmt.Printf("Redirect (%s): %s\n", resp.Status, redirection)
        follow_redirect(redirection)
    } else {
        meta_redirect, meta_location := follow_meta_redirect(location)

        if meta_redirect {
            fmt.Printf("Redirect (%s): %s\n", "303 See Other", meta_location)
            follow_redirect(meta_location)
        } else {
            fmt.Printf("%s\n", "---------")
            fmt.Printf("%s %s\n", resp.Proto, resp.Status)
            for header_key, header_value := range resp.Header {
                var values int = len(header_value)
                if values == 1 {
                    fmt.Printf("%s: %s\n", header_key, header_value[0])
                } else if values > 1 {
                    fmt.Printf("%s:\n", header_key)
                    for _, value := range header_value {
                        fmt.Printf("  %s\n", value)
                    }
                }
            }
            os.Exit(0)
        }
    }
}

func follow_meta_redirect(location string) (bool, string) {
    client := &http.Client{ }
    req, err3 := http.NewRequest("GET", location, nil)

    if err3 == nil {
        req.Header.Set("User-Agent", "Mozilla/5.0 (KHTML, like Gecko)")
        resp, err4 := client.Do(req)

        if err4 == nil {
            defer resp.Body.Close()
            body, _ := ioutil.ReadAll(resp.Body)
            var r = regexp.MustCompile(`content=.[0-9]+;[ ]+?URL=(.+)"`)
            var results []string = r.FindStringSubmatch( string(body) )

            if len(results) == 2 {
                return true, results[1]
            }
        }
    }

    return false, ""
}

func main() {
    if len(os.Args) == 2 {
        var location string = os.Args[1]

        var r = regexp.MustCompile(`^([f|ht]+tp+s?):\/\/(.+)`)
        var scheme []string = r.FindStringSubmatch(location)

        if len(scheme) == 3 {
            if scheme[1] == "ftp" || scheme[1] == "ftps" {
                fmt.Printf("URL protocol not allowed, use only HTTP or HTTPS\n")
                os.Exit(1)
            }
        } else {
            location = "http://" + location
        }

        fmt.Printf("Original: %s\n", location)
        follow_redirect(location)
        os.Exit(0)
    } else {
        fmt.Printf("Usage: %s <URL>\n", os.Args[0])
        os.Exit(1)
    }
}
