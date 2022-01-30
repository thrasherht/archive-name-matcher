#!/bin/bash

#function for color coding
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
purple=`tput setaf 5`
white=`tput setaf 7`
reset=`tput sgr0`
bold=`tput bold`


workingextension=".$1"
workingdir="$PWD"
DEBUG=0

#proper variable check
usage() {
 echo "Invalid input"
 echo "How to use: $0 interior-file-extension"
 exit 1
}

if [[ ! $1 ]]; then
  usage
fi

#Pre-Run information
echo "${green}++++ Archive File renamer ++++${reset}"
echo "This will scan directory for 7z archive, and rename mismatched interior files"
echo "  Dir to scan: ${yellow}$workingdir${reset}"
echo "   Ext to use: ${yellow}$workingextension${reset}"
echo ""

#Check if user wants to continue
while true; do
  read -p "${red}Continue? ${purple}(yes|no)${reset} : " yn
    case $yn in
      [Yy]* ) break;;
      [Nn]* ) exit;;
      * ) echo "Invalid input";;
    esac
done

files="$(find $workingdir -maxdepth 1 -type f -iname '*.7z')"

if [[ $DEBUG == 1 ]]; then
  echo "${red}DEBUG: This is a debug run. Archives found below"
  echo "$files${reset}" | sed 's/^/  /g'
fi

echo "$files" | while read filepath; do
  basefile=$(basename $filepath)
  shortarchivename=$(basename $filepath | rev | cut -d'.' -f2- |rev)
  
  echo -n "${purple}Checking archive : ${yellow}$basefile${reset} : "
  #echo "=>${blue}Files inside archive${reset}"
  filesinside="$(7zr l -ba -slt $filepath | grep 'Path' | grep "$workingextension\$" | awk -F'Path = ' {'print $2'})"
  multicheck=$(echo "$filesinside" | wc -l)
  echo "$filesinside" | while read filename; do
    if [[ $multicheck -gt 1 ]]; then
      echo "${purple}Skipping | Multiple files inside${reset}"
      break
    fi
    if [[ $filename == '' ]]; then
      echo "${purple}No matching files${reset}"
      continue
    fi
    shortfilename=$(basename "$filename" | rev | cut -d'.' -f2- |rev)
    #echo "  =>${yellow}$filename${reset}"
    if [[ ! $shortfilename == $shortarchivename ]]; then
      echo "${red}BAD${reset}"
      echo "   => ${red}Name mismatch: ${yellow}$filename${reset}"
      echo "   => ${blue}Renaming to ${yellow}'${shortarchivename}$workingextension'${reset}"
      if [[ $DEBUG == 1 ]]; then
        echo "${red}Debug only, simulated rename. Command below"
	echo "7zr rn $basefile \"${shortfilename}$workingextension\" \"${shortarchivename}$workingextension\" >/dev/null${reset}"
      else
	7zr rn $basefile "${shortfilename}$workingextension" "${shortarchivename}$workingextension" >/dev/null
      fi
    else
      echo "${green}OK"
    fi
  done
done
