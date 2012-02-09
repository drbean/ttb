package Tennis::Schema::Result::Rally;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Tennis::Schema::Result::Rally

=cut

__PACKAGE__->table("rally");

=head1 ACCESSORS

=head2 server

  data_type: 'varchar'
  is_nullable: 0
  size: 13

=head2 receiver

  data_type: 'varchar'
  is_nullable: 0
  size: 13

=head2 league

  data_type: 'varchar'
  is_nullable: 0
  size: 13

=head2 exercise

  data_type: 'varchar'
  is_nullable: 0
  size: 13

=head2 game

  data_type: 'smallint'
  is_nullable: 0

=head2 point

  data_type: 'smallint'
  is_nullable: 0

=head2 question

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 questiontime

  data_type: 'timestamp'
  is_nullable: 0

=head2 answer

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=head2 answertime

  data_type: 'timestamp'
  is_nullable: 0

=head2 correct

  data_type: 'boolean'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "league",
  { data_type => "varchar", is_nullable => 0, size => 13 },
  "round",
  { data_type => "smallint", is_nullable => 0 },
  "pair",
  { data_type => "smallint", is_nullable => 0 },
  "game",
  { data_type => "smallint", is_nullable => 0 },
  "point",
  { data_type => "smallint", is_nullable => 0 },
  "id",
  { data_type => "smallint", is_nullable => 0 },
  "question",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "questiontime",
  { data_type => "timestamp", is_nullable => 0 },
  "answer",
  { data_type => "varchar", is_nullable => 0, size => 30 },
  "answertime",
  { data_type => "timestamp", is_nullable => 0 },
  "correct",
  { data_type => "boolean", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id", "point", "game", "pair", "round", "league");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-02-06 18:13:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vHzk4/Ljssqje+ccDja/fQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
