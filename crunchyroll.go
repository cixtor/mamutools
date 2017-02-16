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

import (
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"regexp"
	"strings"
)

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
	requestURL := fmt.Sprintf("http://www.crunchyroll.com/%s", *anime)
	pattern := regexp.MustCompile(`<a href="/` + *anime + `/([^"\/]+)"`)

	if *debug != "" {
		requestURL = fmt.Sprintf("%s/%s", *debug, *anime)
	}

	request, err := http.NewRequest("GET", requestURL, nil)

	if err != nil {
		fmt.Println("HTTP request:", err)
		os.Exit(1)
	}

	request.Header.Add("DNT", "1")
	request.Header.Add("Origin", "http://www.crunchyroll.com")
	request.Header.Add("Referer", "http://www.crunchyroll.com/")
	request.Header.Add("Accept-Language", "en-US,en;q=0.8")
	request.Header.Add("User-Agent", "Mozilla/5.0 (KHTML, like Gecko) Safari/537.36")
	request.Header.Add("Accept", "text/html,application/xhtml+xml,application/xml")
	request.Header.Add("Cache-Control", "max-age=0")
	request.Header.Add("Connection", "keep-alive")

	response, err := client.Do(request)

	if err != nil {
		fmt.Println("Request execution:", err)
		os.Exit(1)
	}

	defer response.Body.Close()

	body, _ := ioutil.ReadAll(response.Body)

	episodeMatches := pattern.FindAllStringSubmatch(string(body), -1)
	totalEpisodes := len(episodeMatches)

	if totalEpisodes < 2 {
		fmt.Println("[x] No episodes were found.")
		os.Exit(1)
	}

	episodeList := make([]string, 0)
	animeClean := strings.Replace(*anime, "-", "\x20", -1)
	animeTitle := strings.Title(animeClean)

	for _, episode := range episodeMatches {
		episodeURL := episode[1]
		entry := fmt.Sprintf("http://www.crunchyroll.com/%s/%s", *anime, episodeURL)

		episodeList = append(episodeList, entry)
	}

	fmt.Printf("#!/bin/bash\n")
	fmt.Printf("EPISODES=(\n")

	totalEntries := len(episodeList)
	itStart := totalEntries - 1

	for i := itStart; i >= 0; i-- {
		fmt.Printf("  '%s'\n", episodeList[i])
	}

	fmt.Printf(")\n")
	fmt.Printf("CURRENT_DIR=$(pwd)\n")
	fmt.Printf("VIDEO_FORMAT=\"%s\"\n", *format)
	fmt.Printf("if ! command -v rtmpdump &> /dev/null; then\n")
	fmt.Printf("  echo 'The rtmpdump package is required'\n")
	fmt.Printf("  exit 1\n")
	fmt.Printf("fi\n")
	fmt.Printf("for EPISODE_URL in \"${EPISODES[@]}\"; do\n")
	fmt.Printf("  FOLDER_NAME=$(echo \"$EPISODE_URL\" | rev | cut -d '/' -f 1 | rev)\n")
	fmt.Printf("  mkdir -pv \"${CURRENT_DIR}/${FOLDER_NAME}\" 2> /dev/null\n")
	fmt.Printf("  cd \"${CURRENT_DIR}/${FOLDER_NAME}\" || exit\n")
	fmt.Printf("  echo \"Anime: %s\"\n", animeTitle)
	fmt.Printf("  echo \"Episode: ${EPISODE_URL}\"\n")
	fmt.Printf("  echo \"Directory: ${FOLDER_NAME}\"\n")
	fmt.Printf("  if [[ \"$VIDEO_FORMAT\" == \"best\" ]]; then\n")
	fmt.Printf("    FORMAT=$(youtube-dl -F \"$EPISODE_URL\" 2> /dev/null | grep best | awk '{print $1}')\n")
	fmt.Printf("  else\n")
	fmt.Printf("    FORMAT=\"$VIDEO_FORMAT\"\n")
	fmt.Printf("  fi\n")
	fmt.Printf("  echo \"Video Format: ${FORMAT}\"\n")
	fmt.Printf("  if ! youtube-dl --all-subs --format \"$FORMAT\" \"$EPISODE_URL\"; then exit; fi\n")
	fmt.Printf("  echo\n")
	fmt.Printf("done\n")
}
