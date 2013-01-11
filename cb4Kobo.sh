#!/bin/sh

# see also http://linuxfr.org/users/yodaz/journaux/mini-shell-script-pour-optimiser-des-images-pour-une-liseuse
# see also http://www.admin6.fr/2011/03/passage-propre-darguments-en-script-shell/
# sudo apt-get install p7zip-fullp7zip-rar imagemagick

TOLERANCE=4%
JPG_QUALITY=75
SIZE=600x800
TMP_DIR=/tmp/koboTest
INPUT_COMIC_TYPE=.cbr
READING_DIRECTION=rtl
OPTIMIZE=false

FILE=${@: -1}

while getopts 'r:o' OPTION
do
	case $OPTION in
	r)    READING_DIRECTION="$OPTARG"
          ;;
	o)    OPTIMIZE=true
          ;;
	esac
done

rm -rf $TMP_DIR

mkdir $TMP_DIR

7z e "$FILE" -o$TMP_DIR

i=0

for f in $TMP_DIR/*.jpg
do
    width=`convert "$f" -ping -format '%[fx:w]' info:`
    height=`convert "$f" -ping -format '%[fx:h]' info:`
	halfwidth=`echo "$width/2"| bc`
    windowleft=`echo "$halfwidth"x"$height"+0+0`
	windowright=`echo "$width"x"$height"+"$halfwidth"+0`
	if [ $width -gt $height ]
	then
		echo "convert $f"
		if ([ $READING_DIRECTION = "rtl" ] && [ $i -ne 0 ]) || ([ $READING_DIRECTION = "ltr" ] && [ $i -eq 0 ])
		then
			convert -crop $windowright "$f" "$f".1.jpg
			convert -crop $windowleft "$f" "$f".2.jpg			
		else
			convert -crop $windowleft "$f" "$f".1.jpg
			convert -crop $windowright "$f" "$f".2.jpg			
		fi
		rm "$f"
		i=$(($i + 1))
	else
		echo "no crop for $f"
	fi

	if [ $OPTIMIZE = true ]
	then	
		if [ -f "$f" ]
		then 
			echo "optimize $f"
			convert "$f" -fuzz $TOLERANCE -quality $JPG_QUALITY -resize $SIZE -trim +repage -colorspace gray "$f"
		else
			echo "optimize $f.1.jpg"
			convert "$f.1.jpg" -fuzz $TOLERANCE -quality $JPG_QUALITY -resize $SIZE -trim +repage -colorspace gray "$f.1.jpg"
			echo "optimize $f.2.jpg"
			convert "$f.2.jpg" -fuzz $TOLERANCE -quality $JPG_QUALITY -resize $SIZE -trim +repage -colorspace gray "$f.2.jpg"
		fi
	fi
done

7z a -tzip -w$TMP_DIR "`basename "$FILE" $fNPUT_COMIC_TYPE`"-kobo.cbz $TMP_DIR/*

rm -rf $TMP_DIR
