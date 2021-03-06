use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Request::Common:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 4;

{
    package App1;
    use Dancer2;
    get '/' => sub {'App1'};
}

{
    package App2;
    use Dancer2;
    get '/pass' => sub { pass };
}

{
    package App3;
    use Dancer2;
    get '/pass' => sub {'App3'};
    get '/forward' => sub { forward '/' };
}

# pass from App2 to App3
# forward from App3 to App1
my $app = Dancer2->psgi_app;
isa_ok( $app, 'CODE' );

test_psgi $app, sub {
    my $cb = shift;

    is( $cb->( GET '/' )->content, 'App1', 'Simple request' );

    is(
        $cb->( GET '/pass' )->content,
        'App3',
        'Passing from App to App works',
    );

    is(
        $cb->( GET '/forward' )->content,
        'App1',
        'Forwarding from App to App works',
    );
};
done_testing;
EOF
