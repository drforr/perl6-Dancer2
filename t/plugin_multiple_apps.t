use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Request::Common:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;

{
    package App;

    BEGIN {
        use Dancer2;
        set session => 'Simple';
    }

    use t::lib::SubApp1 with => { session => engine('session') };

    use t::lib::SubApp2 with => { session => engine('session') };
}

my $app = Dancer2->psgi_app;
is( ref $app, 'CODE', 'Got app' );

test_psgi $app, sub {
    my $cb = shift;

    is( $cb->( GET '/subapp1' )->content, 1, '/subapp1' );
    is( $cb->( GET '/subapp2' )->content, 2, '/subapp2' );
};

done_testing;
EOF
