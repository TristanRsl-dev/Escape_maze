#!/bin/bash

#GLOBAL VARIABLE
PLAYER_POSITION=""
EXIT_POSITION=""
MAP_SIZE_X=""
MAP_SIZE_Y=""
MONSTERS_POSITIONS=""
#END

init_map() {
    #FUNC ARGS
    local file_map="$1"
    #END  ARGS

    exec 6< ${file_map}

    #read the first line that contains the size of the map
    read map_size <&6

    #read the second line that contains the initial position of the player
    read player_position <&6
    PLAYER_POSITION="${player_position}"

    #read the third line that contains the exit
    read exit_position <&6
    EXIT_POSITION="${exit_position}"

    #read the following lines that contains positions of monsters
    local monsters_positions=()
    while read monster_position; do
        monster_position=$(echo ${monster_position} | tr ' ' '-')
        monsters_positions+=("(${monster_position})")
    done <&6
    MONSTERS_POSITIONS="${monsters_positions[@]}"

    #draw the map following parameters
    map_size_x="$(get_info "${map_size}" x)"
    map_size_y="$(get_info "${map_size}" y)"
    MAP_SIZE_X="${map_size_x}"
    MAP_SIZE_Y="${map_size_y}"

}

#draw a map from a .txt file (specs to create your own map are in the README.md)
#'-' represent a wall
#' ' represent a case with no danger
#'M' represent a case with a monster
#'A' represent our friend, Aston
#'O' represent the exit
draw_map() {
    for row in $(seq 0 ${MAP_SIZE_Y}); do
        for column in $(seq 0 ${MAP_SIZE_X}); do
            if [[ "${EXIT_POSITION}" != "${column} ${row}" \
            && (0 == ${column} || 0 == ${row} \
            || ${MAP_SIZE_X} == ${column} || ${MAP_SIZE_Y} == ${row}) ]]; then
                echo -n '-'
            elif [[ "${PLAYER_POSITION}" == "${column} ${row}" ]]; then
                echo -n "A"
            elif [[ "${EXIT_POSITION}" == "${column} ${row}" ]]; then
                echo -n "O"
            elif [[ $(echo $(contains "(${column}-${row})" "${MONSTERS_POSITIONS[@]}")) != "1" ]]; then
                echo -n "M"
            else
                echo -n " "
            fi
        done
        echo ""
    done
}

#return the specified element from the couple passed as argument (x or y)
get_info() {
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

#return '0' or '1' if the element is in the list or not
contains() {
    #FUNC ARGS
    local coordonate="$1"
    shift
    local coordonates="$@"
    #END  ARGS

    for index in ${coordonates[@]}; do
        if [[ "${coordonate}" == "${index}" ]]; then
            echo 0
        fi
    done
    echo 1
}

#with a direction given, move the player if it's possible
#the value for the direction are the following:
#'N' to go to the north
#'E' to go to the East
#'S' to go to the South
#'W' to go to the West
move_player() {
    #FUNC ARGS
    local direction="$1"
    #END  ARGS

    case "${direction}" in
        "N")
            local y_position="$(get_info "${PLAYER_POSITION}" "y")"
            if [[ ${y_position} != "1" ]]; then
                PLAYER_POSITION=$((${y_position} - 1))
            fi
            ;;
        "E")
            ;;
        "S")
            ;;
        "W")
            ;;
    esac
}

main() {
    init_map $@
    draw_map
}

main $@
