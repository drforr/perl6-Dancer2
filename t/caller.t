use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Request::Common:from<Perl5>;
use File::Spec:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 2;

{
    package App;
    use Dancer2;

    get '/' => sub { app->caller };

}

my $app = App->to_app;
test_psgi $app, sub {
    my $cb  = shift;
    my $res = $cb->( GET '/' );

    is( $res->code, 200, '[GET /] Successful' );
SKIP: {
    skip "### XXX Fix this later", 1 if $] < 6;
    is(
        File::Spec->canonpath( $res->content),
        File::Spec->catfile(t => 'caller.t'),
        'Correct App name from caller',
    );
}
};

done_testing;
EOF
