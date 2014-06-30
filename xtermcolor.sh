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

action="${1}"
boldness="${2}"

function usage {
    echo 'X-Term Color'
    echo '  http://cixtor.com/'
    echo '  https://github.com/cixtor/mamutools'
    echo '  http://en.wikipedia.org/wiki/ANSI_escape_code'
    echo 'Usage:'
    echo "  $0 basic [clear]"
    echo "  $0 basic [bold]"
    echo "  $0 cubes [clear]"
    echo "  $0 cubes [bold]"
    echo "  $0 palette"
    echo "  $0 verbose"
    exit 1
}

if [ "${action}" == "" ]; then
    usage
elif [ "${action}" == "basic" ]; then
    if [ "${boldness}" == "bold" ]; then boldnum=1; else boldnum=0; fi

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

        echo -ne "${a_indent}[0;${a}m : \e[${boldnum};${a}mHello world\e[0m   ";
        echo -ne "${b_indent}[0;${b}m : \e[${boldnum};${b}mHello world\e[0m   ";
        echo -e  "${c_indent}[0;${c}m : \e[${boldnum};${c}mHello world\e[0m";
    done
elif [ "${action}" == "cubes" ]; then
    function render_cube {
        combo=$1
        rgb_seq=$(seq 0 5)
        if [ "${boldness}" == "clear" ]; then fgbg=38; else fgbg=48; fi

        for x in $rgb_seq; do
            for y in $rgb_seq; do
                for z in $rgb_seq; do
                      if [ "${combo}" == "rgb" ]; then r=$x; g=$y; b=$z;
                    elif [ "${combo}" == "rbg" ]; then r=$x; g=$z; b=$y;
                    elif [ "${combo}" == "grb" ]; then r=$y; g=$x; b=$z;
                    elif [ "${combo}" == "gbr" ]; then r=$y; g=$z; b=$x;
                    elif [ "${combo}" == "brg" ]; then r=$z; g=$x; b=$y;
                    elif [ "${combo}" == "bgr" ]; then r=$z; g=$y; b=$x;
                    else r=0; g=0; b=0;
                      fi

                    color=$(( 16 + $r * 36 + $g * 6 + $b ))
                    echo -en "\e[${fgbg};5;${color}m::"
                done
                echo -en "\e[0m "
            done
            echo
        done
    }

    for combination in rgb bgr gbr grb rbg brg; do
        echo "Color cube (${combination}):"
        render_cube "${combination}"
    done
elif [ "${action}" == "palette" ]; then
    for c in $(seq 0 255);do
        CONTENT='::::::::::'
        if   [ $c -lt 10  ]; then d="00${c}";
        elif [ $c -lt 100 ]; then d="0${c}";
        else d="${c}";
        fi
        echo -e "\e[0;48;5;${c}m${d} $CONTENT\e[0m";
    done
elif [ "${action}" == "verbose" ]; then
    # System colors
    for fgbg in 38 48; do
        echo "System colors (${fgbg};5;0..15):"

        for color in {0..15}; do
            echo -en "\e[${fgbg};5;${color}m::\e[0m"

            if [ $color -eq 7 ] || [ $color -eq 15 ]; then echo; fi
        done

        echo
    done

    # Color cubes
    for fgbg in 38 48; do
        echo "Color cube (6x6):"
        rgb_seq=$(seq 0 5)

        for g in $rgb_seq; do
            for r in $rgb_seq; do
                for b in $rgb_seq; do
                    color=$(( 16 + $r * 36 + $g * 6 + $b ))
                    echo -en "\e[${fgbg};5;${color}m::"
                done
                echo -en "\e[0m "
            done
            echo
        done

        echo
    done

    # Grayscale ramp
    echo "Grayscale ramp:"

    for fgbg in 38 48; do
        for color in {232..255}; do
            echo -en "\e[${fgbg};5;${color}m::\e[0m"
        done
        echo
    done
else
    usage
fi
