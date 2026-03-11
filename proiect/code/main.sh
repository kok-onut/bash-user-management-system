#!/bin/bash
#am structurat proiectul astfel:
#bash: -> folderul unde se afla tot proiectul
#	code: -> un folder care contine toate scripturile, la inceput doar main.sh
#	desktop: -> aici vor aparea directoarele home ale utilizatorilor
#	security: -> chestii legate de credentiale, login history si statusul usrilor, daca sunt online sau nu

#variabila care stocheaza adresa dir unde se afla scriptul, necesar pentru realizarea proiectului utilizand adrese absolute (pt crearea structurii)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

#variabila care stocheaza adresa directorului unde se afla proiectul
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

#exportam variabilele
export ROOT_DIR SCRIPT_DIR

#test:
#echo "$SCRIPT_DIR"
#echo "$ROOT_DIR"

#cream structura
#magicul -p -> daca dir nu exista -> le creeaza; daca da -> nu face nmk, nici nu afis eroare
#also valid cu if [ ! -d ] but it looks cleaner;
mkdir -p "$ROOT_DIR/desktop"
mkdir -p "$ROOT_DIR/security"

#stocam adresele pentru fisierele de securitate -> implementam absolut !!!
export USERS_CSV="$ROOT_DIR/security/users.csv"
export HISTORY_CSV="$ROOT_DIR/security/login_history.csv"
export ONLINE_CSV="$ROOT_DIR/security/online.csv"

#daca fisierele nu exista la adresa mentionata (sau daca au fost create cu typo-uri in nume -> le cream din nou si adaugam headerele
if [ ! -f "$USERS_CSV" ]
then
	echo "id,user,pass,email,data_crearii,last_login" > "$USERS_CSV"
fi

if [ ! -f "$HISTORY_CSV" ]
then
	echo "timp,user,act,ip" > "$HISTORY_CSV"
fi

if [ ! -f "$ONLINE_CSV" ]
then
	echo "user,timp,pid" > "$ONLINE_CSV"
fi

#curatare, daca utilizatorul nu s-a delogat manual, o facem noi aici
{
    #preluam header-ul
    head -1 "$ONLINE_CSV"
    tail -n +2 "$ONLINE_CSV" | while IFS=',' read -r user d pid; do
        #verificam daca mai traieste procesul cu pid-ul respectiv
        kill -0 "$pid" && echo "${user},${d},${pid}"
    done
} > "${ONLINE_CSV}.tmp" && mv "${ONLINE_CSV}.tmp" "$ONLINE_CSV"

#loop principal

source "$SCRIPT_DIR/operatii_csv.sh"

while true; do
    clear
    echo ""
    echo "----------------------------------------------------------------------------"
    echo "  SISTEM DE GESTIUNE"
    printf "    %(%d-%m-%Y)T\n" -1
    echo ""
    # Utilizatori online (unici)
    useri_online=$(tail -n +2 "$ONLINE_CSV" | cut -d',' -f1 | sort -u)
    nr=$(echo "$useri_online" | grep -c . || echo 0)
    if [ -z "$useri_online" ]; then
        nr=0
    fi

    if [ "$nr" -gt 0 ]; then
        nume=$(echo "$useri_online" | paste -sd ', ')
        echo "  [!] Online ($nr): $nume"
    else
        echo "  [X] Niciun utilizator online"
    fi
    echo ""
    source "$SCRIPT_DIR/greeting.sh"
     echo "----------------------------------------------------------------------------"
    echo ""
    echo "  [1] Inregistrare"
    echo "  [2] Autentificare"
    echo "  [3] Resetare sistem"
    echo "  [0] Iesire"
    echo ""
    read -rp "Optiune: " aux

    case "$aux" in
        1)
            LOGIN_SUCCESS=0
            source "$SCRIPT_DIR/inregistrare.sh"
            ;;
        2)
            LOGIN_SUCCESS=0
            source "$SCRIPT_DIR/login.sh"
            if [ "$LOGIN_SUCCESS" == "1" ]; then
                source "$SCRIPT_DIR/meniu_user.sh"
            fi
            ;;
        3)
            clear
            echo "  ATENTIE! Se vor sterge TOATE datele."
            echo ""
            echo "  [0] DA, reseteaza tot"
            echo "  [1] NU, inapoi"
            echo ""
            read -rp "Optiune: " ok
            if [ "$ok" == "0" ]; then
                rm -f "$USERS_CSV" "$HISTORY_CSV" "$ONLINE_CSV"
                if [ -d "$ROOT_DIR/desktop" ]; then
                    rm -rf "$ROOT_DIR/desktop/"*
                fi
                echo "  Sistem resetat. Repornire..."
                sleep 1
                exec bash "$SCRIPT_DIR/main.sh"
            fi
            ;;
        0)
            clear
            exit 0
            ;;
    esac
done


