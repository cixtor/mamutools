#!/bin/bash
#
# Brackets Upgrade
# http://cixtor.com/
# https://github.com/cixtor/mamutools
# https://github.com/adobe/brackets
#
# Brackets is an open source code editor for web designers and front-end developers.
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
url_target='http://brackets.io/'
user_agent='Mozilla/5.0 (KHTML, like Gecko)'
github_releases='https://github.com/adobe/brackets/releases/download'
versioning_url='http://s3.amazonaws.com/files.brackets.io/updates/stable/en.json'
target_folder='/opt/brackets'
local_filename='brackets.deb'

echo 'Brackets Upgrade'
echo '  http://cixtor.com/'
echo '  https://github.com/cixtor/mamutools'
echo '  https://github.com/adobe/brackets'
echo

# Check target folder existence.
if [ ! -e "${target_folder}" ]; then mkdir -p "${target_folder}"; fi
if [ -e "${target_folder}" ]; then cd "${target_folder}"; fi

# Detect system architecture.
architecture=$(uname -m)
echo "Computer architecture detected: ${architecture}"
if [ "${architecture}" == "x86_64" ]; then archi_type=64; else archi_type=32; fi

# Retrieve the URL to download.
build_number=$(curl --silent "${url_target}" --user-agent "${user_agent}" | grep 'var buildNum =')
build_number=$(echo "${build_number}" | sed 's/ //g' | awk -F '"' '{print $2}')
if [ "${build_number}" == "" ]; then
    versioning=$(curl --compressed --silent "${versioning_url}" --user-agent "${user_agent}" | grep versionString)
    versioning=$(echo "${versioning}" | head -n 1 | sed 's/[":,a-zA-Z ]//g')
    build_number=$versioning
fi
download_link="${github_releases}/release-${build_number}/Brackets.Release.${build_number}.${archi_type}-bit.deb"
echo "Download link: ${download_link}"
echo "Build number: ${build_number}"

# Download package.
if [ $(pwd) == "${target_folder}" ]; then
    rm -rf ./*
    echo 'Downloading package...'
    wget -c "${download_link}" --user-agent "${user_agent}" -O "${local_filename}"

    # Check whether the package was downloaded successfully.
    is_empty=$(file "${local_filename}" | tr -d ' ' | cut -d ':' -f 2)
    if [ "${is_empty}" == "empty" ]; then
        rm -f "${local_filename}"
    fi
fi

# Check whether the package was downloaded or not.
if [ -e "${local_filename}" ]; then
    # Extracting package content.
    echo -n 'Installing... '
    dpkg --extract ./brackets*.deb ./upgrade-package
    echo 'Done'

    # Moving around the package files.
    mv upgrade-package/usr/share/doc/brackets/copyright ./
    mv upgrade-package/usr/share/icons/hicolor/scalable/apps/brackets.svg ./
    mv upgrade-package/opt/brackets/* ./

    # Install the desktop shortcut icon.
    if [ -e "/usr/share/applications/" ]; then
        # Change desktop shortcut icon
        shortcut_icon=""
        allowed_icons=("appshell32.png" "appshell48.png" "appshell128.png" "appshell256.png" "brackets.svg")
        for icon in "${allowed_icons[@]}" ; do
            if [ -e "./${icon}" ]; then shortcut_icon="/opt/brackets/${icon}"; fi
        done
        echo '[Desktop Entry]' > temp.desktop
        echo 'Type=Application' >> temp.desktop
        echo "Name=Brackets (build ${build_number})" >> temp.desktop
        echo 'Exec=/opt/brackets/brackets %U' >> temp.desktop
        echo "Icon=${shortcut_icon}" >> temp.desktop
        echo 'Categories=Development' >> temp.desktop
        echo 'MimeType=text/html;' >> temp.desktop
        cat temp.desktop > brackets.desktop && rm -f temp.desktop
        # Install desktop shortcut
        cd /usr/share/applications/
        if [ -e "brackets.desktop" ]; then rm -f brackets.desktop; fi
        ln -s /opt/brackets/brackets.desktop
    fi

    # Cleaning the application directory.
    echo -n 'Cleaning up... '
    cd "${target_folder}" && rm -rf ./upgrade-package/ ./*.deb
    echo 'Done'
    exit 0
else
    echo 'Error. Could not download the remote file, try again.'
    exit 1
fi
