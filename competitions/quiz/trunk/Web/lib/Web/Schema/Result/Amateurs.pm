package Web::Schema::Result::Amateurs;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("amateurs");
__PACKAGE__->add_columns(
  "email",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 60,
  },
  "name",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 15,
  },
  "time",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("email");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-09-22 15:03:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Kzf1D6BowzJdDh326CHYdw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
