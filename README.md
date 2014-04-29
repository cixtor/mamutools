![Header Image](http://cixtor.com/uploads/mamutools-logo.png)

[MamuTools](http://cixtor.com/mamutools) is a collection of custom scripts intended to be used through the command line and to offer more utilities on things like fetch remote content, format piped output, compress and package repositories, string manipulation, etc. These scripts were written in multiple languages to solve specific problems and to facilitate the execution of common actions.

### Requirements

Considering that these scripts are not correlated among them, you'll need to check individually to know what are the dependencies, but here is a list with the basic libraries and interpreters needed to execute most of the scripts.

* Go >= 1.0 (tested on `go1.2rc3`)
* Bash >= 3.0 (Change the [Shebang](http://en.wikipedia.org/wiki/Shebang_(Unix)) to use another shell)
* PHP >= 5.2 (with `gd` and `curl` modules)

### Installation

```shell
$ cd /opt/
$ git clone https://github.com/cixtor/mamutools.git
$ chmod 755 ./mamutools/*.{sh,php}
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
The MIT License (MIT)

Copyright (c) 2013 CIXTOR

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
