#!/usr/bin/perl

# Last Edit: 2013 Oct 08, 04:44:30 PM
# $Id: /cloze/branches/total/dic.pl 2602 2008-06-26T07:40:30.403259Z greg  $

use strict;
use warnings;

use FindBin '$Bin';
use lib "$Bin";

use Getopt::Long;
use Pod::Usage;

my $man = 0;
my $help = 0;

GetOptions (
	'help|?' => \$help, man => \$man) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

use IO::All;
use YAML qw/LoadFile/;
use Parse::RecDescent;
use Text::Template;
use Cloze qw/cloze/;
use Games::Tournament::RoundRobin;
use Games::League::Member;

# my $round = LoadFile( "round.yaml" );
# my $league = LoadFile( "../league.yaml" );
# my @members = @{$league->{member}};
# my %ids = map { $_->{name} => $_->{id} } @members;
# my %names = map { $_->{id} => $_->{name} } @members;
# use Grades;
# use Grades::Groupwork;
# my $l = League->new( leagues => '/home/drbean/021', id => "AFN3Y0" );
# my $g = Grades->new({ league => $l });
# my $cl = $g->classwork;

# my $textSources = $round->{texts};
my $textSources = [ "/home/drbean/class/topics/phones/dic.yaml" ];

my ($text, $question) = LoadFile ($textSources->[0]);

my $fields = shift( $text );

my @latex = (
		{ page => 1, xy => "8,0" },
		{ page => 1, xy => "0,0" },
		# { page => 1, xy => "8,8" },
		# { page => 1, xy => "0,8" },
		# { page => 2, xy => "8,0" },
		# { page => 2, xy => "0,0" },
		# { page => 2, xy => "8,8" },
		# { page => 2, xy => "0,8" },
		# { page => 3, xy => "8,0" },
		# { page => 3, xy => "0,0" },
		# { page => 3, xy => "8,8" },
		# { page => 3, xy => "0,8" },
	);
my $paging = 0;
my $threepages = 0;

my $tmpl = io "$Bin/dic.tmpl";
my $tmplString = $tmpl->all;

my @ids = @ARGV;
my %texts;
my %next;
for my $id ( @ids ) {
	my $i = 0;
	my $lines = $text->[0]->[4];
	my @lines = split /\n/, $lines;
	my $unclozeables = $text->[0]->[5];
	my $text = cloze($unclozeables, @lines);
	my $textA = join '', @{$text->{A}};
	my $textB = join '', @{$text->{B}};
	my @text;
	@text[0,1] = ($textA, $textB);

# my $groups = $round->{group};
# my $groups = $cl->beancans(1);

#foreach my $group ( keys %$groups )
#{
#	next unless $group;
#	#my @group =  map { { name => $_, id => $ids{$_} } }
#	#					values %{$round->{group}->{$group}}; 
#	my @group =  @{ $groups->{$group} };
# my @text = map { $next{$textSources->[$_]}->() } 1..$#$textSources;
#	if ( $#group == 1 ) 
	{
		$tmplString .= "
\\begin{textblock}{7.5}($latex[$paging]->{xy})
\\textblocklabel{picture$latex[$paging]->{xy}}
\\mycard
{$text[0]}
\\end{textblock}\n";
		&paging;
		$tmplString .= "
\\begin{textblock}{7.5}($latex[$paging]->{xy})
\\textblocklabel{picture$latex[$paging]->{xy}}
\\mycard
{$text[1]}
\\end{textblock}\n";
		&paging;
	}
#	elsif ( $#group == 2 ) 
#	{
#		$tmplString .= "
#\\begin{textblock}{5.9}($latex[$paging]->{xy})
#\\textblocklabel{picture$latex[$paging]->{xy}}
#\\mycard
#{}
#{}
#{$text[0]}
#\\end{textblock}\n";
#		&paging;
#		$tmplString .= "
#\\begin{textblock}{5.9}($latex[$paging]->{xy})
#\\textblocklabel{picture$latex[$paging]->{xy}}
#\\mycard
#{}
#{}
#{$text[1]}
#\\end{textblock}\n";
#		&paging;
#	}
#	elsif ($group eq 'Bye')
#	{	
#		my $byes = $round->{group}->{Bye};
#		foreach my $byer ( @$byes )
#		{
#			$tmplString .= "
#\\begin{textblock}{8}($latex[$paging]->{xy})
#\\textblocklabel{picture$latex[$paging]->{xy}}
#\\mycard
#{$byer $ids{$byer}}
#{$byer $ids{$byer}}
#{$byer! No homework needed. Take a break this week. You win 3 points. \\rule{8.5cm}{1pt}}
#{No homework needed. Take a break this week. You win 3 points. \\rule{8.5cm}{1pt}}
#{No homework needed. Take a break this week. You win 3 points.}
#\\end{textblock}\n";
#
#			&paging;
#		}
#	}

# }

}

$tmplString .= '
\end{document}
';

my $quiz;
#$quiz->{cardIdentifier} = $textSources ) =~ 
#			s{.*/(\w+/\w+)/?$}{$1};
# $quiz->{cardIdentifier} = join ' ', map { m{^/.*/.*/(.*)$};$1 } @$textSources;
$quiz->{cardIdentifier} = "dictation";
$quiz->{autogen} = "% This file, cards.tex was autogenerated on " . localtime() . "by dic.pl out of cards.tmpl";

my $template = Text::Template->new(TYPE => 'STRING', SOURCE => $tmplString
				, DELIMITERS => [ '<TMPL>', '</TMPL>' ] );
open TEX, ">cards.tex";
print TEX $template->fill_in( HASH => $quiz );

sub nextText
{
	my $texts = shift;
	# my $number = $#$texts;
	my $index = 0;
	my ($nextText, $nextFile);
	return sub
	{
		$nextText = $texts->{messages};
		# $index = 0 if ++$index == $number;
		# $index = 0 if $index++ == $number;
		# $index = int rand( $number );
		# $index = int rand( $number + 1);
		my $textA = join '', @{$nextText->{A}};
		my $textB = join '', @{$nextText->{B}};
		return ( $textA, $textB );
	};
}

sub paging
{	if ($paging == 2 or $paging == 4 or $paging == 6 )
	{
		$tmplString .= "
\\begin{tiny}" . ($threepages + $latex[$paging]->{page}) . "\\end{tiny}\\newpage\n\n";
	}
	if ($paging == 11) { $threepages = $threepages+3; $paging = 0; }
	else { $paging++; }
}

__END__

=head1 NAME

Total blanks

=head1 SYNOPSIS

./dic.pl

./form.pl

./scoresheet.pl

./grade

=head1 DESCRIPTION

B<dic.pl> generates totally blanked cards of a dialog, one blank per letter. But there are fillable squares only for one side of the conversation on one card, and fillable squares for only the other side of the conversation on the other card.

This makes it suitable for pairs listening to a tape.

B<form.pl> makes up the form for the other side of the piece of paper.

B<scoresheet.pl> creates B<scores.yaml>, a YAML-style template file that can be filled in with the number of letters correct.

B<grade> grades the scores and writes a report.

=cut
