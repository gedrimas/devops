#!/bin/bash

DB="../data/users.db"

validate_user_input() {
  case $1 in
    name) while ! [[ $user =~ [a-zA-z] ]]
            do
              read -p "Only Latin letters are allowed for user name: " user
            done;;
    role) while ! [[ $role =~ [a-zA-z] ]]
            do
              read -p "Only Latin letters are allowed for user role: " role
            done;;
  esac
}

check_db() {
  if ! [ -e "$1" ]; then
      echo "DB does not exist"
      create_db $1
  fi
}

create_db() {
  echo "Create users.db file?"
  select answer in "yes" "no"
  do
    case $answer in
      yes) touch $1; break;;
      no) echo "Good bay"; exit;;
    esac
  done
}

add_user() {
  check_db $DB
  read -p "Please enter new user name: " user
  validate_user_input "name" $user
  read -p "Provide the user role: " role
  validate_user_input "role" $role
  echo "_${user}_, _${role}_" >> ../data/users.db
}

backup_db() {
  current_date=$(date +%Y-%m-%d)
  cp $DB "../data/${current_date}-users.db.backup"
}

restore() {
  latest_backup=$(ls ../data -t)
  echo "${latest_backup}"
}


case $1 in
  add) add_user;;
  help) echo "Help tra-la-la..."; check_db $DB;;
  backup) backup_db;;
  restore) restore;;
  *) check_db $DB;;
esac

