cb4kobo
=======

cbr and cbz spliter to have decent comic book size on Kobo devices.

* convert any reading direction in left to right direction (the one of Kobo devixes)
* optimize image for Kobo devices

prerequisite
------------
you'll need the following packages

``` bash
$ sudo apt-get install p7zip-full p7zip-rar imagemagick
```

usage
-----

``` bash
$ bash cd4kobo.sh my-cb-file.cbr
```

option
------

* `-r{'ltr'|'rtl'}`: specify reading direction of the source
* `-o`: optimize image for Kobo devices

todo
----

* keep cover at first
* PyQT Version to get a real time preview

see also
--------

* http://linuxfr.org/users/yodaz/journaux/mini-shell-script-pour-optimiser-des-images-pour-une-liseuse
* http://www.admin6.fr/2011/03/passage-propre-darguments-en-script-shell/

