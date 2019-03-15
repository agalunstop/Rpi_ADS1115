#!/usr/bin/wish
#PROGRAM 2 : Print something when a file is changed
#
#package require Tk

#graph prep
 set width 100
 set height 100
 canvas .c -width $width -height $height -background white
 pack .c
  
#bind .c <Configure> {
#    bind .c <Configure> {}
#    .c xview scroll 0 unit
#    set t 0
#}
#set t 0
#.c create line $t 239 [expr $t + 5] 239 -fill gray
.c create line 0 12 1 13

#Initial reading
 set filename "data.txt"
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
 set oldy [lindex $lines 0]
 for {set i 1} {$i < [llength $lines]} {incr i} {
	 #puts "$i : [lindex $lines $i]"
	 set newx $i
	 set newy [lindex $lines $i]
	 .c create line $oldx $oldy $newx $newy
	 set oldx $newx
	 set oldy $newy
 }

## after 10000
## #looping to detect change
 while 1 {
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
	 		#puts "$i : [lindex $lines $i]"
	 		set newx $i
	 		set newy [lindex $lines $i]
	 		.c create line $oldx $oldy $newx $newy
	 		set oldx $newx
	 		set oldy $newy
 		}
     	}
     }
 }
