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
flag.add_argument('-search', help='Search text in commit summary', action="store")
flag.add_argument('-commits', default=False, help='Print all the normal commits', action="store_true")
flag.add_argument('-merges', default=False, help='Print all the merged branches', action="store_true")
flag.add_argument('-all', default=False, help='Print all the commit logs', action="store_true")
flag.add_argument('-latest', default=0, help='Print the latest commit logs', action="store")
args = flag.parse_args()

exit_status = os.system('hg log 1> hglog.txt')

if exit_status == 0:
    data_set = {}
    response = []
    commit_logs = []
    fstream = open('hglog.txt', 'r')

    for line in fstream:
        line_str = line.strip()
        match = re.search('(changeset|parent|branch|tag|date|summary|user):\s*(.+)', line_str)

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
            # Check whether the commit is a merge.
            data_set['is_merge'] = 'parent' in data_set

            # Append commit information to the history pool.
            commit_logs.append(data_set)
            data_set = {}

    # Close file stream.
    fstream.close()

    # Delete the repository log file.
    os.remove('hglog.txt')

    # Search text in commit summary.
    if args.search is not None:
        results = []
        for commit in commit_logs:
            position = commit['summary'].find(sys.argv[2])
            if position is not -1:
                results.append(commit)
        response = results

    # Search all normal commits.
    elif args.commits is True:
        results = []
        for commit in commit_logs:
            if not commit['is_merge']:
                results.append(commit)
        response = results

    # Search commits for merges.
    elif args.merges is True:
        results = []
        for commit in commit_logs:
            position = commit['summary'].lower().find('merge')
            in_position = position is not -1
            if commit['is_merge'] and in_position:
                results.append(commit)
        response = results

    # Print the latest commits.
    elif args.latest > 0:
        counter, results, maximum = 0, [], int(args.latest)
        for commit in commit_logs:
            if counter < maximum:
                results.append(commit)
                counter += 1
            else:
                break
        response = results

    # Print all the commits.
    elif args.all is True:
        response = commit_logs

    # Exit to system safely.
    try:
        print json.dumps(response, indent=4)
        sys.exit(0)
    except IOError:
        pass
else:
    print 'Failure: exporting mercurial logs'
    sys.exit(1)
