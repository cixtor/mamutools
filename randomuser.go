/**
 * Random User
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://en.wikipedia.org/wiki/Randomness
 * https://randomuser.me/
 *
 * Microservice to generate random user data.
 *
 * Randomness means lack of pattern or predictability in events. A random
 * sequence of events, symbols or steps has no order and does not follow an
 * intelligible pattern or combination. Individual random events are by
 * definition unpredictable, but in many cases the frequency of different
 * outcomes over a large number of events or trials is predictable. In this
 * view, randomness is a measure of uncertainty of an outcome, rather than
 * haphazardness, and applies to concepts of chance, probability, and
 * information entropy.
 */

package main

import "encoding/json"
import "flag"
import "fmt"
import "io/ioutil"
import "net/http"
import "net/url"
import "os"
import "strconv"

var results = flag.Int("results", 1, "Quantity of users to generate")
var apikey = flag.String("key", "", "API key to remove limitations")
var gender = flag.String("gender", "", "Either male or female users")
var seed = flag.String("seed", "", "Use a specific user data set")
var format = flag.String("format", "", "Either json, csv, sql, yaml, none")
var nationality = flag.String("nat", "", "Nationality of the users")

func main() {
	flag.Usage = func() {
		fmt.Println("Random User")
		fmt.Println("  http://cixtor.com/")
		fmt.Println("  https://github.com/cixtor/mamutools")
		fmt.Println("  http://en.wikipedia.org/wiki/Randomness")
		fmt.Println("  https://randomuser.me/")
		fmt.Println("Usage:")
		flag.PrintDefaults()
	}

	flag.Parse()

	var parse_json bool = true
	var request_url string = "http://api.randomuser.me/"
	request_params := url.Values{}

	if *results < 1 {
		request_params.Add("results", "1")
	} else if *results > 500 {
		request_params.Add("results", "500")
	} else {
		var quantity string = strconv.Itoa(*results)
		request_params.Add("results", quantity)
	}

	if *apikey != "" {
		request_params.Add("key", *apikey)
	}

	if *gender == "male" || *gender == "female" {
		request_params.Add("gender", *gender)
	}

	if *seed != "" {
		request_params.Add("seed", *seed)
	}

	if *format == "csv" || *format == "sql" || *format == "yaml" {
		parse_json = false
		request_params.Add("format", *format)
	}

	if *format == "" || *format == "none" || *format == "json" {
		parse_json = false
	}

	if *nationality != "" && len(*nationality) == 2 {
		request_params.Add("nat", *nationality)
	}

	if len(request_params) > 0 {
		request_url = fmt.Sprintf("%s?%s", request_url, request_params.Encode())
	}

	client := http.Client{}
	request, err := http.NewRequest("GET", request_url, nil)

	if err == nil {
		request.Header.Add("DNT", "1")
		request.Header.Add("Origin", "https://randomuser.me")
		request.Header.Add("Accept-Language", "en-US,en")
		request.Header.Add("User-Agent", "Mozilla/5.0 (KHTML, like Gecko) Safari/537.36")
		request.Header.Add("Content-Type", "application/json;charset=UTF-8")
		request.Header.Add("Accept", "application/json, text/plain, */*")
		request.Header.Add("Referer", "https://randomuser.me/")
		request.Header.Add("Connection", "keep-alive")

		response, err := client.Do(request)

		if err == nil {
			defer response.Body.Close()
			body, _ := ioutil.ReadAll(response.Body)

			if parse_json == true {
				var users interface{}
				err := json.Unmarshal(body, &users)

				if err == nil {
					output, _ := json.MarshalIndent(users, "", "\x20\x20")
					fmt.Println(output)
					os.Exit(0)
				} else {
					fmt.Printf("JSON Decode: %s\n", err)
					os.Exit(1)
				}
			} else {
				fmt.Printf("%s", body)
				os.Exit(0)
			}
		} else {
			fmt.Printf("HTTP Request (Execute): %s\n", err)
			os.Exit(1)
		}
	} else {
		fmt.Printf("HTTP Request (Setup): %s\n", err)
		os.Exit(1)
	}
}
