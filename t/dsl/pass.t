use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Request::Common:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;

subtest 'pass within routes' => sub {
    {

        package App;
        use Dancer2;

        get '/' => sub { 'hello' };
        get '/**' => sub {
            header 'X-Pass' => 'pass';
            pass;
            redirect '/'; # won't get executed as pass returns immediately.
        };
        get '/pass' => sub {
            return "the baton";
        };
    }

    my $app = App->to_app;
    is( ref $app, 'CODE', 'Got app' );

    test_psgi $app, sub {
        my $cb = shift;

        {
            my $res = $cb->( GET '/pass' );
            is( $res->code, 200, '[/pass] Correct status' );
            is( $res->content, 'the baton', '[/pass] Correct content' );
            is(
                $res->headers->header('X-Pass'),
                'pass',
                '[/pass] Correct X-Pass header',
            );
        }
    };

};

done_testing;
EOF
