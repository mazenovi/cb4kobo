#!/bin/sh

TOLERANCE=4%
JPG_QUALITY=75
SIZE=600x800
TMP_DIR=/tmp/koboTest
INPUT_COMIC_TYPE=.cbr
READING_DIRECTION=ltr
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

for i in $TMP_DIR/*.jpg
do
    width=`convert "$i" -ping -format '%[fx:w]' info:`
    height=`convert "$i" -ping -format '%[fx:h]' info:`
	halfwidth=`echo "$width/2"| bc`
    windowleft=`echo "$halfwidth"x"$height"+0+0`
	windowright=`echo "$width"x"$height"+"$halfwidth"+0`
	if [ $width -gt $height ]
	then
		echo "convert $i"
		if [ $READING_DIRECTION = "ltr" ]
		then
			convert -crop $windowleft "$i" "$i".1.jpg
			convert -crop $windowright "$i" "$i".2.jpg
		else			
			convert -crop $windowright "$i" "$i".1.jpg
			convert -crop $windowleft "$i" "$i".2.jpg
		fi
		rm "$i"
	else
		echo "no crop for $i"
	fi

	if [ $OPTIMIZE = true ]
	then	
		if [ -f "$i" ]
		then 
			echo "optimize $i"
			convert "$i" -fuzz $TOLERANCE -quality $JPG_QUALITY -resize $SIZE -trim +repage -colorspace gray "$i"
		else
			echo "optimize $i.1.jpg"
			convert "$i.1.jpg" -fuzz $TOLERANCE -quality $JPG_QUALITY -resize $SIZE -trim +repage -colorspace gray "$i.1.jpg"
			echo "optimize $i.2.jpg"
			convert "$i.2.jpg" -fuzz $TOLERANCE -quality $JPG_QUALITY -resize $SIZE -trim +repage -colorspace gray "$i.2.jpg"
		fi
	fi
done

7z a -tzip -w$TMP_DIR "`basename "$FILE" $INPUT_COMIC_TYPE`"-kobo.cbz $TMP_DIR/*

rm -rf $TMP_DIR
