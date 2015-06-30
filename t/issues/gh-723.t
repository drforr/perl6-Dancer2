use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Request::Common:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 4;

{
    package App;
    use Dancer2;
    get '/' => sub {'OK'};
}

{
    package App::Extended;
    use Dancer2;
    prefix '/test';
    get '/'  => sub {'Also OK'};
    post '/' => sub {
        my $params = params;
        ::isa_ok( $params, 'HASH' );
        ::is( $params->{'foo'}, 'bar', 'Got params' );
        return $params->{'foo'};
    };
}

my $app = Dancer2->psgi_app;
isa_ok( $app, 'CODE' );

my $test = Plack::Test->create($app);

subtest 'GET /' => sub {
    plan tests => 2;
    my $res = $test->request( GET '/' );
    is( $res->code,    200,  'Correct code'    );
    is( $res->content, 'OK', 'Correct content' );
};

subtest 'GET /test/' => sub {
    plan tests => 2;
    my $res = $test->request( GET '/test/' );
    is( $res->code,     200,      'Correct code'    );
    is( $res->content, 'Also OK', 'Correct content' );
};

subtest 'Missing POST params' => sub {
    plan tests => 4;
    my $res = $test->request(
        POST '/test/',
        { foo => 'bar' },
    );

    is( $res->code,    200,   'Correct code'    );
    is( $res->content, 'bar', 'Correct content' );
};

done_testing;
EOF
