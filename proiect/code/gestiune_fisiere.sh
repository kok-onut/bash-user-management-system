#!/bin/bash
#gestiunea fisierelor din home-ul userului - functii pe care le apelam in prog principal

#daca nu este trimis niciun argument la apelare, default este 'show_tree'
act="${1:-viz_fisiere}"

#functie ajutatoare, daca fisierul nu are extensie adauga un .txt
adauga_txt() 
{
    local f="$1"

    #contine deja punct
    if [[ "$f" == *.* ]]; then
        #are deja extensie -> returnam fara modif
        echo "$f"
    else
        #nu are punct -> modif si punem .
        echo "${f}.txt"
    fi
}

#comanda tree , afiseaza toate dir + fis utilizatorului in froma de tree
viz_fisiere() 
{
    clear
    echo " Fisierele tale "
    echo " ${C_USER}'s home"
    echo ""
    
    # -h adauga dimensiuni lizibile, -F adauga simboluri
    tree -h -F "$USER_HOME"
    read -rp "  Apasa Enter..." _

}

creare_fisier() 
{
    clear
    echo " Creare fisier nou "
    echo ""
    read -rp " Nume fisier (.txt automat daca nu ai extensie): " fname
    fname=$(adauga_txt "$fname")

    local cale="$USER_HOME/$fname"
    if [ -e "$cale" ]; then
        echo " '$fname' exista deja."
    else
        touch "$cale"
        echo " Fisier '$fname' creat."
    fi
    echo ""
    read -rp "  Apasa Enter..." _
}

creare_folder() 
{
    clear
    echo " Creare folder nou "
    echo ""
    read -rp "  Nume folder: " dname
    dname="${dname// /_}"

    local cale="$USER_HOME/$dname"
    if [ -e "$cale" ]; then
        echo " '$dname' exista deja."
    else
        mkdir -p "$cale"
        echo " Folder '$dname' creat."
    fi
    echo ""
    read -rp "  Apasa Enter..." _
}

scriere_fisier() 
{
    clear
    echo " Scriere in fisier"
    echo ""

    mapfile -t fis < <(find "$USER_HOME" -type f | sed "s|$USER_HOME/||" | sort)
    if [ "${#fis[@]}" -eq 0 ]; then
        echo "Nu exista fisiere."; sleep 1; return
    fi



    echo "  Alege fisierul pentru editare:"
    for i in "${!fis[@]}"; do printf "  [%d] %s\n" "$((i+1))" "${fis[$i]}"; done
    read -rp "  Numar: " sel
    local idx=$((sel-1))


    if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#fis[@]}" ]; then
        nano "$USER_HOME/${fis[$idx]}"
    else
        echo " Selectie invalida."; sleep 1
    fi
}

citeste_fisier() 
{
    clear
    echo "Citire fisier"
    echo ""

    mapfile -t fis < <(find "$USER_HOME" -type f | sed "s|$USER_HOME/||" | sort)
    if [ "${#fis[@]}" -eq 0 ]; then
        echo "  Nu exista fisiere."; sleep 1; return
    fi

    echo " Alege fisierul pentru citire:"
    for i in "${!fis[@]}"; do printf "  [%d] %s\n" "$((i+1))" "${fis[$i]}"; done
    read -rp "  Numar: " sel
    local idx=$((sel-1))

    if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#fis[@]}" ]; then
        less -R "$USER_HOME/${fis[$idx]}"
    else
        echo " Selectie invalida."; sleep 1
    fi
}

redenumire() 
{
    clear
    echo "Redenumire fisier/folder"
    echo ""

    # listeaza tot ce exista in home
    mapfile -t vect < <(find "$USER_HOME" -mindepth 1 | sed "s|$USER_HOME/||" | sort)
    if [ "${#vect[@]}" -eq 0 ]; then
        echo " Niciun fisier sau folder."
        echo ""; read -rp "  Apasa Enter..." _; return
    fi

    echo "  Disponibile:"
    for i in "${!vect[@]}"; do
        printf "    [%d] %s\n" "$((i+1))" "${vect[$i]}"
    done

    echo ""
    read -rp "  Alegere (numar): " sel
    local idx=$((sel-1))
    if [ "$idx" -lt 0 ] || [ "$idx" -ge "${#vect[@]}" ]; then
        echo "Selectie invalida."; sleep 0.5; return
    fi

    local v_name="${vect[$idx]}"
    local v_path="$USER_HOME/$v_name"

    read -rp "  Nume nou: " n_name
    #pastreaza extensia daca e fisier .txt si noul nume n-are extensie
    if [[ "$v_name" == *.txt ]] && [[ "$n_name" != *.* ]]; then
        n_name="${n_name}.txt"
    fi

    local n_path="$USER_HOME/$n_name"
    if [ -e "$n_path" ]; then
        echo " Exista deja '$n_name'."
    else
        mv "$v_path" "$n_path"
        echo " '$v_name' -> '$n_name'"
    fi
    echo ""
    read -rp "  Apasa Enter..." _
}

stergere() 
{
    clear
    echo "Stergere fisier/folder"
    echo ""

    mapfile -t vect < <(find "$USER_HOME" -mindepth 1 | sed "s|$USER_HOME/||" | sort)
    if [ "${#vect[@]}" -eq 0 ]; then
        echo "  Niciun fisier sau folder."
        echo ""; read -rp "  Apasa Enter..." _; return
    fi

    echo "  Disponibile:"
    for i in "${!vect[@]}"; do
        printf "    [%d] %s\n" "$((i+1))" "${vect[$i]}"
    done

    echo ""
    read -rp "  Alegere (numar): " sel
    local idx=$((sel-1))
    if [ "$idx" -lt 0 ] || [ "$idx" -ge "${#vect[@]}" ]; then
        echo "Selectie invalida."; sleep 0.5; return
    fi

    local name="${vect[$idx]}"
    local path="$USER_HOME/$name"

    echo ""
    if [ -d "$path" ]; then
        local cnt
        cnt=$(find "$path" -mindepth 1 | wc -l)
        echo "Folder-ul '$name' contine $cnt element(e)."
    fi
    echo "  Vrei sa stergi '$name'?"
    echo "  [0] Da   [1] Nu"
    echo ""
    read -rp "  Optiune: " ok
    if [ "$ok" == "0" ]; then
        rm -rf "$path"
        echo " '$name' sters."
    else
        echo "  Anulat."
    fi
    echo ""
    read -rp "  Apasa Enter..." _
}


case "$act" in
    viz_fisiere)  viz_fisiere;;
    creare_fisier)  creare_fisier;;
    creare_folder) creare_folder;;
    scriere_fisier) scriere_fisier;;
    citeste_fisier) citeste_fisier;;
    redenumire) redenumire;;
    stergere) stergere;;
esac

