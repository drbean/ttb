package Bett::dicSchema;

use strict;
use warnings;
use FindBin qw/$Bin/;

use lib "$Bin/../../dic/lib";

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces(
	result_namespace => '+dic::Schema'
	);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-09-22 15:03:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:iWpEslRAR3iF6A9uKxwYoQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
