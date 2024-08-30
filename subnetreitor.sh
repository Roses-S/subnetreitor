#!/bin/bash

# Colors
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Ctrl + C

function ctrl_c(){
  echo -e "\n\n${redColour}[!] Exiting...${endColour}"
  rm ut.t* 2>/dev/null
  tput cnorm; exit 1
}

trap ctrl_c INT

# Banner

function banner(){ 
  echo -e "${turquoiseColour}
                  .----.
      .---------. | == |
      |.-\"\"\"\"\"-.| |----|
      ||       || | == |    ${endColour}${blueColour}Subnetreitor${endColour}${grayColour} - Networks and more${endColour}${turquoiseColour}
      ||       || |----|    ${endColour}${grayColour}\t\t     by${endColour} ${redColour}Roses${endColour}${redColour} <3${endColour}${turquoiseColour}
      |'-.....-'| |::::|
      \`\"\")---(\"\"\` |___.|
     /:::::::::::\\\" _  \"
    /:::=======:::\\\\\`\\\`\\
    \`\"\"\"\"\"\"\"\"\"\"\"\"\"\`  '-'
  ${endColour}"
  echo -e "${blueColour}-------------------------------------------------------------${endColour}"
}

# Make a format of table

function printTable(){

    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                #echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
                echo -e "${table}" | column -s '#' -t | awk '/^  ?\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function removeEmptyLines(){

    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString(){

    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString(){

    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString(){

    local -r string="${1}"
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}

# Help Panel

function helpPanel(){
  banner
  echo -e "${blueColour}[?] How to use:${endColour} ${yellowColour}$0${endColour}"
  echo -e "${blueColour}-------------------------------------------------------------${endColour}"
  echo -e "\t${blueColour}Network Reconnaissance${endColour}"
  echo -e "\t${blueColour}i)${endColour} ${turquoiseColour}Ip${endColour}"
  echo -e "\t\t${grayColour}Ex: 182.168.1.70${endColour}"
  echo -e "\t${blueColour}s)${endColour} ${turquoiseColour}Subnetmask or ${endColour}${blueColour}p)${endColour} ${turquoiseColour}Prefix${endColour}"
  echo -e "\t\t${grayColour}Ex: 255.255.255.192 / 28${endColour}"
  echo -e "\t${blueColour}-----------------------------${endColour}"
  echo -e "\t${blueColour}Subnetting a Network${endColour}"
  echo -e "\t${blueColour}i)${endColour} ${turquoiseColour}Ip${endColour}"
  echo -e "\t\t${grayColour}Ex: 192.168.1.0${endColour}"
  echo -e "\t${blueColour}d)${endColour} ${turquoiseColour}Host or${endColour} ${blueColour}n)${endColour} ${turquoiseColour}Networks${endColour}"
  echo -e "\t\t${grayColour}Ex: 35 Hosts / 16 Networks${endColour}"
  echo -e "\t${blueColour}t)${endColour} ${turquoiseColour}Show Subnetting Table${endColour}"
  echo -e "\t${blueColour}-----------------------------${endColour}"
  #echo -e "\t${blueColour}VLSM Subnetting${endColour}"
  #echo -e "\t${turquoiseColour}Working in this...${endColour}"
  echo -e "\t${blueColour}Help${endColour}"
  echo -e "\t${blueColour}h)${endColour} ${turquoiseColour}Show Help Panel${endColour}"
}

# Network Reconnaissance

function reconnaissance(){
  tput civis
  ip=$1
  subnet_or_prefix=$2
  if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    for octet in $(echo $ip | tr "." " "); do
      if [[ $octet -lt 0 || $octet -gt 255 ]]; then
        echo -e "\n${redColour}[!] This IP doesn't exist!!!${endColour}"
        exit 1
      fi
    done
    # Detect if is a subnetmask
    if [[ $subnet_or_prefix =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
      for octet in $(echo $subnet_or_prefix | tr "." " "); do
        if [[ $octet -lt 0 || $octet -gt 255 ]]; then
          echo -e "\n${redColour}[!] This Subnetmask doesn't exist!!!${endColour}"
          exit 1
        fi
      done
      prefix=0
      class_prefix=0
      networkID=""      

      for (( i=1; i<=4; i++)); do
        value1=$(echo $ip | tr "." " " | awk -v var=$i '{print $var}')
        value2=$(echo $subnet_or_prefix | tr "." " " | awk -v var=$i '{print $var}')
        network_octet=$(( value1 & value2 ))
        inverted_mask=$(( 255 - value2 ))
        broadcast_octet=$(( value1 | inverted_mask ))
        broadcast_add+="$broadcast_octet."
        networkID+="$network_octet."
      done
      networkID=${networkID%.}
      broadcast_add=${broadcast_add%.}
      
      # Calculate prefix
      for octet in $(echo $subnet_or_prefix | tr "." " "); do
          #binary_octet=$(echo "obase=2; $octet" | bc | awk '{printf "%08d\n", $0}')
          binary_octet=$(printf "%08d" "$(echo "obase=2; $octet" | bc)")
          prefix_octet=$(echo "$binary_octet" | grep -o "1" | wc -l)
          prefix=$((prefix + prefix_octet))
      done

      # Determinate Class
      first_octet_ip=$(echo $ip | tr "." " " | awk '{print $1}')
      if [ $first_octet_ip -ge 1 ] && [ $first_octet_ip -le 127 ]; then
        class="A"
        class_prefix=8
      elif [ $first_octet_ip -ge 128 ] && [ $first_octet_ip -le 191 ]; then
        class="B"
        class_prefix=16
      elif [ $first_octet_ip -ge 192 ] && [ $first_octet_ip -le 223 ]; then
        class="C"
        class_prefix=24
      else
        echo -e "${redColour}[!] IP Reserved for experimenting${endColour}"
        exit 1
      fi

      # Calculate subnetworks
      subnetworks=$((2 ** (prefix - class_prefix)))
      total_hosts=$((2 ** (32 - prefix) - 2))
      jump=$((2 ** (32 - prefix)))
      #ip_asign=$((jump - 2))
      #jump=$(((total_hosts + 256 - 1) / 256)) # Redondear hacia arriba
      
      echo -e "\n${yellowColour}Host:${endColour} ${greenColour}$ip${grayColour}/${endColour}${greenColour}$prefix${endColour}"
      echo -e "${yellowColour}------------------------------------------${endColour}"
      echo -e "${yellowColour}Class:${endColour} ${greenColour}$class${endColour}"
      echo -e "${yellowColour}Subnetmask:${endColour} ${greenColour}$subnet_or_prefix${endColour}"
      echo -e "${yellowColour}NetworkID:${endColour} ${greenColour}$networkID${endColour}"
      echo -e "${yellowColour}Broadcast Address:${endColour} ${greenColour}$broadcast_add${endColour}"
      echo -e "${yellowColour}Total hosts:${endColour} ${greenColour}$total_hosts${endColour}"
      echo -e "${yellowColour}Jump:${endColour} ${greenColour}$jump${endColour}"
      echo -e "${yellowColour}Subnetworks:${endColour} ${greenColour}$subnetworks${endColour}"
      #echo -e "${yellowColour}Ip asingable:${endColour} ${greenColour}$ip_asign${endColour}"

    # Detect if is a prefix
    elif [[ $subnet_or_prefix =~ ^[0-9]+$ && $subnet_or_prefix -ge 0 && $subnet_or_prefix -le 32 ]]; then
      # Prefix become subnetmask
      subnetmask=""
      binary_subnetmask=""
      flag=1

      for (( i=1; i<=32; i+=8 )); do
         for(( j=1; j<=8; j++ )); do
          if [ $flag -le $subnet_or_prefix ]; then
            binary_subnetmask+="1"
            let flag+=1
          else
            binary_subnetmask+="0"
            let flag+=1
          fi
        done
        binary_subnetmask+=" "
      done
      binary_subnetmask=${binary_subnetmask%.}
      #echo $binary_subnetmask

      #Convertir a decimal
      for ((i=1; i<=4; i++)); do
        subnetmask+="$(echo "ibase=2; $(echo $binary_subnetmask | awk -v var=$i '{print $var}')" | bc)."
      done
      subnetmask=${subnetmask%.}

      # ID network and broadcast
      for (( i=1; i<=4; i++ )); do
        value1=$(echo $ip | tr "." " " | awk -v var=$i '{print $var}')
        value2=$(echo $subnetmask | tr "." " " | awk -v var=$i '{print $var}')
        network_octet=$(( value1 & value2 ))
        inverted_mask=$(( 255 - value2))
        broadcast_octet=$(( value1 | inverted_mask ))
        broadcast_add+="$broadcast_octet."
        networkID+="$network_octet."
      done
      networkID=${networkID%.}
      broadcast_add=${broadcast_add%.}

      # Determinate Class
      first_octet_ip=$(echo $ip | tr "." " " | awk '{print $1}')
      if [ $first_octet_ip -ge 1 ] && [ $first_octet_ip -le 127 ]; then
        class="A"
        class_prefix=8
      elif [ $first_octet_ip -ge 128 ] && [ $first_octet_ip -le 191 ]; then
        class="B"
        class_prefix=16
      elif [ $first_octet_ip -ge 192 ] && [ $first_octet_ip -le 223 ]; then
        class="C"
        class_prefix=24
      else
        echo -e "${redColour}[!] IP Reserved for experimenting${endColour}"
        exit 1
      fi
       # Calculate subnetworks
      subnetworks=$((2 ** (subnet_or_prefix - class_prefix)))
      total_hosts=$((2 ** (32 - subnet_or_prefix) - 2))
      jump=$((2 ** (32 - subnet_or_prefix)))

      echo -e "\n${yellowColour}Host:${endColour} ${greenColour}$ip${grayColour}/${endColour}${greenColour}$subnet_or_prefix${endColour}"
      echo -e "${yellowColour}------------------------------------------${endColour}"
      echo -e "${yellowColour}Class:${endColour} ${greenColour}$class${endColour}"
      echo -e "${yellowColour}Subnetmask:${endColour} ${greenColour}$subnetmask${endColour}"
      echo -e "${yellowColour}NetworkID:${endColour} ${greenColour}$networkID${endColour}"
      echo -e "${yellowColour}Broadcast Address:${endColour} ${greenColour}$broadcast_add${endColour}"
      echo -e "${yellowColour}Total hosts:${endColour} ${greenColour}$total_hosts${endColour}"
      echo -e "${yellowColour}Jump:${endColour} ${greenColour}$jump${endColour}"
      echo -e "${yellowColour}Subnetworks:${endColour} ${greenColour}$subnetworks${endColour}"

    else
      echo -e "\n${redColour}[!] Format of Subnetmask or Prefix Wrong!!!${endColour}"
      #helpPanel
      exit 1
    fi
  else
    echo -e "\n${redColour}[!] Format of IP Wrong!!!${endColour}"
    exit 1
  fi
  tput cnorm
}

# Subnetting a Network

function subnetting(){
  tput civis
  ip=$1
  hosts_or_networks=$2

  first_octet_ip=$(echo $ip | tr "." " " | awk '{print $1}')
  if [ $first_octet_ip -ge 1 ] && [ $first_octet_ip -le 127 ]; then
    netmask=255.0.0.0
    class_prefix=8
  elif [ $first_octet_ip -ge 128 ] && [ $first_octet_ip -le 191 ]; then
    netmask=255.255.0.0
    class_prefix=16
  elif [ $first_octet_ip -ge 192 ] && [ $first_octet_ip -le 223 ]; then
    netmask=255.255.255.0
    class_prefix=24
  else
    echo -e "[!] IP Reserved for experimenting"
    exit 1
  fi

  # Verifying if is by hosts/devices or subnetworks
  if [ $parameter_counter -eq 5 ]; then
    n=1
    total_hosts=$(((2 ** n) - 2))

    while [ $total_hosts -lt $hosts_or_networks ]; do
      let n+=1
      total_hosts=$(((2 ** n) - 2))
    done

    #echo "n= $n"
    #echo "total host: $total_hosts"

    prefix=$((32 - n))
    #echo $prefix

    flag=1
    for (( i=1; i<=32; i+=8 )); do
      for (( j=1; j<=8; j++ )); do
        if [ $flag -le $prefix ]; then
          binary_netmask+=1
          let flag+=1
        else
          binary_netmask+=0
          let flag+=1
        fi
      done
      binary_netmask+=" "
    done
    binary_subnetmask=${binary_netmask% }
    #echo $binary_netmask

    for (( i=1; i<=4; i++ )); do
      subnetmask+="$(echo "ibase=2; $(echo $binary_netmask | awk -v var=$i '{print $var}')" | bc)."
      #if [ $i -eq 4 ]; then
      #  last_octet=$(echo "ibase=2; $(echo $binary_netmask | awk -v var=$i '{print $var}')" | bc)
      #  jump=$(( 256 - last_octet ))
        #ip_asign=$(( jump - 2 ))
     #fi
    #  subnetmask+="$octet."
    done
    total_subnetworks=$((2 ** (prefix - class_prefix)))
    jump=$((total_hosts + 2))
    subnetmask=${subnetmask%.}
    
  else # If isn't hosts, well is by subnetworks n=1
    n=1
    total_subnetworks=$((2 ** n))

    while [ $hosts_or_networks -gt $total_subnetworks ]; do
      let n+=1
      total_subnetworks=$((2 ** n))
    done
    

    prefix=$((class_prefix + n))

    flag=1
    for (( i=1; i<=32; i+=8 )); do
      for (( j=1; j<=8; j++ )); do
        if [ $flag -le $prefix ]; then
          binary_netmask+=1
          let flag+=1
        else
          binary_netmask+=0
          let flag+=1
        fi
      done
      binary_netmask+=" "
    done
    binary_netmask=${binary_netmask% }

    for (( i=1; i<=4; i++ )); do
      subnetmask+="$(echo "ibase=2; $(echo $binary_netmask | awk -v var=$i '{print $var}')" | bc)."
    done
    ip_asign=$((2 ** (32 - prefix) - 2))
    jump=$((ip_asign + 2))
    subnetmask=${subnetmask%.}
  fi
  
  if [ $table != true ]; then
    #Show all data about subnetting
    echo -e "${yellowColour}Network:${endColour} ${greenColour}$ip${endColour}${grayColour}/${endColour}${greenColour}$class_prefix${endColour}\t ${turquoiseColour}--->${endColour}\t${greenColour}$ip${endColour}${grayColour}/${endColour}${greenColour}$prefix${endColour}"
    echo -e "         ${greenColour}$netmask\t     \t$subnetmask${endColour}" 
    if [ $total_hosts ]; then
      echo -e "${yellowColour}Subnetworks:${endColour} ${greenColour}$total_subnetworks${endColour}" 
      echo -e "${yellowColour}Hosts:${endColour} ${greenColour}$total_hosts${endColour}"
    else
      echo -e "${yellowColour}Subnetworks:${endColour} ${greenColour}$total_subnetworks${endColour}"
      echo -e "${yellowColour}Hosts:${endColour} ${greenColour}$ip_asign${endColour}"
    fi
    echo -e "${yellowColour}Jump:${endColour} ${greenColour}$jump${endColour}"
  else

    echo "Subnetwork_NetworkID_FirstIP_LastIP_Broadcast" > ut.table
    ID=0
    first=1
    ip1=$ip
    ip2=$ip
    ip3=$ip
    ip4=$ip

    if [ $class_prefix -eq 8 ]; then
      if [ $parameter_counter -eq 5 ]; then
        jump3=$((((total_hosts + 2) / 256) / 256))
        echo $jump3
        jump2=256
        jump=256
        last=$((jump - 2))
        BR=$((jump - 1))
        flag2=$jump3
        flag3=$((jump3 - 1))      
      else
        jump3=$(((jump / 256) / 256 ))
        jump2=256
        jump=256
        last=$((jump - 2))
        BR=$((jump - 1))
        flag2=$jump3
        flag3=$((jump3 - 1))
      fi

        for (( i=1; i<=$total_subnetworks; i++)); do
        ID=0
        first=1 #Buscar que sea igual al 3 octeto de la ip en una diferente variable para 
        last=$((jump - 2))
        BR=$((jump - 1))
        for (( j=1; j<256; j+=$jump)); do
          ip1=$(echo $ip1 | sed "s/\.[0-9]\+$/\.$ID/")
          ip2=$(echo $ip2 | sed "s/\.[0-9]\+$/\.$first/")
          ip3=$(echo $ip3 | sed "s/\.[0-9]\+$/\.$last/")
          ip4=$(echo $ip4 | sed "s/\.[0-9]\+$/\.$BR/")
          ip1=$(echo $ip1 | awk -F '.' -v new=$ID '{print $1 "." $2 "." new "." $4}')
          ip2=$(echo $ip2 | awk -F '.' -v new=$((first - 1)) '{print $1 "." $2 "." new "." $4}')
          ip3=$(echo $ip3 | awk -F '.' -v new=$((last + 1 )) '{print $1 "." $2 "." new "." $4}')
          ip4=$(echo $ip4 | awk -F '.' -v new=$BR '{print $1 "." $2 "." new "." $4}')
          let ID+=$jump
          let first+=$jump
          let last+=$jump
          let BR+=$jump
#          echo "${i}_${ip1}_${ip2}_${ip3}_${ip4}" >> ut.table
        done
        #ip1=$(echo $ip1 | awk -F '.' -v new=$flag2 '{print $1 "." $2 "." new "." $4}')
        #ip2=$(echo $ip2 | awk -F '.' -v new=$flag2 '{print $1 "." $2 "." new "." $4}')
        ip3=$(echo $ip3 | awk -F '.' -v new=$flag3 '{print $1 "." new "." $3 "." $4}')
        ip4=$(echo $ip4 | awk -F '.' -v new=$flag3 '{print $1 "." new "." $3 "." $4}')
        echo "${i}_${ip1}_${ip2}_${ip3}_${ip4}" >> ut.table
        ip1=$(echo $ip1 | awk -F '.' -v new=$flag2 '{print $1 "." new "." $3 "." $4}')
        ip2=$(echo $ip2 | awk -F '.' -v new=$flag2 '{print $1 "." new "." $3 "." $4}')
        let flag2+=$jump3
        let flag3+=$jump3
      done
    elif [ $class_prefix -eq 16 ]; then # Condition to determine if subnetworks are less than devices if is true so build diferent structure
      if [ $parameter_counter -eq 5 ]; then
        jump2=$(((total_hosts + 2) / 256))
       # if [$jump2 -lt 2]
        jump=256
        flag2=$jump2
        flag3=$((jump2 - 1))
      else
        jump2=$(((ip_asign + 2) / 256))
        jump=256
        flag2=$jump2
        #flag2=$(echo $(echo $ip | awk -F '.' '{print $3}') + $jump2 | bc) -- Modify to make a vlsm
        #echo $flag
        flag3=$((jump2 - 1))
      fi

      for (( i=1; i<=$total_subnetworks; i++)); do
        ID=0
        first=1 #Buscar que sea igual al 3 octeto de la ip en una diferente variable para 
        last=$((jump - 2))
        BR=$((jump - 1))
        for (( j=1; j<256; j+=$jump)); do
          ip1=$(echo $ip1 | sed "s/\.[0-9]\+$/\.$ID/")
          ip2=$(echo $ip2 | sed "s/\.[0-9]\+$/\.$first/")
          ip3=$(echo $ip3 | sed "s/\.[0-9]\+$/\.$last/")
          ip4=$(echo $ip4 | sed "s/\.[0-9]\+$/\.$BR/")
          let ID+=$jump
          let first+=$jump
          let last+=$jump
          let BR+=$jump
#          echo "${i}_${ip1}_${ip2}_${ip3}_${ip4}" >> ut.table
        done
        #ip1=$(echo $ip1 | awk -F '.' -v new=$flag2 '{print $1 "." $2 "." new "." $4}')
        #ip2=$(echo $ip2 | awk -F '.' -v new=$flag2 '{print $1 "." $2 "." new "." $4}')
        ip3=$(echo $ip3 | awk -F '.' -v new=$flag3 '{print $1 "." $2 "." new "." $4}')
        ip4=$(echo $ip4 | awk -F '.' -v new=$flag3 '{print $1 "." $2 "." new "." $4}')
        echo "${i}_${ip1}_${ip2}_${ip3}_${ip4}" >> ut.table
        ip1=$(echo $ip1 | awk -F '.' -v new=$flag2 '{print $1 "." $2 "." new "." $4}')
        ip2=$(echo $ip2 | awk -F '.' -v new=$flag2 '{print $1 "." $2 "." new "." $4}')
        let flag2+=$jump2
        let flag3+=$jump2
#        jump=256

      done
    else
      ID=0
      first=1
      last=$((jump - 2))
      BR=$((jump - 1))
      for (( i=1; i<=$total_subnetworks; i++ )); do
        ip1=$(echo $ip1 | sed "s/\.[0-9]\+$/\.$ID/")
        ip2=$(echo $ip2 | sed "s/\.[0-9]\+$/\.$first/")
        ip3=$(echo $ip3 | sed "s/\.[0-9]\+$/\.$last/")
        ip4=$(echo $ip4 | sed "s/\.[0-9]\+$/\.$BR/")
        flag2=$(echo "$ip4"| awk -F. '{print $NF}')
        let ID+=$jump
        let first+=$jump
        let last+=$jump
        let BR+=$jump
        echo "${i}_${ip1}_${ip2}_${ip3}_${ip4}" >> ut.table
      done
    fi
    echo -ne "${turquoiseColour}"
    printTable "_" "$(cat ut.table)"
    echo -e "${endColour}"

       echo -e "${yellowColour}Network:${endColour} ${greenColour}$ip${endColour}${grayColour}/${endColour}${greenColour}$class_prefix${endColour}\t ${turquoiseColour}--->${endColour}\t${greenColour}$ip${endColour}${grayColour}/${endColour}${greenColour}$prefix${endColour}"
      echo -e "         ${greenColour}$netmask\t     \t$subnetmask${endColour}" 
      if [ $total_hosts ]; then
        echo -e "${yellowColour}Subnetworks:${endColour} ${greenColour}$total_subnetworks${endColour}" #Corregir 'cause is subnetworks 'cause ip asign is equals that hosts
        echo -e "${yellowColour}Hosts:${endColour} ${greenColour}$total_hosts${endColour}"
      else
        echo -e "${yellowColour}Subnetworks:${endColour} ${greenColour}$total_subnetworks${endColour}"
        echo -e "${yellowColour}Hosts:${endColour} ${greenColour}$ip_asign${endColour}"
      fi
      echo -e "${yellowColour}Jump:${endColour} ${greenColour}$jump${endColour}"
  fi
  rm ut.t* 2>/dev/null
  tput cnorm
}

# Main Function

if [ $(id -u) -eq 0 ]; then
  declare -i parameter_counter=0
  declare table=false
  while getopts "i:s:p:d:n:th" arg; do
    case $arg in
    i) ip=$OPTARG; let parameter_counter+=1;;
    s) subnetmask=$OPTARG; let parameter_counter+=2;;
    p) prefix=$OPTARG; let parameter_counter+=3;;
    d) hosts=$OPTARG; let parameter_counter+=4;;
    n) networks=$OPTARG; let parameter_counter+=5;;
    t) table=true;;
    h) ;;
    esac
  done

  if [ $parameter_counter -eq 3 ]; then
    reconnaissance $ip $subnetmask
  elif [ $parameter_counter -eq 4 ]; then
    reconnaissance $ip $prefix
  elif [ $parameter_counter -eq 5 ]; then
    subnetting $ip $hosts
  elif [ $parameter_counter -eq 6 ]; then
    subnetting $ip $networks
  else 
    helpPanel
  fi
else 
  echo -e "\n${redColour}[!] You're not root >:(${endColour}"
fi
