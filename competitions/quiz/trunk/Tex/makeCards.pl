#!/usr/bin/perl

use strict;
use warnings;

use YAML qw/LoadFile DumpFile/;
my $cards = LoadFile "$ARGV[0]/cards.yaml";
use Text::Template;
my $n = 1;
for my $q ( @ { $cards->{quiz} } ) {
	$cards->{ "q$n" } = $q->{question};
	$n++;
}
my $cardtmpl = Text::Template->new( type => 'file', source =>  'oneA4twopairs.tmpl' , delimiters => [ '<TMPL>', '</TMPL>' ]);
my $quiztmpl = Text::Template->new( type => 'file', source =>  'questionsA4.tmpl' , delimiters => [ '<TMPL>', '</TMPL>' ]);
my $fourtmpl = Text::Template->new( type => 'file', source =>  'oneA4twogroups.tmpl' , delimiters => [ '<TMPL>', '</TMPL>' ]);
use IO::All;
my $cio = io "$ARGV[0]/cards.tex";
my $qio = io "$ARGV[0]/quiz.tex";
my $hio = io "$ARGV[0]/quiz.html";
my $fio = io "$ARGV[0]/four.tex";
$cio->print( $cardtmpl->fill_in( hash=> $cards ) );
$qio->print( $quiztmpl->fill_in( hash=> $cards ) );
$fio->print( $fourtmpl->fill_in( hash=> $cards ) );
my @questions = map { $_->{question} } @{$cards->{quiz} };
$,="\n";
$hio->print(@questions);
