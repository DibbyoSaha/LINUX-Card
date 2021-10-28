#!/bin/bash
my_exits () {
    if [ $# != 1 ] || [ ! -r $1 ] ; 
    then
			echo "input file missing or unreadable"
    exit 1
    fi
    local FILE_NAME="$1"
    local FILE_LINES=`grep "" -c $FILE_NAME`
    local LINE_1_FORMAT=`awk -e '/^[0-9]*$/ {print FNR}' $FILE_NAME | tr -d '\n'` #get the line number for seed line and format into 1 number to check against 1 in my_exits
    local LINE_4_FORMAT=`awk -e '/^([0][1-9]|[1][0-5])\s([1][6-9]|[2][0-9]|[3][0])\s[0]{2}\s([4][6-9]|[5][0-9]|[6][0])\s([6][1-9]|[7][0-5])$/ {print FNR}' $FILE_NAME | tr -d '\n'` #get the line number for middle line with 00 and format into 1 number to check against 4 in my_exits
    local LINE_2356_FORMAT=` awk -e '/^([0][1-9]|[1][0-5])\s([1][6-9]|[2][0-9]|[3][0])\s([3][1-9]|[4][0-5])\s([4][6-9]|[5][0-9]|[6][0])\s([6][1-9]|[7][0-5])$/ {print FNR}' $FILE_NAME | tr -d '\n'` #get the line numbers for non-middle lines 
    local COUNT_DUPLICATES=`grep -Eo '[0-9\.]+' $FILE_NAME | tail -n +2 | sort | uniq -cd | wc -l` #get all the numbers, remove seed, sort, count duplicates
    if [ $FILE_LINES -ne 6 ] ; 
    then
			echo "input file must have 6 lines"
    exit 2
    elif [ -z "${LINE_1_FORMAT}" ] || [ $LINE_1_FORMAT -ne 1 ] ; #check if string is empty & if seed is on line 1
    then
			echo "seed line format error"
    exit 3
    elif [ -z "${LINE_4_FORMAT}" ] || [ $LINE_4_FORMAT -ne 4 ] || [ -z "${LINE_2356_FORMAT}" ] || [ $LINE_2356_FORMAT -ne 2356 ] ; #check if string is empty & if the expected line numbers match
    then
			echo "card format error"
    exit 4
    elif [ $COUNT_DUPLICATES -ne 0 ] ; #if not 0 it has a duplicate
    then
			echo "card format error, has duplicates"
    exit 5
    fi


}
my_exits $1

#file exists so proceed
FILE_NAME="$1"

fullCode(){
seed=$(head -1 $FILE_NAME)
declare -a r1=$(sed '2q;d' $FILE_NAME)
declare -a r2=$(sed '3q;d' $FILE_NAME)
declare -a r3=$(sed '4q;d' $FILE_NAME)
declare -a r4=$(sed '5q;d' $FILE_NAME)
declare -a r5=$(sed '6q;d' $FILE_NAME)

local row1=(${r1[*]}) #Arrays being assigned to elements from the file so that they appear as 5 elements per array
local row2=(${r2[*]})
local row3=(${r3[*]})
local row4=(${r4[*]})
local row5=(${r5[*]})

declare -a printedI
declare -a printed
declare -a randNums
declare -a noRepeat

arrayBuild(){
	RANDOM=$seed
	i=0
	while [ $i -le 500 ]
		do
		rand=$((1 + $RANDOM % 75))
		
		if [[ "${randNums[*]}" =~ "$rand" ]]
		then	
			while [[ ! "${randNums[*]}" =~ "$rand" ]] 
			do
				rand=$((1 + $RANDOM % 75))
			done
			randNums+=($rand)
		fi
		
		letterL="L"
		letterI="I"
		letterN="N"
		letterU="U"
		letterX="X"

		if [ "$rand" -gt 0 ] && [ "$rand" -lt 10 ]
		then
			letterL+=0
			letterL+=$rand
			printedI+=($letterL)
		elif [ "$rand" -gt 9 ] && [ "$rand" -lt 16 ]
		then
			letterL+=$rand
			printedI+=($letterL)
		elif [ "$rand" -gt 15 ] && [ "$rand" -lt 31 ]
		then
                        letterI+=$rand
                        printedI+=($letterI)
		elif [ "$rand" -gt 30 ] && [ "$rand" -lt 46 ]
		then
                        letterN+=$rand
			printedI+=($letterN)
		elif [ "$rand" -gt 45 ] && [ "$rand" -lt 61 ]
		then
                        letterU+=$rand
			printedI+=($letterU)
		elif [ "$rand" -gt 60 ] && [ "$rand" -lt 76 ]
		then
                        letterX+=$rand
			printedI+=($letterX)
		fi
		((i++))
	done
	printed=($(echo "${printedI[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')) # Filters out duplicate elements
}
arrayBuild

j=-1
declare -a callList
declare -a twoLetterArr
y=""
str=""
row3[2]+="m"
flag=""

#Functions to checks if any of the winning criterias has been met
checkCorners(){
	if [[ "${row1[0]}" =~ "m" && "${row1[4]}" =~ "m" && "${row5[0]}" =~ "m" && "${row5[4]}" =~ "m" ]]
	then
		y="yes"
		flag="checkCorners"
	fi
}

checkRow1(){
	if [[ "${row1[0]}" =~ "m" ]]
        then
        	if [[ "${row1[1]}" =~ "m" ]]
                then
                	 if [[ "${row1[2]}" =~ "m" ]]
                         then
                         	if [[ "${row1[3]}" =~ "m" ]]
                                then
                                	if [[ "${row1[4]}" =~ "m" ]]
                                        then
                                        	y="yes"
flag="checkRow1"
                                        fi
                                fi
                         fi
                fi
        fi
}

checkRow2(){
	if [[ "${row2[0]}" =~ "m" ]]
	then
		if [[ "${row2[1]}" =~ "m" ]]
		then
			if [[ "${row2[2]}" =~ "m" ]]
			then
				if [[ "${row2[3]}" =~ "m" ]]
				then
					if [[ "${row2[4]}" =~ "m" ]]
					then
						y="yes"
flag="checkRow2"
					fi
				fi
			fi
		fi
	fi
}

checkRow3(){
	if [[ "${row3[0]}" =~ "m" ]]
	then
		if [[ "${row3[1]}" =~ "m" ]]
		then
			if [[ "${row3[2]}" =~ "m" ]]
			then
				if [[ "${row3[3]}" =~ "m" ]]
				then
					if [[ "${row3[4]}" =~ "m" ]]
					then
						y="yes"
flag="checkRow3"
					fi
				fi
			fi
		fi
	fi
}

checkRow4(){
	if [[ "${row4[0]}" =~ "m" ]]
        then
        	if [[ "${row4[1]}" =~ "m" ]]
                then
                	if [[ "${row4[2]}" =~ "m" ]]
                        then
                        	if [[ "${row4[3]}" =~ "m" ]]
                                then
                                	if [[ "${row4[4]}" =~ "m" ]]
                                        then
                                        	y="yes"
flag="checkRow4"
                                        fi
                                fi
                        fi
                fi
        fi
}

checkRow5(){
	if [[ "${row5[0]}" =~ "m" ]]
        then
        	if [[ "${row5[1]}" =~ "m" ]]
                then
                	if [[ "${row5[2]}" =~ "m" ]]
                        then
                     		if [[ "${row5[3]}" =~ "m" ]]
                                then
                                	if [[ "${row5[4]}" =~ "m" ]]
                                        then
                                        	y="yes"
flag="checkRow5"
                                        fi
                                fi
                        fi
                fi
        fi
}

checkCol1(){
        if [[ "${row1[0]}" =~ "m" ]]
        then    
                if [[ "${row2[0]}" =~ "m" ]]
                then     
                         if [[ "${row3[0]}" =~ "m" ]]
                         then   
                                if [[ "${row4[0]}" =~ "m" ]]
                                then    
                                        if [[ "${row5[0]}" =~ "m" ]]
                                        then    
                                                y="yes"
flag="checkCol1"
                                        fi
                                fi
                         fi
                fi
        fi
}

checkCol2(){
        if [[ "${row1[1]}" =~ "m" ]]
        then
                if [[ "${row2[1]}" =~ "m" ]]
                then
                         if [[ "${row3[1]}" =~ "m" ]]
                         then
                                if [[ "${row4[1]}" =~ "m" ]]
                                then
                                        if [[ "${row5[1]}" =~ "m" ]]
                                        then
                                                y="yes"
flag="checkCol2"
                                        fi
                                fi
                         fi
                fi
        fi
}

checkCol3(){
        if [[ "${row1[2]}" =~ "m" ]]
        then
                if [[ "${row2[2]}" =~ "m" ]]
                then
                         if [[ "${row3[2]}" =~ "m" ]]
                         then
                                if [[ "${row4[2]}" =~ "m" ]]
                                then
                                        if [[ "${row5[2]}" =~ "m" ]]
                                        then
                                                y="yes"
flag="checkCol3"
                                        fi
                                fi
                         fi
                fi
        fi
}

checkCol4(){
        if [[ "${row1[3]}" =~ "m" ]]
        then
                if [[ "${row2[3]}" =~ "m" ]]
                then
                         if [[ "${row3[3]}" =~ "m" ]]
                         then
                                if [[ "${row4[3]}" =~ "m" ]]
                                then
                                        if [[ "${row5[3]}" =~ "m" ]]
                                        then
                                                y="yes"
flag="checkCol4"
                                        fi
                                fi
                         fi
                fi
        fi
}

checkCol5(){
        if [[ "${row1[4]}" =~ "m" ]]
        then
                if [[ "${row2[4]}" =~ "m" ]]
                then
                         if [[ "${row3[4]}" =~ "m" ]]
                         then
                                if [[ "${row4[4]}" =~ "m" ]]
                                then
                                        if [[ "${row5[4]}" =~ "m" ]]
                                        then
                                                y="yes"
flag="checkCol5"
                                        fi
                                fi
                         fi
                fi
        fi
}

arrayCall(){
	while read -n1 -r -p  "enter any key to get a call or q to quit: " 
	do
		echo
		if [[ $REPLY == q ]]
		then	
			break;
		else
			j=$(( j+1 ))
			lenPrinted=${#printed[*]}
			finLetter=${printed[j]}
			sub="${printed[j]}"
        		twoLetter="${sub#?}"

			callList+=($finLetter)

			twoLetterArr+=($twoLetter)

			lenTwoLetterArr=${#twoLetterArr[*]}
			
			#Code below checks the last two numbers from the call list number (like 07 from L07) to the row indexes and marks "m" if found
			for (( index=0; index<${#row1[*]}; index++ ));
			do
				if [[ ${row1[index]} == ${twoLetterArr[lenTwoLetterArr-1]} ]]
        			then
                			row1[index]+="m"
        			fi
			done

                        for (( index=0; index<${#row2[*]}; index++ ));
                        do
                                if [[ ${row2[index]} == ${twoLetterArr[lenTwoLetterArr-1]} ]]
                                then
                                        row2[index]+="m"
                                fi
                        done
			
                        for (( index=0; index<${#row3[*]}; index++ ));
                        do
                                if [[ ${row3[index]} == ${twoLetterArr[lenTwoLetterArr-1]} ]]
                                then
                                        row3[index]+="m"
                                fi
                        done

                      	for (( index=0; index<${#row4[*]}; index++ ));
                        do
                                if [[ ${row4[index]} == ${twoLetterArr[lenTwoLetterArr-1]} ]]
                                then
                                        row4[index]+="m"
                                fi
                        done

			for (( index=0; index<${#row5[*]}; index++ ));
                        do
                                if [[ ${row5[index]} == ${twoLetterArr[lenTwoLetterArr-1]} ]]
                                then
                                        row5[index]+="m"
                                fi
                        done
			
			checkCorners
			checkRow1		
			checkRow2
			checkRow3
			checkRow4
			checkRow5
			checkCol1
			checkCol2
			checkCol3
			checkCol4
			checkCol5
			
			echo "CALL LIST:" ${callList[*]}
			echo "L I N U X"
			echo ${row1[*]}
			echo ${row2[*]}
			echo ${row3[*]}
			echo ${row4[*]}
			echo ${row5[*]}
			if [[ "${y}" == "yes" ]]
			then
        			str="WINNER"
        			echo $str
				break;
			fi 
	
		fi
	done	
}
arrayCall
}
fullCode
