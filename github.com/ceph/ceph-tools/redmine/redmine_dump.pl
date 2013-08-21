#!/usr/bin/perl
#
my $usage = "usage: redmine_dump dbasename owner\n";

#
# Go to the MySQL database behind a Redmine bug system, and dump
# out a record for each bug, containing information that can be
# used to generate historical statistics reports not directly 
# supported by Redmine.
#
# Perhaps if I were a better person I would have implemented the
# reports I wanted as Redmine plug-ins, but I was finding Redmine
# difficult to dance with, and once we have this information out
# we can do anything we want with it.
#	 
# Note:
#	Clearly this script knows a lot about the schemas and table
#	relationships within a Redmine database ... and some of this
#	knowledge may turn out to be specific to the cephtracker 
#	database I started with.

use warnings;
use strict;
use Carp;

use Time::Local;
use Ndn::Dreamhost::Mysql;
use Ndn::People::Person;

# Output format (note: reduction scripts use the first comment line to understand the columns)
my $output="# bugid\tcategory\tissue type\tsource  \tprty\tpoints\tversion\tcreated \tclosed   \thistory\tproject \ttags    \tstatus\n";
my $dashes="# -----\t--------\t----------\t------  \t----\t------\t-------\t------- \t------   \t-------\t------- \t----    \t------\n";

#
# translate a mysql time/date into a mm/dd/yyyy
#
sub sqldate {
	my @date = split(' ', $_[0]);
	(my $year, my $month, my $day) = split('-',$date[0]);
	return "$month/$day/$year";
}

#
# translate a mysql time/date into a per time
#
sub sql_to_time {
	my @date = split(' ', $_[0]);
	(my $year, my $month, my $day) = split('-',$date[0]);
	return timegm( 0, 0, 0, $day, $month-1, $year );
}


# figure out what dabase we are using and who owns it
if (scalar @ARGV != 2) {
	print STDERR $usage;
	exit( 1 );
}
my $dbase = $ARGV[0];
my $webid = $ARGV[1];

# go get the system ID for the owner of the tracker
my $Person = Ndn::People::Person->LoadOrDie($webid);
my ($Account) = $Person->Accounts();
my ($DH) = $Account->Dreamhosts();

# open a Mysql session to that database
my $db = Ndn::Dreamhost::Mysql->LoadOrDie({db_name => $dbase, dh_id => $DH->sys_id});
my $Service = $db->Service;
my $dbh = $Service->_connect_admin;
$dbh->do("use $dbase");

# Drop-down menu values in a Redmine bug come from other tables,
# and are represented in the issue as indexes into those other
# tables.  Rather than do massive joins, I chose to simply read
# in those maps and interpret the values here ... giving me the
# opportunity to do some slightly more clever processing of the
# reports.

# buid up the issue categories map
my %categories = ('NULL'=>'none');
my $sth=$dbh->prepare("select id,name from issue_categories;");
$sth->execute();
while ( my @ref = $sth->fetchrow_array() ) {
	$categories{$ref[0]} = $ref[1];
}

# buid up the versions map
my %versions = ('NULL'=>'none');
my %sprints  = ('NULL'=>'none');
$sth=$dbh->prepare("select id,name,sprint_start_date from versions;");
$sth->execute();
while ( my @ref = $sth->fetchrow_array() ) {
	$versions{$ref[0]} = $ref[1];
	$sprints{$ref[0]} = $ref[2];
}

# buid up the priorities map
my %priorities = ('NULL'=>'none');
$sth=$dbh->prepare("select id,name from enumerations;");
$sth->execute();
while ( my @ref = $sth->fetchrow_array() ) {
	$priorities{$ref[0]} = $ref[1];
}

# build up the issue status map
my %statuses = ('NULL'=>'none');
my %is_closed = ('NULL'=>0);
$sth=$dbh->prepare("select id,name,is_closed from issue_statuses;");
while ( my @ref = $sth->fetchrow_array() ) {
	$statuses{$ref[0]} = $ref[1];
	$is_closed{$ref[0]} = $ref[2];
}

my %closures = ('NULL'=>'none');
#
# build up the bug-fixed-on map
#
#	This information is not in the issues table, so we must
#	consult the journal_details and journals tables to find
#	the last/latest status change from open to closed.
#
my $fields = 'journalized_id,old_value,value,created_on';
my $tables = 'journals,journal_details';
my $join   = 'journal_details.journal_id=journals.id and prop_key="status_id"';
my $order  = 'journal_details.id';
$sth=$dbh->prepare("select $fields from $tables where $join order by $order;");
$sth->execute();
while ( my @ref = $sth->fetchrow_array() ) 
{	if (!$is_closed{ $ref[1] } && $is_closed{ $ref[2] }) {
		$closures{$ref[0]} = sqldate($ref[3]);
	}
}

my %sources = ('NULL'=>'none');
#
# build up the list of sources map
#
#	This is not only not in the issues table, but is a
#	custom field (not likely to be present in most databases).  
# 	both of these reasons it is much easier to deal with them 
#	in a separate lookup than to include them in the main query.
#
#	If the field is not in the database or bugs do not have
#	values for the custom field, this query will simply come
#	back empty, and there will be no source map entry for those bugs.
#
$fields = 'customized_id,value';
$tables = 'custom_values,custom_fields';
$join   = 'custom_field_id=custom_fields.id and name="Source"';
$sth=$dbh->prepare("select $fields from $tables where $join;");
$sth->execute();
while ( my @ref = $sth->fetchrow_array() ) 
{	$sources{$ref[0]} = $ref[1];
}

