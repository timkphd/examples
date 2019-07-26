#!/opt//python/gcc/3.4.3/bin/python3
"""
Show how to make date plots in matplotlib using date tick locators and
formatters.  See major_minor_demo1.py for more information on
controlling major and minor ticks
"""
import datetime
from datetime import date
from pylab import figure, show,save
from matplotlib.dates import MONDAY, SATURDAY,SUNDAY
from matplotlib.dates import MonthLocator, WeekdayLocator, DateFormatter


date1 = datetime.date( 2002, 1, 5 )
date2 = datetime.date( 2003, 12, 1 )

# every sunday
sundays   = WeekdayLocator(SUNDAY)

# every 3rd month
months    = MonthLocator(range(1,13), bymonthday=1, interval=1)
monthsFmt = DateFormatter("%b '%y")



nodes=[]
cumu=[]
when=[]
x=[]

f=open("2017.bike","r")
lines=f.readlines()
for l in lines:
	l=l.split("\t")
	when.append(l[0])
	nodes.append(int(l[1]))
cumu.append(nodes[0])
k=0
for n in nodes[1:]:
	cumu.append(cumu[k]+n)
	k=k+1


for d in when:
	d=d.split("-")
	x.append(date.toordinal(date(int(d[0]),int(d[1]),int(d[2]))))
#print x,cumu
fig = figure()
ax = fig.add_subplot(111)
ax.plot_date(x, nodes, 'b+')
ax2 = ax.twinx()
ax2.plot(x, cumu, 'r')
ax.xaxis.set_major_locator(months)
ax.xaxis.set_major_formatter(monthsFmt)
ax.xaxis.set_minor_locator(sundays)
ax.autoscale_view()
#ax.xaxis.grid(False, 'major')
#ax.xaxis.grid(True, 'minor')
ax.grid(True)
for tl in ax2.get_yticklabels():
    tl.set_color('r')
for tl in ax.get_yticklabels():
    tl.set_color('b')
ax2.set_ylabel('Cumulative', color='r')
ax.set_ylabel('Daily', color='b')
ax.set_xlabel('Date')
ax.set_title('2017 Cycling History')



fig.autofmt_xdate()

show()


