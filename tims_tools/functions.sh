
prepend() {
  END=`printenv $1`
  if [ -z "$END" ]  ; then
    export $1=$2
  else
    export $1=$2:$END
  fi
}


append() {
  END=`printenv $1`
  if [ -z "$END" ]  ; then
    export $1=$2
  else
    export $1=$END:$2
  fi
}

today() {
     local now=`date +"%Y-%m-%d"`
     if (( $# > 0 )) ; then
         if [[ $1 == "-f" ]] ; then
            find . -type f -newermt $now
         fi
         if [[ $1 == "-d" ]] ; then
            find . -type d -newermt $now
         fi
    else
        find .  -newermt $now
    fi
    }

setperm() {
echo setting permissions for $1
find $1 -perm -u=x -exec chmod go+x {} \;
find $1 -perm -u=r -exec chmod go+r {} \;
}


cstrip() {
# You can effectively make comments in a
# bash script by delimiting with :<<++++ and ++++
# This function removes them.
for script in "$@" ; do
    out=_$script
    echo $out
    sed  '/:<<++++/,/^++++/d' $script > $out
done
}


account() {
    if (( $# > 0 )) ; then
      sacctmgr show assoc user=$1 format=account
      lslogins $1
    else
      sacctmgr show assoc user=tkaiser2 format=account
    fi
}

scr() {
    if [ $# -lt 1 ]; then
    cd /scratch/$USER
    else
    cd /scratch/$USER/$1
    fi
    }

alias sq="squeue -u $USER --format='%18A%15l%15L%6D%20S%15P%15r%20V%N'"
alias sqd="squeue -u $USER --format='%18A%15l%15L%6D%20S%15P%15r%20V%20N%20E'"

dogpu() until sq | grep $1 > /dev/null ; (($?)) ;do date ; gpus ; sleep 5; done
docpu() until sq | grep $1 > /dev/null ; (($?)) ;do date ; onnodes  ; sleep 5; done
alias showuser="lslogins"



running() { nl=`sq | wc -l`; if [ "$nl" -gt "1" ] ; then return 0 ; else return 1 ; fi; }
dorunning() { running ; while [ $? -eq "0" ] ; do echo "running" ; sleep 10 ; running ; done }


dompt() {
export MYVERSION=dompt
module load conda
source activate
source activate $MYVERSION
module load gcc/8.4.0
module load mpt
}


mdiff(){ d1=$1 ;  while test $# -gt 0; do     ls -lt $1 ; diff $d1 $1;     echo ++++++++++++++++++++++++++++++ ;shift; done;  }
wackit () { 
# function to remove an entry from a variable such as PATH based on a substring
# export PATH=`wackit PATH mypath`
str=`printenv $1`
IFS=':'                    # set delimiter
read -ra ADDR <<< "$str"   # str is read into an array as tokens separated by IFS
SUB=$2
export NP=""
for i in "${ADDR[@]}"; do  # access each element of array
    if grep -q "$SUB" <<< "$i"; then
       :                   # put it back together skipping entires that contain the substring
    else 
       NP=`echo ${NP}" "${i}`
    fi
done
                           # print is out with ":" replacing " " and stripping the first if needed
echo $NP | sed "s, ,:,g" | sed "s,^:,,"
}
