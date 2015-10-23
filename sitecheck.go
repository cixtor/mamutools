/**
 * Sucuri SiteCheck
 * http://cixtor.com/
 * https://sitecheck.sucuri.net/
 * https://github.com/cixtor/mamutools
 * https://en.wikipedia.org/wiki/Web_application_security_scanner
 *
 * A web application security scanner is a program which communicates with a web
 * application through the web front-end in order to identify potential security
 * vulnerabilities in the web application and architectural weaknesses. It
 * performs a black-box test. Unlike source code scanners, web application
 * scanners don't have access to the source code and therefore detect
 * vulnerabilities by actually performing attacks.
 *
 * The malware scanner is a free tool powered by Sucuri SiteCheck, it will check
 * your website for known malware, blacklisting status, website errors, and out-
 * of-date software. Although we do our best to provide the best results, 100%
 * accuracy is not realistic, and not guaranteed. Note that the information
 * returned by this tool will be kept available in the website for other people
 * to see, if you are not comfortable with this you may consider to use another
 * scanner.
 */

package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"strings"
)

type SiteCheck struct{}

type Result struct {
	Scan            map[string][]string
	System          map[string][]string
	Links           map[string][]string
	Recommendations [][]string
	OutdatedScan    [][]string
	Malware         InfoWarning
	Blacklist       InfoWarning
	Webapp          struct {
		Info    [][]string
		Warn    []string
		Version []string
		Notice  []string
	}
}

type InfoWarning struct {
	Info [][]string
	Warn [][]string
}

func (s *SiteCheck) Scan(domain string) []byte {
	var url string = fmt.Sprintf("https://sitecheck.sucuri.net/?fromwp=2&clean=1&json=1&scan=%s", domain)
	req, err := http.NewRequest("GET", url, nil)
	client := &http.Client{}

	req.Header.Set("User-Agent", "Mozilla/5.0 (KHTML, like Gecko) Safari/537.36")
	req.Header.Add("Accept-Language", "end-US,en")
	req.Header.Add("Accept", "application/json")
	req.Header.Add("Connection", "keep-alive")
	req.Header.Add("DNT", "1")

	if err != nil {
		fmt.Printf("Error request initialization: %s\n", err)
		os.Exit(1)
	}

	resp, err := client.Do(req)

	if err != nil {
		fmt.Printf("Error request execution: %s\n", err)
		os.Exit(1)
	}

	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)

	if err != nil {
		fmt.Printf("Error response data: %s\n", err)
		os.Exit(1)
	}

	return body
}

func (s *SiteCheck) Data(domain string) Result {
	var result Result
	var response []byte = s.Scan(domain)
	err := json.Unmarshal(response, &result)

	if err != nil {
		fmt.Printf("JSON structure not supported: %s\n", err)
		fmt.Println(string(response))
		os.Exit(1)
	}

	return result
}

func (s *SiteCheck) Justify(text string) string {
	var chunk int = 97
	var lines int = 10
	var limit int = lines * chunk
	var final string
	var counter int

	text = strings.Replace(text, "\n", "", -1)
	text = strings.Replace(text, "\t", "", -1)
	text = strings.Replace(text, "\r", "", -1)

	if len(text) > limit {
		text = text[0:limit] + "..."
	}

	for _, char := range text {
		if counter == 0 {
			final += "\x20\x20\x20"
		}

		final += string(char)
		counter++

		if counter >= chunk {
			final += "\n"
			counter = 0
		}
	}

	final += "\n"

	return final
}

