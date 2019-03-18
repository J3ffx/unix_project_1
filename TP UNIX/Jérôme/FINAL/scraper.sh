#!/bin/bash

initialisation()
{
		{
			echo "http://www.allocine.fr/film/agenda/WEEK"
			echo "http://www.premiere.fr/Cinema/Films-et-seances/Sorties-Cinema/WEEK"
			echo "https://www.telerama.fr/cine/film_datesortie.php?when%5Bdate%5D=WEEK&when_radios=1"
			echo "https://www.senscritique.com/films/sorties-cinema/WEEK" 
		} > sitelist.txt

}

cleard()
{
	rm -f data*.txt | rm -f site*.txt
}

erase()
{
	rm -f ana*.txt

}

download()
{	
	./scraper.sh -i
		day=$(echo $1 | cut -d/ -f2)
		month=$(echo $1 | cut -d/ -f1)
		year=$(echo $1 | cut -d/ -f3)
		week=$(date -d "$year$month$day" +%V)
		if [ "$2" = 'allocine' -o "$2" = 'allo' -o "$2" = '1' ]
		then
			if [ ! -e data_allocine.txt ]
			then
				grep  'allocine' sitelist.txt > site.txt
				n=`sed "s+WEEK+sem-$year-$month-$day/+g" site.txt`
				curl --silent $n > data_allocine.txt
				rm -f site.txt
			fi
		fi

		if [ "$2" = 'premiere' -o "$2" = 'prem' -o "$2" = '2' ]
		then
			if [ ! -e data_premiere.txt ]
			then
				grep  'premiere' sitelist.txt > site.txt
				n=`sed "s+WEEK+$week/$year+g" site.txt`
				curl --silent $n > data_premiere.txt
				grep -E "tabindex=\"0\">Bandes-annonces</a>" data_premiere.txt > temp.txt
				sed -e 's+<a\ href="+http://www.premiere.fr+g' -i temp.txt
				sed -e 's+"\ tabindex="0">Bandes-annonces</a>++g' -i temp.txt
				i=1
				while read ban; do
					curl --silent -a firefox $ban > data_prem$i.txt
					((i++))
				done < temp.txt
				rm -f temp.txt
				rm -f site.txt
			fi
		fi

		if [ "$2" = 'telerama' -o "$2" = 'tele' -o "$2" = '3' ]
		then
				if [ ! -e data_telerama.txt ]
				then
				i=0
				while true ; do
					grep  'telerama' sitelist.txt > site.txt
					lnk=`sed "s+WEEK+$day/$month/$year+g" site.txt`
					lnk_p=`echo "$lnk&page=$i"`
					curl --silent $lnk_p > data_temp.txt
					cd=`grep -E "Désolé" data_temp.txt  | cut -c 10`
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
				rm -f data_temp.txt
				rm -f site.txt
			fi
		fi

		if [ "$2" = 'senscritique' -o "$2" = 'sens' -o "$2" = '4' ]
		then
			if [ ! -e data_senscritique.txt ]
			then
			i=1
				while true ; do
					grep  'senscritique' sitelist.txt > site.txt
					lnk=`sed "s+WEEK+$year/semaine/$week+g" site.txt`
					lnk_p=`echo "$lnk/page-$i"`
					curl --silent $lnk_p > data_temp.txt
					cd=`grep -E -m 1 'Bande-annonce' data_temp.txt  | cut -c 35`
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
				rm -f data_temp.txt
				rm -f site.txt
			fi
		fi

		if [ "$2" = '-' ]
		then
			if [ ! -e data_allocine.txt ]
			then
				grep  'allocine' sitelist.txt > site.txt
				n=`sed "s+WEEK+sem-$year-$month-$day/+g" site.txt`
				curl --silent $n > data_allocine.txt
				rm -f site.txt
			fi

			if [ ! -e data_premiere.txt ]
			then
				grep  'premiere' sitelist.txt > site.txt
				n=`sed "s+WEEK+$week/$year+g" site.txt`
				curl --silent $n > data_premiere.txt
				grep -E "tabindex=\"0\">Bandes-annonces</a>" data_premiere.txt > temp.txt
				sed -e 's+<a\ href="+http://www.premiere.fr+g' -i temp.txt
				sed -e 's+"\ tabindex="0">Bandes-annonces</a>++g' -i temp.txt
				i=1
				while read ban; do
					curl --silent -a firefox $ban > data_prem$i.txt
					((i++))
				done < temp.txt
				rm -f temp.txt
				rm -f site.txt
			fi

			if [ ! -e data_telerama.txt ]
				then
				i=0
				while true ; do
					grep  'telerama' sitelist.txt > site.txt
					lnk=`sed "s+WEEK+$day/$month/$year+g" site.txt`
					lnk_p=`echo "$lnk&page=$i"`
					curl --silent $lnk_p > data_temp.txt
					cd=`grep -E "Désolé" data_temp.txt  | cut -c 10`
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
				rm -f data_temp.txt
				rm -f site.txt
			fi

			if [ ! -e data_senscritique.txt ]
			then
			i=1
				while true ; do
					grep  'senscritique' sitelist.txt > site.txt
					lnk=`sed "s+WEEK+$year/semaine/$week+g" site.txt`
					lnk_p=`echo "$lnk/page-$i"`
					curl --silent $lnk_p > data_temp.txt
					cd=`grep -E -m 1 'Bande-annonce' data_temp.txt  | cut -c 35`
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
				rm -f data_temp.txt
				rm -f site.txt
			fi
		fi

}

