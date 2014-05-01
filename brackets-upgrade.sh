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
user_agent='Mozilla/5.0 (KHTML, like Gecko)'
echo 'Brackets Upgrade'
echo '    http://cixtor.com/'
echo '    https://github.com/cixtor/mamutools'
echo '    https://github.com/adobe/brackets'
echo
#
target_folder="/opt/brackets/"
if [ ! -e "${target_folder}" ]; then mkdir -p "${target_folder}"; fi
if [ -e "${target_folder}" ]; then cd "${target_folder}"; fi
#
architecture=$(uname -m)
echo "Computer architecture detected: ${architecture}"
if [ "${architecture}" == "x86_64" ]; then archi_type=64; else archi_type=32; fi
download_link=$(curl --silent 'http://download.brackets.io/' | grep "file\.cfm?platform=LINUX${archi_type}" | head -n 1)
download_link=$(echo "${download_link}" | cut -d '"' -f 2 | sed 's/file\.cfm/http:\/\/download\.brackets\.io\/file\.cfm/g')
build_number=$(echo "${download_link}" | awk -F '=' '{print $3'})
echo "Download link: ${download_link}"
echo "Build number: ${build_number}"
#
echo -n "Verifying the remote upgrade file... "
file_headers=$(curl --silent --head "${download_link}" --user-agent "${user_agent}")
file_name=$(echo "${file_headers}" | grep '; filename=' | awk -F '=' '{print $2}' | tr -d "\r")
echo "Done"
if [ "${file_name}" != "" ]; then
    echo
    wget -c "${download_link}" --user-agent "${user_agent}" -O "${file_name}"
    echo -n "Installing... "
    dpkg --extract ./brackets*.deb ./upgrade-package
    echo "Done"
    mv upgrade-package/usr/share/doc/brackets/copyright ./
    mv upgrade-package/usr/share/icons/hicolor/scalable/apps/brackets.svg ./
    mv upgrade-package/opt/brackets/* ./
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
    echo -n "Cleaning up... "
    cd "${target_folder}" && rm -rf ./upgrade-package/ ./*.deb
    echo "Done"
else
    echo "Error. Could not get the remote upgrade:"
    echo "${file_headers}"
fi
#