func (s *SiteCheck) Print(result Result) {
	fmt.Println("\033[48;5;008m >>> Website Information <<< \033[0m")
	for key, value := range result.Scan {
		fmt.Printf(" \033[1;95m%s:\033[0m %s\n", key, strings.Join(value, ",\x20"))
	}
	for _, values := range result.System {
		for _, value := range values {
			fmt.Printf(" \033[0;2m%s\033[0m\n", value)
		}
	}

	if len(result.Webapp.Warn) > 0 ||
		len(result.Webapp.Info) > 0 ||
		len(result.Webapp.Version) > 0 ||
		len(result.Webapp.Notice) > 0 {
		fmt.Println()
		fmt.Println("\033[48;5;008m >>> Application Details <<< \033[0m")
		for _, value := range result.Webapp.Warn {
			fmt.Printf(" %s\n", value)
		}
		for _, values := range result.Webapp.Info {
			fmt.Printf(" %s \033[0;2m%s\033[0m\n", values[0], values[1])
		}
		for _, value := range result.Webapp.Version {
			fmt.Printf(" %s\n", value)
		}
		for _, value := range result.Webapp.Notice {
			fmt.Printf(" %s\n", value)
		}
	}

	// Print security recommendations.
	if len(result.Recommendations) > 0 {
		fmt.Println()
		fmt.Println("\033[48;5;068m >>> Recommendations <<< \033[0m")
		for _, values := range result.Recommendations {
			fmt.Printf(" \033[0;94m\u2022\033[0m %s\n", values[0])
			fmt.Printf("   %s\n", values[1])
			fmt.Printf("   %s\n", values[2])
		}
	}

	// Print outdated software information.
	if len(result.OutdatedScan) > 0 {
		fmt.Println()
		fmt.Println("\033[48;5;068m >>> OutdatedScan <<< \033[0m")
		for _, values := range result.OutdatedScan {
			fmt.Printf(" \033[0;94m\u2022\033[0m %s\n", values[0])
			fmt.Printf("   %s\n", values[1])
			fmt.Printf("   %s\n", values[2])
		}
	}

	// Print links, iframes, and local/external javascript files.
	for key, values := range result.Links {
		fmt.Println()
		fmt.Printf("\033[48;5;097m >>> Links %s <<< \033[0m\n", key)
		for _, value := range values {
			fmt.Printf(" %s\n", value)
		}
	}

	// Print blacklist status information.
	if len(result.Blacklist.Warn) > 0 || len(result.Blacklist.Info) > 0 {
		fmt.Println()
		var blacklist_color string = "034"
		if len(result.Blacklist.Warn) > 0 {
			blacklist_color = "161"
		}
		fmt.Printf("\033[48;5;%sm >>> Blacklist Status <<< \033[0m\n", blacklist_color)
		for _, values := range result.Blacklist.Warn {
			fmt.Printf(" \033[0;91m\u2718\033[0m %s\n", values[0])
			fmt.Printf("   %s\n", values[1])
		}
		for _, values := range result.Blacklist.Info {
			fmt.Printf(" \033[0;92m\u2714\033[0m %s\n", values[0])
			fmt.Printf("   %s\n", values[1])
		}
	}

	// Print malware payload information.
	if len(result.Malware.Warn) > 0 {
		fmt.Println()
		fmt.Println("\033[48;5;161m >>> Malware Payloads <<< \033[0m")
		for _, values := range result.Malware.Warn {
			fmt.Printf(" \033[0;91m\u2022\033[0m %s\n", values[0])
			fmt.Printf("%s", s.Justify(values[1]))
		}
	}
}

func main() {
	if len(os.Args) <= 1 {
		fmt.Println("Sucuri SiteCheck")
		fmt.Println("  http://cixtor.com/")
		fmt.Println("  https://sitecheck.sucuri.net/")
		fmt.Println("  https://github.com/cixtor/mamutools")
		fmt.Println("  https://en.wikipedia.org/wiki/Web_application_security_scanner")
		fmt.Println("Usage: sitecheck example.com")
		os.Exit(2)
	}

	var domain string = os.Args[1]
	var scanner SiteCheck
	var result Result

	fmt.Printf(" Sucuri SiteCheck\n")
	fmt.Printf(" https://sitecheck.sucuri.net/\n")
	fmt.Printf(" Scanning %s ...\n\n", domain)
	result = scanner.Data(domain)
	scanner.Print(result)

	os.Exit(0)
}
