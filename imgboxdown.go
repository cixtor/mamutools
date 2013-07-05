/**
 * Imgbox Downloader
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://imgbox.com/
 *
 * ImgBox is a free image hosting service which supports JPG, GIF and PNG files
 * with a maximum of 10 MB of size, and they can be stored for a life time, they
 * have no limits to store your images once you register for a free account. You
 * can also inline link (hotlink) the images uploaded using the provided full-
 * size share codes only (considering that other URLs may change in the future).
 * There is no hard limit for inline linking (hotlinking) but there are
 * bandwidth limitations in case of abusive referrers where the requests will be
 * blocked.
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

var photo_id = flag.String("photo", "", "Specify the photo identifier to download")
var gallery_id = flag.String("gallery", "", "Specify the gallery identifier to download all its images")

const user_agent = "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"

func getRemoteContent(url string) []byte {
	client := &http.Client{}
	req, err1 := http.NewRequest("GET", url, nil)

	if err1 == nil {
		req.Header.Set("User-Agent", user_agent)
		resp, err2 := client.Do(req)

		if err2 == nil {
			defer resp.Body.Close()
			body, _ := ioutil.ReadAll(resp.Body)
			return body
		}
	}

	return nil
}

func getRemoteContentSplitted(url string) []string {
	var body []byte = getRemoteContent(url)
	var str_lines []string = strings.Split(string(body), "\n")

	return str_lines
}

func getPhoto(photo_id string) {
	var r = regexp.MustCompile(`<img alt=".*" class=".*" id="img" onclick=".*" src="(.*)" title="(.*)" \/>`)
	var photo_url string = fmt.Sprintf("http://imgbox.com/%s", photo_id)
	var image_lines []string = getRemoteContentSplitted(photo_url)

	for _, line := range image_lines {
		var results []string = r.FindStringSubmatch(line)

		if len(results) > 0 {
			fmt.Printf("--> Downloading '%s' as '%s'\n", results[1], results[2])
			var filedata []byte = getRemoteContent(results[1])
			ioutil.WriteFile(results[2], filedata, 0644)
		}
	}
}

func getGallery(gallery_id string) {
	var gallery_folder string = fmt.Sprintf("imgbox-%s", gallery_id)
	_, err1 := os.Stat(gallery_folder)

	if err1 == nil {
		fmt.Printf("OK. Gallery folder already exists: %s\n", gallery_folder)
	} else {
		err2 := os.Mkdir(gallery_folder, 0755)

		if err2 == nil {
			fmt.Printf("OK. Gallery folder created: %s\n", gallery_folder)
		} else {
			fmt.Printf("[x] Could not create gallery folder: %s\n", gallery_folder)
			os.Exit(1)
		}
	}

	os.Chdir(gallery_folder)

	var r = regexp.MustCompile(`<a href="\/(.*)"><img alt=".*" src="[a-z]+:\/\/s\.imgbox\.com\/.*" \/><\/a>`)
	var album_url string = fmt.Sprintf("http://imgbox.com/g/%s", gallery_id)
	var album_lines []string = getRemoteContentSplitted(album_url)

	for _, line := range album_lines {
		var results []string = r.FindStringSubmatch(line)

		if len(results) > 0 {
			getPhoto(results[1])
		}
	}
}

func download(photo_id string, gallery_id string) {
	if photo_id != "" {
		fmt.Printf("OK. Download photo: %s\n", photo_id)
		getPhoto(photo_id)
	} else if gallery_id != "" {
		fmt.Printf("OK. Download gallery: %s\n", gallery_id)
		getGallery(gallery_id)
	} else {
		fmt.Printf("Missing argument: -photo or -gallery\n")
		flag.Usage()
		os.Exit(1)
	}
}

func main() {
	flag.Usage = func() {
		fmt.Printf("Imgbox Downloader\n")
		fmt.Printf("  http://cixtor.com/\n")
		fmt.Printf("  https://github.com/cixtor/mamutools\n")
		fmt.Printf("  http://imgbox.com/\n")
		fmt.Printf("Usage:\n")
		flag.PrintDefaults()
	}

	flag.Parse()

	download(*photo_id, *gallery_id)
	fmt.Printf("OK. Finished\n")
}
