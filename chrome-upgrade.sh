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
GOOGLE_FOLDER_PATH='/opt/google/'
CHROME_FOLDER_PATH="${GOOGLE_FOLDER_PATH}chrome/"
TEMP_PACKAGE='google-chrome-latest.deb'
#
function fail {
    echo -e "\e[0;91m[x] Error.\e[0m ${1}"
    exit
}
function success {
    echo -e "\e[0;92mOK.\e[0m ${1}"
}
function warning {
    echo -e "\e[0;93m[!]\e[0m ${1}"
}
function question {
    echo -en "\e[0;94m[?]\e[0m ${1}"
}
function initialize {
    echo 'Google Chrome Upgrade'
    echo '    http://cixtor.com/'
    echo '    https://github.com/cixtor/mamutools'
    echo '    http://cixtor.com/blog/chrome-upgrade'
    echo
    question 'Choose the version family (beta|stable) '; read VERSION
    if [[ "${VERSION}" =~ (beta|stable) ]]; then VERSION="${VERSION}"; else VERSION='beta'; fi
    question 'Choose the architecture in bits (i386|amd64) '; read ARCHITECTURE
    if [[ "${ARCHITECTURE}" =~ (i386|amd64) ]]; then ARCHITECTURE="${ARCHITECTURE}"; else ARCHITECTURE='i386'; fi
}
function request_sudo {
    warning 'Some operations will require Root provileges, type your password to continue:'
    echo -n '    '
    if [ $(sudo whoami) == 'root' ]; then
        success 'Root privileges granted'
    else
        fail 'You can not proceed without root privileges.'
    fi
}
function stop_current_processes {
    question 'Stop all current Google Chrome processes (Y/n) '
    read STOP_PROCESSES
    if [ "${STOP_PROCESSES}" == 'y' ] || [ "${STOP_PROCESSES}" == 'Y' ]; then
        STOP_PROCESSES='yes'
    else
        question 'Are you sure? Do you want to let those processes running? (Y/n) '
        read LET_THEM_RUNNING
        if [ "${LET_THEM_RUNNING}" == 'n' ] || [ "${LET_THEM_RUNNING}" == 'N' ]; then
            STOP_PROCESSES='yes'
        else
            STOP_PROCESSES='no'
        fi
    fi
    if [ "${STOP_PROCESSES}" == 'yes' ]; then
        for PROCESS in $(ps -A u | grep "${CHROME_FOLDER_PATH}" | awk '{print $2}'); do
            echo -n "    Killing Chrome process ${PROCESS}: "
            sudo skill -kill $PROCESS
            success
        done
    fi
}
function remove_old_version {
    if [ -e "${CHROME_FOLDER_PATH}" ]; then
        question 'Remove old versions of Google Chrome from your system (Y/n) '
        read REMOVE
        if [ "${REMOVE}" == 'y' ] || [ "${REMOVE}" == 'Y' ]; then
            sudo rm -rf "${CHROME_FOLDER_PATH}";
        else
            fail 'You need to remove all the old versions of Google Chrome to continue.'
        fi
    fi

    CONFIG_FILES_PATH="${HOME}/.config/google-chrome"
    if [ -e "${CONFIG_FILES_PATH}" ]; then
        question 'Remove old configuration files (stable edition) (Y/n)'
        read REMOVE
        if [ "${REMOVE}" == 'y' ] || [ "${REMOVE}" == 'Y' ]; then
            sudo rm -rf "${CONFIG_FILES_PATH}"
        fi
    fi

    BETA_CONFIG_FILES_PATH="${HOME}/.config/google-chrome-beta"
    if [ -e "${BETA_CONFIG_FILES_PATH}" ]; then
        question 'Remove old configuration files (beta edition) (Y/n)'
        read REMOVE
        if [ "${REMOVE}" == 'y' ] || [ "${REMOVE}" == 'Y' ]; then
            sudo rm -rf "${BETA_CONFIG_FILES_PATH}"
        fi
    fi

    CACHE_FILES_PATH="${HOME}/.cache/google-chrome"
    if [ -e "${CACHE_FILES_PATH}" ]; then
        question 'Remove old cache files (stable edition) (Y/n)'
        read REMOVE
        if [ "${REMOVE}" == 'y' ] || [ "${REMOVE}" == 'Y' ]; then
            sudo rm -rf "${CACHE_FILES_PATH}"
        fi
    fi

    BETA_CACHE_FILES_PATH="${HOME}/.cache/google-chrome-beta"
    if [ -e "${BETA_CACHE_FILES_PATH}" ]; then
        question 'Remove old cache files (stable edition) (Y/n)'
        read REMOVE
        if [ "${REMOVE}" == 'y' ] || [ "${REMOVE}" == 'Y' ]; then
            sudo rm -rf "${BETA_CACHE_FILES_PATH}"
        fi
    fi
}
function goto_google_folder {
    if [ ! -e "${GOOGLE_FOLDER_PATH}" ]; then sudo mkdir "${GOOGLE_FOLDER_PATH}"; fi
    if [ -e "${GOOGLE_FOLDER_PATH}" ]; then
        cd "${GOOGLE_FOLDER_PATH}"
        CWD=$(pwd)
        success "Current working directory: ${CWD}"
    else
        fail 'Impossible to continue, Google folder was not created.'
    fi
}
function setup_download_package {
    LATEST_CHROME="https://dl.google.com/linux/direct/google-chrome-${VERSION}_current_${ARCHITECTURE}.deb"
    echo -en "    Downloading configured package \e[0;93m${VERSION}/${ARCHITECTURE}\e[0m... "
    sudo rm -f "${TEMP_PACKAGE}"
    wget --quiet --continue "${LATEST_CHROME}" -O "${TEMP_PACKAGE}"
    success
}
function install_package {
    setup_download_package
    if [ -e "${TEMP_PACKAGE}" ]; then
        echo "    Installing Google Chrome..."
        dpkg --extract "${TEMP_PACKAGE}" "${CHROME_FOLDER_PATH}"
        if [ -e "${CHROME_FOLDER_PATH}" ]; then
            cd "${CHROME_FOLDER_PATH}"
            if [ -e "./opt/google/chrome-beta" ]; then
                mv -i ./opt/google/chrome-beta/* ./
            else
                mv -i ./opt/google/chrome/* ./
            fi
            rm -rf ./etc/ ./opt/ ./usr/
            # Change user owner and permissions of the Chrome Sandbox file.
            sudo chown root:root chrome-sandbox
            sudo chmod 4755 chrome-sandbox
            # Install desktop shortcut to the main menu.
            LAUNCHER_PATH='/opt/google/chrome/google-chrome.desktop';
            echo '[Desktop Entry]' > "${LAUNCHER_PATH}"; # Reset original file.
            echo 'Type=Application' >> "${LAUNCHER_PATH}";
            echo "Name=Google Chrome $(echo $VERSION | tr 'a-z' 'A-Z')" >> "${LAUNCHER_PATH}";
            echo 'Comment=Access the Internet' >> "${LAUNCHER_PATH}";
            echo 'Exec=/opt/google/chrome/google-chrome %U' >> "${LAUNCHER_PATH}";
            echo 'Icon=/opt/google/chrome/product_logo_256.png' >> "${LAUNCHER_PATH}";
            echo 'Categories=Network;' >> "${LAUNCHER_PATH}";
            echo 'MimeType=text/html;text/xml;application/xhtml_xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;' >> "${LAUNCHER_PATH}";
            cd /usr/share/applications/
            sudo rm -f google-chrome.desktop
            sudo ln -s "${LAUNCHER_PATH}";
            # Install Google Chrome binary globally.
            cd /usr/local/bin/
            sudo rm -f google-chrome
            sudo ln -s /opt/google/chrome/google-chrome
            # Finishing
            echo
            success "Package installed in: \e[0;93m${CHROME_FOLDER_PATH}\e[0m"
            success "Press ALT + F2 and type \e[0;93mgoogle-chrome\e[0m"
        else
            fail 'Package installation failed, try again.'
        fi
    else
        fail 'Package download failed, try again.'
    fi
}
#
initialize
request_sudo
stop_current_processes
remove_old_version
goto_google_folder
install_package
#