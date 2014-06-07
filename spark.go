/**
 * Spark
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://en.wikipedia.org/wiki/Sparkline
 *
 * A sparkline is a very small line chart, typically drawn without axes or
 * coordinates. It presents the general shape of the variation (typically over
 * time) in some measurement, such as temperature or stock market price, in a
 * simple and highly condensed way. Sparklines are small enough to be embedded
 * in text, or several sparklines may be grouped together as elements of a small
 * multiple.
 *
 * Whereas the typical chart is designed to show as much data as possible, and
 * is set off from the flow of text, sparklines are intended to be succinct,
 * memorable, and located where they are discussed.
 *
 * PS. All credits go to @holman by its original implementation in Bash.
 */

package main

import "os"
import "fmt"
import "strconv"

func main() {
    if len(os.Args) > 1 {
        var numbers []int = get_numbers(os.Args)
        var max_num int = max_slice(numbers)
        var num_len int = len(numbers)
        var sparks = make([]rune, 0)

        // Unicode representation of the sparks.
        var sticks = []rune {
            '\u2581',
            '\u2582',
            '\u2583',
            '\u2584',
            '\u2585',
            '\u2586',
            '\u2587',
            '\u2588',
        }

        // Get the sparkline for each number.
        for i := 0; i < num_len; i++ {
            var num int = int(numbers[i])
            var unit int = (num * 7 ) / max_num
            sparks = append( sparks, sticks[unit] )
        }

        // Print the sparklines in the console.
        for i := 0; i < num_len; i++ {
            fmt.Printf( "%s", string(sparks[i]) )
        }

        fmt.Printf("\n")

    } else {
        os.Exit(1)
    }
}

func get_numbers( arguments []string ) []int {
    var numbers []int
    var letters []string = arguments[1:]
    var list_len int = len(letters)

    for i := 0; i < list_len; i++ {
        num, _ := strconv.Atoi(letters[i])
        numbers = append( numbers, num )
    }

    return numbers
}
