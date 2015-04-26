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

import argparse
import json
import os
import re
import sys

flag = argparse.ArgumentParser()
flag.add_argument('-search', help='Search text in commit summary')
flag.add_argument('-all', default=False, help='Print all the commit logs')
args = flag.parse_args()

exit_status = os.system('hg log 1> hglog.txt')
if exit_status == 0:
    data_set = {}
    commit_logs = []
    fstream = open('hglog.txt', 'r')

    for line in fstream:
        line_str = line.strip()
        match = re.search('(changeset|branch|tag|date|summary|user):\s*(.+)', line_str)

        if match is not None:
            key_name = match.group(1)
            key_value = match.group(2)
            data_set[key_name] = key_value

            if key_name == 'user':
                match = re.search('([^<]+)\s*<([^>]+)>', key_value)

                if match is not None:
                    data_set['display_name'] = match.group(1).strip()
                    data_set['user_email'] = match.group(2)
                else:
                    data_set['display_name'] = None
                    data_set['user_email'] = None

            if key_name == 'changeset':
                match = re.search('([0-9]+):([0-9a-z]+)', key_value)

                if match is not None:
                    data_set['changeset'] = match.group(1)
                    data_set['commit'] = match.group(2)
                else:
                    data_set['commit'] = None

        if line_str is '':
            commit_logs.append(data_set)
            data_set = {}

    # Close file stream.
    fstream.close()

    # JSON-encode and print the commit logs.
    if sys.argv[1] == '-all':
        print json.dumps(commit_logs, indent=4)
        sys.exit(0)

    # Search text in commit summary.
    if sys.argv[1] == '-search':
        results = []
        for commit in commit_logs:
            position = commit['summary'].find( sys.argv[2] )
            if position is not -1:
                results.append(commit)
        print json.dumps(results, indent=4)

    # Delete the repository log file.
    os.remove('hglog.txt')
else:
    print 'Failure: exporting mercurial logs'
