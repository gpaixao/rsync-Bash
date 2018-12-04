#!/bin/bash


# script to remove the backup folders that have more than 180 days
# (baseado no nome da pasta)

maintenance2(){


# The functions recieves two parameters
# The function only works if it recives two parameters
if [[ -n "$1" ]] && [[ -n "$2" ]]; then

	#The current date and time
	date=`date "+%Y-%m-%dT%H:%M:%S"`

	# writes in the log file
	echo Started at `date` >> $2

	# Location of the folder to list
	folders=$1

	#http://stackoverflow.com/questions/4651437/how-to-set-a-bash-variable-equal-to-the-output-from-a-command
	# stores the result from ls in one variable
	OUTPUT=$(ls $folders)

	# http://www.tldp.org/LDP/abs/html/comparison-ops.html
	# if the string not null
	if  [ -n "$OUTPUT" ];
		then

		#http://tldp.org/LDP/abs/html/string-manipulation.html
		# puts the variable content in a array
		array=($OUTPUT)

		# Creates an ordered array from the previous array
		sorted=($(for a in "${array[@]}"; do echo $a; done | sort))

		# stores the array length
		arrayLength=${#sorted[*]}

######################################################################################## Revision (20181204)
		
		# retira 1 ao comprimento do array para podermos excluir o link current
		# que se encontra na ultima posicao da lista
		arrayLength=$(($arrayLength-1))

		# use for loop read all values and indexes
		for (( i=1; i<$arrayLength+1; i++ ));
		do
		  temp=${sorted[$i-1]}
		  #echo ${temp:5}
		 
		# data atual em segundos
		date1=(`date -d $date +%s`)

		# data passada em segundos
		date2=(`date -d ${temp:5} +%s`)

		#date3=$(($date1-$date2))
		#echo $date3

		# tempo em segundos
		# segundos x minutos x horas x dias
		#t1=$((60*60*24*186))
		t1=$((60*60*24*186))

		#Data passada em segundos mais um determinado tempo em segundos
		date3=$(($date2+$t1))

		#echo $date3

		# http://www.tldp.org/LDP/abs/html/comparison-ops.html
		#if [ "$date3" -ge "$date1" ]; #put the loop where you need it
		if [ "$date3" -ge "$date1" ]; #put the loop where you need it
		then
		#echo 'menos de x tempo, n pode ser apagado';

		# transforma segundos em dias horas minutos e segundos
		function displaytime {
		  local T=$1
		  local D=$((T/60/60/24))
		  local H=$((T/60/60%24))
		  local M=$((T/60%60))
		  local S=$((T%60))
		  [[ $D > 0 ]] && printf '%d days ' $D
		  [[ $H > 0 ]] && printf '%d hours ' $H
		  [[ $M > 0 ]] && printf '%d minutes ' $M
		  [[ $D > 0 || $H > 0 || $M > 0 ]] && printf 'and '
		  printf '%d seconds\n' $S
		}

		# Quanto tempo falta para a pasta ser apagada
		#displaytime $(($date3-$date1))
		
		else
		#echo 'mais de x tempo, pode ser apagado'
		echo 'a remover a pasta ' ${temp};
		echo $1${temp} >> $2
		rm -r $1${temp};
		
		fi  
		  
		done

		else
		echo 'A pasta encontra-se vazia'
	fi
	echo Finiched at `date` >> $2
	echo '*********************************************************************' >> $2

else
	# sai da função caso não sejam introduzidos 2 parâmetros.
	echo "Nao foram intruduzidos 2 parametros na funcao maintenance2";
	exit;
fi
	
}