locald()
{	
		./scraper.sh -i
		sed -e 's+http://+htpp://localhost/+g' -i sitelist.txt | sed -e 's+https://+htpp://localhost/+g' -i
		./scraper.sh -t $1 $2
}

analysis()
{
	if [ -e data_allocine.txt ]
	then
		grep -E "fichefilm_gen_cfilm=" data_allocine.txt > ana_tit_allo.txt
		sed -e 's+[^ ]*">++g' -i ana_tit_allo.txt
		sed -e 's+[^ ]*"++g' -i ana_tit_allo.txt
		sed -e 's+[^ ]*<a++g' -i ana_tit_allo.txt
		sed -e 's+<[^ ]*++g' -i ana_tit_allo.txt
		sed -e 's+[^ ]*\ \ ++g' -i ana_tit_allo.txt
		wc -l ana_tit_allo.txt > n.txt
		sed -e 's+\ ana_tit_allo.txt++g' -i n.txt
		n=`grep -E '[0-99]' n.txt`
		rm -f n.txt

		grep -E "width=\"216\"\ height=\"288\"" data_allocine.txt > ana_pic_allo.txt
		sed -e 's+[^ ]*\ \ ++g' -i ana_pic_allo.txt
		sed -e 's+\<img\ class=\"thumbnail-img\"\ ++g' -i ana_pic_allo.txt
		sed -e 's+\ +_+g' -i ana_pic_allo.txt
		sed -e 's+\"_alt=[^ ]*++g' -i ana_pic_allo.txt
		sed -e 's+<src=\"++g' -i ana_pic_allo.txt
		sed -e 's+[^ ]*_data-src=\"++g' -i ana_pic_allo.txt


		grep -E -A7 "<div\ class=\"synopsis\">" data_allocine.txt > data_synt.txt
		sed -e 's+\ +_+g' -i data_synt.txt
		sed -e 's+____________<[^ ]*++g' -i data_synt.txt
		sed -e 's+__________<[^ ]*++g' -i data_synt.txt
		sed -e 's+____________________________++g' -i data_synt.txt
		sed -e 's+____++g' -i data_synt.txt
		sed -e 's+___________________++g' -i data_synt.txt
		sed -e 's+________________++g' -i data_synt.txt
		sed -e 's+___++g' -i data_synt.txt
		grep -E "__" data_synt.txt > ana_syn_allo.txt
		sed -e 's+__++g' -i ana_syn_allo.txt
		sed -e 's+_+\ +g' -i ana_syn_allo.txt
		sed -e "s+\&amp;+\&+g" -i ana_syn_allo.txt
		rm -f data_synt.txt

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
		rm -f data_temp.txt
		rm -f data_tmp.txt

		i=1
		t=2
		while ((i!=$n+1))
		do
			head -$t data_spect.txt | tail -1
			t=$(($t+3))
			((i++))
		done > ana_ras_allo.txt
		rm -f data_spect.txt

		i=1
		t=3
		while ((i!=$n+1))
		do
			head -$t data_presst.txt | tail -1
			t=$(($t+4))
			((i++))
		done > ana_rap_allo.txt
		rm -f data_presst.txt

		sed -e 's+\ ++g' -i ana_ras_allo.txt
		sed -e 's+\	++g' -i ana_ras_allo.txt
		sed -e 's+\ ++g' -i ana_rap_allo.txt
		sed -e 's+\	++g' -i ana_rap_allo.txt

		sed -e 's+,+.+g' -i ana_ras_allo.txt
		sed -e 's+,+.+g' -i ana_rap_allo.txt

		paste ana_tit_allo.txt ana_pic_allo.txt ana_syn_allo.txt ana_rap_allo.txt ana_ras_allo.txt | while IFS="$(printf '\t')" read -r f1 f2 f3 f4 f5
		do
			printf "%s\n" "$f1"
			printf "%s\n" "$f2"
			printf "%s\n" "$f3"
			printf "%s\n" "$f4"
			printf "%s\n\n" "$f5"
		done > ana_allocine.txt
		rm -f ana_pic_allo.txt
		rm -f ana_syn_allo.txt
		rm -f ana_ras_allo.txt
		rm -f ana_rap_allo.txt
	fi

	if [ -e data_premiere.txt ]
	then
		grep -E "class=\"thumbnail-title\"><strong class=\"item-title\">" data_premiere.txt > ana_tit_prem.txt
		sed -e 's+[^ ]*">++g' -i ana_tit_prem.txt
		sed -e 's+[^ ]*"++g' -i ana_tit_prem.txt
		sed -e 's+[^ ]*<a++g' -i ana_tit_prem.txt
		sed -e 's+<[^ ]*++g' -i ana_tit_prem.txt
		sed -e 's+[^ ]*\ \ ++g' -i ana_tit_prem.txt
		wc -l ana_tit_prem.txt > n.txt
		sed -e 's+\ ana_tit_prem.txt++g' -i n.txt
		n=`grep -E '[0-99]' n.txt`
		rm -f n.txt

		i=1
		while ((i!=$n+1)); do
			grep -E -B1 "<meta\ property=\"position\"\ content=\"3\"\ />" data_prem$i.txt > data_typtmp$i.txt
			grep -E -A9 "internautes" data_prem$i.txt > data_rattmp$i.txt
			grep -E ">[^ ]*<" data_typtmp$i.txt > data_typtm$i.txt
			grep -E "rating-value" data_rattmp$i.txt > data_rattm$i.txt
			grep -E "allow" data_prem$i.txt > data_tra$i.txt
			rm -f data_typtmp$i.txt
			rm -f data_rattmp$i.txt

			sed -e 's+\ +_+g' -i data_typtm$i.txt
			sed -e 's+[^ ]*"name">++g' -i data_typtm$i.txt
			sed -e 's+<[^ ]*++g' -i data_typtm$i.txt
			sed -e 's+_+\ +g' -i data_typtm$i.txt
			typ=`grep -E "[^ ]*" data_typtm$i.txt`
			echo "$typ" >> ana_typ_prem.txt
			rm -f data_typtm$i.txt

			sed -e 's+\ +_+g' -i data_rattm$i.txt
			sed -e 's+[^ ]*\">++g' -i data_rattm$i.txt
			sed -e 's+_([^ ]*++g' -i data_rattm$i.txt
			rat=`grep -E "[^ ]*" data_rattm$i.txt`
			echo "$rat" >> ana_rat_prem.txt
			rm -f data_rattm$i.txt

			sed -e 's+\ +_+g' -i data_tra$i.txt
			sed -e 's+[^ ]*src="//+http://+g' -i  data_tra$i.txt
			sed -e 's+0">[^ ]*+1+g' -i  data_tra$i.txt
			tra=`grep -E "[^ ]*" data_tra$i.txt`
			echo "$tra" >> ana_tra_prem.txt
			rm -f data_tra$i.txt
			((i++))
		done

		sed -e 's+,+.+g' -i ana_rat_prem.txt

		paste ana_tit_prem.txt ana_typ_prem.txt ana_rat_prem.txt ana_tra_prem.txt | while IFS="$(printf '\t')" read -r f1 f2 f3 f4
		do
			printf "%s\n" "$f1"
			printf "%s\n" "$f2"
			printf "%s\n" "$f3"
			printf "%s\n\n" "$f4"
		done > ana_premiere.txt
		rm -f ana_tra_prem.txt
		rm -f ana_typ_prem.txt
		rm -f ana_rat_prem.txt
	fi

	if [ -e data_telerama.txt ]
	then
		grep -E "rel=\"conserver-contexte-recherche\">" data_telerama.txt > ana_tit_tele.txt
		sed -e 's+\ +_+g' -i ana_tit_tele.txt
		sed -e 's+[^ ]*recherche">++g' -i ana_tit_tele.txt
		sed -e 's+<[^ ]*++g' -i ana_tit_tele.txt
		sed -e 's+_+\ +g' -i ana_tit_tele.txt
		wc -l ana_tit_tele.txt > n.txt
		sed -e 's+\ ana_tit_tele.txt++g' -i n.txt
		n=`grep -E '[0-99]' n.txt`
		rm -f n.txt

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
		grep -E "\ " data_temp.txt > ana_act_tele.txt
		rm -f data_temp.txt

		grep -E "<span\ itemprop=\"genre\">" data_telerama.txt > ana_typ_tele.txt
		sed -e 's+\ +_+g' -i ana_typ_tele.txt
		sed -e 's+[^ ]*genre">++g' -i ana_typ_tele.txt
		sed -e 's+<[^ ]*++g' -i ana_typ_tele.txt
		sed -e 's+_+\ +g' -i ana_typ_tele.txt

		paste ana_tit_tele.txt ana_act_tele.txt ana_typ_tele.txt | while IFS="$(printf '\t')" read -r f1 f2 f3
		do
			printf "Titre : %s\n" "$f1"
			printf "%s\n" "$f2"
			printf "%s\n\n" "$f3"
		done > ana_telerama.txt
		rm -f ana_act_tele.txt
		rm -f ana_typ_tele.txt
	fi

	if [ -e data_senscritique.txt ]
	then
		grep -E -A30 "id=\"product-title-" data_senscritique.txt > data_senstmp.txt

		grep -E "id=\"product-title-" data_senstmp.txt > ana_tit_sens.txt
		sed -e 's+\ +_+g' -i ana_tit_sens.txt
		sed -e 's+[^ ]*">++g' -i ana_tit_sens.txt
		sed -e 's+<[^ ]*++g' -i ana_tit_sens.txt
		sed -e 's+_+\ +g' -i ana_tit_sens.txt
		wc -l ana_tit_sens.txt > n.txt
		sed -e 's+\ ana_tit_sens.txt++g' -i n.txt
		n=`grep -E '[0-99]' n.txt`
		rm -f n.txt

		grep -E "Sortie : <time datetime=" data_senstmp.txt > ana_out_sens.txt
		sed -e 's+\ +_+g' -i ana_out_sens.txt
		sed -e 's+\	+_+g' -i ana_out_sens.txt
		sed -e 's+[^ ]*_>++g' -i ana_out_sens.txt
		sed -e 's+<[^ ]*++g' -i ana_out_sens.txt
		sed -e 's+_+\ +g' -i ana_out_sens.txt

		
		grep -E "de\ <a\ href=\"" data_senstmp.txt > ana_rea_sens.txt
		sed -e 's+\ +_+g' -i ana_rea_sens.txt
		sed -e 's+\	+_+g' -i ana_rea_sens.txt
		sed -e 's+[^ ]*">++g' -i ana_rea_sens.txt
		sed -e 's+<[^ ]*++g' -i ana_rea_sens.txt
		sed -e 's+_+\ +g' -i ana_rea_sens.txt

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
		done > ana_rat_sens.txt
		rm -f data_tmp.txt

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
		done > ana_tim_sens.txt
		rm -f data_timt.txt

		rm -f data_senstmp.txt

		sed -e 's+,+.+g' -i ana_rat_sens.txt
		sed -e 's+-++g' -i ana_rat_sens.txt
		paste ana_tit_sens.txt ana_out_sens.txt ana_rea_sens.txt ana_tim_sens.txt ana_rat_sens.txt | while IFS="$(printf '\t')" read -r f1 f2 f3 f4 f5
		do
			printf "Titre : %s\n" "$f1"
			printf "%s\n" "$f2"
			printf "%s\n" "$f3"
			printf "%s\n" "$f4"
			printf "%s\n\n" "$f5"

		done > ana_senscritique.txt
		rm -f ana_out_sens.txt
		rm -f ana_rea_sens.txt
		rm -f ana_tim_sens.txt
		rm -f ana_rat_sens.txt
	fi

	sed -e "s+&#039;+'+g" -i ana*.txt
	sed -e "s+\&amp;+\&+g" -i ana*.txt
	sed -e 's+\ \&\ +\&+g' -i ana*.txt
}

