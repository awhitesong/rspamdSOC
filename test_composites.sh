HAM_TEST_DIR="testham"
SPAM_TEST_DIR="testspam"
HAM_TRAIN_DIR="trham"
SPAM_TRAIN_DIR="trspam"

for file in Composites/ham/*.* 
do
	sort "$file" -u >> "hamcomposites.txt"
done

for file in Composites/spam/*.* 
do
	sort "$file" -u >> "spamcomposites.txt"
done

#removing all previously learned cache

rm "/usr/local/var/lib/rspamd/bayes.ham" >/dev/null 2>&1
rm "/usr/local/var/lib/rspamd/bayes.spam" >/dev/null 2>&1
rm "/usr/local/var/lib/rspamd/learn_cache.sqlite" >/dev/null 2>&1
rm "/usr/local/var/lib/rspamd/rspamd.history" >/dev/null 2>&1
rm "/usr/local/var/lib/rspamd/symbols.cache" >/dev/null 2>&1

#disabling stats and metrics

rm "/usr/local/etc/rspamd/metrics.conf"
cp "Disabled/metrics.conf" "/usr/local/etc/rspamd/"

rm "/usr/local/etc/rspamd/statistic.conf"
cp "Disabled/statistic.conf" "/usr/local/etc/rspamd/"


pkill rspamd
rspamd

ham=()
spam=()

echo "matching composites ham"

for file in "$HAM_TRAIN_DIR"/*.*
do
	regex="^($(awk '{printf $0"|"}' <(rspamc symbols "$file" | grep Symbol | cut -d" " -f2 )) )+\$"
	temp=$(grep -E "$regex" "hamcomposites.txt" | wc -l)
	if test "$temp" -gt 0	
	then
	ham+=("$file")
	echo "$file"
	fi
done

echo "matching composites spam"

for file in "$SPAM_TRAIN_DIR"/*.*
do
	regex="^($(awk '{printf $0"|"}' <(rspamc symbols "$file" | grep Symbol | cut -d" " -f2 )) )+\$"
	temp=$(grep -E "$regex" "spamcomposites.txt" | wc -l)
	if test "$temp" -gt 0	
	then
	echo "$file"
	spam+=("$file")
	fi
done

rm "/usr/local/etc/rspamd/metrics.conf"
cp "Enabled/metrics.conf" "/usr/local/etc/rspamd/"

rm "/usr/local/etc/rspamd/statistic.conf"
cp "Enabled/statistic.conf" "/usr/local/etc/rspamd/"

pkill rspamd
rspamd

echo "Learning composites ham"

for i in ${ham[@]}
do 
	rspamc learn_ham "$i"
done

echo "Learning composites spam"

for i in ${spam[@]}
do 
	rspamc learn_spam "$i"
done

rm "/usr/local/etc/rspamd/metrics.conf"
cp "Predictconf/metrics.conf" "/usr/local/etc/rspamd/"

pkill rspamd
rspamd

echo "calculating fp1"

FP=0

for file in "$HAM_TEST_DIR"/*.*
do 
	if rspamc symbols "$file" | grep "BAYES_SPAM" ;then
		FP=$(($FP + 1))
	fi
done

TN=0

echo "calculating tn1"

for file in "$SPAM_TEST_DIR"/*.*
do 
	if rspamc symbols "$file" | grep "BAYES_SPAM" ;then
		TN=$(($TN + 1))
	fi
done

FALSE_POSITIVE_RATE=$(echo "scale=4;$FP/($FP+$TN)" | bc)

echo "$FALSE_POSITIVE_RATE" >> "fprate.txt"


#part 2

rm "/usr/local/var/lib/rspamd/bayes.ham" >/dev/null 2>&1
rm "/usr/local/var/lib/rspamd/bayes.spam" >/dev/null 2>&1
rm "/usr/local/var/lib/rspamd/learn_cache.sqlite" >/dev/null 2>&1
rm "/usr/local/var/lib/rspamd/rspamd.history" >/dev/null 2>&1
rm "/usr/local/var/lib/rspamd/symbols.cache" >/dev/null 2>&1

rm "/usr/local/etc/rspamd/metrics.conf"
cp "Enabled/metrics.conf" "/usr/local/etc/rspamd/"

rm "/usr/local/etc/rspamd/statistic.conf"
cp "Enabled/statistic.conf" "/usr/local/etc/rspamd/"

pkill rspamd
rspamd
 

echo "training all ham"

for file in "$HAM_TRAIN_DIR"/*.*
do 
	rspamc learn_ham "$file"
done

echo "training all spam"

for file in "$SPAM_TRAIN_DIR"/*.*
do 
	rspamc learn_spam "$file"
done

rm "/usr/local/etc/rspamd/metrics.conf"
cp "Predictconf/metrics.conf" "/usr/local/etc/rspamd/"

pkill rspamd
rspamd

FP=0

echo "calculating fp2"

for file in "$HAM_TEST_DIR"/*.*
do 
	if rspamc symbols "$file" | grep "BAYES_SPAM" ;then
		FP=$(($FP + 1))
	fi
done

TN=0

echo "calculating tn2"

for file in "$SPAM_TEST_DIR"/*.*
do 
	if rspamc symbols "$file" | grep "BAYES_SPAM" ;then
		TN=$(($TN + 1))
	fi
done

FALSE_POSITIVE_RATE=$(echo "scale=4;$FP/($FP+$TN)" | bc)

echo "$FALSE_POSITIVE_RATE" >> "fprate.txt"
