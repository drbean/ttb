#!/usr/bin/perl 

use strict;
use warnings;

use Cwd; use File::Basename;
use YAML qw/Load Dump LoadFile DumpFile/;
use List::Util qw/max/;

use Getopt::Long;
use Pod::Usage;

my $man = 0;
my $help = 0;
my $modulo = 7;
my $hotseat = '';
my $pool = '';

GetOptions (
        'help|?' => \$help, man => \$man
        , 'modulo=i' => \$modulo
        , 'hotseat=s' => \$hotseat
        , 'pool=s' => \$pool
                ) or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

my $string = <STDIN>;
#While ( my $line = <> ) { $string .= $line; }
print "yes" . $string;
my $old = LoadFile "/home/User/111/cultureB/session/6/groups.yaml";
## my $old = LoadFile <STDIN>;
## my $old = Load($string);
my $new;
my %on_hotseat_row;
my %survivor;
for my $key ( keys %$old ) {
	$survivor{$key} = $old->{$key}->{$hotseat};
	my $observer = $old->{$key}->{$pool};
	$on_hotseat_row{$key} = shift @$observer;
	push @$observer, $survivor{$key};
	$new->{$key}->{$pool} = $observer;
}
for my $key ( keys %$old ) {
	if ( $old->{$key+1} ) {
		$new->{$key}->{$hotseat} = 
			$on_hotseat_row{$key+1};
	}
	else {
		$new->{$key}->{$hotseat} =
			$on_hotseat_row{1};
	}
}
print Dump $new;

__END__

=head1 NAME

hotseat_swap.pl - Role reversal on movement to next group

=head1 SYNOPSIS

hotseat_swap.pl -s 1 -hot interviewee -p interviewer -mod 7

=head1 OPTIONS

=over 8

--help            This help message
--man            A man page

--hotseat interviewee	The scalar field being assigned to
--pool interviewer	The sequence field of observers being assigned from
--modulo 7		The number of hotseat/pool groups

=back

=head1 DESCRIPTION

B<hotseat_swap.pl> generates a YAML file from the one on STDIN, passing the hotseat entry from each group to the end of the observer pool in the group, and replacing it with an observer moved from the first entry in the next group.

=cut
