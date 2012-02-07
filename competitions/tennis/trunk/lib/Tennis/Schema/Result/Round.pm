package Tennis::Schema::Result::Round;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Tennis::Schema::Result::Round

=cut

__PACKAGE__->table("round");

=head1 ACCESSORS

=head2 value

  data_type: 'smallint'
  is_foreign_key: 1
  is_nullable: 0

=head2 tournament

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 15

=cut

__PACKAGE__->add_columns(
  "value",
  { data_type => "smallint", is_foreign_key => 1, is_nullable => 0 },
  "tournament",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 15 },
);
__PACKAGE__->set_primary_key("tournament");

=head1 RELATIONS

=head2 round

Type: belongs_to

Related object: L<Tennis::Schema::Result::Rounds>

=cut

__PACKAGE__->belongs_to(
  "round",
  "Tennis::Schema::Result::Rounds",
  { id => "value", league => "tournament" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-02-06 18:13:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WWyHuVxpYpmuKFJ3wMC0dw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
