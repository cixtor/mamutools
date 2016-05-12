/**
 * Password Generator
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://www.youtube.com/watch?v=BIKV3fYmzRQ
 *
 * A random password generator is software program or hardware device that takes
 * input from a random or pseudo-random number generator and automatically generates
 * a password. Random passwords can be generated manually, using simple sources
 * of randomness such as dice or coins, or they can be generated using a computer.
 *
 * While there are many examples of "random" password generator programs available
 * on the Internet, generating randomness can be tricky and many programs do not
 * generate random characters in a way that ensures strong security. A common
 * recommendation is to use open source security tools where possible, since they
 * allow independent checks on the quality of the methods used. Note that simply
 * generating a password at random does not ensure the password is a strong password,
 * because it is possible, although highly unlikely, to generate an easily guessed
 * or cracked password. In fact there is no need at all for a password to have been
 * produced by a perfectly random process: it just needs to be sufficiently difficult
 * to guess.
 *
 * A password generator can be part of a password manager. When a password policy
 * enforces complex rules, it can be easier to use a password generator based on
 * that set of rules than to manually create passwords.
 */

package main

import (
	"crypto/rand"
	"flag"
	"fmt"
	"math/big"
	"os"
	"strings"
	"sync"
)

var length = flag.Int("length", 10, "Length of each password (default: 10)")
var count = flag.Int("count", 1, "Quantity of passwords to generate (default: 1)")
var type_dict = flag.String("type", "", "Group of characters to use (one of more): a, A, 1, @")
var all_types = flag.Bool("all", false, "Use all character groups, same as: -type '1a@A'")
var custom_types = flag.String("custom", "", "Custom list of characters for the dictionary")

var dictionary = map[string]string{
	"alphabet_minus": "abcdefghijklmnopqrstuvwxyz",
	"alphabet_mayus": "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
	"numbers":        "0123456789",
	"specials":       "!@$%&*_+=-_?/.,:;#",
}

func genUserDictionary() string {
	var user_dict string

	if *all_types {
		for _, key_values := range dictionary {
			user_dict += key_values
		}
	}

	if *type_dict != "" && user_dict == "" {
		if len(*type_dict) == 1 {
			for _, key_values := range dictionary {
				if strings.Contains(key_values, *type_dict) {
					user_dict = key_values
					break
				}
			}
		} else {
			for _, c := range *type_dict {
				for _, key_values := range dictionary {
					if strings.Contains(key_values, string(c)) {
						user_dict += key_values
					}
				}
			}
		}
	}

	if *custom_types != "" {
		user_dict += *custom_types
	}

	return user_dict
}

func genRandomString(wg *sync.WaitGroup, user_dict string, length int) {
	var password []byte

	dictlen := int64(len(user_dict))

	for j := 0; j < length; j++ {
		pos, err := rand.Int(rand.Reader, big.NewInt(dictlen))

		if err != nil {
			panic(err)
		}

		password = append(password, user_dict[pos.Int64()])
	}

	fmt.Printf("%s\n", password)

	defer wg.Done()
}

func main() {
	flag.Usage = func() {
		fmt.Println("Password Generator")
		fmt.Println("  http://cixtor.com/")
		fmt.Println("  https://github.com/cixtor/mamutools")
		fmt.Println("  https://en.wikipedia.org/wiki/Password")
		fmt.Println("  https://www.youtube.com/watch?v=BIKV3fYmzRQ")
		fmt.Println("Usage:")
		flag.PrintDefaults()
	}

	flag.Parse()

	if *count > 0 && *length > 0 {
		var wg sync.WaitGroup
		var user_dict string = genUserDictionary()

		if user_dict == "" {
			fmt.Println("Dictionary is empty, use -type to populate it")
			flag.Usage()
			os.Exit(1)
		}

		wg.Add(*count) /* Number of passwords */

		for i := 0; i < *count; i++ {
			go genRandomString(&wg, user_dict, *length)
		}

		wg.Wait()
	} else {
		flag.Usage()
	}
}
