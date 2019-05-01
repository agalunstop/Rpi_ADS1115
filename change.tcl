#!/usr/bin/wish
#PROGRAM 2 : Print something when a file is changed
#
 package require Tcl 8.6;    # <<<< GOOD STYLE
 package require Tk;         # <<<< GOOD STYLE

#graph prep
 set width 1000
 set height 500
 set scaling 100
 canvas .c -width $width -height $height -background white -xscrollincrement 1
 bind .c <Configure> {
    bind .c <Configure> {}
    .c xview scroll 0 unit
    set t 0
}
pack .c

#Initial reading
 set filename "datafile.txt"
 #puts $filename
 if [file exists $filename] {
	 #puts "file exits!"
 	set accessTime [file mtime $filename]
 	#puts $accessTime
 }
 #opening file
 set a [open $filename]
 set lines [split [read -nonewline $a] "\n"]
 close $a;                          # Saves a few bytes :-)
 #puts [llength $lines]
 
 #printing file
 set oldx 0
 #getting value of each sensor reading
 set val0 [lindex [split [lindex $lines 0] ","] 0]
 set val1 [lindex [split [lindex $lines 0] ","] 1]
 set val2 [lindex [split [lindex $lines 0] ","] 2]
 set val3 [lindex [split [lindex $lines 0] ","] 3]
 set oldy0 [expr 499-[expr $val0/$scaling]]
 set oldy1 [expr 499-[expr $val1/$scaling]]
 set oldy2 [expr 499-[expr $val2/$scaling]]
 set oldy3 [expr 499-[expr $val3/$scaling]]

 for {set i 1} {$i < [llength $lines]} {incr i} {
	 #puts "$i : [lindex $lines $i]"
	 set newx $i
	 #getting value of each sensor reading
	 set val0 [lindex [split [lindex $lines $i] ","] 0]
	 set val1 [lindex [split [lindex $lines $i] ","] 1]
	 set val2 [lindex [split [lindex $lines $i] ","] 2]
	 set val3 [lindex [split [lindex $lines $i] ","] 3]

	 set newy0 [expr 499-[expr $val0/$scaling]]
	 set newy1 [expr 499-[expr $val1/$scaling]]
	 set newy2 [expr 499-[expr $val2/$scaling]]
	 set newy3 [expr 499-[expr $val3/$scaling]]
	 .c create line $oldx $oldy0 $newx $newy0 -fill blue
	 #.c create line $oldx $oldy1 $newx $newy1 -fill black
	 .c create line $oldx $oldy2 $newx $newy2 -fill green
	 .c create line $oldx $oldy3 $newx $newy3 -fill red
	 if {$i > $width} { .c xview scroll 1 unit }
	 set oldx $newx
	 set oldy0 $newy0
	 set oldy1 $newy1
	 set oldy2 $newy2
	 set oldy3 $newy3
 }

## after 10000
## #looping to detect change
coroutine mainloop apply {{} {         
    global i width filename accessTime oldx oldy0 oldy1 oldy2 oldy3 scaling
    while 1 {
        after 1000 [info coroutine];   
        yield;                         
     	if [file exists $filename] {
     	   after 1000		
     	        #	check if new access time
     		set nAccessTime [file mtime $filename]
     		if {$accessTime != $nAccessTime} {
     	   		#puts $nAccessTime
     	    		#puts "found new"
     	   		#update access time
     	    		set accessTime $nAccessTime
     	    		#read new lines	
     	   		set a [open $filename]
     	   		set lines [split [read -nonewline $a] "\n"]
     	   		close $a;                          # Saves a few bytes :-)
     	   		#puts [llength $lines]

     	   		for {} {$i < [llength $lines]} {incr i} {
     	    			puts "$i : [lindex $lines $i]"
     	    			set newx $i
	 			#getting value of each sensor reading
	 			set val0 [lindex [split [lindex $lines $i] ","] 0]
	 			set val1 [lindex [split [lindex $lines $i] ","] 1]
	 			set val2 [lindex [split [lindex $lines $i] ","] 2]
	 			set val3 [lindex [split [lindex $lines $i] ","] 3]

	 			set newy0 [expr 499-[expr $val0/$scaling]]
	 			set newy1 [expr 499-[expr $val1/$scaling]]
	 			set newy2 [expr 499-[expr $val2/$scaling]]
	 			set newy3 [expr 499-[expr $val3/$scaling]]
	 			.c create line $oldx $oldy0 $newx $newy0 -fill blue
	 			#.c create line $oldx $oldy1 $newx $newy1 -fill black
	 			.c create line $oldx $oldy2 $newx $newy2 -fill green
	 			.c create line $oldx $oldy3 $newx $newy3 -fill red
	 			if {$i > $width} { .c xview scroll 1 unit }
     	    			set oldx $newx
     	    			set oldy0 $newy0
     	    			set oldy1 $newy1
     	    			set oldy2 $newy2
     	    			set oldy3 $newy3
     	   		}
     		}
     	}
    }
}}
