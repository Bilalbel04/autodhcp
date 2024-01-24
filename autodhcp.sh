#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\e[34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Limpieza consola
clear

# ¿Eres Root?
if [ "$(id -u)" != "0" ]; then
# No eres root
    echo -e "${RED} ❌ Error | Este script debe ejecutarse como root. Por favor, utiliza sudo.${NC}"
    sleep 1 # Espera 1 segundo
    exit # Para el script
else
# Eres root
    echo -e "${GREEN} 🚀 ¡Perfecto!. Eres Root!${NC}"
    sleep 1 # Espera 1 segundo
    clear # Limpiamos la terminal
fi

# Declaramos Variables necesarias

# Archivos de LOGS #
LOGS_LOG="/var/log/logs.log"
FAIL_LOG="/var/log/faildhcp.log"

# Verifica la conexion a internet.
echo -e "${GREEN} Verificando la conexión a Internet...${NC}"
    if ping -c 1 google.com &> /dev/null; then
        # Tienes conexion
        echo -e "${GREEN} ✅ Conexión a Internet exitosa.${NC}"
        sleep 1 # Espera 1 segundo
        clear # Limpieza terminal
    else
        # No tienes conexion
        echo -e "${RED} Verifica tu conexion a internet, parece que no tienes...${NC}"
        sleep 1 # Espera 1 segundo
        exit # Para el script
    fi

# Actualizar paquetes del sistema
echo -e "${YELLOW} ⚠️ ${GREEN} Para evitar problemas, actualizaremos los paquetes del sistema ${YELLOW}⚠️${NC}"
echo -e "${YELLOW} ❓${GREEN} ¿Estas de acuerdo? ${RED}(Si/No) ${YELLOW}❓ ${NC}"
read respuesta1 # Escuchamos la respuesta1 

sleep 1 # Espera 1 segundo para no colapsar
clear # Limpieza terminal
# Si la respuesta1 es:
while true; do
if [[ "$respuesta1" =~ ^[SsIi]$ ]]; then
# entonces actualizaremos los paquetes del sistema
    echo -e "${GREEN} 🚀 ¡Perfecto! Actualizando paquetes del sistema...${NC}"
    # Actualizamos la lista local de paquetes disponibles
    apt-get update >> "$LOGS_LOG" 2>> "$FAIL_LOG"
    # Ahora actualizamos los paquetes disponibles en el sistema
    apt-get upgrade -y >> "$LOGS_LOG" 2>> "$FAIL_LOG"
    # Comprobamos si la actualizacion se ha realizado satisfactoriamente
    if [ $? -eq 0 ]; then
    # Si se ha actualizado bien entonces
    echo -e "${GREEN} ✅ Se ha actualizado correctamente los paquetes del sistema ${NC}"
    sleep 1 # Esperamos 1 segundo
    clear # Limpiamos la consola
    break
    else
    # Si no se ha actualizado bien entonces
    echo -e "${RED} ❌ Error | Al actualizar los paquetes del sistema ${NC}"
    exit
    fi
elif [[ "$respuesta1" =~ ^[NnOo]$ ]]; then
    echo -e "${YELLOW} ⚠️ ${GREEN} Entiendo, puede que hayan problemas mas adelante... ${YELLOW} ⚠️ ${NC}"
    echo -e "${YELLOW} ⚠️ ${GREEN} Avisado estas ${YELLOW} ⚠️ ${NC}"
    sleep 2 # Espera 2 segundos
    clear # Limpiamos la consola
    break
else
# Si respuesta1 no fue si, entonces
    echo -e "${YELLOW} ⚠️ ${GREEN} "Intervalo incorrecto" ${YELLOW} ⚠️ ${NC}"
    sleep 1 # Espera 3 segundos
    clear
