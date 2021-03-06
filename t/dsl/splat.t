use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Request::Common:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 4;

my @splat;

{
    package App;
    use Dancer2;
    get '/*/*/*' => sub {
        my $params = params();
        ::is_deeply(
            $params,
            { splat => [ qw<foo bar baz> ], foo => 42 },
            'Correct params',
        );

        @splat = splat;
    };
}

my $test = Plack::Test->create( App->to_app );
my $res = $test->request( GET '/foo/bar/baz?foo=42' );

is_deeply( [@splat], [qw(foo bar baz)], 'splat behaves as expected' );
is( $res->code, 200, 'got a 200' );
is_deeply( $res->content, 3, 'got expected response' );

done_testing;
EOF
