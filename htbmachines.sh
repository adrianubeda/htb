#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
	echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
	tput cnorm && exit 1
}

#Ctrl+C
trap ctrl_c INT

#Variables globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
	echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
	echo -e "\t${purpleColour}u)${endColour}${grayColour} Descragar o actualizar archivos necesarios${endColour}"
	echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por un nombre de máquina${endColour}"
	echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar panel de ayuda${endColour}"
}

function searchMachine(){
	machineName="$1"
	
	echo $machineName
}


function updateFiles(){

	# Si no existe el fichero...
	if [ ! -f bundle.js ]; then
		tput civis #Ocultar el cursor
		echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
		curl -s $main_url > bundle.js 
		js-beautify bundle.js | sponge bundle.js
		echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todos los archivos han sido descargados${endColour}"
		tput cnorm
	# Si existe
	else
		tput civis
		echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comprobando si hay actualizaciones pendientes${endColour}"
		curl -s $main_url > bundle_temp.js 
		js-beautify bundle_temp.js | sponge bundle_temp.js
		md5_temp_value="$(md5sum bundle_temp.js | awk '{print $1}')"
		md5_original_value="$(md5sum bundle.js | awk '{print $1}')"
		
		if [ "$md5_temp_value" == "$md5_original_value" ]; then
			echo -e "\n${yellowColour}[+]${endColour}${grayColour} No se han detectado actualizaciones, todo en orden crak :)${endColour}"
			rm bundle_temp.js
		else
			echo -e "\n${yellowColour}[+]${endColour}${grayColour} Se han detectado actualizaciones disponibles${endColour}"
			sleep 1

			rm bundle.js && mv bundle_temp.js bundle.js

			echo -e "\n${yellowColour}[+]${endColour}${grayColour} Los archivos han sido actualziados!!${endColour}"
		fi

		tput cnorm
	fi
}

# Indicadores
declare -i parameter_counter=0 # Creamos una variable de tipo entero con -i

# Creamos dos parametros para cuando lancemos el script, si queremos que el parametro tenga un argumento deberemos de ponerle : seguidos, es decir, si queremos que sea
# así ./htbmachine.sh -m "Nombre_maquina", deberemos indicarle "m:"
while getopts "m:uh" arg; do # Primero se pone los paremtros que necesitan argumentos, y seguido de los : los que no lo necesitan, en este caso u y h no lo necesitan
	case $arg in
	 m) machineName=$OPTARG;  let parameter_counter+=1;;
	 u) let parameter_counter+=2;;
	 h) ;; # Cuando hagamos -h, llamaremos a la función helpPanel
	esac
done

if [ $parameter_counter -eq 1 ]; then 
	searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
else
	helpPanel
fi
