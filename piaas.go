/**
 * PI as a Service
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://en.wikipedia.org/wiki/Pi
 * http://piaas.org/
 *
 * The number PI is a mathematical constant, the ratio of a circle's
 * circumference to its diameter, commonly approximated as 3.14159. Being an
 * irrational number, PI cannot be expressed exactly as a common fraction,
 * although fractions such as 22/7 and other rational numbers are commonly used
 * to approximate PI. Consequently its decimal representation never ends and
 * never settles into a permanent repeating pattern. The digits appear to be
 * randomly distributed; however, to date, no proof of this has been discovered.
 * Also, PI is a transcendental number, a number that is not the root of any
 * non-zero polynomial having rational coefficients. This transcendence of PI
 * implies that it is impossible to solve the ancient challenge of squaring the
 * circle with a compass and straightedge.
 */

package main

import "flag"
import "fmt"
import "io/ioutil"
import "net/http"
import "os"

var decimals = flag.Int("decimals", 16, "Decimals to print")

func main() {
	flag.Usage = func() {
		fmt.Println("PI as a Service")
		fmt.Println("  http://cixtor.com/")
		fmt.Println("  https://github.com/cixtor/mamutools")
		fmt.Println("  http://en.wikipedia.org/wiki/Pi")
		fmt.Println("  http://piaas.org/")
		fmt.Println("Usage:")
		flag.PrintDefaults()
	}

	flag.Parse()

	if *decimals > 0 {
		var request_url string = fmt.Sprintf("http://piaas.org/pi?digits=%d", *decimals)

		client := http.Client{}
		request, err := http.NewRequest("GET", request_url, nil)

		if err == nil {
			request.Header.Add("DNT", "1")
			request.Header.Add("Accept-Encoding", "gzip, deflate, sdch")
			request.Header.Add("Accept-Language", "en-US,en;q=0.8")
			request.Header.Add("User-Agent", "Mozilla/5.0 (KHTML, like Gecko) Safari/537.36")
			request.Header.Add("Accept", "text/html,application/xhtml+xml,application/xml")
			request.Header.Add("Cache-Control", "max-age=0")
			request.Header.Add("Connection", "keep-alive")

			response, err := client.Do(request)

			if err == nil {
				defer response.Body.Close()
				body, _ := ioutil.ReadAll(response.Body)
				fmt.Printf("3.%s\n", body)
			} else {
				fmt.Printf("[x] Could not execute the HTTP request\n")
				fmt.Printf("    URL: %s\n", request_url)
				fmt.Printf("    Error: %s\n", err)
				os.Exit(1)
			}
		} else {
			fmt.Printf("[x] Could not build the request object\n")
			fmt.Printf("    URL: %s\n", request_url)
			fmt.Printf("    Error: %s\n", err)
			os.Exit(1)
		}
	} else {
		flag.Usage()
		os.Exit(1)
	}
}
