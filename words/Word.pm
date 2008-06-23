package Word;  # assumes Some/Module.pm

# Last Edit: 2008 Apr 19, 11:08:55 AM
# $Id$

use strict;
use warnings;

use WWW::Mechanize;
use WWW::Babelfish;

=head2 new

	$prep = Word->new

Establish a WWW::Mechanize object http://www.wordsmyth.net, and a WWW::Babelfish English-Chinese translation object with Google.

=cut

sub new {
	my $self = shift;
	my $scraper = WWW::Mechanize->new();
	my $translator = WWW::Babelfish->new(service => 'Google');
	return bless { scraper => $scraper, translator => $translator };
	}

=head2 explain

	$materials = $prep->explain('new')

Assemble a set of materials for each word, including the word, a definition, an example from the database from which the word was extracted, and a Chinese translation of the example.

=cut

sub explain
{
	my $self = shift;
	my $word = shift;
	my $scraper = $self->{scraper};
	my $translator = $self->{translator};
	$scraper->get(
"http://www.wordsmyth.net/live/home.php?script=search&matchent=$word&matchtype=exact");
	(my $definition = $scraper->response->content) =~ s/^.*?Definition.*?<span[^>]*>[^<]*<\/span>.*?<span[^>]*>([^<]*)<\/span>.*$/$1/si;
	my $example = shift;
	my $translation = $translator->translate(
		source => 'English',
		destination => 'Chinese',
		text => $example );
	return [$definition, $translation];

}

1;  # don’t forget to return a true value from the file
