package Web::Schema::Result::Play;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("play");
__PACKAGE__->add_columns(
  "league",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 15,
  },
  "exercise",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 15,
  },
  "player",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => undef },
  "blank",
  {
    data_type => "SMALLINT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "correct",
  {
    data_type => "TINYINT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("exercise", "player", "blank");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-09-22 15:03:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0BXbV56QfIi2TAp+aZrDqA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
