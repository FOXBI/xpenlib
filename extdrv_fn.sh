#!/bin/bash
ver="0.9.0-r01"
#
# Made by FOXBI
# 2022.04.14
#
# ==============================================================================
# Y or N Function
# ==============================================================================
READ_YN () { # $1:question $2:default
   read -n1 -p "$1" Y_N
    case "$Y_N" in
    y) Y_N="y"
         echo -e "\n" ;;
    n) Y_N="n"
         echo -e "\n" ;;        
    q) echo -e "\n"
       exit 0 ;;
    *) echo -e "\n" ;;
    esac
}
# ==============================================================================
# Color Function
# ==============================================================================
cecho () {
    if [ -n "$3" ]
    then
        case "$3" in
            black  | bk) bgcolor="40";;
            red    |  r) bgcolor="41";;
            green  |  g) bgcolor="42";;
            yellow |  y) bgcolor="43";;
            blue   |  b) bgcolor="44";;
            purple |  p) bgcolor="45";;
            cyan   |  c) bgcolor="46";;
            gray   | gr) bgcolor="47";;
        esac        
    else
        bgcolor="0"
    fi
    code="\033["
    case "$1" in
        black  | bk) color="${code}${bgcolor};30m";;
        red    |  r) color="${code}${bgcolor};31m";;
        green  |  g) color="${code}${bgcolor};32m";;
        yellow |  y) color="${code}${bgcolor};33m";;
        blue   |  b) color="${code}${bgcolor};34m";;
        purple |  p) color="${code}${bgcolor};35m";;
        cyan   |  c) color="${code}${bgcolor};36m";;
        gray   | gr) color="${code}${bgcolor};37m";;
    esac

    text="$color$2${code}0m"
    echo -e "$text"
}
# ==============================================================================
# Extension Driver Function
# ==============================================================================
EXDRIVER_FN () {
    echo ""    
    cecho r "Add to Driver Repository..."
    echo ""
    READ_YN "Do you want Add Driver? Y/N :  "
    ICHK=$Y_N
    while [ "$ICHK" == "y" ] || [ "$ICHK" == "Y" ]
    do
        ICNT=
        JCNT=
        IRRAY=()
        while read LINE_I;
        do
            ICNT=$(($ICNT + 1))
            JCNT=$(($ICNT%5))
            if [ "$JCNT" -eq "0" ]
            then
                IRRAY+=("$ICNT) $LINE_I\ln");
            else
                IRRAY+=("$ICNT) $LINE_I\lt");
            fi
        done < <(curl --no-progress-meter https://github.com/pocopico/rp-ext | grep "raw.githubusercontent.com" | awk '{print $2}' | awk -F= '{print $2}' | sed "s/\"//g" | awk -F/ '{print $7}')
            echo ""
            echo -e " ${IRRAY[@]}" | sed 's/\\ln/\n/g' | sed 's/\\lt/\t/g'
            echo ""
            read -n100 -p " -> Select Number Enter (To select multiple, separate them with , ): " I_O
            echo ""
            I_OCHK=`echo $I_O | grep , | wc -l`
            if [ "$I_OCHK" -gt "0" ]
            then
                while read LINE_J;
                do
                    j=$((LINE_J - 1))
                    IEXT=`echo "${IRRAY[$j]}" | sed 's/\\\ln//g' | sed 's/\\\lt//g' | awk '{print $2}'`
                    $CURDIR/rploader.sh ext $EVERSION add https://raw.githubusercontent.com/pocopico/rp-ext/master/$IEXT/rpext-index.json
                done < <(echo $I_O | tr ',' '\n')
            else
                I_O=$(($I_O - 1))
                for (( i = 0; i < $ICNT; i++)); do
                    if [ "$I_O" == $i ]
                    then
                        export IEXT=`echo "${IRRAY[$i]}" | sed 's/\\\ln//g' | sed 's/\\\lt//g' | awk '{print $2}'`
                    fi
                done
                $CURDIR/rploader.sh ext $EVERSION add https://raw.githubusercontent.com/pocopico/rp-ext/master/$IEXT/rpext-index.json
            fi
        echo ""
        READ_YN "Do you want add driver? Y/N :  "
        ICHK=$Y_N
    done
}
# ==============================================================================
# Process Function
# ==============================================================================
echo ""
echo -e "Extension Driver Function is \033[0;31m"$EVERSION"\033[00m"
echo ""
EXDRIVER_FN
