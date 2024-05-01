#!/usr/bin/zsh

TRAPINT () {
    rm -v /tmp/csv.* movedata.txt
    return 130
}

generate-samples () {
    local labeled_file_list=$1 line
    local i=0
    for line in ${(f)"$(cat $labeled_file_list)"}
    do  (( i += 1 ))
	(process-file $line) &
	if (( $i % 4 == 0 ))
	then wait
	fi

	if (( $i % 16 == 0 ))
	then process-waiting-files
	fi
    done
    wait
    process-waiting-files
}

process-waiting-files () {
    local movedatafile="movedata.txt"
    local line fields timestamp tempdatafile samplepath endfile
    for line in ${(f)"$(cat $movedatafile | sort -n)"}
    do fields=(${=${line}})
       tempdatafile=${fields[2]}
       samplepath=${fields[3]}
       cp $tempdatafile $samplepath
    done
    rm /tmp/csv.*
    rm $movedatafile
}



process-file () {
    local filename prot1 prot2 application day timestamp
    local fields result fullfilename
    local typefolder dir
    local movedatafile="movedata.txt" tempdatafile
    fields=(${=${line}})
    filename=${fields[1]}
    prot1=${fields[2]}
    application=${fields[3]}
    prot2=${fields[4]}
    timestamp=${fields[5]}
    day=${fields[6]}
    result=$(classify-flow $prot1 $application)
    case $result in
	("MAIL") dir="mail";;
	("CHAT") dir="chat" ;;
	("BROWSING")  dir="browse" ;;
	("P2P") dir="p2p" ;;
	("N/A") dir="other" ;;
	("*") ( >&2 echo "Internal error" ); exit 3;;
    esac

    if [[ $prot2 == "TCP" ]]
    then typefolder="tcp"
    else typefolder="udp"
    fi
    

    fullfilename=$(print -C 1 */$typefolder*/$filename)
    if [[ -n $fullfilename ]]
    then tempdatafile=$(mktemp -p /tmp "csv.XXXXXXXXX")
	 ./scapy_statistics.py $fullfilename >> $tempdatafile
	 echo "$timestamp $tempdatafile $dir/$filename" >> $movedatafile
	 echo "Wrote data for $fullfilename"
    else echo "Null file: $filename"
    fi
}


classify-flow () {
    local prot=$1 application=$2
    if [[ ($application == "bittorrent" || $application == "bittorrent.exe" || $application == "amule" \
	  || $application == "Transmission") && ($prot == "edonkey" || $prot == "bittorrent" ) ]]
    then echo "P2P"
    elif [[ ($prot == "pop3" || $prot == "smtp" || $prot == "imap" \
		 || $prot == "ssl" || $prot == "http" || $prot == "https")
		&& ( $application == "thunderbird-bin" || $application == "thunderbird.exe" \
			 || $application == "Mail") ]]
    then echo "MAIL"
	  elif [[ ($prot == "http" || $prot == "https")
                    && ($application == "firefox" || $application == "firefox-bin" \
			     || $application == "firefox.exe" \
	                     || $application  == "Safari") ]]
    then echo "BROWSING"
	  elif [[ ($application == "Skype" || $application == "skype" \
		       || $application == "Skype.exe" || $application == "msmsgs.exe")
                  && ($prot == "msn" || $prot == "skype") ]]
    then echo "CHAT"
    else echo "N/A"
    fi

}

mkdir -p mail chat browse p2p other
generate-samples "$@"
