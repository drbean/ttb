package CompComp::Model::dicDB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

# use Catalyst;
# use Bett;

my $name = CompComp->config->{dic_database};
# my $name = "dic001";

__PACKAGE__->config(
    schema_class => 'CompComp::dicSchema',
    connect_info => {
        dsn => "dbi:Pg:dbname=$name",
        user => '',
        password => '',
    }
);

=head1 NAME

Bett::Model::dicDB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<Bett>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<Bett::dicSchema>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.29

=head1 AUTHOR

Dr Bean

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
