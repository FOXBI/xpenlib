#!/bin/bash
ver="0.9.2-r01"
#
# Made by FOXBI
# 2022.03.28
#
# Synology latest version platform match Library
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
ACHK=`curl --no-progress-meter https://archive.synology.com/download/Os/DSM | grep noreferrer | awk -Fner\"\> '{print $2}'| egrep -vi "download|os|Parent" | sed "s/<\/a>//g" | egrep "^7" | head -3 \
      | awk -F- '{ if($3 ~ "^[0-9]") {print  $1"-"$2"-"$3} }' | head -1`
AMODEL="DS920+"
echo ""
cecho c "Platform Match...."
if [[ "$AMODEL" =~ ^"DS" ]]
then
    BMODEL=`echo $AMODEL | cut -c 3- | tr '[A-Z]' '[a-z]'`
    BMODEL=`echo "_"$BMODEL"\."`
else
    BMODEL=`echo $AMODEL | tr '[A-Z]' '[a-z]'`
    BMODEL=`echo $BMODEL"\."`
fi
ECHK=`curl --no-progress-meter https://archive.synology.com/download/Os/DSM | grep noreferrer | awk -Fner\"\> '{print $2}'| egrep -vi "download|os|Parent" | sed "s/<\/a>//g" | egrep "^7" | head -1 | awk -F- '{print $1"-"$2}'`
FCHK=`echo $ACHK | awk -F- '{print $1"-"$2}'`
if [ "$CVERSION" == "$FCHK" ]
then
    ECHK=`echo $FCHK`
else
    ECHK=`echo $ECHK`
fi

EPLAT=`curl --no-progress-meter https://archive.synology.com/download/Os/DSM/$ACHK | grep noreferrer | awk -Fner\"\> '{print $2}'| grep "synology_" | sed "s/pat<\/a>//g" | sed "s/synology_//g" | grep -i "$BMODEL" | awk -F_ '{print $1}' | sed "s/$.//g"`
EVERSION=`echo $EPLAT"-"$ECHK`

echo ""
echo -e "The Platfor match is \033[0;31m"$EVERSION"\033[00m"
echo ""
