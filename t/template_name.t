use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Request::Common:from<Perl5>;
use File::Spec:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;

use File::Basename 'dirname';

{
    package Foo;

    use Dancer2;

    get '/template_name' => sub {
        return engine('template')->name;
    };
}

my $app = Foo->to_app;
is( ref $app, 'CODE', 'Got app' );

test_psgi $app, sub {
    my $cb = shift;
    is( $cb->( GET '/template_name' )->content, 'Tiny', 'template name' );
};

done_testing;
EOF
