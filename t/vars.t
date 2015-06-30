use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
use strict;
use warnings;
use Plack::Test;
use HTTP::Request::Common;

plan tests => 3;

{
    use Dancer2;

    hook before => sub {
        var( "xpto" => "foo" );
        vars->{zbr} = 'ugh';
    };

    get '/bar' => sub {
        var("xpto");
    };

    get '/baz' => sub {
        vars->{zbr};
    };
}

my $app = __PACKAGE__->to_app;
is( ref $app, 'CODE', 'Got app' );

test_psgi $app, sub {
    my $cb = shift;

    is( $cb->( GET '/bar' )->content, 'foo', 'foo' );
    is( $cb->( GET '/baz' )->content, 'ugh', 'ugh' );
};
done_testing;
EOF
