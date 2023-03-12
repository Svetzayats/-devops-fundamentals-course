#!/bin/bash

dbName=users.db
dbDir=data/
dbPath="${dbDir}${dbName}"
backupDir="${dbDir}backups/"
noBackupMessage="No backup files found"
emptyDbMessage="No added members in db"

#checking functions 

checkDir() {
    if [ ! -d $1 ]
    then 
        if [ $2 ]
        then mkdir $1
        else echo $noBackupMessage; exit
        fi
    fi
}

checkDbFile() {
    if [ ! -f $dbPath ]
    then 
        echo "There is no database yet. Create datadase? :"
        select answer in "Yes" "No"; do
            case $answer in
                Yes) checkDir $dbDir 0; touch $dbPath; break;;
                No) exit;;
            esac
        done
    fi
}

validation() {
    if [[ $1 =~ ^[A-Za-z_]+$ ]]
    then return 0;
    else 
        echo "$2 must contains lattin letters only. Please try again."
        return 1;
    fi
}

#help 

help() {
    echo
    echo "Script works with database."
    echo "db.sh [command] [optional param]"
    echo
    echo "List of commands:"
    echo 
    echo "add"
    echo "Adds a new line to the user.db. Username (latin letters only) + role"
    echo
    echo "backup"
    echo "Create backup - file with copy of current users.db"
    echo
    echo "restore"
    echo "Replace users.db by latest backup if it exists"
    echo
    echo "find"
    echo "Search and print user by provided name"
    echo
    echo "list"
    echo "Show records from users.db. In case of --inverse param results are showed in opposit order" 
}

# user interactions 

add() {
    checkDbFile
    while true
    do
        read -p "Enter user name: " username
        validation $username "Name"
        if [[ $? == 0 ]]; then break; fi
    done

    while true
    do
        read -p  "Enter ${username} role: " role
        validation $role "Role"
        if [[ $? == 0  ]]; then break; fi
    done
    echo "${username}, ${role}" >> $dbPath 
    echo "User ${username} with role ${role} was succesfully added in the database."    
}

list() {
    checkDbFile
    if [ -s $dbPath ] 
    then
    	if [[ $1 == --inverse ]]
	then cat -n $dbPath | tac
	else cat -n $dbPath
	fi
    else echo $emptyDbMessage
    fi
    
}

find(){
    read -p "Enter user name for search: "  searchTerm
    result=$(grep -i -n -w  "${searchTerm}," $dbPath)
    if [[ -z $result ]]
    then
        echo "User not found"
    else 
        echo $result
    fi
}
    
# backup actions

backup() {
    checkDbFile
    checkDir $backupDir 0
    cat $dbPath > "${backupDir}%$(date +%F)%-${dbName}.backup"
    echo "Database backup was successfully created $(date +%F)"
}

restore() {
    checkDbFile
    checkDir $backupDir
    latest=$(ls $backupDir -At | head -1)
    if [ latest ]
    then
        cat $backupDir$latest > $dbPath
        echo "Database was restored with ${latest}"
     else echo $noBackupMessage
     fi
}

case $1 in
    add) add;;
    backup) backup;;
    restore) restore;;
    find) find;;
    list) list $2;;
    help | '' | *)  help;;
esac