fi 
done
# Comprobamos si el paquete isc-dhcp-server esta instalado
if dpkg -l | grep -q "isc-dhcp-server"; then
    # Si está instalado, preguntamos si se desea reinstalar
    echo -e "${YELLOW} ⚠️ ${GREEN} El paquete ${BLUE}isc-dhcp-server ${GREEN}ya está instalado. ${YELLOW} ⚠️ ${NC}"
    echo -e "${YELLOW} ⚠️ ${GREEN} Para que el script funcione correctamente, es ideal reinstalar las configuraciones por defecto ${YELLOW} ⚠️ ${NC}"
    echo -e "${YELLOW} ❓ ${GREEN} ¿Desea reinstalar los valores por defecto? ${RED}(Sí/No) ${YELLOW}❓ ${NC}"
    # Escuchamos la respuesta
    read respuesta
    clear # Limpieza de consola
    # Si la respuesta es si... 
        if [[ "$respuesta" =~ ^[Ss][Ii]?$ ]]; then
        # Entonces reinstalaremos el paquete isc-dhcp-server
        echo -e "${GREEN} 🚀 ¡Perfecto! Estamos reinstalando el paquete isc-dhcp-server...${NC}"
        sleep 1 # Espera 1 segundo
            # borraremos el paquete isc-dhcp-server y comprobamos
            if apt-get purge -y isc-dhcp-server >> "$LOGS_LOG" 2>> "$FAIL_LOG"; then
                # Si se ha borrado satisfactoriamente, entonces:
                echo -e "${YELLOW} ⚠️ ${GREEN}Se ha borrado el paquete isc-dhcp-server exitosamente ${YELLOW} ⚠️ ${NC}"
                sleep 1
            else
                # Si no se ha borrado satisfactoriamente, entonces:
                echo -e "${RED} ❌ Error | Hubo un problema al desinstalar isc-dhcp-server ${NC}"
                # Paramos el script
                exit
            fi
        # Comprobamos que se borro el paquete satisfactoriamente
        if [ $? -eq 0 ]; then
        # Si se ha borrado satisfactoriamente, entonces lo instalamos
            apt-get install isc-dhcp-server -y >> "$LOGS_LOG" 2>> "$FAIL_LOG"
            if [ $? -eq 0 ]; then # Comprobamos que se haya instalado correctamente
                # Si se ha instalado correctamente entonces:
                echo -e "${GREEN} 🚀 ¡Genial! Se ha instalado correctamente el paquete isc-dhcp-server ${NC}"
                sleep 2 # Esperamos 2 segundos
                clear # Limpiamos la consola
            else
                # Si no se ha instalado correctamente, entonces:
                echo "${REED} ❌ Error | Hubo un problema en la instalacion del paquete isc-dhcp-server ${NC}"
                exit # Paramos el script
            fi
        else # Si hay un error en la reinstalacion, entonces:
            echo -e "${RED} ❌ Error | No se ha completado la reinstalacion, porfavor, verifique los logs ${NC}"
            exit # Paramos el script
        fi
    else
        # Si la respuesta fue no, entonces:
        echo -e "${YELLOW} ⚠️ ${RED} Entiendo, no se realizara la reinstalacion ${YELLOW}⚠️ ${NC}"
        echo -e "${YELLOW} ⚠️ ${RED} El proceso terminara aqui  ${YELLOW}⚠️. ${NC}"
        clear # Limpiamos consola pqe quito el exit !
        #exit # Paramos el script
    fi
