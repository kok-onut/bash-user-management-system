#!/bin/bash
#genereaza raport.txt in home-ul userului
#contine: nr. fisiere, nr. directoare, dimensiune disc, lista fisiere, data generarii, istoricul de login

source "$SCRIPT_DIR/operatii_csv.sh"

clear
echo "Generare Raport"
echo ""

while true; do
    read -rp "  Nume raport (fara .txt): " nume_raport

    #sterge extensia .txt daca utilizatorul a pus-o
    nume_raport="${nume_raport%.txt}"
    raport="$USER_HOME/${nume_raport}.txt"

   if [ -z "$nume_raport" ]; then
        echo "Numele nu poate fi gol."
    elif [[ ! "$nume_raport" =~ ^[A-Za-z0-9_-]+$ ]]; then
        echo "Numele poate contine doar litere, cifre, _ si -"
    elif [ -e "$raport" ]; then
        # extragem data ultimei modificari
        modif=$(date -r "$raport" +"%d/%m/%Y %H:%M:%S" | cut -d'.' -f1)
        echo ""
        echo "Raportul '$nume_raport.txt' exista deja."
        echo "Ultima modificare: $modif"
        echo ""
        echo "   [1] Suprascrie   [2] Alt nume   [3] Anuleaza"
        echo ""
        read -rp "Optiune: " aux

        if [ "$aux" == "1" ]; then
            echo "   > Se va suprascrie fisierul existent."
            break
        elif [ "$aux" == "3" ]; then
            echo "   > Generare anulata."
            return 0
        else
            echo "   > Te rugam sa introduci un nume nou."
        fi
    else
        break
    fi
done

#stocam datele pe care pe baza carora vom face raportul pt usurinta
#nr total de fisiere
nrfis=$(find "$USER_HOME" -type f | wc -l)
#nr d dir
nrdir=$(find "$USER_HOME" -type d | wc -l)
# excludem folderul radacina
nrdir=$((nrdir - 1))
#spatiul total ocupat
sz=$(du -sh "$USER_HOME" | cut -f1)
#cand a fost generat raportul
realiz=$(date +"%d/%m/%Y %H:%M:%S")

#astea sunt de la sine intelese
id=$(extrage_camp "$C_USER" 1)
email=$(extrage_camp "$C_USER" 4)
creat=$(extrage_camp "$C_USER" 5)
last_login=$(extrage_camp "$C_USER" 6)


#raportul propriu-zis
{
echo "-------------------------------------------------------------"
printf "RAPORT SISTEM\n"
echo "-------------------------------------------------------------"
echo ""
echo "  INFORMATII CONT"
echo "-------------------------------------------------------------"
printf "Utilizator: $C_USER\n"
printf "ID: $id\n"
printf "Email: $email\n"
printf "Cont creat la: $creat\n"
printf "Ultima logare: $last_login\n"
echo ""
echo "  INFORMATII HOME"
echo "-------------------------------------------------------------"
printf "Numar fisiere: $nrfis\n"
printf "Numar directoare: $nrdir\n"
printf "Spatiu ocupat: $sz\n"
echo ""
echo "-------------------------------------------------------------"
echo "  Raport generat la: $realiz"
echo "-------------------------------------------------------------"
} > "$raport"

echo ""
echo "Raport generat: ${raport}"
echo ""
read -rp "  Apasa Enter..." _










