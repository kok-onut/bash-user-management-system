#!/bin/bash

#cream functii cu operatii pe csv-uri pentru a ne face treaba mai usoara

#operatii user-related
#verifica daca un utilizator exista, $1 -> reprezinta username-ul

#user_exists()
#{
#   grep -qi "^[^,]*,$1," "$USERS_CSV"
#}
#scrap that, mai bine folosim variabile locale pentru o mai buna intelegere a codului

user_exists()
{
    #declaram cu local o variabila
    local username="$1"
    grep -qi "^[^,]*,${username}," "$USERS_CSV"
}

#extrage campul unde:
#   1 - id
#   2 - username
#   3 - parola
#   4 - email
#   5 - data crearii
#   6 - last login
extrage_camp()
{
    local user="$1"
    local camp="$2"
    #daca gaseste, prin absurd, 2 utilizatori cu acelasi nume il extrage pe primul;
    #',' separator si extrage field-ul 
    grep -i "^[^,]*,${user}," "$USERS_CSV" | head -1 | cut -d',' -f"$camp"
}

#adauga utilizator
add_user() 
{
    local id="$1" user="$2" pass="$3" email="$4"
    local created
    created=$(date +"%d/%m/%Y %H:%M:%S")
    echo "${id},${user},${pass},${email},${created},-" >> "$USERS_CSV"
}

#update_login -> schimba last login-ul cu data curenta a unui utilizator al carui nume il precizam in primul argument al functiei
update_login() 
{
    local user="$1"
    local nou
    nou=$(date +"%d/%m/%Y %H:%M:%S")
    sed -i "s|^\([^,]*,${user},[^,]*,[^,]*,[^,]*,\).*|\1${nou}|" "$USERS_CSV"
}

#generam un id unic pentru fiecare utilizator
genereaza_id()
{
    local nou
    #cine stie, poate avem 2 id-uri generate identic, nu putem risca asta
    
    while true
    do
        #generam un numar intre 100k si 999k
        nou=$((100000 + RANDOM % 900000))
        #de ce nu am folosit []? -> posibila intrebare
        #pentru ca grep-ul deja returneaza adev sau fals
        if ! grep -q "^${nou}," "$USERS_CSV"
        then
            echo "$nou"
            return
        fi
    done
}

# + stergem utilizatorul

#din csv + directorul lui home de pe disk
stergere_user() 
{
    local user="$1"
    sed -i "/^[^,]*,${user},/d" "$USERS_CSV"
    offline_all "$user"

    rm -rf "$ROOT_DIR/desktop/${user}'s home"
    log_history "$user" "ACCOUNT_DELETED"
}


#operatii pid related, online/offline, sesiuni bash
# pid -> process id, cand rulam o aplicatie, sistemul ii atribuie un id nou, sesiunile le contorizam dupa pid

#you already know
set_online() 
{
    local user="$1"
    local data="$( date +"%d/%m/%Y %H:%M:%S" )"
    local pid="$$" #afiseaza procesul curent
    #sterge o intrare veche din aceeasi sesiune
    sed -i "/^${user},[^,]*,${pid}$/d" "$ONLINE_CSV"
    echo "${user},${data},${pid}" >> "$ONLINE_CSV"
}

#scoate doar sesiunea curenta -> nu afecteaza alte sesiuni ale aceluia si user
set_offline() 
{
    local user="$1"
    local pid="$$"
    sed -i "/^${user},[^,]*,${pid}$/d" "$ONLINE_CSV"
}

#scoate toate sesiunile unui user -> pt stergere de cont
offline_all() 
{
    local user="$1"
    sed -i "/^${user},/d" "$ONLINE_CSV"
}

#verifica daca un user e online
is_online() 
{
    local user="$1"
    grep -q "^${user}," "$ONLINE_CSV"
}

#afiseaza tot continutul din online.csv EXCLUZAND header-ul
list_online() 
{
    tail -n +2 "$ONLINE_CSV"
}


#operatii activity realated pentru activity log
log_history()
{
    local user="$1"
    local actiune="$2"
    local data
    local ip
    data=$(date +"%d/%m/%Y %H:%M:%S")

    #activeaza daca CHIAR iti doresti adresa de ip in activity log
    #ip=$(hostname -I | awk '{print $1}')
    #if [ -z "$ip" ]; then
    #   ip="local"
    #   echo "Nu te-ai conenctat la retea." >> "$HISTORY_CSV"
    #fi
    ip="Confidential"
    echo "${data},${user},${actiune},${ip}" >> "$HISTORY_CSV"
}

#afiseaza history log pentru ultimele k actiuni sau 20(default value)
show_log() 
{
    local cnt="${1:-20}"
    echo ""
    printf "  %-22s %-20s %-20s %-15s\n" "Data" "User" "Actiune" "IP"
    
    echo "---------------------------------------------------------"
    # \ -> impartim comanda
    tail -n +2 "$HISTORY_CSV" | tail -n "$cnt" | \
    while IFS=',' read -r d user act ip; do
        printf "  %-22s %-20s %-20s %-15s\n" "$d" "$user" "$act" "$ip"
    done
    echo ""
}

#similar- doar activitatea unui utilizator introdus ca param
show_user_log() {
    local user="$1" 
    local cnt="${2:-20}"
    echo ""
    printf "  %-22s %-20s %-15s\n" "Data" "Actiune" "IP"
    echo "---------------------------------------------------------"
    grep ",${user}," "$HISTORY_CSV" | tail -n "$cnt" | \
    while IFS=',' read -r d user act ip; do
        printf "  %-22s %-20s %-15s\n" "$d" "$act" "$ip"
    done
    echo ""
}

#afisam tabela users
show_users_table() {
    echo ""
    printf "  %-10s %-20s %-28s %-20s %-20s\n" \
        "ID" "User" "Email" "Data crearii " "Ultima conectare"

    echo "---------------------------------------------------------"

    tail -n +2 "$USERS_CSV" | \
    while IFS=',' read -r id user pass email creare last; do
        local online_notif=""
        is_online "$user" && online_notif=" !"
        printf "  %-10s %-20s %-28s %-20s %-20s%s\n" \
            "$id" "$user" "$email" "$creare" "$last" "$online_notif"
    done
    echo ""
}










