#!/usr/bin/perl
#
# script: bugage.pl
#	
# purpose:
#	to read through a raw bug list and generate
#	aging statistics
#
# output:
#	one row per age accumulation bucket, 
#		with a (time to fix) count for each bug classification 
#		and  an (age) count for each bug classification
#
use warnings;
use strict;
use Carp;

use Getopt::Std;
use File::Basename;
use Time::Local;

use Bugparse;

sub usage()
{	
	print STDERR "Usage: bugmunch.pl [switches] [file ...]\n";
	print STDERR "        -b # ...... bucket multiplier\n";
	print STDERR "        -m # ...... max bucket\n";
	print STDERR "        -s date ... report start date\n";
	print STDERR "        -e date ... report end date\n";
}

# parameters
my $bucket_factor = 2;	# bucket multiplier
my $bucket_max = 1000;	# maximum bucket
my $start_date;		# report starting date
my $end_date;		# report end date

#
# FIX: this shouldn't be hard coded, but I should find a way to
#	put them in/get them from the RedMine dump.  The trick is
#	that these are a function of tracker-type and priority.
#
my @columns =	('Immediate', 'Urgent', 'High', 'Normal', 'Low',
		 'Feature', 'Support', 'Cleanup', 'Tasks', 'Documentation' );

#
# FIX: this shouldn't be hard coded, but should probably be read from
#	a product specific table that maps issue types and priorities
#	into reporting buckets.
#
sub get_bug_class
{	(my $bugtype, my $priority) = ($_[0], $_[1]);
	return ($bugtype eq 'Bug') ? "$priority" : "$bugtype";
}


# accumulated information
my %fix_times = ();	# time to fix counters
my %open_ages = ();	# age counters
my @buckets;		# list of bucket sizes

# figure out the index of the bucket for a particular number
sub get_bucket
{	(my $count) = ($_[0]);

	for( my $i = 0; $i < scalar @buckets; $i++ ) {
		if ($count <= $buckets[$i]) {
			return( $i );
		}
	}

	return scalar @buckets;
}

# return the number of days in a time interval
sub days
{	(my $t) = ($_[0]);

	return ($t / (24 * 60 * 60));
}

#
# routine:	parse_date
#
# parameters:	date (mm/dd/yyyy)
#
# returns:	time value for that date
#
sub parse_date
{
	# discect the specified time
	(my $mon, my $day, my $year) = split( '/', $_[0] );
	return timegm( 0, 0, 0, $day, $mon-1, $year );
}

#
# routine:	process_newbug
#
# purpose:	
# 	accumulate another bug report
#
sub process_bug
{	
	(my $created, my $bugtype, my $priority, my $fixed) = ($_[0], $_[1], $_[2], $_[3]);

	# figure out its class
	my $class_name = get_bug_class( $bugtype, $priority );

	# figure out its age
	my $c = parse_date( $created );
	my $f = ($fixed eq "none") ? time() : parse_date( $fixed );
	my $bucket = get_bucket( days( $f - $c ) );
	my $hash = "$class_name-$bucket";

	# update the appropriate count
	if ($fixed ne "none") {
		if (defined $fix_times{$hash}) {
			$fix_times{$hash}++;
		} else {
			$fix_times{$hash} = 1;
		}
	} else {
		if (defined $open_ages{$hash}) {
			$open_ages{$hash}++;
		} else {
			$open_ages{$hash} = 1;
		}
	}
}

#
# routine:	flush_buckets
#
# purpose:	generate the output (bucket names and per-column counts)
#
sub flush_buckets
{
	# print out the column headers
	printf( "# bucket " );
	for ( my $i = 0; $i < scalar @columns; $i++ ) {
		printf( "fix-%s ", $columns[$i] );
	}
	for ( my $i = 0; $i < scalar @columns; $i++ ) {
		printf( "age-%s ", $columns[$i] );
	}
	printf("\n");

	# for each bucket
	my $prev = 0;
	for ( my $i = 0; $i <= scalar @buckets; $i++ ) {
		if ($i < scalar @buckets) {
			printf("%d-%d\t", $prev,$buckets[$i]);
		} else {
			printf(">%d\t", $prev);
		}

		# print all of the fix times
		for ( my $j = 0; $j < scalar @columns; $j++ ) {
			my $hash = "$columns[$j]-$i";
			printf("%d\t", defined($fix_times{$hash}) ? $fix_times{$hash} : 0);
		}

		# print all of the ages
		for ( my $j = 0; $j < scalar @columns; $j++ ) {
			my $hash = "$columns[$j]-$i";
			printf("%d\t", defined($open_ages{$hash}) ? $open_ages{$hash} : 0);
		}
		$prev = $buckets[$i];
		printf("\n");
	}
}

#
# routine:	process_file
#
# purpose:	
# 	to read the lines of an input file and pass the non-comments
# 	to the appropriate accumulation routines.
#
sub process_file
{	(my $file) = ($_[0]);

	# first line should be a headers comment
	my $first = <$file>;
	my %columns = Bugparse::parser($first);

	# make sure we got all the columns we needed
	foreach my $c ('created','priority','type','closed') {
		if (!defined( $columns{$c})) {
			die("Unable to find column: $c\n");
		}
	} 
	my $crt = $columns{'created'};
	my $prt = $columns{'priority'};
	my $typ = $columns{'type'};
	my $cls = $columns{'closed'};

	# use those columns to find what we want in the following lines
	while( <$file> ) {
		if (!/^#/) {	# ignore comments
			# carve it into tab separated fields
			my @fields = split( '\t', $_ );
			
			# remove any leading or trailing blanks
			for ( my $i = 0; $i < scalar @fields; $i++ ) {
				$fields[$i] =~ s/^\s+//;
				$fields[$i] =~ s/\s+$//;
			}

			# and process the fields we care about
			process_bug( $fields[$crt], $fields[$typ], $fields[$prt], $fields[$cls]);
		}
	}
}


#
# routine:	main
#
# purpose:
#	process arguments
#	figure out what operations we are supposed to do
#	perform them
#
# notes:
#	we require a command just to make sure the caller
#	knows what he is doing
#
sub main
{	
	# parse the input parameters
	my %options = ();
	if (!getopts('wmafs:e:', \%options)) {
		usage();
		exit(1);
	}

	# see what our bucket parameters are
	if (defined( $options{'b'} )) {
		$bucket_factor = $options{'b'};
	}
	if (defined( $options{'m'} )) {
		$bucket_max = $options{'m'};
	}

	# initialize the bucket size array
	my $i = 0;
	for( my $sz = 1; $sz <= $bucket_max; $sz *= $bucket_factor ) {
		$buckets[$i++] = $sz;
	}

	# see what our reporting period is
	$start_date = defined( $options{'s'} ) ? parse_date($options{'s'}) : 0;
	$end_date   = defined( $options{'e'} ) ? parse_date($options{'e'}) : time();

	# then process the input file(s)
	my $args = scalar @ARGV;
	if ( $args < 1 ) {
		process_file( 'STDIN' );
	} else {
		for( my $i = 0; $i < $args; $i++ ) {
			open(my $file, "<$ARGV[$i]") || 
				die "Unable to open input file $ARGV[$i]";
			process_file( $file );
			close( $file );
		}
	}

	# and flush out the accumulated counts
	flush_buckets();

	exit(0);
}

main();
