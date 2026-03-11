#!/bin/bash

#meniu pentru user dupa autentificare

source "$SCRIPT_DIR/operatii_csv.sh"

#prima data cand se apeleaza script-ul se va crea dir de home al utilizatorului
USER_HOME="$ROOT_DIR/desktop/${C_USER}'s home"
mkdir -p "$USER_HOME"

while true; do
    clear
    #header cu info user
    id=$(extrage_camp "$C_USER" 1)
    last_login=$(extrage_camp "$C_USER" 6)
    echo "-------------------------------------------------------------"
    printf  "$C_USER  (ID: $id)\n"
    printf  "Ultima conectare: $last_login\n"
    echo "-------------------------------------------------------------"
    echo ""
    echo "-----Fisiere-------------------------------------------------"
    echo "  [1] Vezi fisierele"
    echo "  [2] Creeaza fisier"
    echo "  [3] Creeaza folder"
    echo "  [4] Scrie intr-un fisier"
    echo "  [5] Citeste un fisier"
    echo "  [6] Redenumeste fisier/folder"
    echo "  [7] Sterge fisier/folder"
    echo ""
    echo "-----Sistem--------------------------------------------------"
    echo "  [8]  Genereaza raport"
    echo "  [9] Utilizatori online"
    echo "  [10] Activity log-ul meu"
    echo "  [0]  Deconectare"
    echo ""
    read -rp "  Optiune: " opt

    case "$opt" in
        1)  source "$SCRIPT_DIR/gestiune_fisiere.sh" viz_fisiere ;;
        2)  source "$SCRIPT_DIR/gestiune_fisiere.sh" creare_fisier ;;
        3)  source "$SCRIPT_DIR/gestiune_fisiere.sh" creare_folder ;;
        4)  source "$SCRIPT_DIR/gestiune_fisiere.sh" scriere_fisier ;;
        5)  source "$SCRIPT_DIR/gestiune_fisiere.sh" citeste_fisier ;;
        6)  source "$SCRIPT_DIR/gestiune_fisiere.sh" redenumire ;;
        7)  source "$SCRIPT_DIR/gestiune_fisiere.sh" stergere ;;
        8)  source "$SCRIPT_DIR/raport.sh" ;;
        9)
            clear
            echo "-----Utilizatori Online--------------------------------------------------"
            echo ""
            cnt=0
            #afisam sesiuni unice (un user poate aparea de mai multe ori daca are sesiuni multiple)
            prev_user=""
            while IFS=',' read -r username login pid; do
                if [ "$username" != "$prev_user" ]; then
                    #nr-ul de sesiuni ale unui util
                    nr=$(grep "^${username}," "$ONLINE_CSV" | wc -l)
                    if [ "$nr" -gt 1 ]; then
                        printf "$username este online! | de la:$login nr  sesiuni: $nr\n"
                    else
                        printf "$username este online! | de la:$login\n"
                    fi
                    prev_user="$username"
                    ((cnt++))
                fi
            done < <(list_online | sort -t',' -k1)
            if [ "$cnt" -eq 0 ]; then
                echo "  Niciun utilizator online."
            fi
            echo ""
            read -rp "  Apasa Enter..." _
            ;;
        10)
            clear
            echo "--------Activity Log---$C_USER------------------"
            show_user_log "$C_USER" 30
            read -rp "  Apasa Enter..." _
            ;;
        0)
            set_offline "$C_USER"
            log_history "$C_USER" "LOGOUT"
            LOGIN_SUCCESS=0
            export LOGIN_SUCCESS
            clear
            echo "  La revedere, $C_USER!"
            sleep 0.8
            return 0
            ;;
        *)  ;;
    esac
done
