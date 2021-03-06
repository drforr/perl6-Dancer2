use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Request::Common:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 4;
use Dancer2;

get '/' => sub {
    return 'Forbidden';
};

get '/default' => sub {
    return 'Default';
};

get '/redirect' => sub {
    return 'Secret stuff never seen';
};

hook before => sub {
    return if request->dispatch_path eq '/default';

    # Add some content to the response
    response->content("SillyStringIsSilly");

    # redirect - response should include the above content
    return redirect '/default'
        if request->dispatch_path eq '/redirect';

    # The response object will get replaced by the result of the forward.
    forward '/default';
};

my $app = __PACKAGE__->to_app;
is( ref $app, 'CODE', 'Got app' );

test_psgi $app, sub {
    my $cb = shift;

    like(
        $cb->( GET '/' )->content,
        qr{Default},
        'forward in before hook',
    );

    my $r = $cb->( GET '/redirect' );

    # redirect in before hook
    is( $r->code, 302, 'redirect in before hook' );
    is(
        $r->content,
        'SillyStringIsSilly',
        '.. and the response content is correct',
    );
};

done_testing;
EOF
