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
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"time"
)

type VcsChart struct{}

func (chart VcsChart) GetDates() []string {
	kommand := exec.Command("git", "log", "--pretty=format:%at")
	response, err := kommand.CombinedOutput()

	if err != nil {
		os.Exit(1)
	}

	var dates []string
	var output []string = strings.Split(string(response), "\n")
	var length int = len(output) - 1
	var timestamp int64

	for line := length; line >= 0; line-- {
		timestamp, err = strconv.ParseInt(output[line], 10, 64)
		if err == nil {
			dates = append(dates, chart.TimeToDate(timestamp))
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

	for day = 370; day >= 0; day-- {
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
