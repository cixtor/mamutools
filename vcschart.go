/**
 * VCS (Version Control System) Chart
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * https://en.wikipedia.org/wiki/Revision_control
 *
 * A component of software configuration management, revision control, also
 * known as version control or source control, is the management of changes to
 * documents, computer programs, large web sites, and other collections of
 * information. Changes are usually identified by a number or letter code, each
 * revision is associated with a timestamp and the person making the change.
 *
 * The profile contributions graph is a record of contributions you have made to
 * VCS (Version Control System) repositories but they are only counted if they
 * meet certain criteria. Commits will appear on your contributions graph if
 * they meet all of the following conditions:
 *
 * - The commits were made within the past year.
 * - The commits were made in a standalone repository, not a fork.
 * - The commits were made in the repository's default branch.
 */

package main

import (
	"flag"
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"time"
)

type VcsChart struct{}

var weekdays = []string{"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
var repotype = flag.String("type", "git", "Repository type: git, mercurial, subversion, etc")

func (chart VcsChart) TimeToDate(timestamp int64) string {
	const dlayout = "2006-01-02"
	var dtime time.Time = time.Unix(timestamp, 0)
	var date string = dtime.Format(dlayout)

	return date
}

func (chart VcsChart) IsCommitDate(needle string, haystack []string) bool {
	for _, value := range haystack {
		if value == needle {
			return true
		}
	}

	return false
}

func (chart VcsChart) GetGitDates() (string, error) {
	kommand := exec.Command("git", "log", "--pretty=format:%at")
	response, err := kommand.CombinedOutput()
	var output string = string(response)

	return output, err
}

func (chart VcsChart) GetMercurialDates() (string, error) {
	kommand := exec.Command("hg", "log", "--template={date}\n")
	response, err := kommand.CombinedOutput()
	var output string = string(response)

	return output, err
}

func (chart VcsChart) GetDates(repo string) []string {
	var response string
	var err error

	if repo == "git" {
		response, err = chart.GetGitDates()
	} else if repo == "mercurial" || repo == "hg" {
		response, err = chart.GetMercurialDates()
	} else {
		fmt.Println("Repository type not supported")
		os.Exit(1)
	}

	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	var dates []string
	var output []string = strings.Split(response, "\n")
	var length int = len(output) - 1
	var timestamp int64
	var parts []string
	var line string

	for lnum := length; lnum >= 0; lnum-- {
		line = output[lnum]
		if line != "" {
			parts = strings.Split(line, ".")
			timestamp, err = strconv.ParseInt(parts[0], 10, 64)
			if err == nil {
				dates = append(dates, chart.TimeToDate(timestamp))
			}
		}
	}

	return dates
}

func (chart VcsChart) GetBackTime(now time.Time) (time.Time, string) {
	var one_year int64 = 31536000
	var timeago int64 = now.Unix() - one_year
	var pasttime time.Time = time.Unix(timeago, 0)
	var weekday string = weekdays[pasttime.Weekday()]

	return pasttime, weekday
}

func (chart VcsChart) GetCalendar() (map[string][]string, time.Time) {
	var started bool
	var dname string
	var day_counter int
	var date_time int64
	var day int64
	var cal_value string
	var now time.Time = time.Now()
	yearago, weekday := chart.GetBackTime(now)

	var calendar = map[string][]string{
		"Sun": {},
		"Mon": {},
		"Tue": {},
		"Wed": {},
		"Thu": {},
		"Fri": {},
		"Sat": {},
	}

	for day = 366; day >= 0; day-- {
		dname = weekdays[day_counter]

		if dname == weekday || started {
			started = true
			date_time = now.Unix() - (day * 86400)
			cal_value = chart.TimeToDate(date_time)
		} else {
			cal_value = ""
		}

		calendar[dname] = append(calendar[dname], cal_value)

		if day_counter < 6 {
			day_counter += 1
		} else {
			day_counter = 0
		}
	}

	return calendar, yearago
}

func (chart VcsChart) PrintCalendarHeader(calendar map[string][]string, yearago time.Time) {
	var fix_month bool = false
	var prev_month string = yearago.Month().String()
	var short_format string = "2006-01-02"
	var dtime time.Time
	var month string

	for _, dhead := range calendar["Sun"] {
		dtime, _ = time.Parse(short_format, dhead)
		month = dtime.Month().String()
		if dhead != "" && month != prev_month {
			fmt.Printf("%s", month[0:3])
			prev_month = month
			fix_month = true
		} else if fix_month {
			fmt.Printf("\x20")
			fix_month = false
		} else {
			fmt.Printf("\x20\x20")
		}
	}
	fmt.Println()
}

func (chart VcsChart) PrintCalendarDates(calendar map[string][]string, commits []string) {
	for _, weekday := range weekdays {
		for _, date := range calendar[weekday] {
			if date == "" {
				fmt.Printf("~\x20")
			} else if chart.IsCommitDate(date, commits) {
				fmt.Printf("\x1b[0;92m@\x1b[0m\x20")
			} else {
				fmt.Printf("\u00B7\x20")
			}
		}
		fmt.Println()
	}
}

func main() {
	flag.Usage = func() {
		fmt.Println("VCS (Version Control System) Chart")
		fmt.Println("  http://cixtor.com/")
		fmt.Println("  https://github.com/cixtor/mamutools")
		fmt.Println("  https://en.wikipedia.org/wiki/Revision_control")
		fmt.Println("Usage:")
		flag.PrintDefaults()
	}

	flag.Parse()

	var chart VcsChart
	commits := chart.GetDates(*repotype)
	calendar, yearago := chart.GetCalendar()

	chart.PrintCalendarHeader(calendar, yearago)
	chart.PrintCalendarDates(calendar, commits)

	os.Exit(0)
}
