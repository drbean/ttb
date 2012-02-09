package Tennis::Schema::Result::Point;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Tennis::Schema::Result::Point

=cut

__PACKAGE__->table("point");

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

=head2 game

  data_type: 'smallint'
  is_nullable: 0

=head2 id

  data_type: 'smallint'
  is_nullable: 0

=head2 question

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 grammatical

  data_type: 'boolean'
  is_nullable: 0

=head2 answer

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=head2 correct

  data_type: 'boolean'
  is_nullable: 0

=head2 winner

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
  "game",
  { data_type => "smallint", is_nullable => 0 },
  "id",
  { data_type => "smallint", is_nullable => 0 },
  "winner",
  { data_type => "varchar", is_nullable => 0, size => 13 },
);
__PACKAGE__->set_primary_key("id", "game", "pair", "round", "league");

__PACKAGE__->has_many('faults', 'Tennis::Schema::Result::Fault', {
	'foreign.point' => 'self.id', 'foreign.game' => 'self.game',
	'foreign.pair' => 'self.pair', 'foreign.round' => 'self.pair',
	'foreign.round' => 'self.round', 'foreign.league' => 'self.league'});
__PACKAGE__->has_many('lets', 'Tennis::Schema::Result::Let', {
	'foreign.point' => 'self.id', 'foreign.game' => 'self.game',
	'foreign.pair' => 'self.pair', 'foreign.round' => 'self.pair',
	'foreign.round' => 'self.round', 'foreign.league' => 'self.league'});
__PACKAGE__->has_many('rally', 'Tennis::Schema::Result::Rally', {
	'foreign.point' => 'self.id', 'foreign.game' => 'self.game',
	'foreign.pair' => 'self.pair', 'foreign.round' => 'self.pair',
	'foreign.round' => 'self.round', 'foreign.league' => 'self.league'});

# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-02-06 18:13:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rpg/SG2L2srxlUJzz4Dp3g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
