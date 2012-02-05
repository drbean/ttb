package Tennis::dicSchema;

use strict;
use warnings;
use FindBin qw/$Bin/;

use lib "$Bin/../../dic/lib";

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces(
	result_namespace => '+dic::Schema'
	);

1;
