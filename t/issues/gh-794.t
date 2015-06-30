use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Request::Common:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 2;

{
    package App;
    use Dancer2;
    set serializer => 'JSON';

    post '/' => sub { request->data };
}

my $test = Plack::Test->create( App->to_app );

is(
    $test->request( POST '/', Content => '{"foo":42}' )->content,
    '{"foo":42}',
    'Correct JSON content in POST',
);

TODO: {
    local $TODO = 'Return 500 Internal Server Error';

    my $res = $test->request( POST '/', Content => 'invalid' );
    is( $res->code, 500, 'Failed to decode invalid content' );
}
done_testing;
EOF