else
    # En caso de que no este instalado, lo instalaremos
    echo -e "${YELLOW} ⚠️ ${RED} El paquete isc-dhcp-server no esta instalado ${YELLOW}⚠️ ${NC}"
    echo -e "${GREEN} 🚀 Procederemos a instalarla! ${NC}"
    sleep 1 # Esperamos 1 segundo para no colapsar
    # Instalamos el paquete isc-dhcp-server
    apt-get install isc-dhcp-server -y >> "$LOGS_LOG" 2>> "$FAIL_LOG"

    # Verificamos si la instalación fue exitosa
    if [ $? -eq 0 ]; then
    # Si se ha instalado correctamente, entonces:
        echo -e "${GREEN} 🚀 ¡Genial! El paquete isc-dhcp-server se instalo de manera correcta ${NC}"
        sleep 1 # Esperamos 1 segundo
        clear # Limpiamos la consola
    else
    # De lo contrario:
        echo -e "${RED} ❌ Error | Parece que hubo un error en la instalacion. ${NC}"
        echo -e "${YELLOW} ⚠️ ${RED} Porfavor, verifique los LOGS ${YELLOW}⚠️ ${NC}"
        exit # Paramos el script
    fi
fi

# Miramos y enumeramos las interfaces de red que tiene en la variable INTERFACES
INTERFACES=$(ip l | grep -oP '\d+: \K[^:]+')

# Preguntamos qué interfaz es la correcta
echo -e "${YELLOW} ⚠️ ${GREEN} Necesitamos saber cuál es la interfaz de red por la que escucharemos las peticiones ${YELLOW}⚠️ ${NC}"
echo -e "${YELLOW} ❓ ${GREEN} ¿Cuál es la interfaz correcta? ${YELLOW}❓ ${NC}"

select respuesta_interfaz in $INTERFACES

do
    if [ "$respuesta_interfaz" ]; then
        clear # Limpiamos consola
        echo -e "${YELLOW} ⚠️ ${GREEN} Has seleccionado ${RED}$respuesta_interfaz ${NC}"
        echo -e "${GREEN} ¿Es correcto? ${RED}(Sí/No) ⚠️ ${NC}"
        read respuesta_correcta_interfaz 
        if [[ "$respuesta_correcta_interfaz" =~ ^[Ss][Ii]?$ ]]; then
            echo -e "${GREEN} 🚀 ¡Genial! Continuaremos con la configuración ${NC}"
            sleep 1 # Esperamos 1 segundo
            break
            clear
        else
            echo -e "${REED} ❌ | Lo siento, vuelve a iniciar el script. Selecciona la interfaz correcta. ${NC}"
            exit 1
        fi
    else
        echo -e "${REED} ❌ | Selección no válida, por favor inténtalo de nuevo ${NC}"
    fi
done

# Asignamos la interfaz de escucha

# Si existe el fichero /etc/default/isc-dhcp-server entonces
if [ -e "/etc/default/isc-dhcp-server" ]; then
# Busca la palabra INTERFACESv4 de la ruta /etc/default/isc-dhcp-server, si existe entonces
    if grep "INTERFACESv4" "/etc/default/isc-dhcp-server" ; then
# La palabra INTERFACESv4 remplazala por la variable $respuesta_interfaz
        sed -i "s/INTERFACESv4=.*/INTERFACESv4=\"$respuesta_interfaz\"/" /etc/default/isc-dhcp-server
        clear # Limpiamos consola
# Si se ha podido remplazar correctamente, entonces
        echo -e "${GREEN} 🚀 ¡Genial! se ha asignado la interfaz ${RED} $respuesta_interfaz ${GREEN} correctamente ${NC}"
        sleep 1 # Espera 1 segundo
        clear # Limpiamos la consola
    else
# Si no ha encontrado la palabra, entonces
        echo "La palabra 'INTERFACESv4' no se encuentra en el archivo /etc/default/isc-dhcp-server."
    fi
else
# Si el archivo /etc/default/isc-dhcp-server no existe, entonces
    echo -e "${RED} ❌ | El archivo /etc/default/isc-dhcp-server no existe. ${NC}"
fi

# Asignamos los rangos de IP

# Preguntas necesarias

echo -e "${YELLOW} ❓ ${GREEN} Cual es la IP de la red? ${YELLOW}❓ ${NC}"
echo -e "${YELLOW} ⚠️ ${GREEN} ${RED}(Ej: 192.168.1.0 )${YELLOW} ⚠️ ${NC}"
read ip_red
clear # Limpiamos terminal

