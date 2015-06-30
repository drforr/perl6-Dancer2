use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Request::Common:from<Perl5>;
use Test::Fatal:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 1;

{
    package App;
    use Dancer2;

    set log     => 'core';
    set engines => {
        logger => { Capture => { log_format => '%{x-test}h %i' } },
    };

    set logger => 'Capture';

    get '/' => sub {
        my $req = app->request;
        ::isa_ok( $req, 'Dancer2::Core::Request' );

        my $logger = app->engine('logger');
        ::isa_ok( $logger, 'Dancer2::Logger::Capture' );
        ::can_ok( $logger, 'format_message' );

        my $trap = $logger->trapper;
        ::isa_ok( $trap, 'Dancer2::Logger::Capture::Trap' );
        my $msg = $trap->read;
        ::is_deeply(
            $msg,
            [
                {
                    level     => 'core',
                    message   => 'looking for get /',
                    formatted => "- 1\n",
                },

                {
                    level     => 'core',
                    message   => 'Entering hook core.app.before_request',
                    formatted => "- 1\n",
                },
            ],
            'Messages logged successfully',
        );

        ::can_ok( $logger, 'format_message' );
        my $fmt_str = $logger->format_message(
            $msg->[0]{'debug'}, $msg->[0]{'message'}
        );

        ::is( $fmt_str, "- 1\n", 'Correct formatted message created' );

        return;
    };
}

my $test = Plack::Test->create( App->to_app );

subtest 'Logger can access request' => sub {
    my $res = $test->request( GET '/' );
    ok( $res->is_success, 'Successful request' );
};
done_testing;
EOF
