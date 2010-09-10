use CatalystX::Declare;

model FileServer::Model::Files {
	has 'topicforms' => ( is => 'ro', isa => 'ArrayRef[Str]',
		default => sub {[ qw/xmas_easter xmas_australia shopping_chinese/ ]} );
	has 'questions' => ( is => 'ro', isa => 'ArrayRef[Num]',
		default => sub { [ 1 .. 8 ] } );
}