echo -e "${YELLOW} ❓ ${GREEN} Cual es la mascara de la red? ${YELLOW}❓ ${NC}"
echo -e "${YELLOW} ⚠️ ${GREEN} Porfavor, escribe la mascara en formato IP ${RED}(Ej: 255.255.255.0 )${YELLOW} ⚠️ ${NC}"
read ip_mascara
clear # Limpiamos terminal

echo -e "${YELLOW} ❓ ${GREEN} ¿Que rango de IP quieres asignar? ${YELLOW}❓ ${NC}"
echo -e "${YELLOW} ⚠️ ${GREEN} El servidor DHCP empezara a repartir IP desde: ${YELLOW} ⚠️ ${NC}"
read ip_start
clear # Limpiamos la terminal

echo -e "${YELLOW} ⚠️ ${GREEN} El servidor DHCP acabara de repartir IP hasta: ${YELLOW} ⚠️ ${NC}"
read ip_stop
clear # Limpiamos la terminal

echo -e "${YELLOW} ❓ ${GREEN} Cual es el gateway de la RED? ${YELLOW}❓ ${NC}"
read ip_gateway
clear # Limpiamos la terminal

echo -e "${YELLOW} ❓ ${GREEN} Cual es el 1r DNS de la RED? ${YELLOW}❓ ${NC}"
read ip_dns1
clear # Limpiamos la terminal

echo -e "${YELLOW} ❓ ${GREEN} Cual es el 2n DNS de la RED? ${YELLOW}❓ ${NC}"
read ip_dns2
clear # Limpiamos la terminal

echo -e "${YELLOW} ❓ ${GREEN} Cual es el dominio del servidor DNS? ${YELLOW}❓ ${NC}"
read dominio_red
clear # Limpiamos la terminal

echo -e "${YELLOW} ❓ ${GREEN} esta informacion es correcta? ${YELLOW}❓ ${NC}"
echo -e "Desde $ip_start hasta $ip_stop"
echo -e "El gateway de la red es $ip_gateway"
echo -e "Los DNS de la red son $ip_dns1 y $ip_dns2"

read -p "¿Desea continuar con el proceso? (Sí/No): " respuesta_info_red

# Verificar la respuesta del usuario
if [[ "$respuesta_info_red" =~ ^[SsIiYy]$ ]]; then 
    echo -e "${YELLOW} ⚠️ ${GREEN} Continuaremos con el proceso ${YELLOW} ⚠️ ${NC}"
    sleep 1 # Esperar 1 segundo
    clear # Limpiar la terminal
else
    echo -e "${REED} ❌  | Lo siento, deberás iniciar nuevamente el script. ${NC}"
    sleep 1 # Esperar 1 segundo
    exit 1 # Salir con código de error
fi

# Empezamos a configurar el servicio
# Borramos el archivo de configuracion por defecto
rm /etc/dhcp/dhcpd.conf

# Creamos un nuevo archivo de configuracion
touch /etc/dhcp/dhcpd.conf

# Añadimos la configuracion 

echo -e "
# Asignamos el dominio de la red o del servidor DNS
option domain-name "$dominio_red";
# Asignamos IP de servidores DNS accesibles
option domain-name-servers $ip_dns1,$ip_dns2;

# Tiempo por defecto de espera en la solicitud
default-lease-time 600;

# Maximo tiempo de espera
max-lease-time 7200;

# No permitir actualizaciones dinamicas al servidor DNS
ddns-update-style none;

# Configuracion del servicio DHCP
subnet $ip_red netmask $ip_mascara {
    range $ip_start $ip_stop;
    option routers $ip_gateway;
}" >> /etc/dhcp/dhcpd.conf

# Iniciamos el servicio DHCP
systemctl restart isc-dhcp-server 