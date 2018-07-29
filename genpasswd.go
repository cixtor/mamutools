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

var (
	length      int
	howmany     int
	typeDict    string
	allTypes    bool
	customTypes string
	dictionary  map[string]string
)

func init() {
	flag.IntVar(&length, "length", 10, "Length of each password (default: 10)")
	flag.IntVar(&howmany, "count", 1, "Quantity of passwords to generate (default: 1)")
	flag.StringVar(&typeDict, "type", "", "Group of characters to use (one of more): a, A, 1, @")
	flag.BoolVar(&allTypes, "all", false, "Use all character groups, same as: -type '1a@A'")
	flag.StringVar(&customTypes, "custom", "", "Custom list of characters for the dictionary")

	dictionary = map[string]string{
		"alphabet_minus": "abcdefghijklmnopqrstuvwxyz",
		"alphabet_mayus": "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
		"numbers":        "0123456789",
		"specials":       "!@$%&*_+=-_?/.,:;#",
	}

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
}

func main() {
	if howmany == 0 || length == 0 {
		return
	}

	var wg sync.WaitGroup

	userDict := genUserDictionary()

	if userDict == "" {
		fmt.Println("Dictionary is empty, use -type to populate it")
		flag.Usage()
		os.Exit(1)
	}

	wg.Add(howmany)

	for i := 0; i < howmany; i++ {
		go genRandomString(&wg, userDict, length)
	}

	wg.Wait()
}

func genUserDictionary() string {
	var userDict string

	if allTypes {
		for _, values := range dictionary {
			userDict += values
		}
	}

	if typeDict != "" && userDict == "" {
		if len(typeDict) == 1 {
			for _, values := range dictionary {
				if strings.Contains(values, typeDict) {
					userDict = values
					break
				}
			}
		} else {
			for _, c := range typeDict {
				for _, values := range dictionary {
					if strings.Contains(values, string(c)) {
						userDict += values
					}
				}
			}
		}
	}

	if customTypes != "" {
		userDict += customTypes
	}

	return userDict
}

func genRandomString(wg *sync.WaitGroup, userDict string, length int) {
	var password []byte

	dictlen := int64(len(userDict))

	for j := 0; j < length; j++ {
		pos, err := rand.Int(rand.Reader, big.NewInt(dictlen))

		if err != nil {
			panic(err)
		}

		password = append(password, userDict[pos.Int64()])
	}

	fmt.Printf("%s\n", password)

	defer wg.Done()
}
