![Header Image](http://cixtor.com/uploads/mamutools-logo.png)

[MamuTools](http://cixtor.com/mamutools) is a collection of custom scripts intended to be used through the command line and to offer more utilities on things like fetch remote content, format piped output, compress and package repositories, string manipulation, etc. These scripts were written in multiple languages to solve specific problems and to facilitate the execution of common actions.

### Installation

This script will create a directory at `/opt/mamutools` _(if it does not exists yet)_, then will make all the scripts in the repository runnable by granting executable privileges to all users, finally will compile the Go files. Notice that if you don't have a working installation of the Go programming language this step will fail, I DO NOT distribute binaries with this repository for security reasons.

```shell
mkdir -p /opt/
git clone https://github.com/cixtor/mamutools /opt/mamutools
chmod -- 755 /opt/mamutools/*.{sh,py,php} 2> /dev/null
for FILE in $(ls -1 /opt/mamutools/*.go); do \
  CLEAN=$(echo "$FILE" | sed 's;\.go;;'); \
  echo "${FILE} -> ${CLEAN}"; \
  go build -o "$CLEAN" "$FILE"; \
done
echo 'export PATH="$PATH:/opt/mamutools"' 1>> ~/.profile
source ~/.profile
```

### Additional Tools

There is a additional list of tools that were originally part of this repository but then were moved to independent projects for maintainability, easy distribution and reusability by 3rd-party programs.

- [Sparkline](https://github.com/cixtor/sparkline) — `go get -u github.com/cixtor/sparkline`
- [Website TTFB](https://github.com/cixtor/webttfb) — `go get -u github.com/cixtor/webttfb`
- [String Conversion](https://github.com/cixtor/strconv) — `go get -u github.com/cixtor/strconv`
- [Wordpress Tickets](https://github.com/cixtor/wptickets) — `go get -u github.com/cixtor/wptickets`

### Uninstall

The uninstallation process is as simple as the deletion of the `/opt/mamutools` directory which contains all the scripts and binaries. Then you have to manually remove the _"export"_ line added to the `~/.profile` file during the installation process.
