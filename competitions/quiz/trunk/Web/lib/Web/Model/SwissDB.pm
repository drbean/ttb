package Web::Model::SwissDB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

use Catalyst;
use Web;

my $name = Web->config->{database};
# my $db = Web->path_to( '../../swiss/web/db', $name );
my $db = Web->path_to( '/var/cgi-bin/swiss/db', $name );

my $connect_info;
if ( $^O eq 'linux' ) { $connect_info = [ "dbi:SQLite:$db", '', '', ]; }

__PACKAGE__->config(
    schema_class => 'Web::SwissSchema',
    connect_info =>  $connect_info,
		        # connect_info => ['dbi:SQLite:db/demo','','']
);

=head1 NAME

Web::Model::SwissDB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<Web>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<Web::SwissSchema>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.29

=head1 AUTHOR

Dr Bean

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
