#Last Edit: 2017 Oct 23, 09:03:34 PM
#$Id$

use MooseX::Declare;

=head1 NAME

Grades::Individual - A way of working as an individual in a competition or school

=head1 SYNOPSIS

	use Grades;
	use Grades::Individual;

	my $grades = Grades->new( league => $league );
	my $classworkgrades = $grades->classwork;

=head1 DESCRIPTION

A superclass for the various ways a group (as opposed to pair) can work together and achieve a result.

Grades' Classwork role delegates its methods to one of a number of approaches. Some popular approaches, or forms of curriculum, are subclasses of Groupwork, like Groupwork::Responsible, Groupwork::NoFault. Other popular non-Groupwork approaches are Compcomp, and Jigsaw, and this one, Individual.

Keywords: gold stars, token economies, bean counter

=cut

=head1 ATTRIBUTES & METHODS

=cut

class Individual extends Approach {
	use List::Util qw/max min sum/;
	use List::MoreUtils qw/any/;
	use Carp;
	use POSIX;
	use Grades::Types qw/Beancans Card Results/;
	use Try::Tiny;

=head3 classMax

The maximum score possible in individual lessons for classwork.

=cut

	has 'classMax' => (is => 'ro', isa => 'Int', lazy => 1, required => 1,
			default => sub { shift->league->yaml->{classMax} } );

=head3 beancanseries

The different beancans for each of the sessions in the series. In the directory for each session of the series, there is a file called beancans.yaml, containing mappings of a beancan name to a sequence of PlayerNames, the members of the beancan. If beancans.yaml cannot be found, a file called groups.yaml is used instead.

=cut

    has 'beancanseries' => ( is => 'ro', lazy_build => 1 );
    method _build_beancanseries {
	my $dir = $self->beancandirs;
        my $series = $self->series;
        my $league = $self->league->id;
	my %beancans;
	for my $round ( @$series ) {
	    my $beancanfile = "$dir/$round/beancans.yaml";
	    my $file = -e $beancanfile? $beancanfile: "$dir/$round/groups.yaml";
	    try { $beancans{$round} = $self->inspect( $file ) }
		catch { local $" = ', ';
		    warn "Missing beancans in $league $dir round $round," };
	}
	return \%beancans;
    }

=head3 beancans

A hashref of all the beancans in a given session with the names keying the ids of the members of each beancan. The number, composition and names of the beancans may change from one session of the series to the next.
	
Players in one beancan all get the same Individual grade for that session. The beancan members may be the same as the members of the class group, who work together in class, or may be individuals. Usually in a big class, the beancans will be the same as the groups, and in a small class they will be individuals.

Players in the 'Absent' beancan all get a grade of 0 for the session.

Rather than refactor the class to work with individuals rather than groups, and expand some methods (?) to fall back to league members if it finds them in the weekly files instead of groups, I decided to introduce another file, beancans.yaml, and change all variable and method names mentioning group to beancan.

=cut 

	method beancans (Str $session) {
	    my $beancans = $self->beancanseries->{$session};
	    my $league = $self->league;
	    my %beancans = map { my $can = $_;
	        $can => { map { $_ => $league->ided( $_ ) }
	        		    @{$beancans->{$can}} } } keys %$beancans;
	    return \%beancans;
	}
=head3 beancan_names

A hashref of all the beancans in a given session with the names of the members of each beancan.
	
=cut 

	method beancan_names (Str $session) { $self->beancanseries->{$session}; }

=head3 allfiles

The files (unsorted) containing classwork points (beans) awarded to beancans, of form, groupworkdir/\d+\.yaml$

=cut


	has 'allfiles'  => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1 );
	method _build_allfiles {
		my $dir = $self->groupworkdirs;
		my $series = $self->series;
		my $league = $self->league->id;
		my $files = [ grep m|/(\d+)\.yaml$|, glob "$dir/*.yaml"];
		carp "${league}'s @$series groupwork files: @$files?" unless @$files;
		return $files;
	}

=head3 all_ided_files

The files containing classwork points (beans) awarded to beancans, of form, groupworkdir/\d+\.yaml$ keyed on the \d+.

=cut


	has 'all_ided_files'  => ( is => 'ro', isa => 'HashRef', lazy_build => 1 );
	method _build_all_ided_files {
		my $files = $self->allfiles;
		my %files = map { m|/(\d+)\.yaml$|; $1 => $_ } @$files;
		croak "No classwork files: $files?" unless %files;
		return \%files;
	}

=head3 all_events

The events (an array ref of integers) in which beans were awarded.

=cut

	has 'all_events' => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1 );
	method _build_all_events {
		my $files = $self->all_ided_files;
		my @events = sort { $a <=> $b } keys %$files;
		croak "No classwork weeks: @events" unless @events;
		return \@events;
	}

