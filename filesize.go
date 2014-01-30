/**
 * File Size
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://en.wikipedia.org/wiki/File_size
 *
 * File size measures the size of a computer file. Typically it is measured in
 * bytes with a prefix. The actual amount of disk space consumed by the file
 * depends on the file system. The maximum file size a file system supports
 * depends on the number of bits reserved to store size information and the total
 * size of the file system. For example, with FAT32, the size of one file cannot
 * be equal or larger than 4 GiB.
 *
 * Some common file size units are:
 *   1 byte = 8 bits
 *   1 KiB = 1,024 bytes
 *   1 MiB = 1,048,576 bytes
 *   1 GiB = 1,073,741,824 bytes
 *   1 TiB = 1,099,511,627,776 bytes
 *
 * Conversion Table
 *   | Name      | Symbol | Binary Measurement | Decimal Measurement | Number of Bytes                   | Equal to
 *   |-----------|--------|--------------------|---------------------|-----------------------------------|---------
 *   | KiloByte  | KB     | 2 ^ 10             | 10 ^ 3              | 1,024                             | 1,024 B
 *   | MegaByte  | MB     | 2 ^ 20             | 10 ^ 6              | 1,048,576                         | 1,024 KB
 *   | GigaByte  | GB     | 2 ^ 30             | 10 ^ 9              | 1,073,741,824                     | 1,024 MB
 *   | TeraByte  | TB     | 2 ^ 40             | 10 ^ 12             | 1,099,511,627,776                 | 1,024 GB
 *   | PetaByte  | PB     | 2 ^ 50             | 10 ^ 15             | 1,125,899,906,842,624             | 1,024 TB
 *   | ExaByte   | EB     | 2 ^ 60             | 10 ^ 18             | 1,152,921,504,606,846,976         | 1,024 PB
 *   | ZettaByte | ZB     | 2 ^ 70             | 10 ^ 21             | 1,180,591,620,717,411,303,424     | 1,024 EB
 *   | YottaByte | YB     | 2 ^ 80             | 10 ^ 24             | 1,208,925,819,614,629,174,706,176 | 1,024 ZB
 */

package main

import "fmt"
import "net/http"
import "regexp"
import "math"
import "flag"
import "os"
import "github.com/rakyll/magicmime"
// import "github.com/dustin/go-humanize"

func main(){
    flag.Parse()
    location := flag.Arg(0)

    if location == "" {
        fmt.Println("File Size")
        fmt.Println("  http://cixtor.com/")
        fmt.Println("  https://github.com/cixtor/mamutools")
        fmt.Println("  http://en.wikipedia.org/wiki/File_size")
        fmt.Println()
        fmt.Println("Usage:")
        fmt.Println("  filesize /local/file/path.ext")
        fmt.Println("  filesize http://domain.com/file_path.ext")
    }else{
        file_size(location)
    }
}

func file_size(location string){
    finfo, err := os.Stat(location)

    if err == nil {
        fmt.Printf("Location: %s\n", location)

        mm, err := magicmime.New()
        if err != nil { fmt.Printf("Error ocurred") }
        mimetype, err := mm.TypeByFile(location)
        fmt.Printf("Mimetype: %s\n", mimetype)

        fsize := finfo.Size()
        fmt.Printf("Filesize: %d bytes\n", fsize)
        fmt.Printf("Humanize: %s\n", readable_size(fsize))
    }else{
        remote_file_size(location)
    }
}

func remote_file_size(location string){
    match_scheme, _ := regexp.MatchString("^(http|https)://", location)
    if ! match_scheme { location = fmt.Sprintf("http://%s", location) }

    client := &http.Client{}
    req, err := http.NewRequest("HEAD", location, nil)

    if err == nil {
        req.Header.Set("User-Agent", "Mozilla/5.0 (KHTML, like Gecko)")
        resp, err := client.Do(req)

        if err == nil {
            fmt.Printf("Location: %s\n", location)
            fmt.Printf("Mimetype: %s\n", resp.Header.Get("Content-Type"))
            fmt.Printf("Filesize: %d bytes\n", resp.ContentLength)
            fmt.Printf("Humanize: %s\n", readable_size(resp.ContentLength))
        }else{
            fmt.Println("Error executing the HTTP request")
            fmt.Printf("Error: %s\n", err)
        }
    }else{
        fmt.Println("Error creating the HTTP request")
    }
}

func logn(n, b float64) float64 {
    return math.Log(n) / math.Log(b)
}

func readable_size(bytes int64) string {
    var base float64 = 1000 // List command in UNIX use 1000 instead of 1024
    sizes := []string{ "B", "KB", "MB", "GB", "TB", "PB", "EB" }

    if bytes < 10 {
        return fmt.Sprintf("%dB", bytes)
    }

    e := math.Floor(logn(float64(bytes), base))
    suffix := sizes[int(e)]
    val := float64(bytes) / math.Pow(base, math.Floor(e))
    f := "%.0f"
    if val < 10 { f = "%.1f" }

    return fmt.Sprintf(f+"%s", val, suffix)
}
