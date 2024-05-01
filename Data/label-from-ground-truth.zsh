#!/usr/bin/zsh

label-from-ground-truth () {
    local truth_file=groundtruth.log line label_file=labeledtruth.log
    local i=0
    for line in ${(f)"$(tail -n +2 $truth_file)"}
    do
	(( i += 1 ))
	( generate-record $line >> $label_file ) &
	if (( $i % 11 == 0))
	then wait
	fi
    done
}

generate-record () {
    local timestamp ipsrc ipdst trsrc trdst verdict application protocol fields
    local filename record day
    ## Local constants, because I am not using magic numbers here.
    #  Start of Sept 30, 2009, in Unix time
    local DAY1=1254261600
    local DAY2=1254348000
    local DAY3=1254434400
    local END=1254520800
    fields=(${=${${1}//:/ }//;/})
    timestamp=${${fields[1]}%%.*}
    ipsrc=${fields[2]}
    ipdst=${fields[3]}
    trsrc=${fields[4]}
    trdst=${fields[5]}
    verdict=${fields[6]}
    application=${fields[7]}
    protocol=${fields[8]}
    filename=${ipsrc}_${trsrc}_${ipdst}_${trdst}_${timestamp}.pcap
    if [[ $DAY1 -gt $timestamp || $END -lt $timestamp ]]
    then ( >&2 echo "Timestamp outside range" )
	 exit 3
    elif [[ $timestamp -lt $DAY2 ]]
    then day=1
    elif [[ $timestamp -lt $DAY3 ]]
    then day=2
    else day=3
    fi
    
    record="$filename $verdict $application $protocol $timestamp $day"
    echo $record
}

label-from-ground-truth
