use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Cookies:from<Perl5>;;
use HTTP::Request::Common:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;

{
    package TestApp;

    use Dancer2;
# XXX JMG changes to accommodate relocation
use FindBin qw($Bin);
set appdir => "$Bin/t";
set views => config->{'appdir'}.'/views';
set public_dir => config->{'appdir'}.'/public';

    get '/' => sub {
        template 'session_in_template'
    };

    get '/set_session/*' => sub {
        my ($name) = splat;
        session name => $name;
        template 'session_in_template';
    };

    get '/destroy_session' => sub {
        # Need to call the 'session' keyword, so app->setup_session
        # is called and the session attribute in the engines is populated
        my $name = session 'name';
        # Destroying the session should remove the session object from
        # all engines.
        app->destroy_session;
        template 'session_in_template';
    };

    setting(
        engines => {
            session => { 'Simple' => { session_dir => 't/sessions' } }
        }
    );
    setting( session => 'Simple' );
}

my $app = TestApp->to_app;
is( ref $app, 'CODE', 'Got app' );

my $test = Plack::Test->create($app);
my $jar = HTTP::Cookies->new();
my $base = 'http://localhost';

{
    my $res = $test->request( GET "$base/" );

    ok $res->is_success, 'Successful request';
    is $res->content, "session.name \n";

    $jar->extract_cookies($res);
}

{
    my @requests = (
        GET("$base/set_session/test_name"),
        GET("$base/")
    );
    for my $req ( @requests ) {
        $jar->add_cookie_header($req);

        my $res = $test->request($req);
        ok $res->is_success, 'Successful request';
        is $res->content, "session.name test_name\n";

        $jar->extract_cookies($res);
    }
}

{
    my $request = GET "$base/";
    $jar->add_cookie_header($request);

    my $res = $test->request($request);
    ok $res->is_success, 'Successful request';
    is $res->content, "session.name test_name\n";

    $jar->extract_cookies($res);
}


{
    my $request = GET "$base/destroy_session";
    $jar->add_cookie_header($request);

    my $res = $test->request($request);
    ok $res->is_success, 'Successful request';
    is $res->content, "session.name \n";

    $jar->extract_cookies($res);
}

done_testing;
EOF
