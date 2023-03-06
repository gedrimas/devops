#!/bin/bash

DB="../data/users.db"

validate_user_input() {
  case $1 in
    name) while :
            do
	      [[ $user =~ ^[a-zA-Z]+$ ]] && break
              read -p "Only Latin letters are allowed for user name: " user
            done;;
    role) while :
            do
	      [[ $role =~ ^[a-zA-Z]+$ ]] && break
              read -p "Only Latin letters are allowed for user role: " role
            done;;
  esac
}

check_db() {
  if [ ! -f "$1" ]; then
      echo "DB does not exist"
      create_db
  fi
}

create_db() {
  echo "Create users.db file?"
  select answer in "yes" "no"
  do
    case $answer in
      yes) cd "../data" && touch users.db; break;;
      no) echo "Good bay"; exit;;
    esac
  done
}

add_user() {
  check_db $DB
  read -p "Please enter new user name: " user
  validate_user_input "name"
  read -p "Provide the user role: " role
  validate_user_input "role"
  echo "_${user}_, _${role}_" >> ../data/users.db
}

backup_db() {
  current_date=$(date +%Y-%m-%d)
  cp $DB "../data/${current_date}-users.db.backup"
}

restore() {
  latest_backup=$(find ../data -regex '.*backup' -printf '%T@ %p\n' | sort -n | tail -1 | cut -d" " -f2- )
  echo "last backup: ${latest_backup}"
  if [ -f $latest_backup ]; then
	cat "$latest_backup" > "$DB"
  else
	echo "No backup file found"
  fi
}

find_user(){
  read -p "Please enter user name: " username
  grep "${username}_," $DB || echo "User not found" 
}

inverse_option=$2
list_all_users(){
  if [[ $inverse_option = "--inverse" ]]; then
    sed 's/_//g' $DB | nl -s '. ' | tac
  else
    sed 's/_//g' $DB | nl -s '. '
  fi
}

help(){
echo ./db.sh add - add new user
echo ./db.sh backup - create the DB backup based on users.db file
echo ./db.sh find - find user by name
echo ./db.sh list - list all users, --inverse option lists users using 'in' back order
echo ./db.sh restore - recriate users.db using last backup
echo ./db.sh help - show how to use
}

case $1 in
  add) add_user;;
  help) help; check_db $DB;;
  backup) backup_db;;
  restore) restore;;
  find) find_user;;
  list) list_all_users;;
  *) check_db $DB;;
esac

