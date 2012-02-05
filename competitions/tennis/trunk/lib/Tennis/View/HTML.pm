package Tennis::View::HTML;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt2',
    render_die => 1,
    INCLUDE_PATH => [
            Tennis->path_to( 'root', 'src' ),
        ],
    TIMER              => 0,
    WRAPPER => 'wrapper.tt2',
);

=head1 NAME

Tennis::View::HTML - TT View for Tennis

=head1 DESCRIPTION

TT View for Tennis.

=head1 SEE ALSO

L<Tennis>

=head1 AUTHOR

Dr Bean

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
