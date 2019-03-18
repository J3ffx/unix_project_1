#!/bin/bash

initialisation()
{
	#if [ ! -f sitelist.txt ]
	#then
		echo "starting initialisation.."
		sleep 1
		{
			echo "http://www.allocine.fr/film/agenda/WEEK"
			echo "http://www.premiere.fr/Cinema/Films-et-seances/Sorties-Cinema/WEEK"
			echo "https://www.telerama.fr/cine/film_datesortie.php?when%5Bdate%5D=WEEK&when_radios=1"
			echo "https://www.senscritique.com/films/sorties-cinema/WEEK" 
		} > sitelist.txt
		echo "initialisation complete"
	#fi
}

cleard()
{
	echo "clearing data.."
	sleep 1
	rm data*.txt | rm site*.txt
	echo "data cleared"
}

erase()
{
	echo "erasing analysis.."
	sleep 1
	rm ana*.txt
	echo "analysis erased"

}

download()
{	./scraper.sh -i
	echo "starting curl.."
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
	echo "page curled"
}

locald()
{	./scraper.sh -i
	echo "starting curl.."
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
		echo "page curled"
}

analysis()
{
	echo "starting analysis.."
	if [ -e data_allocine.txt ]
	then
		grep -E "fichefilm_gen_cfilm=" data_allocine.txt > data_tit.txt
		sed -e 's+[^ ]*">++g' -i data_tit.txt
		sed -e 's+[^ ]*"++g' -i data_tit.txt
		sed -e 's+[^ ]*<a++g' -i data_tit.txt
		sed -e 's+<[^ ]*++g' -i data_tit.txt
		sed -e 's+[^ ]*\ \ ++g' -i data_tit.txt
		sed -e "s+&#039;+'+g" -i data_tit.txt
		wc -l data_tit.txt > n.txt
		sed -e 's+\ data_tit.txt++g' -i n.txt
		n=`grep -E '[0-99]' n.txt`
		rm n.txt
		printf "analysing %s movies..\n" "$n"

		grep -E "width=\"216\"\ height=\"288\"" data_allocine.txt > data_pic.txt
		sed -e 's+[^ ]*\ \ ++g' -i data_pic.txt
		sed -e 's+\<img\ class=\"thumbnail-img\"\ ++g' -i data_pic.txt
		sed -e 's+\ +_+g' -i data_pic.txt
		sed -e 's+\"_alt=[^ ]*++g' -i data_pic.txt
		sed -e 's+<src=\"++g' -i data_pic.txt
		sed -e 's+[^ ]*_data-src=\"++g' -i data_pic.txt


		grep -E -A7 "<div\ class=\"synopsis\">" data_allocine.txt > data_synt.txt
		sed -e 's+\ +_+g' -i data_synt.txt
		sed -e 's+____________<[^ ]*++g' -i data_synt.txt
		sed -e 's+__________<[^ ]*++g' -i data_synt.txt
		sed -e 's+____________________________++g' -i data_synt.txt
		sed -e 's+____++g' -i data_synt.txt
		sed -e 's+___________________++g' -i data_synt.txt
		sed -e 's+________________++g' -i data_synt.txt
		sed -e 's+___++g' -i data_synt.txt
		grep -E "__" data_synt.txt > data_syn.txt
		sed -e 's+__++g' -i data_syn.txt
		sed -e 's+_+\ +g' -i data_syn.txt
		rm data_synt.txt

		grep -E -A39 "<div\ class=\"rating-holder\">" data_allocine.txt > data_temp.txt
		sed -e 's+\ +_+g' -i data_temp.txt
		grep -E "__[0-9]" data_temp.txt > data_hm.txt
		sed -e 's+[^ ]*_++g' -i data_hm.txt
		sed -e 's+<[^ ]*++g' -i data_hm.txt
		grep -E "rating-title\">" data_temp.txt > data_who.txt
		sed -e 's+[^ ]*\">++g' -i data_who.txt
		sed -e 's+<[^ ]*++g' -i data_who.txt
		sed -e 's+_++g' -i data_who.txt
		rm data_temp.txt
		paste data_who.txt data_hm.txt | while IFS="$(printf '\t')" read -r f1 f2
		do
			verif=`printf "%s" "$f1"`
			P="Presse"
			S="Spectateurs"
			if [ "$verif" == "$P" ]
			then
				printf "%s " "$f1"
				printf "%s " "$f2"
			fi
			if [ "$verif" == "$S" ]
			then
				printf "%s " "$f1"
  				printf "%s\n" "$f2"
			fi
		done > data_rat.txt
		rm data_who.txt
		rm data_hm.txt

		paste data_tit.txt data_pic.txt data_syn.txt data_rat.txt | while IFS="$(printf '\t')" read -r f1 f2 f3 f4
		do
			printf "Titre : %s\n" "$f1"
			printf "	image : %s\n" "$f2"
			printf "	synopsis : %s\n" "$f3"
			printf "	notes : %s\n\n" "$f4"
		done > ana_allocine.txt
		rm data_tit.txt
		rm data_pic.txt
		rm data_syn.txt
		rm data_rat.txt
	fi

	#if [ -e data_premiere.txt ]
	#then
	
	#fi

	#if [ -e data_telerama.txt ]
	#then
	
	#fi

	#if [ -e data_senscritique.txt ]
	#then

	#fi
	echo "analysis done"
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

		-a)analysis;
		exit 0;;

		-w)web $2 $3;
		exit 0;;

		-h)hlp;
		exit 0;;
		
	esac
done
