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
