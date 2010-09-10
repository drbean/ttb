package FileServer::ControllerRole::Bar;

# Created: 西元2010年04月19日 13時44分52秒
# Last Edit: 2010  4月 19, 13時56分23秒
# $Id$

=head1 NAME

Bar.pm - A role consumed by Read FileServer Controller

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use strict;
use warnings;

use CatalystX::Declare;

=head1 DESCRIPTION

Don't know what I will use Controller for yet.

=cut

controller_role FileServer::ControllerRole::Bar {

   # use MyApp::Types qw( Username );

   around _build_welcome_message { $self->$orig . '!' }

   after welcome (Object $ctx) {

       $ctx->response->body(join "\n",
       $ctx->response->body,
       time(),
       );
   }

   final action special_welcome (Str $name) under base {

       $ctx->response->body('Hugs to ' . $name);
   }
}


=head1 AUTHOR

Dr Bean C<< <drbean at cpan, then a dot, (.), and org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-/home/drbean/comp/web/lib/FileServer/ControllerBar.pm at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=/home/drbean/comp/web/lib/FileServer/ControllerBar.pm>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc /home/drbean/comp/web/lib/FileServer/ControllerBar.pm

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist//home/drbean/comp/web/lib/FileServer/ControllerBar.pm>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d//home/drbean/comp/web/lib/FileServer/ControllerBar.pm>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=/home/drbean/comp/web/lib/FileServer/ControllerBar.pm>

=item * Search CPAN

L<http://search.cpan.org/dist//home/drbean/comp/web/lib/FileServer/ControllerBar.pm>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2010 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;    # End of /home/drbean/comp/web/lib/FileServer/ControllerBar.pm

# vim: set ts=8 sts=4 sw=4 noet:

