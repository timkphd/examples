#!/usr/bin/env python
"""
Show how to make date plots in matplotlib using date tick locators and
formatters.  See major_minor_demo1.py for more information on
controlling major and minor ticks
"""
import datetime
from datetime import date
from pylab import figure, show,save,savefig
from matplotlib.dates import MONDAY, SATURDAY
from matplotlib.dates import MonthLocator, WeekdayLocator, DateFormatter


date1 = datetime.date( 2002, 1, 5 )
date2 = datetime.date( 2003, 12, 1 )

# every monday
mondays   = WeekdayLocator(MONDAY)

# every 3rd month
months    = MonthLocator(range(1,13), bymonthday=1, interval=4)
monthsFmt = DateFormatter("%b '%y")



nodes=[4,16,26,32,48,50,52,60,84,90,100,120,122,124,126,128,130,158]
cores=[32,128,208,256,448,472,496,592,880,952,1072,1392,1424,1456,1496,1536,1576,2248]
when=['2010-03-09', '2010-04-21', '2010-05-14', '2010-08-31', '2010-10-06', '2011-06-24', 
'2011-06-24', '2011-07-12', '2011-11-04', '2011-11-02', '2012-03-26', '2012-09-28', 
'2013-08-26', '2014-03-15', '2014-06-15', '2014-06-20', '2014-06-17', '2015-04-01']
x=[]

# ganesh 160-167 8*24 2015-08-01
nodes.append(int(nodes[-1])+8)
cores.append(int(cores[-1])+8*24)
when.append('2015-08-01')

# bgthomas 168-171 4*24 2016-02-01
nodes.append(int(nodes[-1])+4)
cores.append(int(cores[-1])+4*24)
when.append('2016-02-01')

# tkaiser p001-002 2*20 2016-03-01
nodes.append(int(nodes[-1])+2)
cores.append(int(cores[-1])+2*20)
when.append('2016-03-01')

# lcarr 172-173 2*24 2016-05-01
nodes.append(int(nodes[-1])+2)
cores.append(int(cores[-1])+2*24)
when.append('2016-05-01')

# kappes 174-175 2*24 2016-05-30
nodes.append(int(nodes[-1])+2)
cores.append(int(cores[-1])+2*24)
when.append('2016-05-30')

# cdurfee 176-177 2*24 2016-05-30
nodes.append(int(nodes[-1])+2)
cores.append(int(cores[-1])+2*24)
when.append('2016-08-18')

# kleiderman 178-179 2*24 2016-05-30
nodes.append(int(nodes[-1])+2)
cores.append(int(cores[-1])+2*24)
when.append('2016-09-30')

# dgomezgualdron 180-191 2*28 2016-05-30
nodes.append(int(nodes[-1])+12)
cores.append(int(cores[-1])+12*28)
when.append('2017-01-26')

# tkaiser 192-193 2*28 2016-05-30
nodes.append(int(nodes[-1])+12)
cores.append(int(cores[-1])+12*28)
when.append('2017-02-02')

# meberhar 194-195 2*28 2016-05-30
nodes.append(int(nodes[-1])+2)
cores.append(int(cores[-1])+2*28)
when.append('2017-02-21')

# lcarr 196 1*28 2016-05-30
nodes.append(int(nodes[-1])+1)
cores.append(int(cores[-1])+1*28)
when.append('2017-07-30')

# dgomezgualdron 197 1*28 2016-05-30
nodes.append(int(nodes[-1])+1)
cores.append(int(cores[-1])+1*28)
when.append('2017-07-30')

# gbrennec 198-201 4*28 2016-05-30
nodes.append(int(nodes[-1])+4)
cores.append(int(cores[-1])+4*28)
when.append('2017-08-30')

nodes.append(int(nodes[-1])+16)
cores.append(int(cores[-1])+16*28)
when.append('2018-01-30')


for d in when:
	d=d.split("-")
	x.append(date.toordinal(date(int(d[0]),int(d[1]),int(d[2]))))
#print x,cores
fig = figure()
ax = fig.add_subplot(111)
ax.plot_date(x, nodes, 'b-')
ax2 = ax.twinx()
ax2.plot(x, cores, 'r-')
ax.xaxis.set_major_locator(months)
ax.xaxis.set_major_formatter(monthsFmt)
#ax.xaxis.set_minor_locator(mondays)
ax.autoscale_view()
#ax.xaxis.grid(False, 'major')
#ax.xaxis.grid(True, 'minor')
ax.grid(True)
for tl in ax2.get_yticklabels():
    tl.set_color('r')
for tl in ax.get_yticklabels():
    tl.set_color('b')
ax2.set_ylabel('Cores', color='r')
ax.set_ylabel('Nodes', color='b')
ax.set_xlabel('Date')
ax.set_title('Mio "Normal" Compute Nodes and Cores over Time')



fig.autofmt_xdate()

#show()
savefig("nodes.pdf")
