package Script;
use Moose;
with 'MooseX::Getopt';

has 'man' => (is => 'ro', isa => 'Bool');
has 'help' => (is => 'ro', isa => 'Bool');
has 'league' => (traits => ['Getopt'], is => 'ro', isa => 'Str',
		cmd_aliases => 'l',);
has 'weights' => (traits => ['Getopt'], is => 'ro', isa => 'Str',
		cmd_aliases => 'w',);
has 'player' => (traits => ['Getopt'], is => 'ro', isa => 'Str',
		cmd_aliases => 'p',);

package League;
use Moose;
use YAML qw/LoadFile DumpFile/;
use List::MoreUtils qw/any/;

has 'leagueId' => (is => 'ro', isa => 'Str', required => 1);
has 'yaml' => (is => 'ro', isa => 'HashRef', lazy_build => 1);
sub _build_yaml {
		my ($instance) = @_;
		my $league = $instance->leagueId;
		LoadFile "$league/league.yaml";
}
has 'name' => (is => 'ro', isa => 'Str', lazy_build => 1);
sub _build_name {
	my $self = shift;
	my $data = $self->yaml;
	$data->{league};
}
has 'members' => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);
sub _build_members {
	my $self = shift;
	my $data = $self->yaml;
	my @members = sort { $a->{id} cmp $b->{id} } @{$data->{member}};
	[ map { Player->new(league => $self, id=>$_->{id},name=>$_->{name})
			} @members ];
}
has 'absentees' => (is => 'ro', isa => 'ArrayRef', lazy => 1, default =>
				sub { shift->yaml->{absent} } );

sub is_member {
	my $self = shift;
	my $id = shift;
	my $data = $self->yaml;
	any { $_->{id} eq $id } @{$data->{member}};
}

sub input {
	my $self = shift;
	LoadFile shift();
}

sub save {
	my $self = shift;
	DumpFile shift(), shift();
}

sub sprintround {
	my $self = shift;
	my @returns;
	for my $arg ( @_ ) {
		unless ( ref $arg ) {
			push @returns, sprintf '%.0f', $arg;
		}
		if ( ref( $arg ) eq 'ARRAY' ) {
			push @returns, [ map { sprintf '%.0f', $_ } @$arg ];
		}
		if ( ref( $arg ) eq 'HASH' ) {
			push @returns, +{ map { $_=>sprintf '%.0f',
					$arg->{$_} } keys %$arg};
		}
	}
	return wantarray? @returns: $returns[0] if @returns == 1;
	return wantarray? @returns: \@returns if @returns >= 1;
}

package Homework;
use Moose;
use YAML qw/LoadFile DumpFile/;
use List::Util qw/sum/;

has 'league' => (is =>'ro', isa => 'League', handles => [ 'yaml', 'leagueId' ]);
has 'hwdir' => (is => 'ro', isa => 'Str', lazy_build => 1);
sub _build_hwdir {
	my $self = shift;
	my $league = $self->leagueId;
	my $data = $self->yaml;
	my $hwdir = $data->{hw} || "$league/homework"
}
has 'rounds' => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);
sub _build_rounds {
	my $self = shift;
	my $hwdir = $self->hwdir;
	my @hw = glob "$hwdir/*.yaml";
	[ sort {$a<=>$b} map m/^$hwdir\/(\d+)\.yaml$/, @hw ];
}
has 'hwbyround' => (is => 'ro', isa => 'HashRef', lazy_build => 1);
sub _build_hwbyround {
	my $self = shift;
	my $hwdir = $self->hwdir;
	my $rounds = $self->rounds;
	+{ map { $_ => LoadFile "$hwdir/$_.yaml" } @$rounds };
}
has 'roundMax' => (is => 'ro', isa => 'Int', lazy => 1, default =>
				sub { shift->yaml->{hwMax} } );
has 'totalMax' => (is => 'ro', isa => 'Int', lazy_build => 1);
sub _build_totalMax {
	my $self = shift;
	my $rounds = $self->rounds;
	my $hwMax = $self->roundMax;
	$hwMax * @$rounds;
}

sub hwforid {
	my $self = shift;
	my $hw = $self->hwbyround;
	my $rounds = $self->rounds;
	my $id = shift;
	my @hwbyid;
	for my $round ( @$rounds ) {
		if ( $hw->{$round} and defined $hw->{$round}->{$id} ) {
			push @hwbyid, $hw->{$round}->{$id};
		}
		else { warn "No homework result for $id in Round $round\n"; }
	}
	\@hwbyid;
}

sub total {
	my $self = shift;
	my $id = shift;
	my $hw = $self->hwforid($id);
	sum @$hw;
}

