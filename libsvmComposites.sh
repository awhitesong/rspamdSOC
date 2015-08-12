#!/bin/bash
for file in Composites/ham/*.*
do
	sort "$file" | uniq -c | sed 's/[ ]*//' >> "Compositesnumbered.txt"
done

for file in Composites/spam/*.*
do
	sort "$file" | uniq -c | sed 's/[ ]*//' >> "Compositesnumbered.txt"
done


awk '{printf "%d %s\n", NR, $0}' "Compositesnumbered.txt" > "Compositestemp.txt" && mv "Compositestemp.txt" "Compositesnumbered.txt" 

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
