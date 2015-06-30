use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Test::Fatal:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 3;

use Dancer2::Core::Route;

my @no_leading_slash = ( 'no+leading+slash', '' );
my @leading_slash = ('/+leading+slash', '/', '//' );

subtest "no prefix, paths without a leading slash" => sub {
    for my $string ( @no_leading_slash ) {
        my $route;
        my $exception = exception {
            $route = Dancer2::Core::Route->new(
                regexp => $string,
                method => 'get',
                code   => sub {1},
            );
        };
        is( $exception, undef,
            "'$string' is a valid route pattern"
        );
        is( $route->spec_route, "/$string",
            "undef prefix prepends '/' to spec_route"
        );
    }
};

subtest "no prefix, paths with a leading slash" => sub {
    for my $string ( @leading_slash ) {
        my $route;
        my $exception = exception {
            $route = Dancer2::Core::Route->new(
                regexp => $string,
                method => 'get',
                code   => sub {1},
            );
        };
        is( $exception, undef,
            "'$string' is a valid route pattern"
        );
        is( $route->spec_route, $string,
            "undef prefix does not prepend '/' to spec_route"
        );
    }
};

subtest "prefix and paths append" => sub {
    my $prefix = '/prefix';
    for my $string ( @no_leading_slash, @leading_slash) {
        my $route;
        my $exception = exception {
            $route = Dancer2::Core::Route->new(
                regexp => $string,
                prefix => $prefix,
                method => 'get',
                code   => sub {1},
            );
        };
        is( $exception, undef,
            "'$prefix$string' is a valid route pattern"
        );
    }
};

done_testing;
EOF