=head3 lastweek

The last week in which beans were awarded. TODO lexicographic order, not numerical order.

=cut

	has 'lastweek' => ( is => 'ro', isa => 'Int', lazy_build => 1 );
	method _build_lastweek {
		my $weeks = $self->all_events;
		max @$weeks;
	}

=head3 data

The beans awarded to the beancans in the individual cards over the weeks of the series (semester.)

=cut

	has 'data' => (is => 'ro', isa => 'HashRef', lazy_build => 1);
	method _build_data {
		my $files = $self->all_ided_files;
		+{ map { $_ => $self->inspect( $files->{$_} ) } keys %$files };
	}

=head3 card

Classwork beans for each beancan for the given week

=cut

	method card (Num $week) {
		my $card = $self->data->{$week};
		croak "Week $week card probably has undefined or non-numeric Merit, Absence, Tardy scores, or possibly illegal beancan."
		    unless is_Card( $card );
		return $card;
	}

=head3 active

Given a session, returns the active beancans, ie all but the 'Absent' beancan.

=cut

	method active (Str $session) {
		my $beancans = $self->beancan_names($session);
		my %active = %$beancans;
		delete $active{Absent};
		return \%active;
	}

=head3 files

Given a session, returns the files containing beans awarded during the session according to the league.yaml session key. The files are of form, \d+\.yaml$

=cut

    method files (Str $session) {
	my $sessions = $self->league->session;
	croak "No session $session defined in league.yaml.\n" unless defined $sessions->{$session};
	my $firstweek = $sessions->{$session};
	my $allfiles = $self->allfiles;
	my @files;
	if ( defined $sessions->{$session+1} ) {
	    my $nextfirstweek = $sessions->{$session+1};
	    my $lastweek = $nextfirstweek - 1;
	    if ( $lastweek >= $firstweek ) {
		my $range = ( $firstweek .. $lastweek );
		@files = grep { m/\/(\d+)*\.yaml/;
		    $1 >= $firstweek && $1 <= $lastweek } @$allfiles;
	    }
	    else {
croak "Following session starts in week $nextfirstweek, the same week as or earlier than the start of session $session, in week $firstweek\n"
	    }
	}
	else {
	    @files = grep { m/(\d+)*\.yaml/; $1 >= $firstweek } @$allfiles;
	}
	return \@files;
    }

=head3 weeks

Given a session, returns the weeks (an array ref of integers) in which beans were awarded in the session.

=cut

    method weeks (Str $session) {

	my $files = $self->files($session);
	[ map { m|(\d+)\.yaml$|; $1 } @$files ];
    }

=head3 week2session

	$Individual->week2session(15) # fourth

Given the name of a week, return the name of the session it is in.

=cut

	method week2session (Num $week) {
		my $sessions = $self->series;
		my %sessions2weeks = map { $_ => $self->weeks($_) } @$sessions;
		while ( my ($session, $weeks) = each %sessions2weeks ) {
			return $session if any { $_ eq $week } @$weeks;
		}
		my $session = $self->league->session;
		my @series = sort { $b <=> $a } keys %$session;
		while ( my $next = shift @series ) {
		    return $next if $week >= $session->{$next};
		}
		croak "Week $week in none of @$sessions sessions.\n";
	}

=head3 names2beancans

A hashref of names of members of beancans (players) and the beancans they were members of in a given session.

=cut

	method names2beancans (Str $session) {
		my $beancans = $self->beancan_names($session);
		my %beancansreversed;
		while ( my ($beancan, $names) = each %$beancans ) {
			for my $name ( @$names ) {
			croak
	"$name in $beancan beancan and other beancan in $session session.\n"
					if exists $beancansreversed{$name};
				$beancansreversed{$name} = $beancan;
			}
		}
		\%beancansreversed;
	}

=head3 name2beancan

	$Individual->name2beancan( $week, $playername )

Given the name of a player, the name of the beancan they were a member of in the given week.

=cut

	method name2beancan (Num $week, Str $name) {
		croak "Week $week?" unless defined $week;
		my $session = $self->week2session($week);
		my $beancans = $self->beancan_names($session);
		my @names; push @names, @$_ for values %$beancans;
		my @name2beancans;
		while ( my ($beancan, $names) = each %$beancans ) {
			push @name2beancans, $beancan for grep /^$name$/, @$names;
		}
		croak "$name not in exactly one beancan in $session session.\n"
					unless @name2beancans == 1;
		shift @name2beancans;
	}

=head3 name2letter

	$Individual->name2letter( $week, $playername )

Given the name of a player, their letter in the beancan they were a member of in the given week. Used in conjunction with name2beancan.

