use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Request::Common:from<Perl5>;
use JSON:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;

{
    package App;
    use Dancer2;
    set serializer => 'JSON';

    post '/' => sub {
        my $post_params = params('body');

        # should work even with empty post body
        my $foo = $post_params->{'foo'};
        return { foo => $foo };
    };
}

my $test = Plack::Test->create( App->to_app );
my %headers;

subtest 'Basic response failing' => sub {
    TODO: {
        local $TODO = '500 when deserializing bad input';
        my $res = $test->request( POST '/', { foo => 'bar' }, %headers );
        is( $res->code, 500, '[POST /] Failed when sending regular params' );
    }
};

subtest 'Basic response' => sub {
    my $res = $test->request(
        POST '/',
        %headers,
        Content => encode_json { foo => 'bar' }
    );

    is( $res->code, 200, '[POST /] Correct response code' );

    my $response_data = decode_json( $res->decoded_content );
    is($response_data->{foo}, 'bar', "[POST /] Correct response data");
};

subtest 'Empty POST' => sub {
    my $res = $test->request( POST '/', {}, %headers );
    is(
        $res->code,
        200,
        '[POST /] Correct response code with empty post body',
    );
};

done_testing;
EOF
