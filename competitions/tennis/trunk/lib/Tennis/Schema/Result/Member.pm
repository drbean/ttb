package Tennis::Schema::Result::Member;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("member");
__PACKAGE__->add_columns(
  "tournament",
  { data_type => "VARCHAR", is_nullable => 0, size => 15 },
  "player",
  { data_type => "VARCHAR", is_nullable => 0, size => 13 },
);
__PACKAGE__->set_primary_key("tournament", "player");


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-08-26 18:19:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2H0UYSYlc/ex3aLButFiBg

#
# Set relationships:
#

# belongs_to():
#   args:
#     1) Name of relationship, DBIC will create accessor with this name
#     2) Name of the model class referenced by this relationship
#     3) Column name in *this* table
__PACKAGE__->belongs_to(league => 'Tennis::Schema::Result::Tournament',
	'tournament');

# belongs_to():
#   args:
#     1) Name of relationship, DBIC will create accessor with this name
#     2) Name of the model class referenced by this relationship
#     3) Column name in *this* table
__PACKAGE__->belongs_to(profile => 'Tennis::Schema::Result::Login', 'player');
__PACKAGE__->has_many(draws => 'Tennis::Schema::Result::Draw', {
	'foreign.tournament'	=> 'self.tournament',
	'foreign.player'	=> 'self.player' });

#__PACKAGE__->might_have( jigsawrole => 'dic::Schema::Jigsawrole',
#        {'foreign.player' => 'self.player', 'foreign.league' =>'self.league'});

=head1 NAME

DB::Member - A model object representing the JOIN between a player and 
a league

=head1 DESCRIPTION

=cut


# You can replace this text with custom content, and it will be preserved on regeneration
1;
