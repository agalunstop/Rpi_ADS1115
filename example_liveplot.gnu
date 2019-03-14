set xrange [0:20000]
set yrange [0:15000]
set autoscale x
set autoscale y
plot "datafile.txt" using 1:2 with lines
pause 1
reread
