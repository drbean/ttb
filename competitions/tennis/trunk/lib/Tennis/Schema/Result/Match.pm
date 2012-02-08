package Tennis::Schema::Result::Match;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Tennis::Schema::Result::Match

=cut

__PACKAGE__->table("match");

=head1 ACCESSORS

=head2 white

  data_type: 'varchar'
  is_nullable: 0
  size: 13

=head2 black

  data_type: 'varchar'
  is_nullable: 0
  size: 13

=head2 league

  data_type: 'varchar'
  is_nullable: 0
  size: 13

=head2 exercise

  data_type: 'varchar'
  is_nullable: 0
  size: 13

=head2 table

  accessor: undef
  data_type: 'smallint'
  is_nullable: 0

=head2 games

  data_type: 'smallint'
  is_nullable: 0

=head2 receiverpoints

  data_type: 'smallint'
  is_nullable: 0

=head2 winner

  data_type: 'boolean'
  is_nullable: 0

=head2 forfeit

  data_type: 'varchar'
  is_nullable: 0
  size: 13

=cut

__PACKAGE__->add_columns(
  "league",
  { data_type => "varchar", is_nullable => 0, size => 13 },
  "round",
  { data_type => "smallint", is_nullable => 0 },
  "pair",
  { data_type => "smallint", is_nullable => 0 },
  "games",
  { data_type => "smallint", is_nullable => 0 },
  "winner",
  { data_type => "varchar", is_nullable => 0, size => 13 },
  "forfeit",
  { data_type => "varchar", is_nullable => 0, size => 13 },
);
__PACKAGE__->set_primary_key("pair", "round", "league");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-02-06 18:13:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JhstPVzXdkjMG4HJ0E+qDQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
