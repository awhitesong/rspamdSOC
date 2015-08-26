#!/bin/bash

# This will take ham and spam composites formed after clustering and prepare them in libsvm format for assigning weights.
# This will also create a numbered list of composites along with their frequencies of occurance.

for file in Composites/ham/*.*
do
	sort "$file" | uniq -c | sed 's/[ ]*//' >> "Compositesnumbered.txt"
done

for file in Composites/spam/*.*
do
	sort "$file" | uniq -c | sed 's/[ ]*//' >> "Compositesnumbered.txt"
done


awk '{printf "%d %s\n", NR, $0}' "Compositesnumbered.txt" > "Compositestemp.txt" && mv "Compositestemp.txt" "Compositesnumbered.txt" 

# Preparing composites for ham in libsvm format

for file in Composites/ham/*.*
do
	while read -r line; do
		echo -n -e "1 " >> "libsvmComposites.txt"
		count=$(grep -E "^[0-9]* [0-9]* $line$"  "Compositesnumbered.txt" | cut -d" " -f2)
		frac=$(echo "scale=4;1/$count" | bc)
		echo -n $(grep -E "^[0-9]* [0-9]* $line$"  "Compositesnumbered.txt" | cut -d" " -f1 | awk '{print}' ORS=":$frac ") >> "libsvmComposites.txt"
		echo -n -e "\n" >> "libsvmComposites.txt"
	done < "$file"
done

# Preparing composites for spam in libsvm format

for file in Composites/spam/*.*
do
	while read -r line; do
		echo -n -e "0 " >> "libsvmComposites.txt"
		count=$(grep -E "^[0-9]* [0-9]* $line$"  "Compositesnumbered.txt" | cut -d" " -f2)
		frac=$(echo "scale=4;1/$count" | bc)
		echo -n $(grep -E "^[0-9]* [0-9]* $line$"  "Compositesnumbered.txt" | cut -d" " -f1 | awk '{print}' ORS=":$frac ") >> "libsvmComposites.txt"
		echo -n -e "\n" >> "libsvmComposites.txt"
	done < "$file"
done
