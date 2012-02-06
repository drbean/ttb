package Tennis::Schema::Result::Round;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("round");
__PACKAGE__->add_columns(
  "value",
  {
    data_type => "TINYINT",
    default_value => undef,
    is_nullable => 0,
    size => 15,
  },
  "tournament",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 15,
  },
);
__PACKAGE__->set_primary_key("tournament");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-09-22 15:03:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Gy+JKFpLh9KriN3D4enzJw

__PACKAGE__->belongs_to( profile => 'Tennis::Schema::Result::Rounds', {
		'foreign.league' => 'self.tournament',
		'foreign.id' => 'self.value' });
#  { is_deferrable => 0, join_type     => "LEFT",
#    on_delete     => "CASCADE", on_update     => "CASCADE", }
__PACKAGE__->has_one( league => 'dic::Schema::League', {
		'foreign.id' => 'self.tournament' });
__PACKAGE__->has_one( league => 'Swiss::Schema::Matches', {
		'foreign.round' => 'self.value',
		'foreign.tournament' =>'self.tournament' });

__PACKAGE__->has_many( points => 'Tennis::Schema::Point', {
	'foreign.id' => 'self.tournament', 'foreign.round' => 'self.value' });
__PACKAGE__->has_many( faults => 'Tennis::Schema::Point', {
		'foreign.id' => 'self.tournament' });
__PACKAGE__->has_many( lets => 'Tennis::Schema::Point', {
		'foreign.id' => 'self.tournament' });

__PACKAGE__->has_many( whites => 'Tennis::Schema::Result::Match', {
		'foreign.id' => 'self.tournament' });
__PACKAGE__->has_many( blacks => 'Tennis::Schema::Result::Match', {
		'foreign.id' => 'self.tournament' });
# You can replace this text with custom content, and it will be preserved on regeneration
1;
