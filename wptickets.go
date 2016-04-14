/**
 * WordPress Tickets
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * https://wordpress.org/support/
 * https://codex.wordpress.org/Using_the_Support_Forums
 *
 * The WordPress Support Forums are a fantastic resource with a ton of
 * information, but sometimes people have trouble getting help there and they
 * don't know why. This is usually the result of a communication gap. The
 * WordPress forums have one of the most helpful communities on the web, you
 * just need to help them help you. Note: Please read the Supported Versions
 * information as the the WordPress Support Forums only provide assistance for
 * officially released versions of WordPress.
 *
 * This tools sends HTTP requests to the latest twenty pages of the support page
 * of the specified plugin, finds how many of the tickets are marked as
 * resolved, and shows which ones are missing. Many people in the WordPress
 * community sees the number of resolved tickets per month as a sign of
 * responsiveness and promptness, other use this as one of the main reasons to
 * install or not a plugin.
 */

package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"regexp"
	"strings"
)

func httpRequest(urlStr string) []byte {
	req, err := http.NewRequest("GET", urlStr, nil)

	if err != nil {
		log.Fatal(err)
	}

	req.Header.Set("dnt", "1")
	req.Header.Set("pragma", "no-cache")
	req.Header.Set("cache-control", "no-cache")
	req.Header.Set("authority", "wordpress.org")
	req.Header.Set("accept-language", "en-US,en")
	req.Header.Set("upgrade-insecure-requests", "1")
	req.Header.Set("user-agent", "Mozilla/5.0 (KHTML, like Gecko) Safari/537.36")
	req.Header.Set("accept", "text/html,application/xhtml+xml,application/xml")

	client := &http.Client{}
	resp, err := client.Do(req)

	if err != nil {
		log.Fatal(err)
	}

	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)

	if err != nil {
		log.Fatal(err)
	}

	return body
}

func analyzeMonthStats(plugin string) {
	var urlStr string = fmt.Sprintf("https://wordpress.org/plugins/%s/", plugin)
	var response []byte = httpRequest(urlStr)
	var output string = string(response)
	re := regexp.MustCompile(`(\d+) of (\d+) support threads .+ have been resolved`)

	var matches []string = re.FindAllString(output, -1)

	if len(matches) > 0 {
		fmt.Printf("\n%s\n", matches[0])
	}
}

func analyzePageTickets(plugin string, page int) {
	var urlStr string = fmt.Sprintf("https://wordpress.org/support/plugin/%s/page/%d", plugin, page)
	var response []byte = httpRequest(urlStr)

	var maximumPerPage int = 30
	var output string = string(response)

	if strings.Contains(output, "<table") {
		var resolved int = strings.Count(output, "[resolved]")
		var resolvedWithPadding string = fmt.Sprintf("%2d", resolved)
		var pageWithPadding string = fmt.Sprintf("%2d", page)
		var status string

		if resolved == maximumPerPage {
			status = "Ok"
		} else {
			var missing int = maximumPerPage - resolved

			if missing > 5 {
				status = "Error"
			} else if missing > 2 {
				status = "Warning"
			} else {
				status = "Notice"
			}

			status += fmt.Sprintf(" (%d missing) %s", missing, urlStr)
		}

		fmt.Printf("- Page %s %s/%d %s\n",
			pageWithPadding,
			resolvedWithPadding,
			maximumPerPage,
			status)
	}
}

func main() {
	flag.Parse()

	var plugin string = flag.Arg(0)

	fmt.Println("WordPress Tickets")
	fmt.Println("  http://cixtor.com/")
	fmt.Println("  https://github.com/cixtor/mamutools")
	fmt.Println("  https://wordpress.org/support/")

	if plugin == "" {
		fmt.Println("Usage: wptickets [plugin]\n")
		os.Exit(2)
	}

	fmt.Printf("Plugin.: %s\n", plugin)
	fmt.Printf("Website: https://wordpress.org/plugins/%s/\n", plugin)
	fmt.Printf("Support: https://wordpress.org/support/plugin/%s/\n", plugin)
	fmt.Printf("\n")
	fmt.Printf("Resolved threads:\n")

	for key := 1; key <= 20; key++ {
		go analyzePageTickets(plugin, key)
	}

	analyzeMonthStats(plugin)

	os.Exit(0)
}
