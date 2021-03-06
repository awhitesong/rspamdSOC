#!/bin/bash

# This ill split the provided corpus into spam and ham, test and train directories 
# and create directories for composites and clusters which are used later.

rm TR/"Icon" >/dev/null 2>&1
rm -R __MACOSX >/dev/null 2>&1
for file in TR/*.*
do
	mv "$file" "$file.txt"
done

#427 trham 523
filename="spam-mail.tr.label"
mkdir "trham"
mkdir "trspam"
mkdir "testham"
mkdir "testspam"
mkdir "Composites"
mkdir "Clusters"
mkdir "Composites/ham"
mkdir "Composites/spam"
mkdir "Enabled"
mkdir "Disabled"
mkdir "Predictconf" 
while read -r line || [[ -n $line ]]; do
	label=$(echo "$line" | cut -d"," -f2)
	name=$(echo "$line" | cut -d"," -f1)
	if test "$label" -eq "1" && test "$name" -ge "427"; then
		mv TR/"TRAIN_$name.eml.txt" "trham"
	elif test "$label" -eq "0" && test "$name" -ge "523"; then 
		mv TR/"TRAIN_$name.eml.txt" "trspam"
	elif test "$label" -eq "1"; then
		mv TR/"TRAIN_$name.eml.txt" "testham"
	elif test "$label" -eq "0"; then
		mv TR/"TRAIN_$name.eml.txt" "testspam"
	fi
done < "$filename"

rm "spam-mail.tr.label"

rm -R TR >/dev/null 2>&1
