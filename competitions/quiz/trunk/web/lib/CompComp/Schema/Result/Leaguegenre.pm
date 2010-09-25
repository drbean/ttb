package CompComp::Schema::Result::Leaguegenre;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("leaguegenre");
__PACKAGE__->add_columns(
  "league",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 25,
  },
  "genre",
  {
    data_type => "INT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("league", "genre");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-09-22 15:03:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oKMh+EQxWD0CslwaUfED3A

__PACKAGE__->belongs_to( league => 'CompComp::Schema::Result::Leagues', 'league' );
__PACKAGE__->belongs_to( data => 'CompComp::Schema::Result::Genre', 'genre' );

# You can replace this text with custom content, and it will be preserved on regeneration
1;
