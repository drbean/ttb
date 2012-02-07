package Tennis::Schema::Result::Rounds;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Tennis::Schema::Result::Rounds

=cut

__PACKAGE__->table("rounds");

=head1 ACCESSORS

=head2 league

  data_type: 'varchar'
  is_nullable: 0
  size: 13

=head2 story

  data_type: 'varchar'
  is_nullable: 0
  size: 13

=head2 id

  data_type: 'smallint'
  is_nullable: 0

=head2 swissround

  data_type: 'smallint'
  is_nullable: 0

=head2 start

  data_type: 'timestamp'
  is_nullable: 0

=head2 stop

  data_type: 'timestamp'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "league",
  { data_type => "varchar", is_nullable => 0, size => 13 },
  "story",
  { data_type => "varchar", is_nullable => 0, size => 13 },
  "id",
  { data_type => "smallint", is_nullable => 0 },
  "swissround",
  { data_type => "smallint", is_nullable => 0 },
  "start",
  { data_type => "timestamp", is_nullable => 0 },
  "stop",
  { data_type => "timestamp", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("league", "id");

=head1 RELATIONS

=head2 rounds

Type: has_many

Related object: L<Tennis::Schema::Result::Round>

=cut

__PACKAGE__->has_many(
  "rounds",
  "Tennis::Schema::Result::Round",
  { "foreign.tournament" => "self.league", "foreign.value" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-02-06 18:13:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5AUky7+TzBz+NGUWLWZClg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
