package Tennis::Schema::Result::Login;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table("login");
__PACKAGE__->add_columns(
  "id",
  { data_type => "VARCHAR", is_nullable => 0, size => 13 },
  "name",
  { data_type => "VARCHAR", is_nullable => 0, size => 15 },
  "password",
  { data_type => "VARCHAR", is_nullable => 0, size => 50 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-08-26 18:19:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:L/SxzQ3/Z3aQ1zBC8jOgYA

#
# Set relationships:
#

# has_many():
#   args:
#     1) Name of relationship, DBIC will create accessor with this name
#     2) Name of the model class referenced by this relationship
#     3) Column name in *foreign* table
__PACKAGE__->has_many(player => 'Tennis::Schema::Result::Draw', 'player');

# many_to_many():
#   args:
#     1) Name of relationship, DBIC will create accessor with this name
#     2) Name of has_many() relationship this many_to_many() is shortcut for
#     3) Name of belongs_to() relationship in model class of has_many() above 
#   You must already have the has_many() defined to use a many_to_many().
__PACKAGE__->many_to_many(leagues => 'player', 'league');

# You can replace this text with custom content, and it will be preserved on regeneration
1;
