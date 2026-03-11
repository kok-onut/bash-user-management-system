#!/bin/bash
source "$SCRIPT_DIR/operatii_csv.sh"

#grafica
clear
echo "-------------------------------------------------------------"
echo "INREGISTRARE!"
echo "-------------------------------------------------------------"
echo ""


#username
#   minim 3 caractere, maxim 20
#   litere + cifre
#   unic -> apelam user_exists()

while true; do
    read -rp "  Nume de utilizator: " user
    #eliminam spatiile, nu vrem sa avem ko si ko_ 
    user="${user// /}"   # trim spatii

    if user_exists "$user"; then
        echo " Utilizatorul '$user' exista deja."
        sleep 0.5
        echo ""
    elif [ "${#user}" -lt 3 ]; then
        echo " Minim 3 caractere."
        sleep 0.5 
        echo ""
    elif [ "${#user}" -gt 20 ]; then
        echo " Maximum 20 caractere."
        sleep 0.5 
        echo ""
    elif [[ ! "$user" =~ ^[A-Za-z0-9]+$ ]]; then
        echo " Numele de utilizator trebuie sa contina doar litere si cifre. (fara spatii sau @#$% etc.)."
        sleep 0.5
        echo ""
    else
        #iesim din bucla infinita daca suntem satisfacuti cu user-ul
        break
    fi
done


#parola
#   litere + cifre + simboluri
#   minim 8 caractere
#   + confirmare
#   hash pt securitate

while true; do
    #silent, sa nu vada
    read -rsp " Creeaza o parola: " pass; echo ""
    if [[ ! "$pass" =~ ^[A-Za-z0-9_@-]+$ ]]; then
        echo " Contine caractere interzise! (parola poate contin: litere, cifre, _@-) "
        sleep 0.5
    elif [ "${#pass}" -lt 5 ]; then
        echo " Minim 5 caractere."
        sleep 0.5
    else
        read -rsp " Confirma parola: " aux; echo ""
        if [ "$pass" != "$aux" ]; then
            echo " Parolele nu coincid."
            sleep 0.5
        else
            break
        fi
    fi
done

#pass_hash + eliminare chesii ciudate de la sfarsitul parolei ___- cv de genul
pass_hash=$(echo -n "$pass" | sha256sum | sed 's/ .*//')

#email
#   respecta structura unui email
#   [ceva] @ [ceva] . [ceva]

while true; do
    read -rp " Introdu o adresa de email: " email
    if [[ "$email" =~ ^[a-zA-Z0-9._]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        break
    else
        echo " Adresa email invalida."
        sleep 0.5
    fi
done

#salvarea datelor in fisierul users.csv
new_id=$(genereaza_id)
add_user "$new_id" "$user" "$pass_hash" "$email"

# creeam directorul home al userului
user_home="$ROOT_DIR/desktop/${user}'s home"
mkdir -p "$user_home"

# Log
log_history "$user" "INREGISTRARE"


echo ""
echo " Cont creat cu succes!"
echo " ID: $new_id; Username: $user"
#source "$SCRIPT_DIR/email.sh" -> asta are nevoie de setup, nu am throwaway de dat pe moca ;) read documentation pentru implementare;
echo ""
read -rp "  Apasa ENTER pentru a continua..." _



