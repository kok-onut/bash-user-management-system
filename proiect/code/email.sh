#!/bin/bash

check=$(command -v sendmail)
if [ "$check" ]; then
	echo -e "\nSe va incerca trimiterea unui mail de confirmare..."
	#mailul efectiv:
	titlu="Confirmare inregistrare"
	mesaj="Multumit pentru ca ni te-ai alaturat, $user!"
	echo -e "From: your_mail@here.lol\nSubject: $titlu\n\n$mesaj" | timeout 5 sendmail "$email"
	if [ $? == 0 ]; then
		echo "Mail trimis cu succes!"
	else
		echo "Eroare la trimiterea mail-lui!"
	fi
else
	echo  "Serviciul sendmail nu este disponibil."
fi
sleep .5s
read

#in esenta merge;
