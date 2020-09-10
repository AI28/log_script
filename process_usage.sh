#!/bin/bash

logs=('process' 'disk' 'memory' 'load')

create_file(){
    file="$1.log"
    if [[ -f $file ]];
    then
        echo "file exists."
    else
        touch "/var/log/systemusage/$file"
    fi 
}
process_logs(){
    create_file $1
    `ps -aux --sort=-pcpu | head -n 6 | awk {'print $11, $2, $3'} > /var/log/systemusage/process.log` 

}

disk_logs(){
    create_file $1
    `df | awk '{print $1, $5, $6}' > /var/log/systemusage/disk.log`
}

memory_logs(){
    create_file $1
    date=`date | awk '{print $3, $2, $6, $4}' `
    mem_usage=`free | grep "Mem" | awk '{print $2, $3, $4, $5, $6}'`
    `echo "$date $mem_usage" > /var/log/systemusage/memory.log`
}

load_logs(){
    create_file $1
    loadavg=`cut -d" " -f 1,2,3 /proc/loadavg`
    date=`date | awk '{print $3, $2, $6, $4}'`
    `echo "$date $loadavg" > /var/log/systemusage/load.log`
}

get_logs(){
    case $1 in
        process)
           process_logs "process" 
           ;;
        disk)
            disk_logs "disk"
            ;;
        memory)
            memory_logs "memory"
            ;;
        load)
            load_logs "load"
            ;;
        *)
            echo "Please enter a valid argument."
            echo "$1"
            ;;
    esac

}


for t in ${logs[@]};
do
    get_logs $t
done