package CompComp::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

use Catalyst;
# use CompComp;

# my $name = CompComp->config->{database};
my $name = "comp$ENV{SEMESTER}";

__PACKAGE__->config(
    schema_class => 'CompComp::Schema',
    connect_info =>  {
        dsn => "dbi:Pg:dbname=$name;port=5434",
        user => '',
        password => '',
    }
);

=head1 NAME

CompComp::Model::DB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<CompComp>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<CompComp::Schema>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.29

=head1 AUTHOR

Dr Bean

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
