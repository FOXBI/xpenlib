#!/bin/bash
ver="2.2.0-r01"
#
# Made by FOXBI
# 2023.02.11
#
# Synology cpuinfo-core/Threads/Generation/Link Library
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
cpu_vendor_chk=`cat /proc/cpuinfo | grep model | grep name | sort -u | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/CPU//g" | grep AMD | wc -l`
if [ "$cpu_vendor_chk" -gt "0" ]
then
    cpu_vendor="AMD"
else
    cpu_vendor_chk=`cat /proc/cpuinfo | grep model | grep name | sort -u | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/CPU//g" | grep Intel | wc -l`
    if [ "$cpu_vendor_chk" -gt "0" ]
    then
        cpu_vendor="Intel"
    else    
        cpu_vendor=`cat /proc/cpuinfo | grep Hardware | sort -u | awk '{print $3}' | head -1`
        if [ -z "$cpu_vendor" ]
        then
            cpu_vendor=`cat /proc/cpuinfo grep model | grep name | sort -u | awk '{print $3}' | head -1`
        fi
    fi
fi
if [ "$cpu_vendor" == "AMD" ]
then
    cpu_series=`cat /proc/cpuinfo | grep model | grep name | sort -u | awk -F: '{print $2}' | sed "s/^\s*AMD//g" | sed "s/^\s//g" | head -1 | awk '{ for(i = NF; i > 1; i--) if ($i ~ /^[0-9]/) { for(j=i;j<=NF;j++)printf("%s ", $j);print("\n");break; }}' | sed "s/ *$//g"`
    cpu_family=`cat /proc/cpuinfo | grep model | grep name | sort -u | awk -F: '{print $2}' | sed "s/^\s*AMD//g" | sed "s/^\s//g" | head -1 | awk -F"$cpu_series" '{print $1}' | sed "s/ *$//g"`
elif [ "$cpu_vendor" == "Intel" ]
then
    cpu_family=`cat /proc/cpuinfo | grep model | grep name | sort -u | awk '{ for(i = 1; i < NF; i++) if ($i ~ /^Intel/) { for(j=i;j<=NF;j++)printf("%s ", $j);printf("\n") }}' | awk -F@ '{ print $1 }' | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/ CPU//g" | awk '{print $2}' | head -1 | sed "s/ *$//g"`
    cpu_series=`cat /proc/cpuinfo | grep model | grep name | sort -u | awk '{ for(i = 1; i < NF; i++) if ($i ~ /^Intel/) { for(j=i;j<=NF;j++)printf("%s ", $j);printf("\n") }}' | awk -F@ '{ print $1 }' | sed "s/(.)//g" | sed "s/(..)//g" | sed "s/ CPU//g" | awk -F"$cpu_family " '{print $2}' | head -1 | sed "s/ *$//g"`
    if [ -z "$cpu_series" ]
    then
        cpu_series="Unknown"
    fi
    if [ "$cpu_family" == "Pentium" ]
    then
        cpu_series_b="$cpu_series"
        cpu_series="$cpu_family $cpu_series"
    else
        m_chk=`echo "$cpu_series" | grep -wi ".* M .*" | wc -l`
        if [ "$m_chk" -gt 0 ]
        then
            cpu_series=`echo "$cpu_series" | sed "s/ M /-/g" | awk '{print $0"M"}'`
        fi
    fi
else    
    cpu_family=`cat /proc/cpuinfo | grep model | grep name | sort -u | awk -F: '{print $2}' | sed "s/^\s*$cpu_vendor//g" | sed "s/^\s//g" | head -1`
    cpu_series=""    
fi        
if [ "$cpu_vendor" == "Intel" ]
then
    if [ "$cpu_series" == "ES" ] || [ "$cpu_series" == "Unkown" ]
    then
        cpu_detail="https://ark.intel.com/content/www/us/en/ark.html"
    else
        cpu_search="https://ark.intel.com/content/www/us/en/ark/search.html?_charset_=UTF-8&q=$cpu_series"
        temp_file="/tmp/cpu_info_temp_url.txt"
        wget -q -O $temp_file "$cpu_search"
        url_cnt=`cat $temp_file | grep "FormRedirectUrl" | grep "hidden" | wc -l`
        if [ "$url_cnt" -gt 0 ]
        then
            gen_url=`cat $temp_file | grep "FormRedirectUrl" | grep "hidden" | awk -F"value" '{print $2}' | awk -F\" '{print $2}'`
        else
            gen_url=`cat $temp_file | grep -wi "$cpu_series" | grep "href" | awk -F"href" '{print $2}' | awk -F\" '{print $2}'`
            if [ "$cpu_family" == "Pentium" ]
            then
                chg_series=`echo $cpu_series | awk '{print "\\\-"$1"\\\-"$2"\\\-"}'`
                gen_url=`cat $temp_file | grep -i "$chg_series" | grep "href" | awk -F"href" '{print $2}' | awk -F\" '{print $2}' | head -1`
                cpu_series="$cpu_series_b"
            fi            
            if [ -z "$gen_url" ]
            then
                chg_series=`echo $cpu_series | awk '{print "\\\-"$1".*"$2"\\\-"}'`
                gen_url=`cat $temp_file | grep -i "$chg_series" | grep "href" | awk -F"href" '{print $2}' | awk -F\" '{print $2}' | head -1`
            fi
        fi
        cpu_detail="https://ark.intel.com$gen_url"
        cpu_gen=`curl --silent "$cpu_detail" | grep "Products formerly" | awk -F"Products formerly " '{print $2}' | sed "s/<\/a>//g"`
    fi
