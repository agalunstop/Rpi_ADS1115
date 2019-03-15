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
 set oldy [expr 499-[expr [lindex $lines 0]/$scaling]]
 for {set i 1} {$i < [llength $lines]} {incr i} {
	 #puts "$i : [lindex $lines $i]"
	 set newx $i
	 set newy [expr 499-[expr [lindex $lines $i]/$scaling]]
	 .c create line $oldx $oldy $newx $newy -fill blue
	 if {$i > $width} { .c xview scroll 1 unit }
	 set oldx $newx
	 set oldy $newy
 }

## after 10000
## #looping to detect change
coroutine mainloop apply {{} {         
    global i width filename accessTime oldx oldy scaling
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
     	    			set newy [expr 499-[expr [lindex $lines $i]/$scaling]]
     	    			.c create line $oldx $oldy $newx $newy -fill blue
	 			if {$i > $width} { .c xview scroll 1 unit }
     	    			set oldx $newx
     	    			set oldy $newy
     	   		}
     		}
     	}
    }
}}
