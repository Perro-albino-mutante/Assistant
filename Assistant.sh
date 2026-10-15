BAT_PATH=$(upower -e | grep battery | head -n1)
VOICE_PATH=~/.voices/en_US-libritts_r-medium.onnx
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
BAT_STATE=""
function process_loop {
    read -p ": " user_input
    if [ "$user_input" = "status" ]; then
    	BAT=$(upower -i $BAT_PATH | grep percentage | awk '{print $2}' | tr -d '%')
	BAT_STATUS=$(upower -i $BAT_PATH | grep state | awk '{print $2}')
	RAM_USAGE=$(inxi -m | grep used | awk '{print $12}')
	CPU_USAGE=$(fastfetch | grep "CPU Usage" | awk '{print $4}')
	GPU_DATA=$(fastfetch | grep "GPU" | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}')
	FREE_SPACE=$(df -h | grep "/" -w | awk '{print $5}')
	if test -f "$VOICE_PATH"; then
	    echo "Voice system online"
	    echo "Time system online"
	    if [ "$BAT_STATUS" = "discharging" ]; then
	        echo -e "${RED}Running on battery${NC}\nBattery at $BAT%"
		BAT_STATE="Running on battery. Batter at $BAT percent"
	    else
	        echo "Running on external power"
		BAT_STATE="Running on external power"
    	    fi
	    echo "RAM usage at $RAM_USAGE"
	    echo "CPU usage at $CPU_USAGE"
	    echo "GPU data: $GPU_DATA"
	    python3 -m piper -m $VOICE_PATH -- "Voice system online. Time system online. $BAT_STATE. ram usage at $RAM_USAGE. C P U usage at $CPU_USAGE. $GPU_DATA"
        else
	    echo -e "${RED}Voice system offline${NC}"
	    echo "Time system online"
	    if [ $BAT_STATUS = "discharging" ]; then
                echo -e "${RED}Running on battery${NC}\nBattery at $BAT%"
            else
                echo "Running on external power"
            fi
            echo "RAM usage at $RAM_USAGE"
            echo "CPU usage at $CPU_USAGE"
            echo "GPU data: $GPU_DATA"
	    read
	fi
    elif [ "$user_input" = "time" ]; then
	DATE=$(date +%A%t%d%t%B%t%Y)
	if test -f "$VOICE_PATH"; then
	    echo $DATE
	    python3 -m piper -m $VOICE_PATH -- $DATE
    	else
	    echo $DATE
	    read
    	fi	    
    elif [ "$user_input" = "saved" ]; then
    	ls -la
	read -p "> " file_path
	cat $file_path
	read
    elif [ "$user_input" = "save" ]; then
    	read -p "> " action
	if [ "$action" = "edit" ]; then
	    ls -l
	    read -p "line: " linenu
	    read -p "content: " text
	    read -p "file: " file_path
	    sed -i "${linenu}s/.*/${text}/" $file_path
	    read
	elif [ "$action" = "create" ]; then
	    read -p "content: " text
	    read -p "file: " file_path
	    echo "$text" >> $file_path
	fi
    elif [ "$user_input" = "delete" ]; then
	ls -l
        read -p "> " file_path
	rm $file_path
    elif [ "$user_input" = "run" ]; then
	ls -l
	read -p "> " file_path
	./$file_path
    elif [ "$user_input" = "help" ]; then
	echo "Command list:"
	echo "status: displays the tecnical information of the moment"
	echo "time: displays the current date"
	echo "saved: shows the content of the selected file"
	echo "save: allows to create and edit files, the mode is selected in the begining"
	echo "delete: deletes files"
	echo "run: allows to run programs"
	echo "help: displays command list and description"
	echo "6: exits the program"
	if test -f "$VOICE_PATH"; then
	    python3 -m piper -m $VOICE_PATH -- "Command list. status. time. saved. save. delete. run. help. 6"
	fi
	read
    elif [ "$user_input" = "6" ]; then
    	exit
    else
	echo "Command not recognized"
	read
    fi
    clear
    process_loop
}
process_loop
