package Web::Schema::Result::Words;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("words");
__PACKAGE__->add_columns(
  "genre",
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
  "id",
  {
    data_type => "SMALLINT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "class",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 15,
  },
  "published",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 500,
  },
  "unclozed",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 500,
  },
  "clozed",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 15,
  },
  "pretext",
  { data_type => "CHAR", default_value => undef, is_nullable => 1, size => 50 },
  "posttext",
  { data_type => "CHAR", default_value => undef, is_nullable => 1, size => 50 },
);
__PACKAGE__->set_primary_key("genre", "exercise", "id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-09-22 15:03:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:e8u6O2H19NzI1+RwQsfPWw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
