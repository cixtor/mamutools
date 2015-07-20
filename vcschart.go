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
	"os"
	"os/exec"
	"strconv"
	"strings"
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
