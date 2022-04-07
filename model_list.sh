#!/bin/bash
ver="0.9.2-r01"
#
# Made by FOXBI
# 2022.04.07
#
# Synology Model list Library
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
cecho() {
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
# Process Function
# ==============================================================================
echo ""
ACNT=
BCNT=
ARRAY=()
cecho c "Select Synology Model..."
export ACHK=`curl --no-progress-meter https://archive.synology.com/download/Os/DSM | grep noreferrer | awk -Fner\"\> '{print $2}'| egrep -vi "download|os|Parent" | sed "s/<\/a>//g" | egrep "^7" | head -3 \
            | awk -F- '{ if($3 ~ "^[0-9]") {print  $1"-"$2"-"$3} }' | head -1`
while IFS= read -r LINE_A;
do
    ACNT=$(($ACNT + 1))
    BCNT=$(($ACNT%5))
    if [ "$BCNT" -eq "0" ]
    then
        ARRAY+=("$ACNT) $LINE_A\ln");
    else
        ARRAY+=("$ACNT) $LINE_A\lt");
    fi
done < <(curl --no-progress-meter https://archive.synology.com/download/Os/DSM/$ACHK | grep noreferrer | awk -Fner\"\> '{print $2}'| grep "synology_" | sed "s/.pat<\/a>//g" | sed "s/synology_//g" | awk -F_ '{print $2}' | sort -u \
            | awk '{ if($0 ~ "^[0-9]") {print "DS"$0} else { if($0 ~ "^[a-z]") { print $0 } } }' \
            | sed "s/^rs/RS/g" | sed "s/^fs/FS/g" | sed "s/^ds/DS/g" | sed "s/^dva/DVA/g" | sed "s/^rc/RC/g" | sed "s/sa/SA/g" | sed "s/rpxs/RPxs/g" )
echo ""
echo -e " ${ARRAY[@]}" | sed 's/\\ln/\n/g' | sed 's/\\lt/\t/g'
read -n100 -p " -> Select Number Enter : " A_O
echo ""
A_OCHK=`echo $A_O | grep , | wc -l`
if [ "$A_OCHK" -gt "0" ]
then
    while read LINE_B;
    do
        B=$((LINE_B - 1))
        export AMODEL+=`echo "${ARRAY[$B]}" | sed 's/\\\ln//g' | sed 's/\\\lt//g' | awk '{print $2", "}'`
    done < <(echo $A_O | tr ',' '\n')
    AMODEL=`echo ${AMODEL[@]} | sed "s/,$//g"`
else
    A_O=$(($A_O - 1))
    for (( i = 0; i < $ACNT; i++)); do
        if [ "$A_O" == $i ]
        then
            export AMODEL=`echo "${ARRAY[$i]}" | sed 's/\\\ln/ /g' | sed 's/\\\lt/ /g' | awk '{print $2}'`
        fi
    done
fi
echo ""
echo -e "The model name you selected is \033[0;31m"$AMODEL"\033[00m"
echo ""
