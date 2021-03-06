use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Request::Common:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;

{
    package MyApp;

    use Dancer2;
# XXX JMG changes to accommodate relocation
use FindBin qw($Bin);
set appdir => "$Bin/t/issues/gh-650";
set views => config->{'appdir'}.'/views';
set public_dir => config->{'appdir'}.'/public';

    set template => 'template_toolkit';

    get '/foo' => sub {
        template 'environment_setting'
    };
    get '/bar' => sub {
        set environment => 'development';
        template 'environment_setting'
    };
}

my $app = Dancer2->psgi_app;
is( ref $app, 'CODE', 'Got app' );

test_psgi $app, sub {
    my $cb = shift;
    my $res;

    $res = $cb->(GET '/foo');
    is $res->code, 200, 'Successful request';
    like $res->content, qr/development/, 'Correct content';

    $res = $cb->(GET '/bar');
    is $res->code, 200, 'Successful request';
    like $res->content, qr/development/, 'Correct content';
};

done_testing;
EOF
