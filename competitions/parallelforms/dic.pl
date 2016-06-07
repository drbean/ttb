#!/usr/bin/perl

# Last Edit: 2016 Jun 07, 11:53:10 AM
# $Id: /dic/branches/comp/dic.pl 2601 2008-06-26T04:34:08.435934Z greg  $

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;

use FindBin '$Bin';
use lib "$Bin";

my $man = 0;
my $help = 0;
my $s = '';
my $f = 0;

GetOptions (
	'help|?' => \$help, man => \$man,
	's=s' => \$s, 'f=i' => \$f)
		or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

use IO::All;
use YAML qw/LoadFile DumpFile/;
use Text::Template;
use Cloze qw/cloze/;
use List::Util qw/shuffle/;
our $RD_HINT = 1;

# my $round = LoadFile( "round.yaml" );
# my $league = LoadFile( "../league.yaml" );
# my @members = @{$league->{member}};
# my %ids = map { $_->{name} => $_->{id} } @members;
# my %names = map { $_->{id} => $_->{name} } @members;

# my $textSources = $round->{texts};

my $textSources = shift @ARGV;
my ($text, $question) = LoadFile "$textSources/dic.yaml";

my $io = io->dir($textSources);
my @superdir = $io->all;
@superdir = map $_->name, ( grep $_->is_dir, @superdir );
my $next;
my @blanks = (0)x2;
	my @files;

sub sequences
{
	my $dir = shift;
	my @files = glob("$dir/*.txt");
	my @parallelforms = map { [ $_ ] } @files;
	while ( $dir = shift )
	{
		my @extendedforms;
		my @alternatives =  glob("$dir/*.txt");
		for my  $file ( @alternatives )
		{
			for my $form ( @parallelforms )
			{
				push @extendedforms, [@$form, $file];
			}
		}
		@parallelforms = @extendedforms;
	}
	return @parallelforms;
}

my @parallelfiles = sequences(@superdir);
my @texts;
for my $files ( @parallelfiles )
{
	my @files = map { io $_ } @$files;
	my @lines;
	push @{$lines[$_]}, ( $files[$_]->getlines ) for 0..$#files;
	my @blanks = (0)x2;
	my @text;
	(@blanks[0,1], $text[$_]) = cloze(@blanks, @{$lines[$_]})
								for 0..$#files;
	push @texts, \@text;
}
$next = nextText(@texts);

my $tmpl = io "$Bin/dic.tmpl";
my $tmplString = $tmpl->all;

# my $groups = $round->{group};

my @latex = (
		{ page => 1, xy => "8,0" },
		{ page => 1, xy => "0,0" },
		{ page => 1, xy => "8,8" },
		{ page => 1, xy => "0,8" },
		{ page => 2, xy => "8,0" },
		{ page => 2, xy => "0,0" },
		{ page => 2, xy => "8,8" },
		{ page => 2, xy => "0,8" },
		{ page => 3, xy => "8,0" },
		{ page => 3, xy => "0,0" },
		{ page => 3, xy => "8,8" },
		{ page => 3, xy => "0,8" },
	);
my $paging = 0;
my $threepages = 0;

# foreach my $group ( keys %$groups )
foreach my $group ( qw/Black Blue Brown/ )
{
	# my @group =  %{$groups->{$group}}; 
	my $text = $next->();
	$tmplString .= "
\\begin{textblock}{8}($latex[$paging]->{xy})
\\textblocklabel{picture$latex[$paging]->{xy}}
\\mycard" . (join "\n", map { "{$text->[$_]->{A}}" } 0..$#superdir) . "
\\end{textblock}\n";

		&paging;

		$tmplString .= "
\\begin{textblock}{8}($latex[$paging]->{xy})
\\textblocklabel{picture$latex[$paging]->{xy}}
\\mycard" . (join "\n", map { "{$text->[$_]->{B}}" } 0..$#superdir) . "
\\end{textblock}\n";

		&paging;

}

$tmplString .= '
\end{document}
';

my $quiz;
$quiz->{cardIdentifier} = join ' ', map { s{.*/(\w+)$}{$1} } @$textSources;
# $quiz->{cardIdentifier} = join ' ', map { m{^/.*?/.*?/(.*)$};$1 } @$textSources;
# ($quiz->{cardIdentifier} = $textSources ) =~ 
				# s{.*/(\w+/\w+)/?$}{$1};
				# s{.*/(\w+/(?:dic|cloze|book)\d?)\.txt$}{$1};
				# s|.*/(\S+/\S+).txt$|$1|;
$quiz->{autogen} = "% This file, pair/cards.tex was autogenerated on " . localtime() . "by dic.pl out of dic.tmpl";
$quiz->{sections} = @$textSources;
$quiz->{sectionsLatex} = join "\n", map {
	"  \\item \\parbox{7.0cm}{\\normalsize #$_}\n\\vspace{0.2cm}"
	} 1..@$textSources;

my $template = Text::Template->new(TYPE => 'STRING', SOURCE => $tmplString
				, DELIMITERS => [ '<TMPL>', '</TMPL>' ] );
open TEX, ">cards.tex";
print TEX $template->fill_in( HASH => $quiz );

sub nextText
{
	my @texts = @_;
	my $number = @texts;
	my $index = 0;
	my $nextText;
	return sub
	{
		$nextText = $texts[$index];
		if (++$index == $number)
		{
			$index = 0 ;
			@texts[0..$number-1] = @texts[shuffle(0..$number-1)];
		}
		# $index = int rand( $number );
		return $nextText;
	};
}

sub paging
{       if ($paging == 3 or $paging == 7 or $paging == 11 )
        {
                $tmplString .= "
\\begin{tiny}" . ($threepages + $latex[$paging]->{page}) .                      +"\\end{tiny}\\newpage\n\n";
        }
        if ($paging == 11) { $threepages = $threepages+3; $paging = 0; }
        else { $paging++; }
}

__END__

=head1 NAME

Parallel forms of exam-type pair dictation

=head1 SYNOPSIS

./dic.pl

./form.pl

./scoresheet.pl

./grade

=head1 DESCRIPTION

B<dic.pl> generates parallel forms for 2 or 3 conversations from a multiple number of files in directories corresponding to the conversations.

This makes it suitable for a number of different short conversations making up one pair dictation exam sheet.

B<form.pl> makes up the form for the other side of the piece of paper.

B<scoresheet.pl> creates B<scores.yaml>, a YAML-style template file that can be filled in with the number of letters correct.

B<grade> grades the scores and writes a report.

=cut