web()
{
	printf "<!DOCTYPE html'>" > $2
	printf "<html lang='fr'>" >> $2
	printf "<head>" >> $2
	printf "<meta charset='utf-8' />" >> $2
	printf "<title>Fanf Scraper</title>" >> $2
	printf "<link rel='icon' href='https://d27ucmmhxk51xv.cloudfront.net/media/english/illustration/scraper.jpg?version=1.1.81'>" >> $2
	printf "</head>" >> $2
	printf "<body style='background-color:#694741;''>" >> $2
	printf "<div id='conteneur'>" >> $2
	printf "<div id='contenu'>" >> $2
	touch temp.txt
	l=1
	a=0
	b=0
	c=0
	d=0
	if [ -e ana_allocine.txt -a $l -le $1 ]
	then
		cat ana_tit_allo.txt >> temp.txt
		((a++))
		((l++))
	fi

	if [ -e ana_premiere.txt -a $l -le $1 ]
	then
		cat ana_tit_prem.txt >> temp.txt
		((b++))
		((l++))
	fi
	
	if [ -e ana_telerama.txt -a $l -le $1 ]
	then
		cat ana_tit_tele.txt >> temp.txt
		((c++))
		((l++))
	fi
	
	if [ -e ana_senscritique.txt -a $l -le $1 ]
	then
		cat ana_tit_sens.txt >> temp.txt
		((d++))
		((l++))
	fi

	sort -u temp.txt > tmp.txt
	rm -f temp.txt
	uniq -i -w 5 tmp.txt > web_tit.txt
	rm -f tmp.txt
	wc -l web_tit.txt > n.txt
	sed -e 's+\ web_tit.txt++g' -i n.txt
	n=`grep -E '[0-99]' n.txt`
	rm -f n.txt

	i=1
	while ((i!=$n+1))
		do
			t=`head -$i web_tit.txt | tail -1`
			printf "<h2><font color=#F5F5DC>%s</font></h2>" "$t" >> $2

			if [ $a -ge 1 ]; then
			grep -i -A4 "$t" ana_allocine.txt > tmp$i.txt
			j=2
			ta1=`head -$j tmp$i.txt | tail -1`
			((j++))
			ta2=`head -$j tmp$i.txt | tail -1`
			((j++))
			ta3=`head -$j tmp$i.txt | tail -1`
			((j++))
			ta4=`head -$j tmp$i.txt | tail -1`
			fi

			if  [ $b -ge 1 ]; then
			grep -i -A3 "$t" ana_premiere.txt > tmp$i.txt
			j=2
			tp1=`head -$j tmp$i.txt | tail -1`
			((j++))
			tp2=`head -$j tmp$i.txt | tail -1`
			((j++))
			tp3=`head -$j tmp$i.txt | tail -1`
			fi

			if [ $c -ge 1 ]; then
			grep -i -A2 "$t" ana_telerama.txt > tmp$i.txt
			j=2
			tt1=`head -$j tmp$i.txt | tail -1`
			((j++))
			tt2=`head -$j tmp$i.txt | tail -1`
			fi

			if [ $d -ge 1 ]; then
			grep -i -A4 "$t" ana_senscritique.txt > tmp$i.txt
			j=2
			ts1=`head -$j tmp$i.txt | tail -1`
			((j++))
			ts2=`head -$j tmp$i.txt | tail -1`
			((j++))
			ts3=`head -$j tmp$i.txt | tail -1`
			((j++))
			ts4=`head -$j tmp$i.txt | tail -1`
			fi

			g=$tt2
			if [ ${#tp1} -gt ${#tt2} ]
			then
				g=$tp1
			fi

			printf "<ul>" >> $2
			printf "<li><a href='%s'><font color=#C1B4B1>bande-annonce</font></a></li>" "$tp3" >> $2
			printf "<a href='%s'><img src='%s' /></a></li>" "$tp3" "$ta1" >> $2
			printf "<li><font color=#9A908E>genre : </font><font color=#C1B4B1>%s</font></li>" "$g" >> $2
			printf "<li><font color=#9A908E>synopsis : </font><font color=#C1B4B1>%s</font></li>" "$ta2" >> $2
			printf "<li><font color=#9A908E>réalisateur(s) : </font><font color=#C1B4B1>%s</font></li>" "$ts2" >> $2
			printf "<li><font color=#9A908E>acteurs/rôles : </font><font color=#C1B4B1>%s</font></li>" "$tt1" >> $2
			printf "<li><font color=#9A908E>durée : </font><font color=#C1B4B1>%s</font></li>" "$ts3" >> $2
			printf "<li><font color=#9A908E>sortie le </font><font color=#C1B4B1>%s</font></li>" "$ts1" >> $2
			printf "<li><font color=#9A908E>notes : </font></li>" >> $2
			printf "<ul>" >> $2
			printf "<li><span title='Allociné (Spectateurs)'><font color=#C1B4B1>- %s/5</font></span></li>" "$ta3" >> $2
			printf "<li><span title='Allociné (Presse)'><font color=#C1B4B1>- %s/5</font></span></li>" "$ta4" >> $2
			printf "<li><span title='Première'><font color=#C1B4B1>- %s/5</font></span></li>" "$tp2" >> $2
			printf "<li><span title='Sens critique'><font color=#C1B4B1>- %s/10</font></span></li>" "$ts4" >> $2
			printf "</ul>" >> $2
			printf "</ul>" >> $2
			((i++))		
		done
		rm -f web_tit.txt
		rm -f tmp*.txt
}

hlp()
{
	echo "
Options :

-i		Initialisation du fichier des sites.

-c		Effacement des téléchargements.

-e 		Effacement des analyses.

-t date site	Téléchargement des sorties cinéma du 'site' à la 'date' donnée. Si 'site' est '-' alors on télécharge tous les sites.

-s date site	Comme -t mais en localhost.

-a		Analyse des fichiers préalablement téléchargés.

-w lien page 	Fabrication de la page web qui portera le nom 'page' à partir d'un nombre minimum de sites de 'lien'.

-h		Affichage de cet aide."
}

error()
{
	echo "enter a valid argument, here is the help page :"
	./scraper.sh -h
}

while [ ! -z $1 ] ; do

		case $1 in
			-t)download $2 $3;
			shift 3;;

			-s)locald $2 $3;
			shift 3;;

			-w)web $2 $3;
			shift 3;;

			-i)initialisation;
			shift 1;;

			-c)cleard;
			shift 1;;

			-e)erase;
			shift 1;;

			-a)analysis;
			shift 1;;
			
			-h)hlp;
			shift 1;;

			-r)remove;
			shift 1;;

			*)error;
			exit 0;;
		esac
done