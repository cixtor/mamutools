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
import "strings"

func main() {
    if len(os.Args) > 1 {
        var action string = os.Args[1]
        var arguments []string = os.Args[1:]
        var verbose bool = false

        if action == "-help" {
            fmt.Println("Spark")
            fmt.Println("  http://cixtor.com/")
            fmt.Println("  https://github.com/cixtor/mamutools")
            fmt.Println("  http://en.wikipedia.org/wiki/Sparkline")
            fmt.Println("Usage:")
            fmt.Println("  spark [-help|-verbose] values")
            fmt.Println("Examples:")
            fmt.Println("  spark 1 5 22 13 53")
            fmt.Println("  spark $(echo 9 13 5 17 1)")
            fmt.Println("  spark $(print i in [1..50])")
            os.Exit(0)
        } else if action == "-verbose" {
            arguments = os.Args[2:]
            verbose = true
        }

        spark_numbers( arguments, verbose )
        os.Exit(0)
    } else {
        os.Exit(1)
    }
}

func spark_numbers( arguments []string, verbose bool ) {
    var numbers []float64 = get_numbers(arguments)
    var max_num float64 = max_slice(numbers)
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
        var unit int = int( (numbers[i] * 7 ) / max_num )
        sparks = append( sparks, sticks[unit] )
    }

    if verbose {
        var min_num float64 = min_slice(numbers)
        var ellipsis_arr []string
        var ellipsis_limit int = num_len
        var add_three_dots bool = false
        var num_ellipsis string

        if num_len > 15 {
            ellipsis_limit = 15
            add_three_dots = true
        }

        for j := 0; j < ellipsis_limit; j++ {
            ellipsis_arr = append( ellipsis_arr, float_to_string(numbers[j]) )
        }

        num_ellipsis = strings.Join( ellipsis_arr, ", " )

        if add_three_dots {
            num_ellipsis += " ..."
        }

        fmt.Printf( "Spark\n" )
        fmt.Printf( "Total numbers: %d\n", num_len )
        fmt.Printf( "Min: %.2f ; Max: %.2f\n", min_num, max_num )
        fmt.Printf( "Numbers: %s\n", num_ellipsis )
    }

    // Print the sparklines in the console.
    for i := 0; i < num_len; i++ {
        fmt.Printf( "%s", string(sparks[i]) )
    }

    fmt.Printf("\n")
}

func get_numbers( letters []string ) []float64 {
    var numbers []float64
    var list_len int = len(letters)

    for i := 0; i < list_len; i++ {
        num, _ := strconv.ParseFloat( letters[i], 64 )
        numbers = append( numbers, num )
    }

    return numbers
}

func max_slice( list []float64 ) float64 {
    var max float64
    var list_len int = len(list)

    for i := 0; i < list_len; i++ {
        var value float64 = list[i]

        if value > max {
            max = value
        }
    }

    return max
}

func min_slice( list []float64 ) float64 {
    var min float64
    var list_len int = len(list)

    for i := 0; i < list_len; i++ {
        var value float64 = list[i]

        if value > min {
            min = value
        }
    }

    return min
}

func float_to_string( number float64 ) string {
    return strconv.FormatFloat( number, 'f', 1, 64 )
}