elif [ "$cpu_vendor" == "AMD" ]
then
    cpu_search=`echo "$cpu_series" | awk '{print $1" "$2}'`
    gen_url=`curl --silent -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" http://stackoverflow.com/questions/28760694/how-to-use-curl-to-get-a-get-request-exactly-same-as-using-chrome \
                https://www.amd.com/en/products/specifications/processors | grep -wi "$cpu_search" | awk -F"views-field" '{print $1}' | awk -F"entity-" '{print $2}'`
    if [ -z "$gen_url" ]
    then
        chg_series=`echo $cpu_series | awk '{print $1}'`
        gen_url=`curl --silent -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" http://stackoverflow.com/questions/28760694/how-to-use-curl-to-get-a-get-request-exactly-same-as-using-chrome \
                https://www.amd.com/en/products/specifications/processors | grep -wi "$chg_series" | awk -F"views-field" '{print $1}' | awk -F"entity-" '{print $2}'`
    fi
    cpu_detail="https://www.amd.com/en/product/$gen_url"
    cpu_gen=`curl --silent -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" http://stackoverflow.com/questions/28760694/how-to-use-curl-to-get-a-get-request-exactly-same-as-using-chrome \
             $cpu_detail | egrep -A 2 -w ">Former Codename<|>Architecture<" | grep "field__item" | sed "s/&quot;/\"/g" | awk -F\"\>\" '{print $2}' | awk -F\" '{print $1}' | tr "\n" "| " | awk -F\| '{if($2=="") {print $1} else {print $1" | " $2}}'`
else
    cpu_detail=""
fi
cpu_ghz=`cat /proc/cpuinfo | grep MHz | sort -u | awk '{print $4}' | awk -F. '{printf "%0.1f", $1/1000}'`

PICNT=`cat /proc/cpuinfo | grep "^physical id" | sort -u | wc -l`
CICNT=`cat /proc/cpuinfo | grep "^core id" | sort -u | wc -l`
CCCNT=`cat /proc/cpuinfo | grep "^cpu cores" | sort -u | awk '{print $NF}'`
CSCNT=`cat /proc/cpuinfo | grep "^siblings" | sort -u | awk '{print $NF}'`
THCNT=`cat /proc/cpuinfo | grep "^processor" | wc -l`
ODCNT=`cat /proc/cpuinfo | grep "processor" | wc -l`
if [ "$THCNT" -gt "0" ] && [ "$PICNT" == "0" ] && [ "$CICNT" == "0" ] && [ "$CCCNT" == "" ] && [ "$CSCNT" == "" ]
then
    PICNT="1"
    CICNT="$THCNT"
    CCCNT="$THCNT"
    CSCNT="$THCNT"
fi
if [ "$PICNT" -gt "1" ]
then
    TPCNT="$PICNT CPUs"
    TCCNT=`expr $PICNT \* $CCCNT`
else
    TPCNT="$PICNT CPU"
    TCCNT="$CCCNT"
fi
if [ "$TCCNT" -gt "1" ]
then
    TCCNT="$TCCNT Cores "
else
    TCCNT="$TCCNT Core "
fi
if [ "$CCCNT" -gt "1" ]
then
    PCCNT="/$CCCNT Cores "
else
    PCCNT=" "
fi    
if [ "$THCNT" -gt "1" ]
then
    TTCNT="$THCNT Threads"
else
    TTCNT="$THCNT Thread"
fi
cpu_cores="$TCCNT($TPCNT$PCCNT| $TTCNT)"
echo ""
echo -e "CPU information : "$cpu_vendor" "$cpu_family" "$cpu_series" "$cpu_ghz"0GHz"
echo -e "CPU core-thread : "$cpu_cores
echo -e "CPU link : "$cpu_detail
echo -e "CPU Generation : "$cpu_gen
echo ""
