account() {
    if (( $# > 0 )) ; then
      sacctmgr show assoc user=$1 format=account
      lslogins $1
    else
      sacctmgr show assoc user=tkaiser2 format=account
    fi
}



