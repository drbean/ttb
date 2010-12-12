#!/usr/bin/perl 

# Created: 西元2010年02月23日 22時33分13秒
# Last Edit: 2010 12月 10, 12時09分22秒
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

With new ideas about Compcomp approach, eg free and set questions, it is necessary to rewrite old forms so they can be accessed by new methods. The code needs to be updated to do this. TODO Redirecting output to file being read from doesn't work.

=cut

use strict;
use warnings;
use IO::All;
use YAML qw/LoadFile Bless DumpFile/;
use List::Util qw/max/;
use Cwd; use File::Basename;

use Moose::Autobox;
use Grades;

my $script = Grades::Script->new_with_options;
my $id = $script->league || basename( getcwd );
my $round = $script->round;
my $qn = $script->exercise || 1;
my $l = League->new( leagues => '/home/drbean/class', id => $id );
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
			$qn = max( scalar keys %{ $free->{$white}->{q} },
						scalar keys %{ $free->{$white}->{a} },
						scalar keys %{ $free->{$black}->{q} },
						scalar keys %{ $free->{$black}->{a} } );
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

rename "comp/$round/response.yaml", "comp/$round/response.yaml.orig";
DumpFile "comp/$round/response.yaml", $new;

=head1 AUTHOR

Dr Bean C<< <drbean at cpan, then a dot, (.), and org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2010 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# vim: set ts=8 sts=4 sw=4 noet:


