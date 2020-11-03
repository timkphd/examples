#!/usr/bin/env python
# coding: utf-8
import pandas as pd

df=pd.read_csv("pandas.csv")

tests=list(df.test.unique())
tests.remove('test')
print(tests)

# Two ways to make individual data frames. This is the first.
# Here we create them one at a time with exec.
for w in tests :
    astr='WHAT=pd.DataFrame(df.loc[df.test=="WHAT"])'
    astr=astr.replace('WHAT',w)
    print(astr)
    exec(astr)
# remove the extra columns from pingpong and barrier
    astr="headrow=WHAT.index.values.tolist()[0]-1 \nif headrow > 0 : WHAT.columns = [df.iloc[headrow]]"
    astr=astr.replace('WHAT',w)
    #print(astr)
    exec(astr)
        
# Two ways to make individual data frames. This is the second.
# We create a dictionary of dataframes with tests as the keys.
bonk={}
for w in tests :
    bonk[w]=pd.DataFrame(df.loc[df.test==w])
    headrow=bonk[w].index.values.tolist()[0]-1
    if headrow > 0 : 
        bonk[w].columns = [df.iloc[headrow]]
        
# Remove the extra columns from pingpong and barrier.
for x in ['a','b','c','d','e','f','g'] :
    bonk['Barrier'] = bonk['Barrier'].drop(x, 1)
for x in ['b','c','d','e','f','g'] :
    bonk['Pingpong'] = bonk['Pingpong'].drop(x, 1)

# If we don't want to work with the dictionary we can break out entires.
# This is general procedure that should work with all dictionaries.
for w in bonk.keys() :
    print(w)
    print(bonk[w])
    astr="WHAT=bonk['WHAT']"
    astr=astr.replace('WHAT',w)
    #print(astr,"\n")
    exec(astr)

if False :
    print(Pingpong)
    print(Barrier)
    print(Alltoall)
    print(Allgather)
    print(Allreduce)
    print(Sendrecv)
    print(Exchange)
    print(Uniband)
    print(Biband)

