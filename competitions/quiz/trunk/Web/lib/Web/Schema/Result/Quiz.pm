package Web::Schema::Result::Quiz;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("quiz");
__PACKAGE__->add_columns(
  "genre",
  {
    data_type => "INT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "topic",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 15,
  },
  "story",
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
    size => 50,
  },
);
__PACKAGE__->set_primary_key("genre", "topic", "story");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-09-22 15:03:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Gy+JKFpLh9KriN3D4enzJw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
