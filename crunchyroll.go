/**
 * Crunchyroll
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://en.wikipedia.org/wiki/Crunchyroll
 *
 * Crunchyroll is an American website and international online community focused
 * on video streaming East Asian media including anime, manga, drama, music,
 * electronic entertainment, and auto racing content. Crunchyroll's distribution
 * channel and partnership program delivers content to over five million online
 * community members worldwide. Crunchyroll is funded by The Chernin Group and
 * TV Tokyo.
 */

package main

import "flag"
import "fmt"
import "io/ioutil"
import "net/http"
import "os"
import "regexp"
import "strings"

var anime = flag.String("anime", "", "Friendly URL of the show")
var format = flag.String("format", "480p", "Force video resolution")
var debug = flag.String("debug", "", "Test server to debug requests")

func main() {
	flag.Usage = func() {
		fmt.Println("Crunchyroll Parser")
		fmt.Println("  http://cixtor.com/")
		fmt.Println("  https://github.com/cixtor/mamutools")
		fmt.Println("  http://en.wikipedia.org/wiki/Crunchyroll")
		fmt.Println("Usage:")
		flag.PrintDefaults()
	}

	flag.Parse()

	if *anime == "" {
		flag.Usage()
		os.Exit(1)
	}

	client := http.Client{}
	var request_url string = fmt.Sprintf("http://www.crunchyroll.com/%s", *anime)
	var pattern = regexp.MustCompile(`<a href="/` + *anime + `/([^"\/]+)"`)

	if *debug != "" {
		request_url = fmt.Sprintf("%s/%s", *debug, *anime)
	}

	request, err := http.NewRequest("GET", request_url, nil)

	if err == nil {
		request.Header.Add("DNT", "1")
		request.Header.Add("Origin", "http://www.crunchyroll.com")
		request.Header.Add("Referer", "http://www.crunchyroll.com/")
		request.Header.Add("Accept-Language", "en-US,en;q=0.8")
		request.Header.Add("User-Agent", "Mozilla/5.0 (KHTML, like Gecko) Safari/537.36")
		request.Header.Add("Accept", "text/html,application/xhtml+xml,application/xml")
		request.Header.Add("Cache-Control", "max-age=0")
		request.Header.Add("Connection", "keep-alive")

		response, err := client.Do(request)

		if err == nil {
			defer response.Body.Close()
			body, _ := ioutil.ReadAll(response.Body)
			var episode_matches [][]string = pattern.FindAllStringSubmatch(string(body), -1)
			var total_episodes int = len(episode_matches)

			if total_episodes > 1 {
				var episode_list = make([]string, 0)
				var anime_clean string = strings.Replace(*anime, "-", "\x20", -1)
				var anime_title string = strings.Title(anime_clean)

				for _, episode := range episode_matches {
					var episode_url string = episode[1]
					var entry string = fmt.Sprintf("http://www.crunchyroll.com/%s/%s", *anime, episode_url)

					episode_list = append(episode_list, entry)
				}

				fmt.Printf("#!/bin/bash\n")
				fmt.Printf("episodes=(\n")

				var total_entries int = len(episode_list)
				var it_start int = total_entries - 1
				for i := it_start; i >= 0; i-- {
					fmt.Printf("  '%s'\n", episode_list[i])
				}

				fmt.Printf(")\n")
				fmt.Printf("for episode_url in \"${episodes[@]}\"; do\n")
				fmt.Printf("  folder_name=$(echo \"$episode_url\" | rev | cut -d '/' -f 1 | rev)\n")
				fmt.Printf("  mkdir \"$folder_name\"\n")
				fmt.Printf("  if [[ -e \"$folder_name\" ]]; then\n")
				fmt.Printf("    cd \"$folder_name\"\n")
				fmt.Printf("    echo \"${folder_name}: ${episode_url}\"\n")
				fmt.Printf("    youtube-dl --all-subs --format %s \"$episode_url\"\n", *format)
				fmt.Printf("    notify-send '%s' \"Downloaded ${folder_name}\\n${episode_url}\" -i 'dialog-information'\n", anime_title)
				fmt.Printf("    cd ../ && echo\n")
				fmt.Printf("  fi\n")
				fmt.Printf("done\n")

				os.Exit(0)
			} else {
				fmt.Printf("[x] No episodes were found.\n")
				os.Exit(1)
			}
		} else {
			fmt.Printf("Request execution: %s\n", err)
			os.Exit(1)
		}
	} else {
		fmt.Printf("HTTP request: %s\n", err)
		os.Exit(1)
	}

	os.Exit(1)
}
