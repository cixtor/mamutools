![Header Image](http://cixtor.com/uploads/mamutools-logo.png)

[MamuTools](http://cixtor.com/mamutools) is a collection of custom scripts intended to be used through the command line and to offer more utilities on things like fetch remote content, format piped output, compress and package repositories, string manipulation, etc. These scripts were written in multiple languages to solve specific problems and to facilitate the execution of common actions.

### Requirements

Considering that these scripts are not correlated among them, you'll need to check individually to know what are the dependencies, but here is a list with the basic libraries and interpreters needed to execute most of the scripts.

* Go >= 1.0 (tested on `go1.2rc3`)
* Bash >= 3.0 (Change the [Shebang](http://en.wikipedia.org/wiki/Shebang_(Unix)) to use another shell)
* Ruby >= 1.8 and RubyGems
* PHP >= 5.2 (with `gd` and `curl` modules)

### Installation

```shell
$ cd /opt/
$ git clone https://github.com/cixtor/mamutools.git
$ chmod 755 ./mamutools/*.{rb,sh,php}
$ for file in $(ls -1 /opt/mamutools/*.go); do \
    echo -n "Compiling '${file}'... "; \
    go build $file && rm -f $file; \
    echo 'Done'; \
  done
$ echo 'export PATH="$PATH:/opt/mamutools"' >> ~/.bashrc
$ source ~/.bashrc
```

### Uninstall

```shell
$ rm -rf /opt/mamutools/
$ REMOVE_LINE=$(cat ~/.bashrc | grep -n mamutools | awk -F ':' '{print $1}')
$ echo -e "Remove line \e[0;91m${REMOVE_LINE}\e[0m from $HOME/.bashrc"
$ source ~/.bashrc
```

### License

```
Copyright (c) 2013, CIXTOR.COM
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list
of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this
list of conditions and the following disclaimer in the documentation and/or other
materials provided with the distribution.
Neither the name of the CIXTOR MAMUTOOLS nor the names of its contributors may be
used to endorse or promote products derived from this software without specific
prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.
```