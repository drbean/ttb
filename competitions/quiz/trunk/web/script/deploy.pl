#!perl

use strict;
use warnings;
use lib "lib";

use Config::General;

use CompComp::Model::DB;
use CompComp::Schema;

my $connect_info = CompComp::Model::DB->config->{connect_info};
my $schema = CompComp::Schema->connect( $connect_info );

$schema->deploy;

=head1 NAME

deploy.pl - Set up db

=head1 SYNOPSIS

perl script_files/deploy.pl

=head1 DESCRIPTION

'CREATE TABLE players (id text, name text, password text, primary key (id))'

=head1 AUTHOR

Dr Bean, C<drbean at (@) cpan dot, yes a dot, org>

=head1 COPYRIGHT


This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
