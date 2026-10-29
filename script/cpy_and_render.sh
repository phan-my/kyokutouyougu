#!/bin/bash

# get path from command input
path="$1"
pattern="$1"s

# inputting path
while :
do
	# strip quotes before and after the pathname
	path=${path#\'} # remove prefix quote
	path=${path%\'} # remove suffix quote
	path=${path%\/} # remove suffix slash
	
	# if a path is inputted from command prompt BUT has issues
	if [ -n "$path" ]
	then
#		# checks if path exists
#		if [ ! -e "$path" ]
#		then
#			echo "Inputted path '$path' does not exist"
		# case path is a directory:
		if [ -d "$path" ]
		then
			# get to stage.c file
			if [ -e "$path"'/src/stage.c' ]
			then
				# strip quotes before and after the pathname
				path=${path#\'} # remove prefix quote
				path=${path%\'} # remove suffix quote
				path=${path%\/} # remove suffix slash
				path="$path"'/src/stage.c'
				break
			else
				echo "File "$path"/src/stage.c not found"
			fi
		# case path is a file:
		elif [ -f "$path" ]
		then
			# parse file stage.c
			if [ $(basename "$path") == "stage.c" ]
			then
				path=${path#\'} # remove prefix quote
				path=${path%\'} # remove suffix quote
				path=${path%\/} # remove suffix slash
				break
			else
				echo "File must be 'stage.c'";
			fi
		# in some way invalid file
		else
			echo "Path '"$path"' is invalid"
		fi
	fi
	
	echo -n "Enter filename: "
	read path
done

# inputting pattern name
# TODO: make foolproof so that wrong function input doesn't return error
echo -n "Enter pattern name: "
read pattern
echo "$pattern"
pattern="${pattern%(*}" # deletes '()' of function

# clone directory to /tmp
cp -r "${path%/*}" /tmp/
rm -rf /tmp/src
cp -r "${path%/*}" /tmp/

# first line in code that contains the function
#start_line=$(awk "/$pattern/{ print NR; exit} " /tmp/src/"$(basename "$path")")
#echo "$start_line"

# copies entire function as string into variable 
# regex: copies everything from void $pattern till the line that contains only '}' without indentation
# TODO: C is a curly bracket language
func=$(sed -n "/^void $pattern()$/,/^}$/p" /tmp/src/stage.c)

# replace /tmp/src/stage.c with template
cp ./stage_template.c /tmp/src/stage.c

echo "$func"

# replaces templates with strings
var="// HAJIME1"
OLD="$var" NEW="$func" perl -0777 -i -pe '
    s/\Q$ENV{OLD}\E/$ENV{NEW}/g
' /tmp/src/stage.c

sed -i -e 's/\/\/ HAJIME2/'"$pattern"'();/g' /tmp/src/stage.c;
# sed -i -e 's/\/\/ HAJIME1/'$func';/g' /tmp/src/stage.c

rm /tmp/src/omain.out
cd /tmp/src/ && make;
/tmp/src/omain.out
