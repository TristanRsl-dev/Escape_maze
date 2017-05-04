#!/bin/bash

#GLOBAL VARIABLE
PLAYER_POSITION=""
EXIT_POSITION=""
MAP_SIZE_X=""
MAP_SIZE_Y=""
MONSTERS_POSITIONS=""

PLAYER_LIFE=""
PLAYER_ATK=""
PLAYER_ARMOR=""

MONSTERS_LIFE=""
MONSTERS_ATK=""
MONSTERS_ARMOR=""
#END

#display the menu to choose what to do
display_menu() {
    echo -e "\n\tWelcome into the magic world of Aston the warrior. As brave as you are, you'll have difficulty to get out.\n"
    sleep 2
    echo -e "\tFirst, choose the difficulty:\n" \
    "\t\t1 (Beginner)\n" \
    "\t\t2 (Explorer)\n" \
    "\t\t3 (Warrior)\n" \
    "\n"

    #wait for the user to choose his difficulty
    read -rsn1 difficulty_choosen

    case "${difficulty_choosen}" in
        1)
            #custom message for each difficulty
            message_of_encouragement="Oh... You choose the easiest one. It's ok buddy, we still appreciate you."
            #set the hud file
            stats_player="lib/hud/beginner.hud"
            #set the monster informations
            monsters_life=50
            monsters_atk=7
            monsters_armor=1
            ;;
        2)
            message_of_encouragement="Neither the easiest, nor the hardest. Fair enough, have fun."
            stats_player="lib/hud/explorer.hud"
            monsters_life=100
            monsters_atk=10
            monsters_armor=2
            ;;
        3)
            message_of_encouragement="Well, the hardest one... Good luck bro."
            stats_player="lib/hud/warrior.hud"
            monsters_life=150
            monsters_atk=12
            monsters_armor=4
            ;;
        *)
            message_of_encouragement="You're probably too shy to choose a difficulty by yourself... It'll be the beginner for you."
            stats_player="lib/hud/beginner.hud"
            monsters_life=50
            monsters_atk=7
            monsters_armor=1

            ;;
    esac

    echo -e "\t${message_of_encouragement}\n" \
    "\n"
    sleep 2
    echo -e "\tBut before starting your adventure, please choose a map:\n" \
    "\t\t1 (Little map - 10*10)" \
    "\t\t2 (Middle size map - 15*15)" \
    "\t\t3 (Large map - 20*20)" \
    "\n"

    #wait for the user to choose the map size
    read -rsn1 map_size_choosen

    case "${map_size_choosen}" in
        1)
            #set the map file
            map_file="lib/map/little.map"
            ;;
        2)
            map_file="lib/map/middle.map"
            ;;
        3)
            map_file="lib/map/large.map"
            ;;
        *)
            echo -e "\t${map_size_choosen} is not in the list that I allow you to choose. You'll play on the middle size map."
            map_file="lib/map/middle.map"
            ;;
    esac

    echo -e "\tLet's get started in 5 seconds !"
    #sleep 5 seconds for better lisibility
    sleep 5

    #initialize the map, the hud and display them
    init_map "${map_file}" "${monsters_life}" "${monsters_atk}" "${monsters_armor}"
    init_hud "${stats_player}"
    main_loop
}

