package Tennis::SwissSchema;

use strict;
use warnings;
use FindBin qw/$Bin/;

use lib "$Bin/../../../swiss/web/lib";

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces(
	result_namespace => '+Swiss::Schema::Result'
	);
1;
