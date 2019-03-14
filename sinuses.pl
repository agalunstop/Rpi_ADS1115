#!/usr/bin/perl -w
use strict;

use Time::HiRes qw/sleep/;
use File::Monitor;
use Array::Utils qw(:all);
 
my $filename = 'datafile.txt';
open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Could not open file '$filename' $!";

# First, set the standard output to auto-flush
select((select(STDOUT), $| = 1)[0]);

chomp(my @fplot = <$fh>);
my @old = @fplot;
#plot for first time
while(1){
	if(@fplot){
	foreach my $row (@fplot) {
	  #chomp $row;
	  #print "$row\n";
	    print "0:".$row."\n";
	    sleep(0.02);
	}
	close($fh);
}
	sleep(0.02);
	#monitor changes to file
	my $monitor = File::Monitor->new();
	$monitor->watch( $filename );
	my @changes = $monitor->scan;
	
	while (!@changes)	#wait for changes
	{
		@changes = $monitor->scan;
	}
	    sleep(0.1);
	
	open(my $fhnew, '<:encoding(UTF-8)', $filename)
	  or die "Could not open file '$filename' $!";
	chomp(my @new = <$fhnew>);
	@fplot = array_diff(@old, @new);
	@old = @new;
}

#    for my $change ( @changes ) {
#        warn $change->name, " changed\n";
#    }


###reading from file
##
### And loop 5000 times, printing values...
##my $offset = 0.0;
##while(1) {
###    print "0:".sin($offset)."\n";
####    print "1:".cos($offset)."\n";
###    $offset += 0.1;
###    if ($offset > 500) {
###        last;
###    }
###    sleep(0.02);
##}
##
##
