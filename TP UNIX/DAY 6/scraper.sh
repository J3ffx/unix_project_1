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
		if [ "$2" = 'allo' ]
		then
			  grep  'allocine' sitelist.txt > site.txt
			  n=`sed "s+WEEK+sem-$year-$month-$day/+g" site.txt`
			  curl $n > data_allocine.txt
			  echo "curling :: $n"
		fi
		if [ "$2" = 'prem' ]
		then
			  grep  'premiere' sitelist.txt > site.txt
			  n=`sed "s+WEEK+$week/$year+g" site.txt`
			  curl $n > data_premiere.txt
			  echo "curling :: $n"
		fi
		if [ "$2" = 'tele' ]
		then
			rm data_telerama.txt
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
		if [ "$2" = 'sens' ]
		then
			rm data_senscritique.txt
			i=1
			while true ; do
				grep  'senscritique' sitelist.txt > site.txt
				lnk=`sed "s+WEEK+$year/semaine/$week+g" site.txt`
				lnk_p=`echo "$lnk/page-$i"`
				curl $lnk_p > data_temp.txt
				cd=`grep -E -m 1 'Bande-annonce' data_temp.txt  | cut -c 35`
				echo "curling :: $lnk_p"
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
			rm data_telerama.txt
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
			rm data_senscritique.txt
			i=1
			while true ; do
				grep  'senscritique' sitelist.txt > site.txt
				lnk=`sed "s+WEEK+$year/semaine/$week+g" site.txt`
				lnk_p=`echo "$lnk/page-$i"`
				curl $lnk_p > data_temp.txt
				cd=`grep -E -m 1 'Bande-annonce' data_temp.txt  | cut -c 35`
				echo "curling :: $lnk_p"
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
		sed -e "s+&#039;+'+g" -i data_tit.txt
		sed -e "s+\&amp;+\&+g" -i data_tit.txt
		rm data_synt.txt

		grep -E -A39 "<div\ class=\"rating-holder\">" data_allocine.txt > data_temp.txt
		echo "--" >> data_temp.txt
		sed -e 's+--+_+g' -i data_temp.txt
		grep -E -B23 "_" data_temp.txt > data_tmp.txt
		sed -i '/--/c\' data_tmp.txt
		sed -i '/<div class="rating-item/c\' data_tmp.txt
		sed -i '/<span class/c\' data_tmp.txt
		sed -i '/ <\/div>/c\' data_tmp.txt
		sed -i '/buttons-holder/c\' data_tmp.txt
		sed -e 's+</span></div>++g' -i data_tmp.txt
		sed -e 's+\ ++g' -i data_tmp.txt
		sed -e 's+\	++g' -i data_tmp.txt
		sed -i '/span/c\' data_tmp.txt
		sed -i '/--/c\' data_tmp.txt
		sed -i '1s/^/_\n/' data_tmp.txt
		grep -E -A1 "_" data_tmp.txt > data_spect.txt
		grep -E -B2 "_" data_tmp.txt > data_presst.txt
		rm data_temp.txt
		rm data_tmp.txt
		i=1
		t=2
		while ((i!=$n+1))
		do
			head -$t data_spect.txt | tail -1
			t=$(($t+3))
			((i++))
		done > data_spec.txt
		rm data_spect.txt
		i=1
		t=3
		while ((i!=$n+1))
		do
			head -$t data_presst.txt | tail -1
			t=$(($t+4))
			((i++))
		done > data_press.txt
		rm data_presst.txt

		sed -e 's+\ ++g' -i data_spec.txt
		sed -e 's+\	++g' -i data_spec.txt
		sed -e 's+\ ++g' -i data_press.txt
		sed -e 's+\	++g' -i data_press.txt
		paste data_tit.txt data_pic.txt data_syn.txt data_press.txt data_spec.txt | while IFS="$(printf '\t')" read -r f1 f2 f3 f4 f5
		do
			printf "Titre : %s\n" "$f1"
			printf "	image : %s\n" "$f2"
			printf "	synopsis : %s\n" "$f3"
			printf "	note presse : %s\n" "$f4"
			printf "	note spectateurs : %s\n\n" "$f5"
		done > ana_allocine.txt
		rm data_tit.txt
		rm data_pic.txt
		rm data_syn.txt
		rm data_spec.txt
		rm data_press.txt
	fi

	if [ -e data_premiere.txt ]
	then
		grep -E "class=\"thumbnail-title\"><strong class=\"item-title\">" data_premiere.txt > data_tit.txt
		sed -e 's+[^ ]*">++g' -i data_tit.txt
		sed -e 's+[^ ]*"++g' -i data_tit.txt
		sed -e 's+[^ ]*<a++g' -i data_tit.txt
		sed -e 's+<[^ ]*++g' -i data_tit.txt
		sed -e 's+[^ ]*\ \ ++g' -i data_tit.txt
		sed -e "s+&#039;+'+g" -i data_tit.txt
		sed -e "s+\&amp;+\&+g" -i data_tit.txt
		wc -l data_tit.txt > n.txt
		sed -e 's+\ data_tit.txt++g' -i n.txt
		n=`grep -E '[0-99]' n.txt`
		rm n.txt
		printf "analysing %s movies..\n" "$n"

		grep -E "tabindex=\"0\">Bandes-annonces</a>" data_premiere.txt > data_ban.txt
		sed -e 's+<a\ href="+http://www.premiere.fr+g' -i data_ban.txt
		sed -e 's+"\ tabindex="0">Bandes-annonces</a>++g' -i data_ban.txt
		i=1
		while read ban; do
			curl $ban > data_curltmp$i.txt
			echo "curling :: $ban"
			grep -E -B1 "<meta\ property=\"position\"\ content=\"3\"\ />" data_curltmp$i.txt > data_typtmp$i.txt
			grep -E -A9 "internautes" data_curltmp$i.txt > data_rattmp$i.txt
			rm data_curltmp$i.txt
			grep -E ">[^ ]*<" data_typtmp$i.txt > data_typtm$i.txt
			grep -E "rating-value" data_rattmp$i.txt > data_rattm$i.txt
			rm data_typtmp$i.txt
			rm data_rattmp$i.txt
			sed -e 's+\ +_+g' -i data_typtm$i.txt
			sed -e 's+[^ ]*"name">++g' -i data_typtm$i.txt
			sed -e 's+<[^ ]*++g' -i data_typtm$i.txt
			sed -e 's+_+\ +g' -i data_typtm$i.txt
			sed -e "s+&#039;+'+g" -i data_typtm$i.txt
			typ=`grep -E "[^ ]*" data_typtm$i.txt`
			tee -a data_typ.txt <<< $typ
			rm data_typtm$i.txt
			sed -e 's+\ +_+g' -i data_rattm$i.txt
			sed -e 's+[^ ]*\">++g' -i data_rattm$i.txt
			sed -e 's+_([^ ]*+/5+g' -i data_rattm$i.txt
			rat=`grep -E "[^ ]*" data_rattm$i.txt`
			tee -a data_rat.txt <<< $rat
			rm data_rattm$i.txt
			((i++))
		done < data_ban.txt 

		paste data_tit.txt data_ban.txt data_typ.txt data_rat.txt | while IFS="$(printf '\t')" read -r f1 f2 f3 f4
		do
			printf "Titre : %s\n" "$f1"
			printf "	bande-annonce : %s\n" "$f2"
			printf "	genre : %s\n" "$f3"
			printf "	note : %s\n\n" "$f4"
		done > ana_premiere.txt
		rm data_tit.txt
		rm data_ban.txt
		rm data_typ.txt
		rm data_rat.txt
	fi

	if [ -e data_telerama.txt ]
	then
		grep -E "rel=\"conserver-contexte-recherche\">" data_telerama.txt > data_tit.txt
		sed -e 's+\ +_+g' -i data_tit.txt
		sed -e 's+[^ ]*recherche">++g' -i data_tit.txt
		sed -e 's+<[^ ]*++g' -i data_tit.txt
		sed -e 's+_+\ +g' -i data_tit.txt
		sed -e "s+&#039;+'+g" -i data_tit.txt
		sed -e "s+\&amp;+\&+g" -i data_tit.txt
		wc -l data_tit.txt > n.txt
		sed -e 's+\ data_tit.txt++g' -i n.txt
		n=`grep -E '[0-99]' n.txt`
		rm n.txt
		printf "analysing %s movies..\n" "$n"

		grep -E -A1 "Réalisé" data_telerama.txt > data_temp.txt
		sed -i '/Réalisé/c\' data_temp.txt
		echo "--" >> data_temp.txt
		sed -e 's+data-href="[^ ]*++g' -i data_temp.txt
		sed -e 's+\ +_+g' -i data_temp.txt
		sed -e 's+____________________Avec_________<a__class="obf"><span_itemprop="name">++g' -i data_temp.txt
		sed -e 's+<a__class="obf"><span_itemprop="name">++g' -i data_temp.txt
		sed -e 's+</span></a>++g' -i data_temp.txt
		sed -e 's+__________</p>++g' -i data_temp.txt
		sed -e 's+_+\ +g' -i data_temp.txt
		sed -e "s+&#039;+'+g" -i data_temp.txt
		sed -e "s+\&amp;+\&+g" -i data_temp.txt
		grep -E "\ " data_temp.txt > data_act.txt
		rm data_temp.txt

		grep -E "<span\ itemprop=\"genre\">" data_telerama.txt > data_typ.txt
		sed -e 's+\ +_+g' -i data_typ.txt
		sed -e 's+[^ ]*genre">++g' -i data_typ.txt
		sed -e 's+<[^ ]*++g' -i data_typ.txt
		sed -e "s+&#039;+'+g" -i data_typ.txt
		sed -e "s+\&amp;+\&+g" -i data_typ.txt
		sed -e 's+_+\ +g' -i data_typ.txt

		paste data_tit.txt data_act.txt data_typ.txt | while IFS="$(printf '\t')" read -r f1 f2 f3
		do
			printf "Titre : %s\n" "$f1"
			printf "	acteurs/rôles : %s\n" "$f2"
			printf "	genre : %s\n\n" "$f3"
		done > ana_telerama.txt
		rm data_tit.txt
		rm data_act.txt
		rm data_typ.txt
	fi

	if [ -e data_senscritique.txt ]
	then
		grep -E -A30 "id=\"product-title-" data_senscritique.txt > data_senstmp.txt

		grep -E "id=\"product-title-" data_senstmp.txt > data_tit.txt
		sed -e 's+\ +_+g' -i data_tit.txt
		sed -e 's+[^ ]*">++g' -i data_tit.txt
		sed -e 's+<[^ ]*++g' -i data_tit.txt
		sed -e 's+_+\ +g' -i data_tit.txt
		sed -e "s+&#039;+'+g" -i data_tit.txt
		sed -e "s+\&amp;+\&+g" -i data_tit.txt
		wc -l data_tit.txt > n.txt
		sed -e 's+\ data_tit.txt++g' -i n.txt
		n=`grep -E '[0-99]' n.txt`
		rm n.txt
		printf "analysing %s movies..\n" "$n"

		grep -E "Sortie : <time datetime=" data_senstmp.txt > data_out.txt
		sed -e 's+\ +_+g' -i data_out.txt
		sed -e 's+\	+_+g' -i data_out.txt
		sed -e 's+[^ ]*_>++g' -i data_out.txt
		sed -e 's+<[^ ]*++g' -i data_out.txt
		sed -e "s+&#039;+'+g" -i data_out.txt
		sed -e "s+\&amp;+\&+g" -i data_out.txt
		sed -e 's+_+\ +g' -i data_out.txt

		
		grep -E "de\ <a\ href=\"" data_senstmp.txt > data_real.txt
		sed -e 's+\ +_+g' -i data_real.txt
		sed -e 's+\	+_+g' -i data_real.txt
		sed -e 's+[^ ]*">++g' -i data_real.txt
		sed -e 's+<[^ ]*++g' -i data_real.txt
		sed -e "s+&#039;+'+g" -i data_real.txt
		sed -e "s+\&amp;+\&+g" -i data_real.txt
		sed -e 's+_+\ +g' -i data_real.txt

		grep -E -A1 "title=\"Note\ globale\ pondérée\ sur" data_senscritique.txt > data_tmp.txt
		sed -i '1s/^/--\n/' data_tmp.txt
		sed -e 's+\	\	\	\	\	\	++g' -i data_tmp.txt
		sed -e 's+</a>++g' -i data_tmp.txt
		i=1
		while ((i!=$n+1))
		do
			t=$((3*$i))
			head -$t data_tmp.txt | tail -1
			((i++))
		done > data_rat.txt
		rm data_tmp.txt

		sed -e 's+\ +_+g' -i data_senstmp.txt
		sed -e 's+\	+_+g' -i data_senstmp.txt
		sed -i '/_____<a/c\' data_senstmp.txt
		sed -e 's+_______________<span_class=\"eins-sprite_eins-clock__elco-clock\"_>++g' -i data_senstmp.txt
		sed -i '/__/c\' data_senstmp.txt
		sed -i '/_<\/h2>/c\' data_senstmp.txt
		sed -i '/_<p_class=\"elco-baseline\">/c\' data_senstmp.txt
		sed -e 's+_++g' -i data_senstmp.txt
		sed -e 's+<[^ ]*>++g' -i data_senstmp.txt
		sed -i '1s/^/--\n/' data_senstmp.txt
		sed -e "s+-+_+g" -i data_senstmp.txt
		grep -E -A2 "_" data_senstmp.txt > data_timt.txt
		sed -i '1s/^/--\n/' data_timt.txt
		i=1
		while ((i!=$n+1))
		do
			t=$((4*$i))
			head -$t data_timt.txt | tail -1
			((i++))
		done > data_tim.txt
		rm data_timt.txt

		rm data_senstmp.txt

		paste data_tit.txt data_out.txt data_real.txt data_tim.txt data_rat.txt | while IFS="$(printf '\t')" read -r f1 f2 f3 f4 f5
		do
			printf "Titre : %s\n" "$f1"
			printf "	sortie : %s\n" "$f2"
			printf "	réalisateur/réalisatrice : %s\n" "$f3"
			printf "	durée : %s\n" "$f4"
			printf "	note : %s/5\n\n" "$f5"

		done > ana_senscritique.txt
		rm data_tit.txt
		rm data_out.txt
		rm data_real.txt
		rm data_tim.txt
		rm data_rat.txt


	fi
	echo "analysis done"
}

#web()
#{
#
#}

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
