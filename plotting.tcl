 #**** PROGRAM 1 -- SIMPLE -- individual lines
 # DECLARE THE SIZE OF THE CANVAS
 set width 100
 set height 100
 canvas .c -width $width -height $height -background white
 pack .c
  
 # READ THE DATA FILE
 set accessTime [file mtime data.txt]
 set infile [open data.txt]
 set indata [read $infile]
 close $infile
  
 set count 0
 #while {[gets $infile point]>=0}
 #{
 #while 1 {
     #if
     foreach point $indata {
     #   $point = $indata($index)
        if {$count == 0} {
           set oldx [lindex [split $point ,] 0]
           set oldy [expr $height-[lindex [split $point ,] 1]]
        }
        if {$count > 0} {
           set newx [lindex [split $point ,] 0]
           set newy [expr $height-[lindex [split $point ,] 1]]
           .c create line $oldx $oldy $newx $newy
           set oldx $newx
           set oldy $newy
        }
        incr count
     }

 while 1 {
     set nAccessTime [file mtime data.txt]
     if {$accessTime != $nAccessTime} {
         puts "found new"
     }
 }