my %tags = ('NULL'=>'none');
#
# build up the list of tags map
#
#	This is not only not in the issues table, but is a
#	custom field (not likely to be present in most databases).  
# 	both of these reasons it is much easier to deal with them 
#	in a separate lookup than to include them in the main query.
#
#	If the field is not in the database or bugs do not have
#	values for the custom field, this query will simply come
#	back empty, and there will be no source map entry for those bugs.
#
$fields = 'customized_id,value';
$tables = 'custom_values,custom_fields';
$join   = 'custom_field_id=custom_fields.id and name="Tags"';
$sth=$dbh->prepare("select $fields from $tables where $join;");
$sth->execute();
while ( my @ref = $sth->fetchrow_array() ) 
{	$tags{$ref[0]} = $ref[1];
}



my $date_fudge = 2;	# free-removal days, from start of sprint
my %history = ('NULL'=>'none');
#
# build up the version history
#
# TRICKS:
#	target version can be set by edits and at initial issue 
#	creation, so on the first edit I need to see if the previous
#	value is non-null, and if so, include that in the history 
#	as well.
#
#	If issue is moved out of a sprint prior to the start of the
#	sprint (or within the first few days), that is not a failure
#	to deliver but a change of plan, and so we don't count that
#	sprint as having been in the issue's history.
#
$fields	= 'journalized_id,value,old_value,created_on';
$tables	= 'journal_details,journals';
$join	= 'property="attr" and prop_key="fixed_version_id" and value!="NULL" and journal_id=journals.id';
$sth=$dbh->prepare("select $fields from $tables where $join;");
$sth->execute();
while ( my @ref = $sth->fetchrow_array() ) 
{	
	my $bugid = $ref[0];

	# there are a few tricks involving previous versions
	my $prev = ( defined( $ref[2] ) and defined( $versions{$ref[2]} )) ? $versions{$ref[2]} : "none";
	if ( $prev ne "none" ) {
		if (!defined( $history{$bugid} )) {
			# first version changed from was specified at create
			$history{$bugid} = $prev;
		} elsif (defined( $sprints{$ref[2]} )) {
			# we may have moved it out before the start of the sprint
			my $sprint_start = sql_to_time($sprints{$ref[2]});
			my $date_removed = sql_to_time($ref[3]);
			if (($date_removed - $sprint_start) / (24 * 60 * 60) < $date_fudge) {
				if ($history{$bugid} eq $prev) { # remove the entire history
					undef( $history{$bugid} );
				} else { # remove the last item from the history
					my $x = index( $history{$bugid}, ",$prev" );
					if ($x > 0) {
						my $upd = substr( $history{$bugid}, 0, $x );
						$history{$bugid} = $upd;
					} else {
						print STDERR "ERROR: unable to remove $prev from end of $history{$bugid} ($bugid)\n";
					}
				}
			} 
		}
	}

	# add the new version (if known) to thie history
	if (defined( $versions{$ref[1]} )) {
		if (defined( $history{$bugid} )) {
			$history{$bugid} = $history{$bugid} . ",$versions{$ref[1]}";
		} else {
			$history{$bugid} = $versions{$ref[1]};
		}
#	} else { # irritating, but it seems to happen
#		print STDERR "WARNING: unknown version, id=$ref[1]\n"
	}
}

# print out the headings
print $output;
print $dashes;

# dump out the interesting information from each issue
$fields = 'issues.id,issues.created_on,priority_id,fixed_version_id,category_id,status_id,trackers.name,story_points,projects.name';
$tables = 'issues,trackers,projects';
$join   = 'tracker_id=trackers.id and project_id=projects.id';
$order  = 'issues.id';
$sth=$dbh->prepare("select $fields from $tables where $join order by $order;");
$sth->execute();
while ( my @ref = $sth->fetchrow_array() )
{	# we assume that all bugs have a bugid and created field
	my $bugid	= $ref[0];
	my $created	= sqldate($ref[1]);

	# many of the other fields, may be empty
	my $priority	= defined($ref[2]) ? $priorities{$ref[2]} : 'none';
	my $vers	= defined($ref[3]) ? $versions{$ref[3]} : 'none';
	my $category	= defined($ref[4]) ? $categories{$ref[4]} : 'none';
	   $category	= sprintf("%-14s", $category);	# these get long
	my $status	= defined($ref[5]) ? $statuses{$ref[5]} : 'none';
	my $tracker	= sprintf("%-14s", $ref[6]);	# these get long
	my $points	= defined($ref[7]) ? sprintf("%6d", $ref[7]) : '     0';
	my $project	= sprintf("%-8s", $ref[8]);

	# custom fields have to be looked up in maps
	my $source	= 'none    ';
	if (defined( $sources{$bugid} )) {
		$source = $sources{$bugid};
		delete $sources{$bugid};
	}
	my $tag		= 'none    ';
	if (defined( $tags{$bugid} )) {
		$tag = $tags{$bugid};
		delete $tags{$bugid};
	}

	# we have to consult the status map to see if a bug is closed,
	# and then we have to look a a separate map to figure out when
	my $closed	= 'none    ';
	if ($is_closed{$ref[5]}) {
		# do we know when it was closed
		if (defined( $closures{$bugid} )) {
			$closed = $closures{$bugid};
			delete $closures{$bugid};
		} else { # this bug was apparently created resolved!
			$closed = $created;
		}
	}

	# get the history of target versions
	my $hist	= $vers;	# default history is current version
	if (defined( $history{$bugid} )) {
		$hist = $history{$bugid};
		if (index($hist,$vers) < 0) {	# this CAN happen :-(
			$hist = $hist . ",$vers";
		}
	}

	# output the report we have
	print "$bugid\t$category\t$tracker\t$source\t$priority\t$points\t$vers\t$created\t$closed\t$hist\t$project\t$tag\t$status\n";
}
