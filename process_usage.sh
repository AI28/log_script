#!/bin/bash

date=`date | awk '{print $3, $2, $6, $4}'`
declare -A to_be_logged=([process]=0 [memory]=0 [disk]=0 [load]=0)

create_file(){
    if [[ -f $file ]];
    then
        echo "file exists."
    else
        touch $1
    fi 
}

#to do == implementare cu top
process_logs(){
    create_file $1
    echo $date>>$1
    ps -aux --sort=-pcpu | head -n 6 | tail -n 5 | awk {'print $11, $2, $3'} >> $1
}

disk_logs(){
    create_file $1
    echo $date>>$1 
    df | tail -n +2 | awk '{print $1, $5, $6}' >> $1
}

memory_logs(){
    create_file $1 
    mem_usage=`free | grep "Mem" | awk '{print $2, $3, $4, $5, $6}'`
    echo "$date $mem_usage" >> $1
}

load_logs(){
    create_file $1 
    loadavg=`cut -d" " -f 1,2,3 /proc/loadavg`
    echo "$date $loadavg" >> $1
}

get_logs(){
    case $1 in
        process)
           process_logs "$2/process.log"
           ;;
        disk)
            disk_logs "$2/disk.log" 
            ;;
        memory)
            memory_logs "$2/memory.log" 
            ;;
        load)
            load_logs "$2/load.log" 
            ;;
        *)
            echo "Please enter a valid argument."
            echo "$1"
            ;;
    esac
}


while getopts 'pmdl' c
do
    case $c in
        p)  to_be_logged[process]=1 ;; 
        d)  to_be_logged[disk]=1 ;;
        m)  to_be_logged[memory]=1 ;;
        l)  to_be_logged[load]=1 ;;
    esac
done

number_of_opts=$(($#-1))
shift $number_of_opts

for key in "${!to_be_logged[@]}";
do
    if [[ ${to_be_logged[$key]} == 1 ]];
    then
        get_logs $key $1
    fi
done