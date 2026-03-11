#!/bin/bash
#un vector cu fun facts care insoteste logo-ul;
	declare -A funfact
	funfact["dimi"]="Stiai ca 5 minute de lumina naturala dimineata iti reseteaza ceasul biologic? Esti practic o baterie solara umana in curs de incarcare!"
	funfact["pranz"]="Stiai ca o pauza scurta de pranz imbunatateste concentrarea cu 40% pentru restul zilei?"
	funfact["seara"]="Stiai ca mintea umana e mai creativa atunci cand e mai obosita? E momentul perfect pentru idei sau planuri mari!"
	funfact["noapte"]="Creierul lucreaza mai mult noaptea decat ziua pentru a procesa informatiile. Practic, tu dormi, dar subconstientul tau face ore suplimentare!"

	#cream o variabila ora si stocam in aceasta ora curenta (folosind formatarea timestamp-ului)
	printf -v ora "%(%H)T" -1

	case $ora in
		#folosind regex asta inseamna orele 07,08,09 sau 10,11
		0[7-9]|1[0-1]) select="dimi";;
		# ----------;;------------ orele 12,13,14,15,16,17
		1[2-7]) select="pranz";;
		# ------------------------ you get the gist of it
		1[8-9]|2[0-1]) select="seara";;
		#aka restul
		*) select="noapte";;
	esac

	echo "@ko_bot:${funfact[$select]}"
