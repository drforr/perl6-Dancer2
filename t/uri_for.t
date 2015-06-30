use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Request::Common:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;

{
    package App;
    use Dancer2;
    get '/foo' => sub {
        return uri_for('/foo');
    };
}

my $app = App->to_app;
is( ref $app, 'CODE', 'Got app' );

test_psgi $app, sub {
    my $cb = shift;

    is( $cb->( GET '/foo' )->code, 200, '/foo code okay' );
    is(
        $cb->( GET '/foo' )->content,
        'http://localhost/foo',
        'uri_for works as expected',
    );
};

done_testing;
EOF
