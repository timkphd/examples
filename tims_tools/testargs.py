#!/usr/bin/python3
import sys
import os
import argparse
parser = argparse.ArgumentParser(add_help=True)
parser.add_argument("input_file", nargs="?", default=None, help="Path to the input file (optional)")
parser.add_argument("-t", type=str, dest="Title",help="string - Title above the table")
parser.add_argument("-n", action="store_true", dest="Header",default=False,help="First Line is not a header")
parser.add_argument("-b", action="store_true", dest="BlueBar",default=False,help="BlueBar")
parser.add_argument("-g", action="store_true", dest="GreenBar",default=True,help="GreenBar (default)")
args, unknown_args = parser.parse_known_args()
print(args)
if(args.BlueBar) : print("bluebar")
print("#####")
print(unknown_args)
