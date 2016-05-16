#!/bin/bash

if [[ -z $1 ]]
then
    exit 0
fi

if [[ ! -f $1 ]]
then
    exit 0
fi

CONFIG_FILE=~/.read_config

FILE_NAME=$1

MD5_FILE_NAME=$(echo -n $FILE_NAME | md5)

read_config()
{
    READ_CONFIG=""
    if [[ -f $CONFIG_FILE ]]
    then
        READ_CONFIG=$(cat ~/.read_config)
    else
        READ_CONFIG="{}"
    fi
    echo $READ_CONFIG
}

read_line()
{
    KEY=$1
    CONFIG_CONTENT=$(read_config)
    LINE_NUMBER="$(echo $(read_config) | jq ".\"${KEY}\"")"
    
    if [[ $LINE_NUMBER -eq null ]]
    then
        LINE_NUMBER=1
    fi

    echo $LINE_NUMBER
}

write_line()
{
    KEY=$1
    LINE_NUMBER=$2
    #echo $(echo $(read_config) | jq ".${KEY} = ${LINE_NUMBER}") > $CONFIG_FILE
    NEW_CONFIG=$(echo $(read_config) | jq ".\"${KEY}\" = ${LINE_NUMBER}")
    echo $NEW_CONFIG > $CONFIG_FILE
}

LINE=$(read_line ${MD5_FILE_NAME})
IFS=$'\n'
trap "exit" INT
for line in $(sed "${LINE},\$!d" $FILE_NAME)
do
    echo $LINE : $line
    echo $line | say
    ((LINE++))
    write_line $MD5_FILE_NAME $LINE
done

