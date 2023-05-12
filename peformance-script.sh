#!/bin/bash
 
mkdir -p /mnt/new/
cd /mnt/new/
 
OUTPUT_FILENAME="run_stats.txt"
 
while true; do
  sleep 10
  echo "*********************" >> $OUTPUT_FILENAME
  echo "`date`" >> $OUTPUT_FILENAME
  echo "`top -b -n 1 | head -6`" >> $OUTPUT_FILENAME
  echo "--------- TOP IO PROCS ------------" >> $OUTPUT_FILENAME
  echo "`iotop -P -a -o -b -n 1`" >> $OUTPUT_FILENAME
  echo "--------- TOP MEM PROCS ------------" >> $OUTPUT_FILENAME
  echo "`ps -e -o stat,pid,ppid,user,pcpu,pmem,args,wchan:32,args --sort=-pmem | head -5`" >> $OUTPUT_FILENAME
  echo "--------- TOP CPU PROCS ------------" >> $OUTPUT_FILENAME
  ps -e -o stat,pid,ppid,user,pcpu,pmem,args,wchan:32 --sort=-pcpu | head -15 >> $OUTPUT_FILENAME
  echo "--------- Procs in D state ------------" >> $OUTPUT_FILENAME
  ps -e -o stat,pid,ppid,user,pcpu,cmd,wchan:32 --sort=stat | grep "^D" >> $OUTPUT_FILENAME
  echo "--------- memory of individual process time ------------" >> $OUTPUT_FILENAME
  ps -eo size,pid,user,command --sort -size |awk '{ hr=$1/1024 ; printf("%13.2f Mb ",hr) } { for ( x=4 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }' |cut -d "" -f2  >> $OUTPUT_FILENAME
  echo "--------- N/W Info state ------------" >> $OUTPUT_FILENAME
  ifconfig >> $OUTPUT_FILENAME
  echo "--------- Netstat ------------" >> $OUTPUT_FILENAME
  netstat -tnp | sort -t: -k2 -n >> $OUTPUT_FILENAME
  echo "--------- ss ------------" >> $OUTPUT_FILENAME
  ss -s >> $OUTPUT_FILENAME
  echo "--------- vmstat ------------" >> $OUTPUT_FILENAME
  vmstat -w -S M >> $OUTPUT_FILENAME
  echo "--------- vmstat disk ------------" >> $OUTPUT_FILENAME
  vmstat -d >> $OUTPUT_FILENAME
  echo "--------- sar disk ------------" >> $OUTPUT_FILENAME
  sar -d -p 5 2 >> $OUTPUT_FILENAME
  echo "--------- sar cpu ------------" >> $OUTPUT_FILENAME
  sar -P ALL 5 1 >> $OUTPUT_FILENAME
  echo "--------- done time ------------" >> $OUTPUT_FILENAME
  echo "`date`" >> $OUTPUT_FILENAME
 
  size="$(stat --format=%s $OUTPUT_FILENAME)"
  #if file is greater than 500mb tar gzip it
  if [ $size -gt 500000000 ]
  then
    if [ -f run_stats.tar.gz ]
    then
      #cp --force --backup=numbered run_stats.tar.gz run_stats.tar.gz
      rm run_stats.tar.gz
    fi
    tar -czf run_stats.tar.gz run_stats.txt
    rm run_stats.txt
    touch run_stats.txt
  fi
done
