package Tennis::Schema::Result::Rally;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

Tennis::Schema::Result::Rally

=cut

__PACKAGE__->table("rally");

=head1 ACCESSORS

=head2 server

  data_type: 'VARCHAR'
  is_nullable: 0
  size: 13

=head2 receiver

  data_type: 'VARCHAR'
  is_nullable: 0
  size: 13

=head2 league

  data_type: 'VARCHAR'
  is_nullable: 0
  size: 13

=head2 exercise

  data_type: 'VARCHAR'
  is_nullable: 0
  size: 13

=head2 game

  data_type: 'TINYINT'
  is_nullable: 0

=head2 point

  data_type: 'TINYINT'
  is_nullable: 0

=head2 question

  data_type: 'VARCHAR'
  is_nullable: 0
  size: 100

=head2 questiontime

  data_type: 'datetime'
  is_nullable: 0

=head2 answer

  data_type: 'VARCHAR'
  is_nullable: 0
  size: 30

=head2 answertime

  data_type: 'datetime'
  is_nullable: 0

=head2 correct

  data_type: 'BOOL'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "server",
  { data_type => "VARCHAR", is_nullable => 0, size => 13 },
  "receiver",
  { data_type => "VARCHAR", is_nullable => 0, size => 13 },
  "league",
  { data_type => "VARCHAR", is_nullable => 0, size => 13 },
  "exercise",
  { data_type => "VARCHAR", is_nullable => 0, size => 13 },
  "game",
  { data_type => "TINYINT", is_nullable => 0 },
  "point",
  { data_type => "TINYINT", is_nullable => 0 },
  "question",
  { data_type => "VARCHAR", is_nullable => 0, size => 100 },
  "questiontime",
  { data_type => "datetime", is_nullable => 0 },
  "answer",
  { data_type => "VARCHAR", is_nullable => 0, size => 30 },
  "answertime",
  { data_type => "datetime", is_nullable => 0 },
  "correct",
  { data_type => "BOOL", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("point", "game", "server", "receiver", "exercise", "league");

#=head1 RELATIONS
#
#=head2 played_by
#
#Type: belongs_to
#
#Related object: L<Bett::Schema::Result::Member>
#
#=cut
#
#__PACKAGE__->belongs_to(
#  "played_by",
#  "Bett::Schema::Result::Member",
#  {	"foreign.player" => "self.player",
#  	"foreign.league" => "self.league"
#  },
#  {
#    is_deferrable => 0,
#    join_type     => "LEFT",
#    on_delete     => "CASCADE",
#    on_update     => "CASCADE",
#  },
#);
#
#=head2 yn
#
#Type: belongs_to
#
#Related object: L<Bett::Schema::Result::Yn>
#
#=cut
#
#__PACKAGE__->belongs_to(
#  "yns",
#  "Bett::Schema::Result::Yn",
#  {   "foreign.player" => "self.player",
#      "foreign.league" => "self.league",
#      "foreign.exercise" => "self.exercise"
#  },
#  {
#    is_deferrable => 0,
#    join_type     => "LEFT",
#    on_delete     => "CASCADE",
#    on_update     => "CASCADE",
#  },
#);

__PACKAGE__->meta->make_immutable;
1;
