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

def show_usage():
    usage_text = f"""
NAME

     {sys.argv[0]} - create a date/time stamped archive

SYNOPSIS

     {sys.argv[0]} [Options] [file]

DESCRIPTION

     All arguments are optional.  If run without arguments
     the program will create an archive of the current directory
     into a date/time/"machine name" stamped file.  The archive
"""
    if mybase == "./":
        usage_text += "     will be placed in the current directory.\n\n"
    else:
        usage_text += f"     will be placed in {mybase}.\n\n"

    usage_text += """
     You can list the files to place in the archive on the command line

     The following options are available:

         -h               show this help and quit
         -s               work silently
         -n               don't time stamp the file name
         -svn             include git, svn, and CVS directories
         -b directory     directory in which to place the archive
         -i file          file or directory to archive
         -o name          replace the machine name in the archive with this name
         -io file_name    combination of -i and -o using the same value for each


"""
    print(usage_text)
    sys.exit(0)

parser = argparse.ArgumentParser(add_help=False)
parser.add_argument("-verbose", action="store_true", dest="verboseornoverbose")
parser.add_argument("-h", action="store_true", dest="help")
parser.add_argument("-n", action="store_true", dest="nodate")
parser.add_argument("-s", action="store_true", dest="silent")
parser.add_argument("-svn", action="store_true", dest="svn")
parser.add_argument("-b", type=str, dest="base")
parser.add_argument("-i", type=str, dest="i")
parser.add_argument("-o", type=str, dest="o")
parser.add_argument("-io", type=str, dest="io")
parser.add_argument("-oi", type=str, dest="io")  # same as -io

args, unknown_args = parser.parse_known_args()

verboseornoverbose = args.verboseornoverbose
help_flag = args.help
nodate = args.nodate
silent = args.silent
svn = args.svn
base = args.base
i = args.i
o = args.o
io = args.io

whoami = getpass.getuser()

command = "tar --exclude .git --exclude .svn --exclude CVS --exclude CVSROOT --exclude .DS_Store -czf "
if svn:
    command = "tar --exclude .DS_Store -czf "

myname = "tkaiser"
# myname = whoami
mybase = "./"

if help_flag:
    mybase = mybase if base is None else base
    show_usage()

if io:
    i = io
    o = io

if unknown_args:
    i = " " + " ".join(unknown_args)

if not base:
    base = mybase
base = base.rstrip()
if not base.endswith("/"):
    base += "/"

host = o if o else socket.gethostname().split('.')[0]

time = "" if nodate else stamp()

if whoami == myname:
    fname = f"{time}{host}.tgz"
else:
    fname = f"{time}{host}_{whoami}.tgz"

fname = base + fname

if i:
    command = f"{command}{fname} {i}"
else:
    command = f"{command}{fname} *"

if not silent:
    print(command)

output = subprocess.getoutput(command)

if not silent:
    print(output)
