#!/bin/bash

trap 'rm -f -- ${tmpfile}; exit' INT

log_ssh_connection () {
  pid="$1"
  wfd="[0-9]"
  rfd="[0-9]"
  strace -e read,write -xx -s 9999999 -p ${pid} 2>&1 | while read -r a; do
    if [[ "${a:0:10}" =~ ^write\(${wfd}, ]] \
    && [ ${#wfd} -le 3 ] \
    && ! [[ "$a" =~ \ =\ 1$ ]]; then
        echo -en "`cut -d'"' -f2 <<<${a}`" | sed "s@\\\\@@g" >> log1.txt
    elif [[ "${a:0:10}" =~ ^read\(${rfd}, ]] \
    && [ ${#rfd} -le 3 ]; then
        echo -en "`cut -d'"' -f2 <<<${a}`" | sed "s@\\\\@@g" >> log1.txt
    elif [[ "$a" =~ ^read\((${rfd}+),.*\ =\ [1-9]$ ]]; then
        fd="${BASH_REMATCH[1]}"
        if [[ "$a" =~ \ =\ 1$ ]]; then
          rfd="$fd"
        fi
    elif [[ "${a:0:10}" =~ ^write\((${wfd}+), ]] \
    && [ ${#wfd} -gt 4 ]; then
        fd="${BASH_REMATCH[1]}"
        if [[ "${a}" =~ \\x00 ]]; then continue; fi
        if [[ "${a}" =~ \ =\ 1$ ]] || [[ "${a}" =~ \"\\x0d\\x0a ]]; then
          wfd="$fd"
        fi
    fi
  done
  echo ">> SSH session ($opt) closed"
  exit 0
}


tmpfile="/tmp/$RANDOM$$$RANDOM"
pgrep -a -f '^ssh ' | while read pid a; do echo "OUTBOUND $a $pid"; done >${tmpfile}
pgrep -a -f '^sshd: .*@' | while read pid a; do
  tty="${a##*@}"
  from="`w | grep ${tty} | awk '{print $3}'`"
  echo "INBOUND $a (from $from) $pid"
done >>${tmpfile}

echo -en "The following shell sessions (pid) will be monitored:\n" >> activeLogs.txt

while read opt; do 
    
    pid="${opt##* }"
    
    if grep -R "$pid" activeLogs.txt
    then
        continue
    fi

    echo "Logging $opt"

    echo -en "$pid" >> activeLogs.txt
    log_ssh_connection "$pid"
done < "$tmpfile"
