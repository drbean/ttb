package Web::Schema::Result::Questionwords;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("questionwords");
__PACKAGE__->add_columns(
  "genre",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 15,
  },
  "text",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 15,
  },
  "question",
  {
    data_type => "SMALLINT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "id",
  {
    data_type => "SMALLINT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "content",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 50,
  },
  "link",
  {
    data_type => "SMALLINT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("genre", "text", "question", "id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-09-22 15:03:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DADyHKpWWeNTckCiExKCqw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
