#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use YAML qw/LoadFile/;

my $man = 0;
my $help = 0;
my ( $letters, $points );

GetOptions (
	"letters=i" => \$letters, "points=i" => \$points,
	);

my $round = LoadFile( "round.yaml" );

my $passLetters = $round->{pass};
my $passGrade = 9;
my $points2letters = sub {
	my $points = shift;
	return 1 + int (($passLetters/$passGrade**2.3)*$points**2.3);
};
my $letters2points = sub {
	my $letters = shift;
	return int ((($letters/$passLetters)**(1/2.3))*$passGrade);
};

my ( $grade, $lettertarget );
if ( $letters )
{ print "$letters letters? " . $letters2points->($letters) . " points\n"; }
if ( $points )
{ print "$points points? " .  $points2letters->($points) . " letters\n"; }


