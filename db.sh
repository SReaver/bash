#!/bin/bash

DATA_DIR="../data"
DB_FILE="$DATA_DIR/users.db"

usage() {
	echo "Usage: db.sh [command]"
	echo "Available commands:"
	echo "  add     - Add a new user to the database"
	echo "  backup  - Create a backup of the database"
	echo "  restore - Restore the database from the last backup"
	echo "  find    - Find a user by username"
	echo "  list    - List all users in the database"
	echo "  help    - Print this help message"
}

check_db() {
	if [ ! -d "$DATA_DIR" ]; then
		mkdir -p "$DATA_DIR"
	fi

	if [ ! -f "$DB_FILE" ]; then
		read -p "Database file $DB_FILE does not exist. Do you want to create it? (y/n) " answer
		case $answer in
		[Yy]*) touch "$DB_FILE" ;;
		[Nn]*) exit ;;
		*) echo "Please answer y or n." ;;
		esac
	fi
}

add_user() {
	check_db

	while true; do
		read -p "Enter the username: " username
		if [[ $username =~ ^[A-Za-z]+$ ]]; then
			break
		else
			echo "Invalid username. Only Latin letters are allowed."
		fi
	done

	while true; do
		read -p "Enter the role: " role
		if [[ $role =~ ^[A-Za-z]+$ ]]; then
			break
		else
			echo "Invalid role. Only Latin letters are allowed."
		fi
	done

	echo "$username,$role" >>"$DB_FILE"

	echo "User $username with role $role added to the database."
}

backup_db() {
	check_db

	DATE=$(date +%F)

	BACKUP_FILE="$DATA_DIR/$DATE-users.db.backup"

	cp "$DB_FILE" "$BACKUP_FILE"

	echo "Backup created: $BACKUP_FILE"
}

restore_db() {
	check_db

	LAST_BACKUP=$(ls -t "$DATA_DIR"/*.backup | head -n1)

	if [ -z "$LAST_BACKUP" ]; then
		echo "No backup file found."
		return
	fi

	read -p "Do you want to restore from $LAST_BACKUP? (y/n) " answer
	case $answer in
	[Yy]*) cp "$LAST_BACKUP" "$DB_FILE" ;;
	[Nn]*) exit ;;
	*) echo "Please answer y or n." ;;
	esac

	echo "Database restored from $LAST_BACKUP."
}

find_user() {
	check_db

	read -p "Enter the username: " username

	MATCHES=$(grep -i "$username" "$DB_FILE")

	if [ -z "$MATCHES" ]; then
		echo "User not found."
		return
	fi

	echo "$MATCHES"
}

reverse_lines() {
	if [ -z "$1" ]; then
		echo "No file name provided."
		return
	fi

	if [ ! -f "$1" ] || [ ! -r "$1" ]; then
		echo "File $1 does not exist or is not readable."
		return
	fi

	lines=()

	while read -r line; do
		lines+=("$line")
	done <"$1"

	len=${#lines[@]}

	for ((i = len - 1; i >= 0; i--)); do
		echo "${lines[i]}"
	done
}

list_users() {
	check_db

	if [ "$1" == "--inverse" ]; then
		LINES=$(reverse_lines "$DB_FILE")
	else
		LINES=$(cat "$DB_FILE")
	fi

	N=0

	while read -r line; do
		N=$((N + 1))

		echo "$N. $line"
	done <<<"$LINES"
}

if [ $# -eq 0 ]; then
	usage
else
	case $1 in
	add) add_user ;;
	backup) backup_db ;;
	restore) restore_db ;;
	find) find_user ;;
	list) list_users $2 ;;
	help) usage ;;
	*) echo "Invalid command. Use db.sh help for more information." ;;
	esac
fi
