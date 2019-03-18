#!/bin/bash

initialisation()
{
	if [ ! -f sitelist.txt ]
	then
		echo "starting initialisation.."
		sleep 1
		{
			echo "http://www.allocine.fr/film/agenda/WEEK"
			echo "http://www.premiere.fr/Cinema/Films-et-seances/Sorties-Cinema/WEEK"
			echo "https://www.telerama.fr/cine/film_datesortie.php?when%5Bdate%5D=WEEK&when_radios=1"
			echo "https://www.senscritique.com/films/sorties-cinema/WEEK" 
		} > sitelist.txt
		echo "initialisation complete"
	fi
}

cleard()
{
	echo "clearing data.."
	sleep 1
	rm data*.txt | rm site.txt
	echo "data cleared"
}

#erase()
#{
#}

download()
{
	#if [ ! -e site.txt ]
	#then
		day=$(echo $1 | cut -d/ -f2)
		month=$(echo $1 | cut -d/ -f1)
		year=$(echo $1 | cut -d/ -f3)
		week=$(date -d "$year$month$day" +%V)
		if [ "$2" = 'allocine' ]
		then
			  grep  'allocine' sitelist.txt > site.txt
			  n=`sed "s+WEEK+sem-$year-$month-$day/+g" site.txt`
			  curl $n > data_allocine.txt
			  echo "curling :: $n"
		fi
		if [ "$2" = 'premiere' ]
		then
			  grep  'premiere' sitelist.txt > site.txt
			  n=`sed "s+WEEK+$week/$year+g" site.txt`
			  curl $n > data_premiere.txt
			  echo "curling :: $n"
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
				echo "curling :: $lnk_p\n"
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
			i=1
			while true ; do
				grep  'senscritique' sitelist.txt > site.txt
				lnk=`sed "s+WEEK+$year/semaine/$week+g" site.txt`
				lnk_p=`echo "$lnk/page-$i"`
				curl $lnk_p > data_temp.txt
				cd=`grep -E -m 1 'Bande-annonce' data_temp.txt  | cut -c 35`
				echo "curling :: $lnk_p\n"
				if [ "$cd" = "B" ]
				then
					cat data_temp.txt >> data_senscritique.txt
				fi
				if [ "$cd" != "B" ]
				then	
					break
				fi
				let "i++"
			done
			rm data_temp.txt
		fi

	#fi
}

locald()
{
	#if [ ! -e site.txt ]
	#then
		day=$(echo $1 | cut -d/ -f2)
		month=$(echo $1 | cut -d/ -f1)
		year=$(echo $1 | cut -d/ -f3)
		week=$(date -d "$year$month$day" +%V)
		sed -i "s+http://+http://localhost/+g" sitelist.txt | sed -i "s+https://+http://localhost/+g"
		if [ "$2" = 'allocine' ]
		then
			grep  'allocine' sitelist.txt > site.txt
			n=`sed "s+WEEK+sem-$year-$month-$day/+g" site.txt`
			curl $n > data_allocine.txt
			echo "curling :: $n"
		fi
		if [ "$2" = 'premiere' ]
		then
			grep  'premiere' sitelist.txt > site.txt
			n=`sed "s+WEEK+$week/$year+g" site.txt`
			curl $n > data_premiere.txt
			echo "curling :: $n"
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
				echo "curling :: $lnk_p\n"
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
			i=1
			while true ; do
				grep  'senscritique' sitelist.txt > site.txt
				lnk=`sed "s+WEEK+$year/semaine/$week+g" site.txt`
				lnk_p=`echo "$lnk/page-$i"`
				curl $lnk_p > data_temp.txt
				cd=`grep -E -m 1 'Bande-annonce' data_temp.txt  | cut -c 35`
				echo "curling :: $lnk_p\n"
				if [ "$cd" = "B" ]
				then
					cat data_temp.txt >> data_senscritique.txt
				fi
				if [ "$cd" != "B" ]
				then	
					break
				fi
				let "i++"
			done
			rm data_temp.txt
		fi

	#fi
}

analyse()
{


}

hlp()
{
	echo "
scraper option*

Option :

-i	Initialisation

-c	Effacement des téléchargements précédents.

-e	Effacement des analyses précédentes.

-t date site	Téléchargement des pages web décrivant les nouveautés de la semaine donnée par date. Si site est '-' alors on télécharge tous les sites, sinon uniquement le site demandé. Un site peut être soit un nom simple qui représente de façon unique un site web de référence alors il faut utiliser l'URL de ce site, soit un nombre alors c'est le numéro d'ordre dans les URL données plus loin dans le sujet.

-s date site	Cette option marche comme t mais remplace l'URL officielle pour atteindre un site local qui héberge les pages précédemment téléchargées. Cette option simule un téléchargement réel.

-a	Analyse des fichiers préalablement téléchargés. Remarque, si vous avez extrait tous les fichiers vous analysez tous les fichiers, si vous n'avez extrait qu'un site vous n'analysez que celui-ci. Vous pourriez aussi extraire les sorties de plusieurs semaines.

-w lien page 	Fabrication de la page web qui portera le nom page. C'est l'utilisateur qui fournit le nom avec la bonne extension. Lien permet de contrôler le nombre minimum de lien pour écrire une sortie cinéma.

-h	Affichage de cet aide"
}

while true ; do
	case $1 in
		-i)initialisation;
		exit 0;;

		-c)cleard;
		exit 0;;

		-e)erase;
		exit 0;;

		-t)download $2 $3;
		exit 0;;

		-s)locald $2 $3;
		exit 0;;

		-a)analyse;
		exit 0;;

		-w)web $2 $3;
		exit 0;;

		-h)hlp;
		exit 0;;
		
	esac
done
