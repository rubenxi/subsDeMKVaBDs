#!/bin/bash
function getidsubs {

# Archivo MKV del que se van a obtener los IDs de los subtítulos
archivo="$1"

# Lista de IDs de subtítulos
ids_subtitulos=$(mkvmerge --identify "$archivo" | grep 'subtitles' | awk '{print $3}' | cut -d':' -f1-1)
arraycarpeta2=("$2"*.mkv) # y mp4?
if [[ ${#arraycarpeta2[@]} -eq 1 ]]
then
arraycarpeta2=("$2"*.mp4) # y mp4?
fi
if [[ ${#arraycarpeta2[@]} -eq 1 ]]
then
echo "No hay MKVs ni MP4s en la carpeta de origen de BD Raw" 
exit
fi

# Iterar sobre cada ID de subtitulo y extraer el track correspondiente
echo "ARCHIVO DE SUBS: $archivo"
for id in $ids_subtitulos
do
nombrefinal="${arraycarpeta2[$3]}"
echo "$(basename "$nombrefinal").$id.ass"
mkvextract tracks "$archivo" $id:"$(basename "$nombrefinal").$id.ass"
mv "$(basename "$nombrefinal").$id.ass" "$2"
done

}



echo "####################################"
echo "Este script coge una carpeta con mkvs, les saca los subs y los mueve con el nombre correcto a una carpeta con mkvs raw"
echo ""
echo "Ambas carpetas deben contener solo los episodios numerados, si hay OPs o EDs o algo extra y está al final de la carpeta tambien vale. Se ignoran subcarpetas"
echo "####################################"
echo ""
echo "Uso: [carpeta con subs] [carpeta con BD]"
echo ""
echo "Si falta algún episodio usa un dummy, crea un archivo de texto vacio con el nombre que tendría el episodio que falta"
echo ""
echo "#################"
if [ -z "$1" ] && [ -z "$2" ]
then
echo ""
if [ "$menumode" == "si" ]
then
echo "Usando menu para elegir primera carpeta"
folder1=$(zenity --file-selection --directory --title "Select BD folder for input MKVs with subs" 2> >(grep -v Gtk >&2))
else
echo "Usando carpeta actual para recoger SUBS"
folder1="$PWD"
fi
folder2=$(zenity --file-selection --directory --title "Select BD folder for output BD Raw" 2> >(grep -v Gtk >&2))
elif [ -z "$2" ]
then
######################
folder2=$(zenity --file-selection --directory --title "Select BD folder for output BD Raw" 2> >(grep -v Gtk >&2))
else
folder1="$1"
folder2="$2"
#####################
fi

contador=0

if [ -z "$folder1" ] || [ -z "$folder2" ]
then
echo "CANCELADO"
exit
fi


for file in "$folder1/"*
do
echo "$file"
    if [[ "$file" == *.mkv ]]
then        
getidsubs "$file" "$folder2/" $contador
            contador=$((contador+1))

fi
done

notify-send -a "SubsDeMKVaBD" "SubsDeMKVaBD acabó. Procesado: $(basename "$folder1")"