=cut

	method name2letter (Num $week, Str $myname) {
		croak "Week $week?" unless defined $week;
		my $session = $self->week2session($week);
		my $beancans = $self->beancan_names($session);
		my $mycan = $self->name2beancan($week, $myname);
		my $names = $beancans->{$mycan};
		my @abc = qw/ A B C /;
		my %letters = map { $names->[$_] => $abc[$_] } (0 .. $#$names);
		my $letter = $letters{$myname};
	}

=head3 beancansNotInCard

	$Individual->beancansNotInCard( $beancans, $card, 3)

Test all beancans, except Absent, exist in the beancans listed on the card for the week.

=cut

	method beancansNotInCard (HashRef $beancans, HashRef $card, Num $week) {
		my %common; $common{$_}++ for keys %$beancans, keys %$card;
		my @notInCard = grep { $common{$_} != 2 and $_ ne 'Absent' }
						keys %$beancans;
		croak "@notInCard beancans not in week $week data" if
					@notInCard;
	}

=head3 beancanDataOnCard

	$Individual->beancansNotInCard( $beancans, $card, 3)

Test all of the beancans, except Absent, have all the points due them for the week. Duplicates the check done by the Card type.

=cut

	method beancanDataOnCard (HashRef $beancans, HashRef $card, Num $week) {
		my @noData = grep { my $beancan = $card->{$_};
				$_ ne 'Absent' and ( 
					not defined $beancan->{merits}
					# or not defined $beancan->{absent}
					# or not defined $beancan->{tardies}
				    ) }
				keys %$beancans;
		croak "@noData beancans missing data in week $week" if @noData;
	}

=head3 merits

The points the beancans gained for the given week.

=cut

	method merits (Num $week) {
		my $session = $self->week2session($week);
		my $beancans = $self->active($session);
		my $card = $self->card($week);
		$self->beancansNotInCard($beancans, $card, $week);
		$self->beancanDataOnCard($beancans, $card, $week);
		+{ map { $_ => $card->{$_}->{merits} } keys %$beancans };
	}

=head3 absences

The numbers of players absent from the beancans in the given week.

=cut

	method absences (Num $week) {
		my $session = $self->week2session($week);
		my $beancans = $self->active($session);
		my $card = $self->card($week);
		$self->beancansNotInCard($beancans, $card, $week);
		$self->beancanDataOnCard($beancans, $card, $week);
		+{ map { $_ => $card->{$_}->{absences} } keys %$beancans };
	}

=head3 tardies

The numbers of players not on time in the beancans in the given week.

=cut

	method tardies (Num $week) {
		my $session = $self->week2session($week);
		my $beancans = $self->active($session);
		my $card = $self->card($week);
		$self->beancansNotInCard($beancans, $card, $week);
		$self->beancanDataOnCard($beancans, $card, $week);
		+{ map { $_ => $card->{$_}->{tardies} } keys %$beancans };
	}

=head3 total

Totals for individual ids, over the whole series.

=cut

    has 'total' => ( is => 'ro', isa => Results, lazy_build => 1 );
    method _build_total {
	my $members = $self->league->members;
	my $series = $self->series;
	my (%grades);
	my $dir = $self->groupworkdirs;
	my $total = $self->league->inspect( "$dir/total.yaml" );
	for my $member ( @$members ) {
	    my $id = $member->{id};
	    if ( exists $total->{$id} ) {
	        my $perfect_score = 100;

	        $grades{$id} = min( $perfect_score, $total->{$id} );
	        warn "$member->{name}: ${id}'s classwork score of $total->{$id} where perfect score == $perfect_score\n"
	            if $total->{$id} > $perfect_score;
	    }
	    else {
		my $name = $member->{name};
		carp "$name $id Individual?";
		$grades{$id} = 0;
	    }
	}
	\%grades;
    }

=head3 totalPercent

Running totals for individual ids out of 100, over the whole series.

=cut
	has 'totalPercent' => ( is => 'ro', isa => Results, lazy_build => 1 );
	method _build_totalPercent {
		my $members = $self->league->members;
		my $totalMax = 100;
		my $grades = $self->total;
		my $series = $self->series;
		my %percent;
		for my $member ( @$members ) {
		    my $id = $member->{id};
		    my $score = 100 * $grades->{$id} / $totalMax ;
		    warn "$member->{name}: ${id}'s classwork score of $score > $totalMax"
			if $score > 100;
		    my $rounded = sprintf '%.2f', $score;
		    $percent{$id} = $rounded;
		}
		return \%percent;
	}

}

1;    # End of Grades::Individual

=head1 AUTHOR

Dr Bean, C<< <drbean, followed by the at mark (@), cpan, then a dot, and finally, org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-grades at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Grades>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Grades

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Grades>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Grades>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Grades>

=item * Search CPAN

L<http://search.cpan.org/dist/Grades>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2010 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut


# vim: set ts=8 sts=4 sw=4 noet:
__END__
