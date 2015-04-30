/**
 * Time to String
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://en.wikipedia.org/wiki/Timestamp
 *
 * Timestamp is the time at which an event is recorded by a device, not the time
 * of the event itself. In many cases, the difference may be inconsequential:
 * the time at which an event is recorded by a timestamp should be close to the
 * time of the event. This data is usually presented in a consistent format,
 * allowing for easy comparison of two different records and tracking progress
 * over time; the practice of recording timestamps in a consistent manner along
 * with the actual data is called timestamping. The sequential numbering of
 * events is sometimes called timestamping.
 *
 * Timestamps are typically used for logging events or in a sequence of events
 * (SOE), in which case each event in the log or SOE is marked with a timestamp.
 * In filesystems, timestamp may mean the stored date/time of creation or
 * modification of a file.
 */

package main

import "fmt"
import "os"
import "strconv"
import "time"

func main() {
	value, err := strconv.ParseInt("1405544146", 10, 64)

	if err == nil {
		time := time.Unix(value, 0)
		fmt.Println(time)
		os.Exit(0)
	} else {
		panic(err)
		os.Exit(1)
	}
}
