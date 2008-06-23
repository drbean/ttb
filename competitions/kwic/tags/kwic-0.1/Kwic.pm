package Kwic;  # assumes Some/Module.pm

# Last Edit: 2006 Jun 12, 10:24:28 AM
# $Id: /kwic/tags/kwic-0.1/Kwic.pm 699 2006-06-12T06:26:23.324776Z greg  $

use strict;
use warnings;

BEGIN {
    use Exporter   ();
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

    $VERSION     = 0.01;
    @ISA         = qw(Exporter);
    # @EXPORT      = qw(&func1 &func2 &func4);
    %EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],
    @EXPORT_OK   = qw(&kwic);
}
our @EXPORT_OK;

use Parse::RecDescent;

sub kwic
{
	my @lines = @_;
	our %text = ();

	our $RD_HINT=1;

	foreach my $line ( @lines )
	{

	our @blankedText = ();
	my $grammar = q[
		{
			my $punctuation = qr/[^-A-Za-z0-9']+/;
			my $name = qr/[A-Z][-A-Za-z0-9']*/; # qr/\u\w\w*\b/;
			my $letter = qr/[-A-Za-z0-9']/;
			# my $skip = '';
			my ($inLatex, $inWord) = (0) x 2;
		}
		line: parsing(s) end | <error>
		parsing: pretext keyword posttext
		pretext: m/^(G|RS):.*?\b/ { $Kwic::text{pretext} = $item[1] }
		keyword: m/\b\w+\b/ { $Kwic::text{keyword} = $item[1] }
		posttext: m/.*$/ { $Kwic::text{posttext} = $item[1] }
		end: m/^\Z/
	]; 

		my $parser = Parse::RecDescent->new($grammar);
		defined $parser->line($line) or die "parse died: $?\n";
	}

	return \%text;

}

1;  # don’t forget to return a true value from the file
