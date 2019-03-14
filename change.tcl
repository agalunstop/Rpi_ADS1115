#PROGRAM 2 : Print something when a file is changed
#

 set filename "data.txt"
 puts $filename
 if [file exists $filename] {
	 puts "file exits!"
 	set accessTime [file mtime $filename]
 	puts $accessTime
 }
 while 1 {
     if [file exists $filename] {
     	set nAccessTime [file mtime $filename]
     	if {$accessTime != $nAccessTime} {
		puts $nAccessTime
         	puts "found new"
         	set accesstime $nAccessTime
     	}
     }
 }
