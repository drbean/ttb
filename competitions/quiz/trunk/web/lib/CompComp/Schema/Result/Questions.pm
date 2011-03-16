package CompComp::Schema::Result::Questions;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("questions");
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
  "id",
  {
    data_type => "SMALLINT",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "description",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 50,
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
    size => 500,
  },
  "answer",
  {
    data_type => "VARCHAR",
    default_value => undef,
    is_nullable => 0,
    size => 500,
  },
);
__PACKAGE__->set_primary_key("topic", "story", "id");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-09-22 15:03:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:56gkl7nOCoZnA1omiRu98A

__PACKAGE__->has_many('played', 'CompComp::Schema::Result::Play', {
		'foreign.topic' => 'self.topic',
		'foreign.story' => 'self.story',
		'foreign.question' => 'self.id', } );

# You can replace this text with custom content, and it will be preserved on regeneration
1;
