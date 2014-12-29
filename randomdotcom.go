/**
 * Random Dotcom
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://en.wikipedia.org/wiki/.com
 * http://www.randomdotcom.com/
 *
 * The domain name com is a top-level domain (TLD) in the Domain Name System of
 * the Internet. Its name is derived from the word commercial,[1] indicating its
 * original intended purpose for domains registered by commercial organizations.
 * However, eventually the distinction was lost when .com, .org and .net were
 * opened for unrestricted registration.
 *
 * The domain was originally administered by the United States Department of
 * Defense, but is today operated by Verisign, and remains under ultimate
 * jurisdiction of U.S. law. Verisign Registrations in com are processed via
 * registrars accredited by ICANN. The registry accepts internationalized domain
 * names. The domain was one of the original top-level domains (TLDs) in the
 * Internet when the Domain Name System was implemented in January 1985, the
 * others being edu, gov, mil, net, org, and arpa. It has grown into the largest
 * top-level domain.
 */

package main

import "flag"
import "fmt"
import "io/ioutil"
import "net/http"
import "os"

var quantity = flag.Int("c", 1, "Quantity of random domains to generate")

func main() {
	flag.Usage = func() {
		fmt.Println("Random Dotcom")
		fmt.Println("  http://cixtor.com/")
		fmt.Println("  https://github.com/cixtor/mamutools")
		fmt.Println("  http://en.wikipedia.org/wiki/.com")
		fmt.Println("  http://www.randomdotcom.com/")
        fmt.Println("Usage:")
        flag.PrintDefaults()
	}

	flag.Parse()

	client := http.Client{}
	var request_url string = "http://www.randomdotcom.com/shortname/domain"
	request, err := http.NewRequest("GET", request_url, nil)

	if err == nil {
		request.Header.Add("DNT", "1")
		request.Header.Add("Accept-Language", "en-US,en;q=0.8")
		request.Header.Add("User-Agent", "Mozilla/5.0 (KHTML, like Gecko) Safari/537.36")
		request.Header.Add("Referer", "http://www.randomdotcom.com/")
		request.Header.Add("X-Requested-With", "XMLHttpRequest")
		request.Header.Add("Connection", "keep-alive")

		response, err := client.Do(request)

		if err == nil {
			defer response.Body.Close()
			body, _ := ioutil.ReadAll(response.Body)

			fmt.Printf("%s.com\n", body)
			os.Exit(0)
		} else {
			fmt.Printf("[x] Error executing the HTTP request.\n")
			fmt.Printf("    Error: %s\n", err)
			os.Exit(1)
		}
	} else {
		fmt.Printf("[x] Error building the HTTP request.\n")
		fmt.Printf("    Error: %s\n", err)
		os.Exit(1)
	}
}
