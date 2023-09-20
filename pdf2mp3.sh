#! /bin/bash

# Script qui converti un pdf passé en paramètre en plusieurs fichiers audio mp3
# Nécessite les application pdftotext, wc, gspeech (pico2wave), soundconverter
# Paramètre :   -t  --> Passe un fichier txt et non pdf en entrée
# Remarque on peut OCRésié le PDF via la commande
# ocrmypdf mon_fichier.pdf mon_fichier_ocr.pdf

# FP.IVART le 12/09/23

TailleMaxiTxt=30000

if [ $1 == "-t" ]; then
  FichierEnt="$2"
  TextEnt=1
else
  FichierEnt="$1"
  TextEnt=0
  if [ ${FichierEnt##*.} != "pdf" ]; then
    echo "Le fichier $1 doit etre un PDF !"
    exit
  fi
fi

FichierSource=$(echo $FichierEnt | cut -d '.' -f1)
echo "Fichier source : $FichierEnt"

if [ $TextEnt == "0" ]; then
  # Si le Fichier txt existe on le supprime
  if [ -e $FichierSource".txt" ]; then
    rm -v $FichierSource".txt"
  fi
  echo "Conversion du fichier .pdf en fichier .txt..."
  # Conversion du fichier .pdf en fichier .txt
  pdftotext $FichierEnt
fi

# Suppression des Fichiers .mp3 précédents
rm -v $FichierSource"_"*".mp3"

# Récupère le nombre de caractères du fichier .txt
NbCarac=$(wc -m $FichierSource".txt" | cut -d " " -f1)

echo "Nombre de caractère du fichier .txt : $NbCarac (Maxi $TailleMaxiTxt)"

# Calcul du nombre de fichiers nécessaire
NbrFichiers="$(echo "($NbCarac/$TailleMaxiTxt)+1" | bc)"

# Découpage en NbrFichiers
echo "Découpage du fichier .txt en $NbrFichiers..."

split -d -n$NbrFichiers $FichierSource".txt" $FichierSource"_"
   
# Conversion des fichiers .txt en .wav
for i in $FichierSource"_"*
do
   # Création du fichier wav depuis le fichier txt
   echo "Création du fichier $i.wav"
   pico2wave -l fr-FR -w $i".wav" < $i

   # Suppression du fichier temporaire
   rm $i

   # Conversion en mp3
   echo "Création du fichier $i.mp3"
   soundconverter -b "$i.wav" -f mp3 -o .
   
   # Suppression du fichier wav
   rm $i".wav"
done 

