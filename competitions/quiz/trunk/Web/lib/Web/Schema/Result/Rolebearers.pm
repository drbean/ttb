package Web::Schema::Result::Rolebearers;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("rolebearers");
__PACKAGE__->add_columns(
  "player",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 10,
  },
  "role",
  { data_type => "INT", default_value => undef, is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("player", "role");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-09-22 15:03:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:T3TmOtj4Cz53qIYPVYXMow


# You can replace this text with custom content, and it will be preserved on regeneration
1;
