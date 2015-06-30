use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 2;
use strict;
use warnings;
use Plack::Test;
use HTTP::Request::Common;

{
    package App1;
    use Dancer2;
    get '/' => sub {'App1'};

    my $app = to_app;
    ::test_psgi $app, sub {
        my $cb = shift;
        ::is( $cb->( ::GET '/' )->content, 'App1', 'Got first App' );
    };
}

{
    package App2;
    use Dancer2;
    get '/' => sub {'App2'};

    my $app = to_app;
    ::test_psgi $app, sub {
        my $cb = shift;
        ::is( $cb->( ::GET '/' )->content, 'App2', 'Got second App' );
    };
}


done_testing;
EOF
