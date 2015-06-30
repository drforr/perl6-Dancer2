use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 3;

use strict;
use warnings;

use Plack::Test;
use HTTP::Request::Common;

{
    package MyApp;
    use Dancer2;

    get '/' => sub {'OK'};
}

my $app = MyApp->to_app;
isa_ok( $app, 'CODE' );

test_psgi $app, sub {
    my $cb = shift;
    is( $cb->( GET '/' )->code,    200,  '[GET /] Correct status'  );
    is( $cb->( GET '/' )->content, 'OK', '[GET /] Correct content' );
};

done_testing;
EOF
