package FileServer;

# Created: 西元2010年04月18日 12時45分36秒
# Last Edit: 2010  4月 18, 14時14分24秒
# $Id$

=head1 NAME

FileServer.pm - Serve files with CatalystX::Declare-built app

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use strict;
use warnings;

=head1 DESCRIPTION

Easy file server by web form of genre, activity (topic, form) and question, built with CatalystX::Declare.

=cut

use CatalystX::Declare;

application FileServer with Static::Simple {

    $CLASS->config(name => 'FileServer');

}

use CatalystX::Declare;

controller FileServer::Controller::Foo
     with FileServer::ControllerRole::Bar {

   use MooseX::Types::Moose qw( Str );

   has welcome_message => (
       is          => 'rw',
       isa         => Str,
       required    => 1,
       lazy_build  => 1,
   );

   method _build_welcome_message { 'Welcome' }

   action base under '/' as '';

   under base {

       final action welcome {
	   $ctx->response->body( $self->welcome_message );
       }
   }
}

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
C<bug-/home/drbean/comp/webFileServer.pm at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=/home/drbean/comp/webFileServer.pm>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc /home/drbean/comp/web/FileServer.pm

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist//home/drbean/comp/web/FileServer.pm>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d//home/drbean/comp/web/FileServer.pm>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=/home/drbean/comp/web/FileServer.pm>

=item * Search CPAN

L<http://search.cpan.org/dist//home/drbean/comp/web/FileServer.pm>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2010 Dr Bean, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;    # End of /home/drbean/comp/webFileServer.pm

# vim: set ts=8 sts=4 sw=4 noet:

