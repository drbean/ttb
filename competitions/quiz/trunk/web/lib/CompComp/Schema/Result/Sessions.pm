package CompComp::Schema::Result::Sessions;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("sessions");
__PACKAGE__->add_columns(
  "id",
  { data_type => "CHAR", default_value => undef, is_nullable => 0, size => 72 },
  "session_data",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 1,
    size => 7500,
  },
  "expires",
  { data_type => "INT", default_value => undef, is_nullable => 1, size => undef },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-09-22 15:03:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DM4MrW51PC8mPAWdPPbIsQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
