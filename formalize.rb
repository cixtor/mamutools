#!/usr/bin/env ruby
#
# Filename Formalizer
# http://www.cixtor.coml/
# https://github.com/cixtor/mamutools
# http://en.wikipedia.org/wiki/Filename
#
# A filename (also written as two words, file name) is a name used to uniquely
# identify a computer file stored in a file system. Different file systems impose
# different restrictions on filename lengths and the allowed characters within
# filenames.
#
# A filename may include one or more of these components:
#   * host (or node or server) - network device that contains the file
#   * device (or drive) - hardware device or drive
#   * directory (or path) - directory tree (e.g., /usr/bin, \TEMP, [USR.LIB.SRC], etc.)
#   * file - base name of the file
#   * type (format or extension) - indicates the content type of the file (e.g., .txt, .exe, .COM, etc.)
#   * version - revision or generation number of the file
#
# The components required to identify a file varies across operating systems, as
# does the syntax and format for a valid filename. Within a single directory,
# filenames must be unique. Since the filename syntax also applies for directories,
# it is not possible to create a file and directory entries with the same name
# in a single directory. Multiple files in different directories may have the
# same name.
#
# Uniqueness approach may differ both on the case sensitivity and on the Unicode
# normalization form such as NFC, NFD. This means two separate files might be
# created with the same text filename and a different byte implementation of the
# filename, such as L"\x00C0.txt" (UTF-16, NFC) (Latin capital A with grave) and
# L"\x0041\x0300.txt" (UTF-16, NFD) (Latin capital A, grave combining).
#