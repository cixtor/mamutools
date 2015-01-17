/**
 * Telize Geo Location
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://en.wikipedia.org/wiki/Geolocation
 * http://www.telize.com/
 *
 * Geolocation is the identification of the real-world geographic location of an
 * object, such as a radar source, mobile phone or Internet-connected computer
 * terminal. Geolocation may refer to the practice of assessing the location, or
 * to the actual assessed location. Geolocation is closely related to the use of
 * positioning systems but may be distinguished from it by a greater emphasis on
 * determining a meaningful location (e.g. a street address) rather than just a
 * set of geographic coordinates.
 *
 * Internet and computer geolocation can be performed by associating a
 * geographic location with the Internet Protocol (IP) address, MAC address,
 * RFID, hardware embedded article/production number, embedded software number
 * (such as UUID, Exif/IPTC/XMP or modern steganography), invoice, Wi-Fi
 * positioning system, device fingerprint, canvas fingerprinting or device GPS
 * coordinates, or other, perhaps self-disclosed information. Geolocation
 * usually works by automatically looking up an IP address on a WHOIS service
 * and retrieving the registrant's physical address.
 */

package main

import "encoding/json"
import "flag"
import "fmt"
import "io/ioutil"
import "net/http"
import "os"

type GeoLocation struct {
	Longitude float64 `json:"longitude"`
	Latitude float64 `json:"latitude"`
	ASN string `json:"asn"`
	Offset string `json:"offset"`
	IP string `json:"ip"`
	AreaCode string `json:"area_code"`
	ContinentCode string `json:"continent_code"`
	DmaCode string `json:"dma_code"`
	City string `json:"city"`
	Timezone string `json:"timezone"`
	Region string `json:"region"`
	CountryCode string `json:"country_code"`
	ISP string `json:"isp"`
	Country string `json:"country"`
	CountryCode3 string `json:"country_code3"`
	RegionCode string `json:"region_code"`
}

var address = flag.String("ip", "127.0.0.1", "IP address to geo-locate")

func main() {
	flag.Usage = func(){
		fmt.Println("Telize Geo Location")
		fmt.Println("  http://cixtor.com/")
		fmt.Println("  https://github.com/cixtor/mamutools")
		fmt.Println("  http://en.wikipedia.org/wiki/Geolocation")
		fmt.Println("  http://www.telize.com/")
		fmt.Println("Usage:")
		flag.PrintDefaults()
	}

	flag.Parse()

	if *address != "" {
		var request_url string = fmt.Sprintf("http://www.telize.com/geoip/%s", *address)

		client := http.Client{}
		request, err := http.NewRequest("GET", request_url, nil)

		if err == nil {
			request.Header.Add("DNT", "1")
			request.Header.Add("Accept-Language", "en-US,en")
			request.Header.Add("User-Agent", "Mozilla/5.0 (KHTML, like Gecko) Safari/537.36")
			request.Header.Add("Accept", "text/html,application/xhtml+xml,application/xml")
			request.Header.Add("Cache-Control", "max-age=0")
			request.Header.Add("Connection", "keep-alive")

			response, err := client.Do(request)

			if err == nil {
				defer response.Body.Close()
				body, _ := ioutil.ReadAll(response.Body)

				var geolocation GeoLocation
				err := json.Unmarshal(body, &geolocation)

				if err == nil {
					output, _ := json.MarshalIndent(geolocation, "", "    ")
					fmt.Printf("%s\n", output)
					os.Exit(0)
				} else {
					fmt.Printf("%s\n", err)
					os.Exit(1)
				}
			}
		}
	}

	flag.Usage()
	os.Exit(1)
}
