#!/bin/bash
source "$SCRIPT_DIR/operatii_csv.sh"

#Login:
#  3 incercari parola, daca nu ai nimerit => blocare si exit
#  se pot loga mai multi useri (sau acelasi din terminale diferite) pot fi conectati simultan

#grafica
clear
echo "-------------------------------------------------------------"
echo "LOGIN!"
echo "-------------------------------------------------------------"
echo ""

#self-explanatory
LOGIN_SUCCESS=0
export LOGIN_SUCCESS

read -rp " Nume de utilizator: " user
user="${user// /}"

if ! user_exists "$user"; then
    echo ""
    echo " Utilizatorul '$user' nu este inregistrat."
    sleep 1
    return 0
fi

#daca userul este in alta sesiune? (e online) => anuntam si il lasam sa se logheze
if is_online "$user"; then
    echo ""
    echo " Utilizatorul '$user' are o sesiune activa il alt terminal. "
    echo " Poti continua in noua sesiune."
    echo ""
    sleep 0.8
fi

#parola cu 3 incercari
#parola stocata in baza de date
pars=$(extrage_camp "$user" 3)
inc=3

while [ "$inc" -gt 0 ]; do
    echo ""
    read -rsp "  Parola (incercarea $((4-inc))/3): " input; echo ""
    input=$(echo -n "$input" | sha256sum | sed 's/ .*//')

    if [ "$input" == "$pars" ]; then
        set_online "$user"
        update_login "$user"
        log_history "$user" "LOGIN"

        C_USER="$user"
        LOGIN_SUCCESS=1
        export C_USER LOGIN_SUCCESS

        echo ""
        echo " Bun venit, $user!"
        sleep 0.6
        return 0
    fi

    ((inc--))
    log_history "$user" "FAILED_LOGIN"

    if [ "$inc" -gt 0 ]; then
        echo " Parola incorecta. Mai ai $inc incercari."
    fi
done

clear
echo ""
echo " ACCES BLOCAT — prea multe incercari eronate."
log_history "$user" "BLOCKED_LOGIN"
sleep 1.5
return 1









