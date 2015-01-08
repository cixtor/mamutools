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
import "fmt"
import "io/ioutil"
import "net/http"
import "os"

type UserLocation struct {
	City string `json:"city"`
	State string `json:"state"`
	Street string `json:"street"`
	Zip string `json:"zip"`
}

type UserNameInfo struct {
	First string `json:"first"`
	Last string `json:"last"`
	Title string `json:"title"`
}

type UserPicture struct {
	Large string `json:"large"`
	Medium string `json:"medium"`
	Thumbnail string `json:"thumbnail"`
}

type UserData struct {
	SSN string `json:"SSN"`
	Cell string `json:"cell"`
	Dob string `json:"dob"`
	Email string `json:"email"`
	Gender string `json:"gender"`
	Location UserLocation `json:"location"`
	Md5 string `json:"md5"`
	Name UserNameInfo `json:"name"`
	Nationality string `json:"nationality"`
	Password string `json:"password"`
	Phone string `json:"phone"`
	Picture UserPicture `json:"picture"`
	Registered string `json:"registered"`
	Salt string `json:"salt"`
	Sha1 string `json:"sha1"`
	Sha256 string `json:"sha256"`
	Username string `json:"username"`
	Version string `json:"version"`
}

type RandomUser struct {
	Results []struct {
		Seed string `json:"seed"`
		User UserData `json:"user"`
	} `json:"results"`
}

func main() {
	client := http.Client{}
	request, err := http.NewRequest("GET", "http://api.randomuser.me/", nil)

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

			var users RandomUser
			err := json.Unmarshal(body, &users)

			if err == nil {
				output, _ := json.MarshalIndent(users, "", "    ")
				fmt.Printf("%s\n", output)
				os.Exit(0)
			} else {
				fmt.Printf( "JSON Decode: %s\n", err )
			}
		} else {
			fmt.Printf( "HTTP Request (Execute): %s\n", err )
		}
	} else {
		fmt.Printf( "HTTP Request (Setup): %s\n", err )
	}

	os.Exit(1)
}
