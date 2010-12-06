#!/usr/bin/perl 

# Created: 西元2010年02月23日 22時33分13秒
# Last Edit: 2010 12月 06, 09時39分03秒
# $Id$

=head1 NAME

rewrite_response.pl - Refactor response forms for newer access methods

=head1 SYNOPSIS 

comptron.pl -l BMA0077 -r 1 > BMA0077/comp/1/response.yaml

 Options:
   -r --round         the round
   -l --league        league's id
 

=cut

=head1 DESCRIPTION

With new ideas about Compcomp approach, eg free and set questions, it is necessary to rewrite old forms so they can be accessed by new methods. The code needs to be updated to do this.

=cut

use strict;
use warnings;
use IO::All;
use YAML qw/LoadFile Bless Dump/;
use Cwd; use File::Basename;

use Moose::Autobox;
use Grades;

my $script = Grades::Script->new_with_options;
my $id = $scantron->league || basename( getcwd );
my $round = $scantron->round;
my $qn = $scantron->exercise || 1;
my $l = League->new( leagues => '/home/drbean/class', id => $dir );
my $g = Grades->new({ league => $l });

my $config = LoadFile "comp/$round/round.yaml";
my $activity = $config->{activity};
my %color;
for my $topic ( keys %$activity ) {
	my $forms = $activity->{$topic};
	for my $form ( keys %$forms ) {
		my $tables = $activity->{$topic}->{$form};
		for my $table ( @$tables ) {
			@color{ values %$table } = keys %$table;
		}
	}
}

my $new;
my $old = LoadFile "comp/$round/response.yaml";
for my $table ( keys %$old ) {
	my $play = $old->{$table};
	for my $topic ( keys %$play ) {
		my $topicplay = $play->{$topic};
		for my $form ( keys %$topicplay ) {
			my $free = $topicplay->{$form};
			my @player = keys %$free;
			my ($white, $black);
			if ( $color{ $player[0] } eq 'White' ) {
				( $white, $black ) = @player;
			}
			else {
				( $black, $white ) = @player;
			}
			Bless( $free->{$white}->{q} )->keys([1 .. $qn ]);
            Bless( $free->{$white}->{a} )->keys([1 .. $qn ]);
            Bless( $free->{$white} )->keys( [ 'q', 'a'] );
            Bless( $free->{$black}->{q} )->keys([1 .. $qn ]);
            Bless( $free->{$black}->{a} )->keys([1 .. $qn ]);
            Bless( $free->{$black} )->keys( [ 'q', 'a'] );
            Bless( $free )->keys( [ $white, $black ] );
			$new->{$table}->{$topic}->{$form}->{ free } = $free;
			my $set = { $player[0] => { 1 => undef },
				$player[1] => { 1 => undef } };
			Bless( $set )->keys( [ $white, $black ] );
			$new->{$table}->{$topic}->{$form}->{ set } = $set;
		}
	}
}

print Dump $new;
