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