init_map() {
    #FUNC ARGS
    local file_map="$1"
    local monsters_life="$2"
    local monsters_atk="$3"
    local monsters_armor="$4"
    #END  ARGS

    exec 6< ${file_map}

    #read the first line that contains the size of the map
    read map_size <&6
    MAP_SIZE_X="$(get_info "${map_size}" x)"
    MAP_SIZE_Y="$(get_info "${map_size}" y)"

    #read the second line that contains the initial position of the player
    read player_position <&6
    PLAYER_POSITION="${player_position}"

    #read the third line that contains the exit
    read exit_position <&6
    EXIT_POSITION="${exit_position}"

    #read the following lines that contains positions of monsters
    local monsters_positions=()
    while read monster_position; do
        #init monsters informations
        local index_monster=$(transform_coordonate_into_index "${monster_position}")
        MONSTERS_LIFE[${index_monster}]=${monsters_life}
        MONSTERS_ATK[${index_monster}]=${monsters_atk}
        MONSTERS_ARMOR[${index_monster}]=${monsters_armor}

        monster_position=$(echo ${monster_position} | tr ' ' '-')
        monsters_positions+=("(${monster_position})")
    done <&6
    MONSTERS_POSITIONS="${monsters_positions[@]}"
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

#read from a file the informations of the player (life, attack, armor)
init_hud() {
    #FUNC ARGS
    local file_hud="$1"
    #END  ARGS

    exec 6< ${file_hud}

    #read the first line that contains the life of the player
    read player_life <&6
    PLAYER_LIFE="${player_life}"

    #read the second line that contains the attack of the player
    read player_atk <&6
    PLAYER_ATK="${player_atk}"

    #read the third line that contains the armor of the player
    read player_armor <&6
    PLAYER_ARMOR="${player_armor}"
}

#display the informations of the player
display_hud() {
    #FUNC ARGS
    #END  ARGS

    echo -e "\n   Life: "${PLAYER_LIFE}"\n" \
    "  Attack: "${PLAYER_ATK}"\n" \
    "  Armor: "${PLAYER_ARMOR}""
}

#retrieve information from the specified monster coordonate
get_information_monster() {
    #FUNC ARGS
    local coordonate="$1"
    #END  ARGS

    local index_monster=$(transform_coordonate_into_index "${coordonate}")

    #retrieve the value into monsters lists
    echo ${MONSTERS_LIFE}
    echo -e "\n   Life: "${MONSTERS_LIFE[${index_monster}]}"\n" \
    "  Attack: "${MONSTERS_ATK[${index_monster}]}"\n" \
    "  Armor: "${MONSTERS_ARMOR[${index_monster}]}""
}

#mathematic formula to create a unique identifier for each monster
transform_coordonate_into_index() {
    #FUNC ARGS
    local coordonate="$1"
    #END  ARGS

    local monster_position_x="$(get_info "${coordonate}" "x")"
    local monster_position_y="$(get_info "${coordonate}" "y")"

    echo "$((${monster_position_x} + (${MAP_SIZE_X} * $((${monster_position_y} - 1)))))"
}

##      MOVE        ##

#with a direction given (a key from the keyboard), move the player if it's possible
#the value for the direction are the following:
#'N' to go to the north
#'E' to go to the East
#'S' to go to the South
#'W' to go to the West
move_player() {
    #FUNC ARGS
    local direction="$1"
    #END  ARGS

    local y_position="$(get_info "${PLAYER_POSITION}" "y")"
    local x_position="$(get_info "${PLAYER_POSITION}" "x")"

    case "${direction}" in
        "z")
            if [[ ${y_position} != "1" ]]; then
                PLAYER_POSITION="${x_position} $((${y_position} - 1))"
            fi
            ;;
        "d")
            if [[ ${x_position} != "$((${MAP_SIZE_X} - 1))" ]]; then
                PLAYER_POSITION="$((${x_position} + 1)) ${y_position}"
            fi
            ;;
        "s")
            if [[ ${y_position} != "$((${MAP_SIZE_Y} - 1))" ]]; then
                PLAYER_POSITION="${x_position} $((${y_position} + 1))"
            fi
            ;;
        "q")
            if [[ ${x_position} != "2" ]]; then
                PLAYER_POSITION="$((${x_position} - 1)) ${y_position}"
            fi
            ;;
    esac
}

##      MAIN        ##

main_loop() {
    #FUNC ARGS
    #END  ARGS

    while true; do
        clear
        draw_map
        display_hud
        read -rsn1 key_pressed
        move_player ${key_pressed}
    done
}

display_menu
