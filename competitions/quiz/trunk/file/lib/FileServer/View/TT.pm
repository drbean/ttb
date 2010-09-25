use CatalystX::Declare;

# nothing special here, so it's just normal MooseX::Declare syntax
view FileServer::View::TT extends Catalyst::View::TT {

__PACKAGE__->config(TEMPLATE_EXTENSION => '.tt2',
                       # Set the location for TT files
               INCLUDE_PATH => [
                       FileServer->path_to( 'root', 'src' ),
                   ],
                TIMER => 0,
                WRAPPER => 'wrapper.tt2',
           );
}
