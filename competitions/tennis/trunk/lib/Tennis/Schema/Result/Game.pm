package Tennis::Schema::Result::Game;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Tennis::Schema::Result::Game

=cut

__PACKAGE__->table("game");

=head1 ACCESSORS

=head2 server

  data_type: 'varchar'
  is_nullable: 0
  size: 13

=head2 receiver

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

=head2 id

  data_type: 'smallint'
  is_nullable: 0

=head2 serverpoints

  data_type: 'smallint'
  is_nullable: 0

=head2 receiverpoints

  data_type: 'smallint'
  is_nullable: 0

=head2 winner

  data_type: 'boolean'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "league",
  { data_type => "varchar", is_nullable => 0, size => 13 },
  "round",
  { data_type => "smallint", is_nullable => 0 },
  "pair",
  { data_type => "smallint", is_nullable => 0 },
  "id",
  { data_type => "smallint", is_nullable => 0 },
  "serverpoints",
  { data_type => "smallint", is_nullable => 0 },
  "receiverpoints",
  { data_type => "smallint", is_nullable => 0 },
  "winner",
  { data_type => "varchar", is_nullable => 0, size => 13 },
);
__PACKAGE__->set_primary_key("id", "pair", "round", "league");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-02-06 18:13:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:j7ERKet/iiRWXsGshm2Jhw

__PACKAGE__->has_many( points => 'Tennis::Schema::Result::Point', {
	'foreign.game' => 'self.id', 'foreign.pair' => 'self.pair',
	'foreign.round' => 'self.round', 'foreign.league' => 'self.league'});
__PACKAGE__->belongs_to( match => 'Tennis::Schema::Result::Match', {
                                     'foreign.pair' => 'self.pair',
       'foreign.round' => 'self.round', 'foreign.league' => 'self.league'});

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
