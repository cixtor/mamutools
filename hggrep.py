#!/usr/bin/env python

'''
Mercurial Grep
http://cixtor.com/
https://github.com/cixtor/mamutools
http://en.wikipedia.org/wiki/Mercurial

Mercurial is a cross-platform, distributed revision control tool for software
developers. It is mainly implemented using the Python programming language, but
includes a binary diff implementation written in C. Mercurial's major design
goals include high performance and scalability, decentralized, fully distributed
collaborative development, robust handling of both plain text and binary files,
and advanced branching and merging capabilities, while remaining conceptually
simple.

Mercurial uses SHA-1 hashes to identify revisions. For repository access via a
network, Mercurial uses an HTTP-based protocol that seeks to reduce round-trip
requests, new connections and data transferred. Mercurial can also work over ssh
where the protocol is very similar to the HTTP-based protocol. By default it
uses a 3-way merge before calling external merge tools.
'''

import os
import re
import sys

exit_status = os.system('hg log 1> hglog.txt')
if exit_status == 0:
    data_set = {}
    commit_logs = []
    fstream = open('hglog.txt', 'r')

    for line in fstream:
        line_str = line.strip()
        print line_str

    # Close file stream.
    fstream.close()

    # Delete the repository log file.
    os.remove('hglog.txt')
else:
    print 'Failure: exporting mercurial logs'
