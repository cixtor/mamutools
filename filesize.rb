#!/usr/bin/env ruby
#
# File Size
# http://www.cixtor.com/
# https://github.com/cixtor/mamutools
# http://en.wikipedia.org/wiki/File_size
#
# File size measures the size of a computer file. Typically it is measured in
# bytes with a prefix. The actual amount of disk space consumed by the file
# depends on the file system. The maximum file size a file system supports
# depends on the number of bits reserved to store size information and the total
# size of the file system. For example, with FAT32, the size of one file cannot
# be equal or larger than 4 GiB.
#
# Some common file size units are:
#   1 byte = 8 bits
#   1 KiB = 1,024 bytes
#   1 MiB = 1,048,576 bytes
#   1 GiB = 1,073,741,824 bytes
#   1 TiB = 1,099,511,627,776 bytes
#
# Conversion Table
#   | Name      | Symbol | Binary Measurement | Decimal Measurement | Number of Bytes                   | Equal to
#   |-----------|--------|--------------------|---------------------|-----------------------------------|---------
#   | KiloByte  | KB     | 2 ^ 10             | 10 ^ 3              | 1,024                             | 1,024 B
#   | MegaByte  | MB     | 2 ^ 20             | 10 ^ 6              | 1,048,576                         | 1,024 KB
#   | GigaByte  | GB     | 2 ^ 30             | 10 ^ 9              | 1,073,741,824                     | 1,024 MB
#   | TeraByte  | TB     | 2 ^ 40             | 10 ^ 12             | 1,099,511,627,776                 | 1,024 GB
#   | PetaByte  | PB     | 2 ^ 50             | 10 ^ 15             | 1,125,899,906,842,624             | 1,024 TB
#   | ExaByte   | EB     | 2 ^ 60             | 10 ^ 18             | 1,152,921,504,606,846,976         | 1,024 PB
#   | ZettaByte | ZB     | 2 ^ 70             | 10 ^ 21             | 1,180,591,620,717,411,303,424     | 1,024 EB
#   | YottaByte | YB     | 2 ^ 80             | 10 ^ 24             | 1,208,925,819,614,629,174,706,176 | 1,024 ZB
#