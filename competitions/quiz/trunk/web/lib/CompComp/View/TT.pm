package CompComp::View::TT;

use strict;
use base 'Catalyst::View::TT';

# __PACKAGE__->config(TEMPLATE_EXTENSION => '.tt');

__PACKAGE__->config(TEMPLATE_EXTENSION => '.tt2',
                       # Set the location for TT files
               INCLUDE_PATH => [
                       CompComp->path_to( 'root', 'src' ),
                   ],
                TIMER => 0,
				WRAPPER => 'wrapper.tt2',
				# render_die => 0,
				# default_view => 'login.tt2'
           );


=head1 NAME

CompComp::View::TT - TT View for CompComp

=head1 DESCRIPTION

TT View for CompComp. 

=head1 AUTHOR

=head1 SEE ALSO

L<CompComp>

Dr Bean

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
