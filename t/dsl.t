use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Request::Common:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;

use Dancer2;

any [ 'get', 'post' ], '/' => sub {
    request->method;
};

my $app = __PACKAGE__->to_app;
is( ref $app, 'CODE', 'Got app' );

test_psgi $app, sub {
    my $cb = shift;
    is( $cb->( GET '/'  )->content, 'GET',  'GET / correct content'  );
    is( $cb->( POST '/' )->content, 'POST', 'POST / correct content' );
};

done_testing;
EOF
