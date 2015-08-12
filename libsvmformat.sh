#!/bin/bash
HAM_TRAIN_DIR="trham"
SPAM_TRAIN_DIR="trspam"
HAM_TEST_DIR="testham"
SPAM_TEST_DIR="testspam"

pkill rspamd 
rspamd

rspamc counters | cut -d"|" -f3 | grep -o -E '\w+' | tail -n +8 | sort | uniq > "allSymbolsNumbered.txt" 
sed -i '/^\(BAYES_HAM\|BAYES_SPAM\|DATE_IN_PAST\|HFILTER_FROM_BOUNCE\|HFILTER_HELO_5\)/d' "allSymbolsNumbered.txt"
awk '{printf "%d %s\n", NR, $0}' "allSymbolsNumbered.txt" > "allSymbolstemp.txt" && mv "allSymbolstemp.txt" "allSymbolsNumbered.txt" 

for file in "$HAM_TRAIN_DIR"/*.*
do
	echo -n -e "1 " >> "Trainlabels.txt"
	echo -n $(awk 'NR==FNR{a[$0];next;}$2 in a' <(rspamc symbols "$file" | grep Symbol | cut -d" " -f2 ) "allSymbolsNumbered.txt" | cut -d" " -f1 | awk '{print}' ORS=':1 ') >> "Trainlabels.txt"
	echo -n -e "\n" >> "Trainlabels.txt"
done

sed -i '/^1\s*$/d' "Trainlabels.txt"

for file in "$SPAM_TRAIN_DIR"/*.*
do
	echo -n -e "0 " >> "Trainlabels.txt"
	echo -n $(awk 'NR==FNR{a[$0];next;}$2 in a' <(rspamc symbols "$file" | grep Symbol | cut -d" " -f2 ) "allSymbolsNumbered.txt" | cut -d" " -f1 | awk '{print}' ORS=':1 ') >> "Trainlabels.txt" #as libsvm should have ascending id's, this(awk) automatically sorts the values
	echo -n -e "\n" >> "Trainlabels.txt"
done

sed -i '/^0\s*$/d' "Trainlabels.txt"

for file in "$HAM_TEST_DIR"/*.*
do
	echo -n -e "1 " >> "Testlabels.txt"
	echo -n $(awk 'NR==FNR{a[$0];next;}$2 in a' <(rspamc symbols "$file" | grep Symbol | cut -d" " -f2 ) "allSymbolsNumbered.txt" | cut -d" " -f1 | awk '{print}' ORS=':1 ') >> "Testlabels.txt"
	echo -n -e "\n" >> "Testlabels.txt"
done

sed -i '/^1\s*$/d' "Testlabels.txt"

for file in "$SPAM_TEST_DIR"/*.*
do
	echo -n -e "0 " >> "Testlabels.txt"
	echo -n $(awk 'NR==FNR{a[$0];next;}$2 in a' <(rspamc symbols "$file" | grep Symbol | cut -d" " -f2 ) "allSymbolsNumbered.txt" | cut -d" " -f1 | awk '{print}' ORS=':1 ') >> "Testlabels.txt"
	echo -n -e "\n" >> "Testlabels.txt"
done

sed -i '/^0\s*$/d' "Testlabels.txt"
