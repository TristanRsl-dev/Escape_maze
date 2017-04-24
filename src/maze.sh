#!/bin/bash

#draw a map from a .txt file (specs to create your own map are in the README.md)
#'x' represent a wall
#' ' represent a case with no danger
#'m' represent a case with a monster
#'A' represent our friend, Aston
draw_map() {
    #FUNC ARGS
    local file_map="$1"
    #END  ARGS

    exec 6< ${file_map}

    #read the first line that contains the size of the map
    read map_size <&6

    #read the second line that contains the initial position of the player
    read player_position <&6

    #read the following lines that contains positions of monsters
    local monsters_positions="()"
    while read monster_position; do
        monsters_positions+=("${monster_position}")
    done <&6

    #draw the map following parameters
    map_size_x="$(getInfo "${map_size}" x)"
    map_size_y="$(getInfo "${map_size}" y)"
    for column in $(seq 0 ${map_size_x}); do
        for row in $(seq 0 ${map_size_y}); do
            if [[ 0 == ${column} || 0 == ${row} \
            || ${map_size_x} == ${column} || ${map_size_y} == ${row} ]]; then
                echo -n 'x'
            elif [[ "$(getInfo "${player_position}" x)" == ${column} \
            && "$(getInfo "${player_position}" y)" == ${row} ]]; then
                echo -n "A"
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
