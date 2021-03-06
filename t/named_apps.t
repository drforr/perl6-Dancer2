use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Request::Common:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;

{
    package Foo;
    use Dancer2;

    hook before => sub { vars->{foo} = 'foo' };

    post '/foo' => sub {
        return vars->{foo} . 'foo' . vars->{baz};
    };
}

{
    package Bar;
    use Dancer2 appname => 'Foo'; # Add routes and hooks to Foo.

    hook before => sub { vars->{baz} = 'baz' };

    post '/bar' => sub {
        return vars->{foo} . 'bar' . vars->{baz};
    }
}

my $app = Dancer2->psgi_app;

test_psgi $app, sub {
    my $cb  = shift;
    for my $path ( qw/foo bar/ ) {
        my $res = $cb->( POST "/$path" );
        is $res->content, "foo${path}baz",
            "Got app content path $path";
    }
};

done_testing;
EOF
