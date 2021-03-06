#!/bin/sh


DST=$HOME/p/documentation/old

rm -rf $DST

if [ ! -d $DST ] ; then
for f in `find . -name \*.xml`; do 
    d=`dirname $DST/$f`
    mkdir -p $d
    pandoc -f docbook -t rst $f -o $DST/${f%.xml}.rst
done
fi

includes=$(find . -name \*.xml -exec grep -H \<include {} \;|awk -F : '{print $1}'|uniq)

for f in $includes ; do 
	echo "Adding includes from $f to $DST/${f%.xml}.rst"
	(awk '
BEGIN{print ".. toctree::\n   :maxdepth: 2\n"}
/<include/ {inc=$2;
            gsub("file=\"", "   ", inc);
            gsub(".xml\"/>", "", inc)
            print inc}
END{print ""}
' $f;
         cat $DST/${f%.xml}.rst) | sed -e '/version:/d' \
                                       -e 's/ITM/EU-IM/g' \
                                       -e '/^::/s/::/.. code-block:: console/'\
                                       > $DST/${f%.xml}.rst.tmp
        mv $DST/${f%.xml}.rst.tmp $DST/${f%.xml}.rst
done

find $DST -name \*.rst -exec sed -i -e 's/ITM/EU-IM/g' -e "s/.efda-itm.eu/.eufus.eu/" {} \;
find $DST -name \*.rst -exec sed -i -e 's,.eu/project/,.eu/gf/project/,' {} \;

