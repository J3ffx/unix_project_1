#!/bin/bash

initialisation()
{
	if [ ! -f sitelist.txt ]
	then	clear
		echo "starting initialisation.."
		sleep 1
		{
			echo "http://www.allocine.fr/film/agenda/WEEK"
			echo "http://www.premiere.fr/Cinema/Films-et-seances/Sorties-Cinema/WEEK"
			echo "https://www.telerama.fr/cine/film_datesortie.php?when%5Bdate%5D=WEEK&when_radios=1"
			echo "https://www.senscritique.com/films/sorties-cinema/WEEK" 
		} > sitelist.txt
		clear
		echo "./scraper.sh -i"
		echo "initialisation complete !"
	fi
}

#erased()
#{
#}

#erasea()
#{
#}

download()
{
	if [ ! -e site.txt ]
	then
		day=$(echo $1 | cut -d/ -f2)
		month=$(echo $1 | cut -d/ -f1)
		year=$(echo $1 | cut -d/ -f3)
		week=$(date -d "$year$month$day" +%V)
		if [ "$2" = 'allocine' ]
		then
			  grep  'allocine' sitelist.txt > site.txt
			  n=`sed "s+WEEK+sem-$year-$month-$day/+g" site.txt`
			  curl $n > data_allocine.txt
		fi
		if [ "$2" = 'premiere' ]
		then
			  grep  'premiere' sitelist.txt > site.txt
			  n=`sed "s+WEEK+$week/$year+g" site.txt`
			  curl $n > data_premiere.txt
		fi
		if [ "$2" = 'telerama' ]
		then
			i=0
			while true ; do
				grep  'telerama' sitelist.txt > site.txt
				lnk=`sed "s+WEEK+$day/$month/$year+g" site.txt`
				lnk_p=`echo "$lnk&page=$i"`
				curl $lnk_p > data_temp.txt
				cd=`grep -E "Désolé" data_temp.txt  | cut -c 10`
				echo "curling :: $lnk_p"
				if [ "$cd" != "D" ]
				then
					cat data_temp.txt >> data_telerama.txt
				fi
				if [ "$cd" = "D" ]
				then	
					break
				fi
				let "i++"
			done
			rm data_temp.txt
		fi
		if [ "$2" = 'senscritique' ]
		then
			  grep  'senscritique' sitelist.txt > site.txt
			  n=`sed "s+WEEK+$year/semaine/$week+g" site.txt`
			  curl $n > data_senscritique.txt
		fi

	fi
}


while true ; do
	case $1 in
		-i)initialisation;
		exit 0;;
		
		-t)download $2 $3;
		exit 0;;

		
	esac
done
