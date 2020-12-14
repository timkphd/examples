# bash function for finding today's files
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

