#!/bin/bash
#
# Google Chrome Upgrade
# http://cixtor.com/
# https://github.com/cixtor/mamutools
# http://cixtor.com/blog/chrome-upgrade
#
# Upgrading is the process of replacing a product with a newer version of the same
# product. In computing and consumer electronics an upgrade is generally a replacement
# of hardware, software or firmware with a newer or better version, in order to bring
# the system up to date or to improve its characteristics.
#
# Examples of common hardware upgrades include installing additional memory (RAM),
# adding larger hard disks, replacing microprocessor cards or graphics cards, and
# installing new versions of software. Many other upgrades are often possible as
# well. Common software upgrades include changing the version of an operating system,
# of an office suite, of an anti-virus program, or of various other tools.
#
# Although developers usually produce upgrades in order to improve a product, there
# are risks involved—including the possibility that the upgrade will worsen the product.
# Upgrades can also worsen a product subjectively. A user may prefer an older version
# even if a newer version functions perfectly as designed.
#

echo 'Google Chrome Upgrade'
echo '  http://cixtor.com/'
echo '  https://github.com/cixtor/mamutools'
echo '  http://cixtor.com/blog/chrome-upgrade'
echo

if [[ ! -e '/opt/google/' ]]; then
    echo 'Directory does not exists: /opt/google/'
    exit 1
elif [[ ! -w '/opt/google/' ]]; then
    echo 'Directory is not writable: /opt/google/'
    exit 1
elif [[ -e '/opt/google/chrome/' ]]; then
    echo 'Installation already exists: /opt/google/chrome/'
    exit 1
else
    mkdir -p '/opt/google/chrome/' 2> /dev/null
    cd '/opt/google/chrome/'

    echo -n 'Which version (beta|stable|unstable) '; read VERSION
    if [[ ! "${VERSION}" =~ (beta|stable|unstable) ]]; then VERSION='stable'; fi

    echo -n 'Which architecture (i386|amd64) '; read ARCHITECTURE
    if [[ ! "${ARCHITECTURE}" =~ (i386|amd64) ]]; then ARCHITECTURE='amd64'; fi

    ARCHIVE_NAME="google-chrome-installer-$(timestamp).deb"
    LATEST_CHROME="https://dl.google.com/linux/direct/google-chrome-${VERSION}_current_${ARCHITECTURE}.deb"
    wget "$LATEST_CHROME" -O "${ARCHIVE_NAME}"
    download_result=$(file "${ARCHIVE_NAME}")

    if [[ $(echo "$download_result" | grep ': empty') ]]; then
        echo 'Downloaded archive is empty'
        exit 1
    elif [[ $(echo "$download_result" | grep 'No such file') ]]; then
        echo 'Archive was not downloaded'
        exit 1
    fi

    dpkg --extract "${ARCHIVE_NAME}" package
    chrome_dirs=$(ls -1 package/opt/google/ 2> /dev/null | wc -l)

    if [[ "$chrome_dirs" -eq 1 ]]; then
        mv -v package/opt/google/chrome*/* ./
        rm -r package

        echo 'Change ownership and permissions of chrome-sandbox'
        sudo chown root:root chrome-sandbox
        sudo chmod 4755 chrome-sandbox
    fi

    rm "${ARCHIVE_NAME}" 2> /dev/null
fi
