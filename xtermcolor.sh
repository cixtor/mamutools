#!/bin/bash
#
# X-Term Color
# http://cixtor.com/
# https://github.com/cixtor/mamutools
# http://en.wikipedia.org/wiki/ANSI_escape_code
#
# In computing, ANSI escape code (or escape sequences) is the method of in-band
# signaling to control formatting, color, and other output options on video text
# terminals. To encode this formatting information, it embeds certain sequences
# of bytes into the text, which have to be interpreted specially, not as codes of
# characters. Although hardware text terminals become increasingly rare in the
# 21st century, the relevance of this standard persists because most terminal
# emulators interpret at least some of the ANSI escape sequences in the output
# text. One notable exception is the win32 console component of Microsoft Windows.
#
# Most terminal emulators running on Unix-like systems (such as xterm and the OS
# X Terminal) interpret ANSI escape sequences. The Linux console (the text seen
# when X is not running) also interprets them. Terminal programs for Microsoft
# Windows designed to show text from an outside source (a serial port, modem, or
# socket) also interpret them. Some support for text from local programs on Windows
# is offered through alternate command processors such as JP Software's TCC (formerly
# 4NT), Michael J. Mefford's ANSI.COM, and Jason Hood's ansicon.
#
# Many Unix console applications (e.g., ls, grep, Vim, and Emacs) can generate them.
# Utility programs such as tput output them, as well as in low-level programming
# libraries, such as termcap or terminfo, or a higher-level library such as curses.
#
echo 'X-Term Color'
echo '  http://cixtor.com/'
echo '  https://github.com/cixtor/mamutools'
echo '  http://en.wikipedia.org/wiki/ANSI_escape_code'
echo
if [ "$1" == "basic" ]; then
    for(( i=0; i<110; i+=3 )); do
        if [ $i -gt 11 ] && [ $i -lt 30 ]; then continue; fi

        if [ $i -gt 50 ] && [ $i -lt 90 ]; then continue; fi

        a=$i
        b=$(( $i+1 ))
        c=$(( $i+2 ))

        if   [ $a -lt 10  ]; then a_indent="  ";
        elif [ $a -lt 100 ]; then a_indent=" ";
        else a_indent=""
        fi

        if   [ $b -lt 10  ]; then b_indent="  ";
        elif [ $b -lt 100 ]; then b_indent=" ";
        else b_indent=""
        fi

        if   [ $c -lt 10  ]; then c_indent="  ";
        elif [ $c -lt 100 ]; then c_indent=" ";
        else c_indent=""
        fi

        echo -ne "${a_indent}[0;${a}m => \e[0;${a}mHello world\e[0m   ";
        echo -ne "${b_indent}[0;${b}m => \e[0;${b}mHello world\e[0m   ";
        echo -e  "${c_indent}[0;${c}m => \e[0;${c}mHello world\e[0m";
    done
elif [ "$1" == "palette" ]; then
    for c in $(seq 0 255);do
        t=5;
        for i in $(seq $t 5); do
            CONTENT=$(seq -s+0 $((40)) | tr -d '[0-9]')
            echo -e "\e[0;48;$i;${c}m$i:$c $CONTENT\e[0m";
        done;
    done
else
    echo "Usage: $0 [basic|palette]";
fi
#