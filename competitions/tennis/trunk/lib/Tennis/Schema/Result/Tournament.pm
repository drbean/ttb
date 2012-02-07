package Tennis::Schema::Result::Tournament;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("tournament");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 15,
  },
  "name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 15,
  },
  "description",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 100,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-09-22 15:03:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Gy+JKFpLh9KriN3D4enzJw

__PACKAGE__->has_many(
	matches => 'Tennis::Schema::Result::Match', 'league' );
__PACKAGE__->has_many(
	players => 'Tennis::Schema::Result::Player', 'tournament' );
__PACKAGE__->has_many(
	rounds => 'Tennis::Schema::Result::Rounds', 'tournament' );
__PACKAGE__->has_one(
	round => 'Tennis::Schema::Result::Round', 'tournament' );

# You can replace this text with custom content, and it will be preserved on regeneration
1;
