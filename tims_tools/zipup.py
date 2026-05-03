#!/usr/bin/env python3

#converted from perl to python using
#https://www.codeconvert.ai/perl-to-python-converter
import os
import sys
import subprocess
import getpass
import socket
from datetime import datetime
import argparse

def stamp():
    now = datetime.now()
    return now.strftime("%m%d_%H%M%S")

def show_usage(script_name, mybase):
    print("\033[1mNAME\033[0m\n")
    print(f"     {script_name} - create a date/time stamped archive\n\n")
    print("\033[1mSYNOPSIS\033[0m\n")
    print(f"     {script_name} [Options] [file]\n\n")
    print("\033[1mDESCRIPTION\033[0m\n")
    print("     All arguments are optional.  If run without arguments")
    print("     the program will create an archive of the current directory")
    print("     into a date/time/\"machine name\" stamped file.")
    if mybase == "./":
        print("     will be placed in the current directory.\n")
    else:
        print(f"     will be placed in {mybase}.\n")
    print("     You can list the files to place in the archive on the command line\n")
    print("     The following options are available:\n")
    print("         -h               show this help and quit")
    print("         -s               work silently")
    print("         -n               don't time stamp the file name")
    print("         -svn             include svn and CVS directories")
    print("         -b directory     directory in which to place the archive")
    print("         -i file          file or directory to archive")
    print("         -o name          replace the machine name in the archive with this name")
    print("         -io file_name    combination of -i and -o using the same value for each\n")
    sys.exit(0)

def main():
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("-verbose", action="store_true", default=False)
    parser.add_argument("-h", action="store_true", default=False)
    parser.add_argument("-n", action="store_true", default=False)
    parser.add_argument("-s", action="store_true", default=False)
    parser.add_argument("-svn", action="store_true", default=False)
    parser.add_argument("-b", type=str, default=None)
    parser.add_argument("-i", type=str, default=None)
    parser.add_argument("-o", type=str, default=None)
    parser.add_argument("-io", type=str, default=None)
    args, unknown = parser.parse_known_args()

    verboseornoverbose = args.verbose
    help_flag = args.h
    nodate = args.n
    silent = args.s
    svn = args.svn
    base = args.b
    i = args.i
    o = args.o
    io = args.io

    whoami = getpass.getuser()
    myname = "tkaiser"
    mybase = "./"

    if help_flag:
        show_usage(sys.argv[0], mybase)

    if io:
        i = io
        o = io

    if unknown:
        i = " " + " ".join(unknown)

    if not base:
        base = mybase
    base = base.rstrip("\n")
    if not base.endswith("/"):
        base = base + "/"

    host = o if o else socket.gethostname().split('.')[0]

    time_str = "" if nodate else stamp()

    if whoami == myname:
        fname = f"{time_str}{host}.zip"
    else:
        fname = f"{time_str}{host}_{whoami}.zip"

    fname = base + fname

    command = "zip "
    if not silent:
        command = "zip "
    else:
        command = "zip -q "

    command += " -r "

    exclude = " -x *.svn* -x *CVS* -x *CVSROOT* -x *.DS_Store* -x __MACOSX*"
    if svn:
        exclude = " -x *.DS_Store*"

    if i:
        command += f"{fname} {i}"
    else:
        command += f"{fname} *"

    command += exclude

    if not silent:
        print(command)

    # Execute the command and capture output
    try:
        output = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT, text=True)
    except subprocess.CalledProcessError as e:
        output = e.output

    if not silent:
        print(output)

if __name__ == "__main__":
    main()
