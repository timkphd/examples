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

