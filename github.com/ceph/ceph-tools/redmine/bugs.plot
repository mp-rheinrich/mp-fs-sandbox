#! /usr/bin/gnuplot
#
# generate plots of numbers of issues per time period.
# broken down by tracker-type or priority
#
# usage:
#	gnuplot weekly.plot bugs.plot
#	gnuplot monthly.plot bugs.plot
#
# expected input format:
# 	date	urgent high normal low feature support cleanup tasks doc
#
# This plot file does not care what the time unit is, it just uses 
# column 1 as a label
#
# TODO
#
#  (1)	I'd like to come up with a function I can use for
#	generating cumulative backlog (as the sum of new-fix).
#	But I'm having trouble using that in a histogram.
#
#  (2)	Having this script know what the names and colors of
#	the issue classifications ties this to the database
#	and the reduction script.  Much better would be if
#	the reduction script could pass the titles and colors
#	in to me.  Maybe 'lc variable' can help here.
#
# NOTE:
#	the variable BASE, which controls input and output file names,
#	must have been initialized ... e.g.
#		BASE = "weekly"
#		INFILE = "bugs.".BASE
#	output files will have names of the form $BASE-{new,fix,net}.png
# 

print "Processing input file: ".INFILE." to create output ".BASE."-{new,fix,net}.png"

# output to png files
set term png font 

# things usually get busier to the right
set key left top

# dates print better rotated
set xtics out nomirror rotate

# stacked histograms
set ytics out nomirror
set style data histograms
set style histogram rowstacked
set style fill solid border -1
set boxwidth 0.8 relative

set output BASE."-new.png"
set title "Issue Arrival Rates";
plot	INFILE	u 2:xticlabels(1) 			\
			t "Immediate"	lc rgb 'violet',\
	''	u 3	t "Urgent"	lc rgb 'red',	\
	''	u 4	t "High"	lc rgb 'pink',	\
	''	u 5	t "Normal"	lc rgb 'orange',\
	''	u 6	t "Low"		lc rgb 'yellow',\
	''	u 7	t "Feature"	lc rgb 'green',	\
	''	u 8	t "Support"	lc rgb 'blue',	\
	''	u 9	t "Cleanup"	lc rgb 'cyan',	\
	''	u 10	t "Tasks"	lc rgb 'white',	\
	''	u 11	t "Doc"		lc rgb 'grey';

set output BASE."-fix.png"
set title "Issue Fix Rates";
plot	INFILE	u 12:xticlabels(1) 			\
			t "Immediate"	lc rgb 'violet',\
	''	u 13	t "Urgent"	lc rgb 'red',	\
	''	u 14	t "High"	lc rgb 'pink',	\
	''	u 15	t "Normal"	lc rgb 'orange',\
	''	u 16	t "Low"		lc rgb 'yellow',\
	''	u 17	t "Feature"	lc rgb 'green',	\
	''	u 18	t "Support"	lc rgb 'blue',	\
	''	u 19	t "Cleanup"	lc rgb 'cyan',	\
	''	u 20	t "Tasks"	lc rgb 'white',	\
	''	u 21	t "Doc"		lc rgb 'grey';


set output BASE."-net.png"
set title "Issue Backlog";
plot	INFILE	u 22:xticlabels(1) 			\
			t "Immediate"	lc rgb 'violet',\
	''	u 23	t "Urgent"	lc rgb 'red',	\
	''	u 24	t "High"	lc rgb 'pink',	\
	''	u 25	t "Normal"	lc rgb 'orange',\
	''	u 26	t "Low"		lc rgb 'yellow',\
	''	u 27	t "Feature"	lc rgb 'green',	\
	''	u 28	t "Support"	lc rgb 'blue',	\
	''	u 29	t "Cleanup"	lc rgb 'cyan',	\
	''	u 30	t "Tasks"	lc rgb 'white',	\
	''	u 31	t "Doc"		lc rgb 'grey';

#
# functions to compute cumulative bug backlogs
#
b1 = 0
b2 = 0
b3 = 0
b4 = 0
b5 = 0
b6 = 0
b7 = 0
b8 = 0
b9 = 0
f1(n,f) = (  n - f )
f2(n,f) = (  n - f )
f3(n,f) = (  n - f )
f4(n,f) = (  n - f )
f5(n,f) = (  n - f )
f6(n,f) = (  n - f )
f7(n,f) = (  n - f )
f8(n,f) = (  n - f )
f9(n,f) = (  n - f )

#set output "ceph-NET.png"
#set title "Issue Backlog";
#plot	'buglist'	using f1($2,$11):xticlabels(1)

