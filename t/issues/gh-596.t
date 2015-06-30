use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Request::Common:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 2;

BEGIN { $ENV{'DANCER_NO_SERVER_TOKENS'} = 'foo' }

{
    package App;
    use Dancer2;
    get '/' => sub { config->{'no_server_tokens'} };
}

my $test = Plack::Test->create( App->to_app );
my $res  = $test->request( GET '/' );

ok( $res->is_success, 'Successful' );
is( $res->content, 'foo', 'Correct server tokens configuration' );

done_testing;
EOF
