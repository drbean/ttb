#!/usr/bin/perl

=head1 NAME

dumpTables.pl - Emulate cli db tool, dbtool.pl with DB schema

=head1 SYNOPSIS

./dumpTables.pl players
95801001 Tom
95801002 Jack

=head1 DESCRIPTION

Dumps tables known by DB schema

=head1 AUTHOR

Sebastian Riedel, C<sri@oook.de>

=head1 COPYRIGHT


This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Config::General;



my @MyAppConf = glob( "$Bin/../*.conf" );
die "Which of @MyAppConf is the configuration file?"
			unless @MyAppConf == 1;
my %config = Config::General->new($MyAppConf[0])->getall;
my $name = $config{name};
require $name . ".pm";
my $schema = "${name}::Schema";
my $modelmodule = "${name}::Model::DB";

my $connect_info = $modelmodule->config->{connect_info};
my $d = $schema->connect( @$connect_info );
my $s = $d->resultset(shift @ARGV);
my @columns = $s->result_source->columns;
$, = "\t";
print @columns, "\n=============================================\n";
my $callback = callback( @ARGV );
while ( my $r = $s->next )
{
	my %values = map { $_ => $r->get_column($_) } @columns;
	if ( $callback->( %values ) )
	{
		local $, = "\t";
		print @values{@columns};
		print "\n";
	}
}

sub callback {
	my @token = @_;
	my $regex = qr/$token[2]/;
	my %callbacks = (
		'=~' => sub { my %r=@_; return ( $r{$token[0]} =~ $regex ) },
		'eq' => sub { my %r=@_; return ( $r{$token[0]} eq $token[2] ) },
		'ne' => sub { my %r=@_; return ( $r{$token[0]} ne $token[2] ) },
		'gt' => sub { my %r=@_; return ( $r{$token[0]} gt $token[2] ) },
		);
	return $callbacks{$token[1]};
}
