package Web::Schema::Result::Texts;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("texts");
__PACKAGE__->add_columns(
  "id",
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
  "genre",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 15,
  },
  "target",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 15,
  },
  "content",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 7500,
  },
  "unclozeables",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 7500,
  },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-09-22 15:03:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wWLViEyt7oDPt+pvE25aSw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
