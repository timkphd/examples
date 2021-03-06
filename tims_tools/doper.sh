#!/bin/bash -v
if [ -z $1 ]; then 
  GROUP=naris
else 
  GROUP=$1
fi

# print or set our current umask set in .bashrc
# we have is set as umask 027  The default is 007.
if [ -z $2 ]; then 
  umask 027
else 
  umask $2
fi

umask


# make a new directory to play in
rm -rf new
mkdir new
chown :${GROUP} new
ls -ld new
cd new
start=`pwd`


# create a source to compile
echo 'void main(){int printf(const char *f, ...);printf("hi\n");}' > hi.c
cat hi.c
chmod 644 hi.c

# make 4 directories
for s in a b c d ; do
  mkdir ${s}_dir
done

# change the group of a,b,c
for s in a b c ; do
  chown :${GROUP} ${s}_dir
done
ls -ld *

# set the group inheritance bit for a,b.
# files and subdirectories created within the 
# directory inherit the group ID of the directory.
for s in a b  ; do
    chmod g+s ${s}_dir
done

# set the group rx acl for a, this is overkill
setfacl -d -mg::rx a_dir

ls -ld *

# create sub directories and files in each
for s in a b c d ; do
	cd ${s}_dir
	touch ${s}_file
	gcc ../hi.c -o ${s}_out
	mkdir ${s}${s}_dir
	cd ${s}${s}_dir
	touch ${s}${s}_file
	gcc ../../hi.c -o ${s}${s}_out
	mkdir ${s}${s}${s}_dir
	cd ${s}${s}${s}_dir
	touch ${s}${s}${s}_file
	gcc ../../../hi.c -o ${s}${s}${s}_out

	cd $start
done

cd $start
ls -ld *
ls -lR *dir
