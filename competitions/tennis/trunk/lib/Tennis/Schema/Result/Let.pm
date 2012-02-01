package Tennis::Schema::Result::Fault;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

Tennis::Schema::Result::Fault

=cut

__PACKAGE__->table("fault");

=head1 ACCESSORS

=head2 server

  data_type: 'VARCHAR(13)'
  is_nullable: 0

=head2 receiver

  data_type: 'VARCHAR(13)'
  is_nullable: 0

=head2 league

  data_type: 'VARCHAR(13)'
  is_nullable: 0

=head2 exercise

  data_type: 'VARCHAR(13)'
  is_nullable: 0

=head2 game

  data_type: 'TINYINT'
  is_nullable: 0

=head2 point

  data_type: 'TINYINT'
  is_nullable: 0

=head2 id

  data_type: 'TINYINT'
  is_nullable: 0

=head2 question

  data_type: 'VARCHAR(100)'
  is_nullable: 0

=head2 questiontime

  data_type: 'datetime'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "server",
  { data_type => "VARCHAR(13)", is_nullable => 0 },
  "receiver",
  { data_type => "VARCHAR(13)", is_nullable => 0 },
  "league",
  { data_type => "VARCHAR(13)", is_nullable => 0 },
  "exercise",
  { data_type => "VARCHAR(13)", is_nullable => 0 },
  "game",
  { data_type => "TINYINT", is_nullable => 0 },
  "point",
  { data_type => "TINYINT", is_nullable => 0 },
  "id",
  { data_type => "TINYINT", is_nullable => 0 },
  "question",
  { data_type => "VARCHAR(100)", is_nullable => 0 },
  "questiontime",
  { data_type => "datetime", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id", "point", "game", "server", "receiver", "exercise", "league");

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
