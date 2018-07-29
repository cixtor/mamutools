/**
 * Password Generator
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://www.youtube.com/watch?v=BIKV3fYmzRQ
 *
 * A random password generator is software program or hardware device that takes
 * input from a random or pseudo-random number generator and automatically
 * generates a password. Random passwords can be generated manually, using
 * simple sources of randomness such as dice or coins, or they can be generated
 * using a computer.
 *
 * While there are many examples of "random" password generator programs
 * available on the Internet, generating randomness can be tricky and many
 * programs do not generate random characters in a way that ensures strong
 * security. A common recommendation is to use open source security tools where
 * possible, since they allow independent checks on the quality of the methods
 * used. Note that simply generating a password at random does not ensure the
 * password is a strong password, because it is possible, although highly
 * unlikely, to generate an easily guessed or cracked password. In fact there
 * is no need at all for a password to have been produced by a perfectly random
 * process: it just needs to be sufficiently difficult to guess.
 *
 * A password generator can be part of a password manager. When a password
 * policy enforces complex rules, it can be easier to use a password generator
 * based on that set of rules than to manually create passwords.
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
	customTypes string
	dictionary  []string
)

func init() {
	flag.IntVar(&length, "l", 24, "Maximum length for each password")
	flag.IntVar(&howmany, "c", 1, "How many passwords to generate")
	flag.StringVar(&typeDict, "t", "", "Group of characters to use (one or more): a, A, 1, @")
	flag.StringVar(&customTypes, "s", "", "String containing a specific list of usable letters")

	dictionary = []string{
		"0123456789",                  /* numbers */
		"~!@#$%^&*()_+-=[]{};:<>,./?", /* specials */
		"abcdefghijklmnopqrstuvwxyz",  /* alphabet_minus */
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ",  /* alphabet_mayus */
	}

	flag.Usage = func() {
		fmt.Println("Password Generator")
		fmt.Println("  http://cixtor.com/")
		fmt.Println("  https://github.com/cixtor/mamutools")
		fmt.Println("  https://en.wikipedia.org/wiki/Password")
		fmt.Println("  https://www.youtube.com/watch?v=BIKV3fYmzRQ")
		fmt.Println("Usage:")
		flag.PrintDefaults()
		fmt.Println("Example:")
		fmt.Println("  genpasswd -t 1      -> only numbers")
		fmt.Println("  genpasswd -t a      -> only lowercase letters")
		fmt.Println("  genpasswd -t A      -> only uppercase letters")
		fmt.Println("  genpasswd -t @      -> only special letters")
		fmt.Println("  genpasswd -t 1a     -> numbers with lowercase letters")
		fmt.Println("  genpasswd -t A@     -> uppercase and special letters")
		fmt.Println("  genpasswd -t 1aA@   -> all kind of letters")
		fmt.Println("  genpasswd -s \"(:)\"  -> only colons and parens")
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
		fmt.Println("Dictionary is empty, use -t to populate it")
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
	if customTypes != "" {
		return customTypes
	}

	if typeDict == "" {
		typeDict = "1a@A"
	}

	var userDict string

	for _, c := range typeDict {
		for _, values := range dictionary {
			if strings.Contains(values, string(c)) {
				userDict += values
			}
		}
	}

	return userDict
}

func genRandomString(wg *sync.WaitGroup, userDict string, length int) {
	defer wg.Done()

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
}
