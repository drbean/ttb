#!/usr/bin/perl

use strict;
use warnings;

use YAML qw/LoadFile DumpFile/;
use IO::All;
use Text::Template;

my $cards = LoadFile "$ARGV[0]/cards.yaml";

for my $t ( keys %$cards ) {
	my $topic = $cards->{$t};
	next unless ref $topic eq 'HASH';
	for my $f ( keys %$topic ) {
		my $form = $topic->{$f};
		my $fourtmpl = Text::Template->new( type => 'file',
			source =>  'oneA4twogroups.tmpl' ,
			delimiters => [ '<TMPL>', '</TMPL>' ]);
		my $quiztmpl = Text::Template->new( type => 'file',
			source =>  'questionsB5.tmpl' ,
			delimiters => [ '<TMPL>', '</TMPL>' ]);
		my $fio = io "$ARGV[0]/four$t$f.tex";
		my $qio = io "$ARGV[0]/quiz$t$f.tex";
		my $n = 1;
		for my $q ( @ { $form->{quiz} } ) {
			$form->{ "q$n" } = $q->{question};
			$n++;
}
		$fio->print( $fourtmpl->fill_in( hash=> $form ) );
		$qio->print( $quiztmpl->fill_in( hash=> $form ) );
	}
}

# my $cardtmpl = Text::Template->new( type => 'file', source =>  'oneA4twopairs.tmpl' , delimiters => [ '<TMPL>', '</TMPL>' ]);
# my $cio = io "$ARGV[0]/cards.tex";
my $hio = io "$ARGV[0]/quiz.html";
# $cio->print( $cardtmpl->fill_in( hash=> $cards ) );
my @questions = map { $_->{question} } @{$cards->{quiz} };
$,="\n<li>";
$hio->print('<ol>', @questions);
