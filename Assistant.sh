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
	    python3 -m piper -m $VOICE_PATH -- "Voice system online. $BAT_STATE. ram usage at $RAM_USAGE. C P U usage at $CPU_USAGE. $GPU_DATA"
        else
	    echo -e "${RED}Voice system offline${NC}"
	    if [ $BAT_STATUS = "discharging" ]; then
                echo -e "${RED}Running on battery${NC}\nBattery at $BAT%"
            else
                echo "Running on external power"
            fi
            echo "RAM usage at $RAM_USAGE"
            echo "CPU usage at $CPU_USAGE"
            echo "GPU data: $GPU_DATA"
	fi
    elif [ "$user_input" = "time" ]; then
	DATE=$(date +%A%t%d%t%B%t%Y)
	if test -f "$VOICE_PATH"; then
	    echo $DATE
	    python3 -m piper -m $VOICE_PATH -- $DATE
    	else
	    echo $DATE
    	fi	    
    elif [ "$user_input" = "saved" ]; then
    	ls -la
	read -p "> " file_path
	cat $file_path
    fi
    clear
    process_loop
}
process_loop
