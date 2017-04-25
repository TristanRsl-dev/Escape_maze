#!/bin/bash

#draw a map from a .txt file (specs to create your own map are in the README.md)
#'-' represent a wall
#' ' represent a case with no danger
#'M' represent a case with a monster
#'A' represent our friend, Aston
#'O' represent the exit
draw_map() {
    #FUNC ARGS
    local file_map="$1"
    #END  ARGS

    exec 6< ${file_map}

    #read the first line that contains the size of the map
    read map_size <&6

    #read the second line that contains the initial position of the player
    read player_position <&6

    #read the third line that contains the exit
    read out_position <&6

    #read the following lines that contains positions of monsters
    local monsters_positions="()"
    while read monster_position; do
        monsters_positions+=("${monster_position}")
    done <&6

    #draw the map following parameters
    map_size_x="$(getInfo "${map_size}" x)"
    map_size_y="$(getInfo "${map_size}" y)"
    for row in $(seq 0 ${map_size_y}); do
        for column in $(seq 0 ${map_size_x}); do
            if [[ "${out_position}" != "${column} ${row}" \
            && (0 == ${column} || 0 == ${row} \
            || ${map_size_x} == ${column} || ${map_size_y} == ${row}) ]]; then
                echo -n '-'
            elif [[ "${player_position}" == "${column} ${row}" ]]; then
                echo -n "A"
            elif [[ "${out_position}" == "${column} ${row}" ]]; then
                echo -n "O"
            else
                echo -n " "
            fi
        done
        echo ""
    done
}

#return the specified element from the couple passed as argument (x or y)
getInfo() {
    #FUNC ARGS
    local coordonate="$1"
    local element_number="$2"
    #END  ARGS

    #split coordonate
    local x="$(echo ${coordonate} | cut -d ' ' -f1)";
    local y="$(echo ${coordonate} | cut -d ' ' -f2)";

    if [[ "x" == "${element_number}" ]]; then
        echo "${x}"
    elif [[ "y" == "${element_number}" ]]; then
        echo "${y}"
    fi
}

draw_map $@
