package Tennis::Schema::Result::Match;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

Tennis::Schema::Result::Match

=cut

__PACKAGE__->table("match");

=head1 ACCESSORS

=head2 white

  data_type: 'VARCHAR'
  is_nullable: 1
  size: 13

=head2 black

  data_type: 'VARCHAR'
  is_nullable: 1
  size: 13

=head2 league

  data_type: 'VARCHAR'
  is_nullable: 0
  size: 13

=head2 exercise

  data_type: ''VARCHAR
  is_nullable: 0
  size: 13

=head2 table

  data_type: 'TINYINT'
  is_nullable: 1

=head2 games

  data_type: 'TINYINT'
  is_nullable: 1

=head2 winner

  data_type: 'BOOL'
  is_nullable: 1

=head2 forfeit

  data_type: 'VARCHAR'
  is_nullable: 1
  size: 13

=cut

__PACKAGE__->add_columns(
  "white",
  { data_type => "VARCHAR", is_nullable => 0, size => 13 },
  "black",
  { data_type => "VARCHAR", is_nullable => 0, size => 13 },
  "league",
  { data_type => "VARCHAR", is_nullable => 0, size => 13 },
  "exercise",
  { data_type => "VARCHAR", is_nullable => 0, size => 13 },
  "table",
  { data_type => "TINYINT", is_nullable => 0 },
  "games",
  { data_type => "TINYINT", is_nullable => 0 },
  "receiverpoints",
  { data_type => "TINYINT", is_nullable => 0 },
  "winner",
  { data_type => "BOOL", is_nullable => 0 },
  "forfeit",
  { data_type => "VARCHAR", is_nullable => 0, size => 13 },
);
__PACKAGE__->set_primary_key("table", "white", "black", "exercise", "league");

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
