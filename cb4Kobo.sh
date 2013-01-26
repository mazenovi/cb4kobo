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

	without_pages=`echo $f | sed -e 's/[0-9]\+\-[0-9]\+ *\.jpg.*//'`
	pages=`echo ${f:${#without_pages}:${#f}} | sed -e 's/ *\.jpg.*//'`
	# get last element
	second_page_number=`echo ${pages##*-}`
	# get first element
	first_page_number=`echo $pages | sed -e "s/\-${pages##*-}//"`

	if [ $first_page_number -lt $second_page_number ]
	then
		left_page_number=$first_page_number
		right_page_number=$second_page_number
	else
		left_page_number=$second_page_number
		right_page_number=$first_page_number
	fi

	if [ -z $first_page_number ] && [ -z $second_page_number ]
	then
		without_pages=`echo $f | sed -e 's/[0-9]\+ *\.jpg.*//'`
		pages=`echo ${f:${#without_pages}:${#f}} | sed -e 's/ *\.jpg.*//'`
		# get last element
		second_page_number=`echo "$pages*2"| bc`
		# get first element
		second_page_number=`echo "$pages*2+1"| bc`
		left_page_number=`echo "$pages*2"| bc`
		right_page_number=`echo "$pages*2+1"| bc`
	fi

	#for consistent number

	if [ -n "$left_page_number" ] 
	then
		if [ $left_page_number -lt 100 ]
		then
			if [ $left_page_number -lt 10 ]
			then
				left_page_number=00$left_page_number	
			else
				left_page_number=0$left_page_number	
			fi
		fi
	fi

	if [ -n "$right_page_number" ]
	then
		if [ $right_page_number -lt 100 ]
		then
			if [ $right_page_number -lt 10 ]
			then
				right_page_number=00$right_page_number	
			else
				right_page_number=0$right_page_number	
			fi
		fi
	fi
	
	if [ $width -gt $height ]
	then
		echo "convert $f"
		if ([ $READING_DIRECTION = "rtl" ] && [ $i -ne 0 ]) || ([ $READING_DIRECTION = "ltr" ] && [ $i -eq 0 ])
		then
			convert -crop $windowright "$f" "$without_pages-kobo-$left_page_number.jpg"
			convert -crop $windowleft "$f" "$without_pages-kobo-$right_page_number.jpg"
		else
			convert -crop $windowleft "$f" "$without_pages-kobo-$left_page_number.jpg"
			convert -crop $windowright "$f" "$without_pages-kobo-$right_page_number.jpg"
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
			echo "optimize $without_pages-kobo-$left_page_number.jpg"
			convert "$f" -fuzz $TOLERANCE -quality $JPG_QUALITY -resize $SIZE -trim +repage -colorspace gray "$without_pages-kobo-$left_page_number.jpg"
			rm "$f"
		else
			echo "optimize $without_pages-kobo-$left_page_number.jpg"
			convert "$without_pages-kobo-$left_page_number.jpg" -fuzz $TOLERANCE -quality $JPG_QUALITY -resize $SIZE -trim +repage -colorspace gray "$without_pages-kobo-$left_page_number.jpg"
			echo "optimize $without_pages-kobo-$right_page_number.jpg"
			convert "$without_pages-kobo-$right_page_number.jpg" -fuzz $TOLERANCE -quality $JPG_QUALITY -resize $SIZE -trim +repage -colorspace gray "$without_pages-kobo-$right_page_number.jpg"
		fi
	fi
done

7z a -tzip -w$TMP_DIR "`basename "$FILE" $fNPUT_COMIC_TYPE`"-kobo.cbz $TMP_DIR/*

rm -rf $TMP_DIR
