/**
 * Hexadecimal to Base64
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * https://en.wikipedia.org/wiki/Base64
 * https://en.wikipedia.org/wiki/Hexadecimal
 * http://cryptopals.com/sets/1/challenges/1/
 *
 * Hexadecimal (also base 16, or hex) is a positional numeral system with a
 * radix, or base, of 16. It uses sixteen distinct symbols, most often the
 * symbols 0–9 to represent values zero to nine, and A, B, C, D, E, F (or
 * alternatively a, b, c, d, e, f) to represent values ten to fifteen.
 * Hexadecimal numerals are widely used by computer systems designers and
 * programmers. Several different notations are used to represent hexadecimal
 * constants in computing languages; the prefix "0x" is widespread due to its
 * use in Unix and C (and related operating systems and languages).
 *
 * Base64 is a group of similar binary-to-text encoding schemes that represent
 * binary data in an ASCII string format by translating it into a radix-64
 * representation. The particular set of 64 characters chosen to represent the
 * 64 place-values for the base varies between implementations. The general
 * strategy is to choose 64 characters that are both members of a subset common
 * to most encodings, and also printable. This combination leaves the data
 * unlikely to be modified in transit through information systems, such as
 * email, that were traditionally not 8-bit clean.
 */

package main

import (
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"os"
)

func main() {
	if len(os.Args) > 0 {
		var text string = os.Args[1]
		var length int = len(text)

		if length > 0 && length%2 == 0 {
			var result []byte
			var section []byte
			var b64text string

			for i := 0; i < length; i += 2 {
				section = []byte{text[i], text[i+1]}
				htext, err := hex.DecodeString(string(section))

				if err == nil {
					result = append(result, htext[0])
				}
			}

			if result != nil {
				b64text = base64.StdEncoding.EncodeToString(result)
				fmt.Println(b64text)
				os.Exit(0)
			}
		}
	}

	fmt.Println("Hexadecimal to Base64")
	fmt.Println("  http://cixtor.com/")
	fmt.Println("  https://github.com/cixtor/mamutools")
	fmt.Println("  https://en.wikipedia.org/wiki/Base64")
	fmt.Println("  https://en.wikipedia.org/wiki/Hexadecimal")
	fmt.Println("  http://cryptopals.com/sets/1/challenges/1/")
	fmt.Println("Usage:")
	fmt.Printf("  %s [string]\n", os.Args[0])
	fmt.Printf("  %s [string] | base64 -d\n", os.Args[0])

	os.Exit(1)
}