sub percent {
	my $self = shift;
	my $id = shift;
	my $hw = $self->total($id);
	my $totalMax = $self->totalMax;
	$hw * ( 100/ $totalMax );
}

package Classwork;
use Moose;
use YAML qw/LoadFile/;
use List::Util qw/max sum/;
use List::MoreUtils qw/any/;
use Carp qw/croak/;
use POSIX;

has 'league' => (is =>'ro', isa => 'League', handles => [ 'yaml', 'leagueId' ]);
has 'series' => (is => 'ro', isa => 'ArrayRef', lazy => 1, default =>
				sub { shift->yaml->{series} } );
has 'groupseries' => (is => 'ro', isa => 'HashRef', lazy_build => 1);
sub _build_groupseries {
	my $self = shift;
	my $series = $self->series;
	my $league = $self->leagueId;
	+{ map { $_ => LoadFile "$league/$_/groups.yaml" } @$series };
}
has 'allfiles'  => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1 );
sub _build_allfiles {
	my $self = shift;
	my $league = $self->leagueId;
	my $series = $self->series;
	my $files = [ map { grep m|/(\d+)\.yaml$|, glob "$league/$_/*" } @$series ];
	die "@$files" unless $files;

}
has 'allweeks' => ( is => 'ro', isa => 'ArrayRef', lazy_build => 1 );
sub _build_allweeks {
	my $self = shift;
	my $files = $self->allfiles;
	[ map { m|/(\d+)\.yaml$|; $1 } @$files ];
}
has 'lastweek' => ( is => 'ro', isa => 'Int', lazy_build => 1 );
sub _build_lastweek {
	my $self = shift;
	my $weeks = $self->allweeks;
	max @$weeks;
}
has 'data' => (is => 'ro', isa => 'HashRef', lazy_build => 1);
sub _build_data {
	my $self = shift;
	my $files = $self->allfiles;
	my $weeks = $self->allweeks;
	+{ map { $weeks->[$_] => LoadFile $files->[$_] } 0..$#$weeks };
}

sub groups {
	my $self = shift;
	my $session = shift;
	$self->groupseries->{$session};
}

sub files {
	my $self = shift;
	my $session = shift;
	my $allfiles = $self->allfiles;
	[ grep m|/$session/\d+\.yaml$|, @$allfiles ];
}

sub weeks {
	my $self = shift;
	my $session = shift;
	my $files = $self->files($session);
	[ map { m|(\d+)\.yaml$|; $1 } @$files ];
}

sub week2session {
	my $self = shift;
	my $week = shift;
	my $sessions = $self->series;
	my %sessions2weeks = map { $_ => $self->weeks($_) } @$sessions;
	while ( my ($session, $weeks) = each %sessions2weeks ) {
		return $session if any { $_ eq $week } @$weeks;
	}
	croak "Week $week in none of @$sessions sessions.\n";
}

sub names2groups {
	my $self = shift;
	my $session = shift;
	my $groups = $self->groups($session);
	my @names; push @names, @$_ for values %$groups;
	my %names2groups;
	while ( my ($group, $names) = each %$groups ) {
		for my $name ( @$names ) {
		die "$name in $group and other group in $session session.\n"
				if $names2groups{$name};
			$names2groups{$name} = $group;
		}
	}
	\%names2groups;
}

sub name2group {
	my $self = shift;
	my $week = shift;
	die "Week $week?" unless defined $week;
	my $session = $self->week2session($week);
	my $name = shift;
	my $groups = $self->groups($session);
	my @names; push @names, @$_ for values %$groups;
	my @name2groups;
	while ( my ($group, $names) = each %$groups ) {
		push @name2groups, $group for grep /^$name$/, @$names;
	}
	die "$name not in exactly one group in $session session.\n"
				unless @name2groups == 1;
	shift @name2groups;
}

=head2 groupsNotInCard

Test groups exist in data

=cut

sub groupsNotInCard {
	my $self = shift;
	my $groups = shift;
	my $card = shift;
	my $week = shift;
	my %common; $common{$_}++ for keys %$groups, keys %$card;
	my @notInCard = grep { $common{$_} != 2 } keys %$groups;
	croak "@notInCard groups not in week $week data" if @notInCard;
}

=head2 groupDataOnCard

Test group data exists on card

=cut

sub groupDataOnCard {
	my $self = shift;
	my $groups = shift;
	my $card = shift;
	my $week = shift;
	my @noData = grep
			{ my $group = $card->{$_};
			not defined $group->{merits}
			or not defined $group->{absences}
			or not defined $group->{tardies} }
			keys %$groups;
	croak "@noData groups missing data in week $week" if @noData;
}

sub merits {
	my $self = shift;
	my $data = $self->data;
	my $week = shift;
	my $session = $self->week2session($week);
	my $groups = $self->groups($session);
	my $card = $data->{$week};
	$self->groupsNotInCard($groups, $card, $week);
	$self->groupDataOnCard($groups, $card, $week);
	+{ map { $_ => $card->{$_}->{merits} } keys %$groups };
}

sub absences {
	my $self = shift;
	my $data = $self->data;
	my $week = shift;
	my $session = $self->week2session($week);
	my $groups = $self->groups($session);
	my $card = $data->{$week};
	$self->groupsNotInCard($groups, $card, $week);
	$self->groupDataOnCard($groups, $card, $week);
	+{ map { $_ => $card->{$_}->{absences} } keys %$groups };
}

sub tardies {
	my $self = shift;
	my $data = $self->data;
	my $week = shift;
	my $session = $self->week2session($week);
	my $groups = $self->groups($session);
	my $card = $data->{$week};
	$self->groupsNotInCard($groups, $card, $week);
	$self->groupDataOnCard($groups, $card, $week);
	+{ map { $_ => $card->{$_}->{tardies} } keys %$groups };
}

=head2 payout

How much should be given out for each week in this session, so that the total score of each player over the series averages 80?

=cut

sub payout {
	my $self = shift;
	my $session = shift;
	my $sessions = $self->series;
	my $groups = $self->groups($session);
	my $weeks = $self->weeks($session);
	my $payout = (80/@$sessions) * (keys %$groups) / @$weeks;
}

=head2 demerits

The demerits that week. calculated as twice the number of absences, plus the number of tardies. In a four-member group, this ranges from 0 to 8.

=cut

sub demerits {
	my $self = shift;
	my $week = shift;
	my $absences = $self->absences($week);
	my $tardies = $self->tardies($week);
	my $session = $self->week2session($week);
	my $groups = $self->groups($session);
	+{map {$_ => ($absences->{$_} * 2 + $tardies->{$_} * 1)} keys %$groups};
}

=head2 favor

A score of 2 given to groups with no more than 6 demerits, to prevent groups who were all there but didn't do anything (ie had no merits and no demerits) from getting a log score of 0, and so getting a grade of 0 for that week.

=cut

sub favor {
	my $self = shift;
	my $week = shift;
	my $demerits = $self->demerits($week);
	my $session = $self->week2session($week);
	my $groups = $self->groups($session);
	+{ map {$_ => ($demerits->{$_} < 7? 1: 0)} keys %$groups };
}

=head2 maxDemerit

The max demerit that week. achieved by the group with the most absences and tardies.

=cut

sub maxDemerit {
	my $self = shift;
	my $week = shift;
	my $demerits = $self->demerits($week);
	max( values %$demerits );
}

=head2 meritDemerit

Let groups with no merits, and no demerits get a score greater than 1, so the log score is greater than 0. Let groups with 3 or more absences and 1 tardies not be eligible for this favor, but get at least 0. Let other groups get the number of merits - number of demerits, but also be eligible for the favor, and get a score of above 1.

=cut

sub meritDemerit {
	my $self = shift;
	my $week = shift;
	my $merits = $self->merits($week);
	my $demerits = $self->demerits($week);
	my $maxDemerit = $self->maxDemerit($week);
	my $favor = $self->favor($week);
	my $session = $self->week2session($week);
	my $groups = $self->groups($session);
	+{ map {$_=> $maxDemerit+$merits->{$_}+$favor->{$_}-$demerits->{$_}}
		keys %$groups };
}

=head2 logwork

The points given by the teacher are log-scaled to prevent active students from taking all the payout, and the other students getting very low grades. There may be better ways of grading to the curve than using log scaling. The log of one point is 0, which results in a grade of 0 for that week for that group.

=cut

sub logwork {
	my $self = shift;
	my $week = shift;
	my $work = $self->meritDemerit($week);
	my $session = $self->week2session($week);
	my $groups = $self->groups($session);
	+{ map { $_ => $work->{$_} == 0 ?  0 : 1 + log $work->{$_} }
		keys %$groups };
}

=head2 work2grades

The work (ie merits - demerits) of the groups for the week, as a percentage of the total work, determines the payout of grades, which should average 80 over the sessions of play.

=cut

sub work2grades {
	my $self = shift;
	my $week = shift;
	my $work = $self->logwork($week);
	my $session = $self->week2session($week);
	my $groups = $self->groups($session);
	my $totalwork = sum values %$work;
	my $payout = $self->payout($session);
	+{ map { $_ => $totalwork == 0? 0: ( $work->{$_}*$payout/ $totalwork )
						} keys %$groups };
}

package Grades;
use Moose;
use YAML qw/LoadFile/;
use List::Util qw/sum/;
use List::MoreUtils qw/all/;

has 'league' => (is =>'ro', isa => 'League', handles =>
	[ 'yaml', 'leagueId', 'input' ]);
has 'homework' => (is => 'ro', isa => 'HashRef', lazy_build => 1);
sub _build_homework {
	my $self = shift;
	my $leaguedir = $self->leagueId;
	my $data = $self->yaml;
	my $hwdir = $data->{hw} || "$leaguedir/homework";
	$self->input( "$hwdir/percent.yaml" );
}
has 'classwork' => (is => 'ro', isa => 'HashRef', lazy_build => 1);
sub _build_classwork {
	my $self = shift;
	my $leaguedir = $self->leagueId;
	LoadFile "$leaguedir/classwork.yaml";
}
has 'examdirs' => (is => 'ro', isa => 'ArrayRef', lazy_build => 1);
sub _build_examdirs {
	my $self = shift;
	my $leagueId = $self->leagueId;
	my $examdirs = $self->yaml->{exams};
	[ map { "$leagueId/$_" } @$examdirs ];
}
has 'examMax' => (is => 'ro', isa => 'Int', lazy => 1, required => 1,
				default => sub { shift->yaml->{examMax} } );
has 'examResults' => (is => 'ro', isa => 'HashRef', lazy_build => 1);
sub _build_examResults {
	my $self = shift;
	my $examdirs = $self->examdirs;
	my @exams = map { $self->input("$_/g.yaml") } @$examdirs;
	my %ids;
	for my $exam ( @exams ) { $ids{$_}++ for keys %$exam; }
	for my $id  ( keys %ids ) {
		warn "Only $ids{$id} exam results for $id\n" unless 
				$ids{$id} == @exams;
	}
	+{ map { my $id=$_; $id => [ map { $_->{$id} } @exams ] } keys %ids };
}
has 'examPercent' => (is => 'ro', isa => 'HashRef', lazy_build => 1);
sub _build_examPercent {
	my $self = shift;
	my $scores = $self->examResults;
	my $max = $self->examMax;
	+{ map { my $id=$_; $id => [ map { $_*(100/$max) } @{$scores->{$_}} ] }
		keys %$scores };
}
has 'examGrade' => (is => 'ro', isa => 'HashRef', lazy_build => 1);
sub _build_examGrade {
	my $self = shift;
	my $grades = $self->examPercent;
	+{ map { my $numbers=$grades->{$_}; $_ =>sum(@$numbers)/@{$numbers} }
						keys %$grades };
}
has 'weights' => (is => 'ro', isa => 'ArrayRef', lazy_build => 1 );
sub _build_weights {
	my $self = shift;
	my $weights = $self->yaml->{weights};
	my @weights = ref $weights eq 'ARRAY' ? split m/,|\s+/, $weights:
				( $weights->{classwork},
				$weights->{homework},
				$weights->{exams} );
	\@weights;
}

package Player;
use Moose;
use List::MoreUtils qw/firstval/;
use List::Util qw/sum/;
use POSIX;

has 'league' => (is => 'ro', isa => 'League', required => 1);
has 'id' => (is => 'ro', isa => 'Str', required => 1);
has 'name' => (is => 'ro', isa => 'Str', lazy_build => 1);
sub _build_name {
	my $self = shift;
	my $league = $self->league;
	my $id = $self->id;
	my $members = $league->members;
	my $member = firstval { $_->id eq $id } @$members;
	$member->name;
}
has 'Chinese' => (is => 'ro', isa => 'Str');
has 'total' => (is => 'ro', isa => 'Int', lazy_build => 1);
sub _build_total {
	my $self = shift;
	my $hwgrades = $self->hwgrades;
	sum @$hwgrades;
}
has 'percent' => (is => 'ro', isa => 'Int', lazy_build => 1);
sub _build_percent {
	my $self = shift;
	my $grade = $self->total;
	my $league = $self->league;
	my $totalMax = $league->totalMax;
	floor (100 * $grade / $totalMax);
}

1;

__END__

=head1 NAME

cumulative - Add player results in individual rounds to get a cumulative total and show present standing

=head1 SYNOPSIS

hwtotal [options] 

Options:

--help            This help message

--man            A man page

--league m/j	The league whose results these are

=head1 OPTIONS

=over 8

=item B<-league>

The league to which the redeemer belongs

=back

=head1 DESCRIPTION

B<hwtotal> tallies individuals' scores in the files in the hw directory recorded in league.yaml. It stores the total in cumulative.yaml, in the same directory.

=cut

