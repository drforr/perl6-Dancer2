use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 6;

use Dancer2::Core::Runner;

{
    my $runner = Dancer2::Core::Runner->new();
    isa_ok( $runner, 'Dancer2::Core::Runner' );

    is(
        $runner->environment,
        'development',
        'Default environment',
    );
}

{
    local $ENV{DANCER_ENVIRONMENT} = 'foo';
    my $runner = Dancer2::Core::Runner->new();
    isa_ok( $runner, 'Dancer2::Core::Runner' );
    is(
        $runner->environment,
        'foo',
        'Successfully set envinronment using DANCER_ENVIRONMENT',
    );
}

{
    local $ENV{PLACK_ENV} = 'bar';
    my $runner = Dancer2::Core::Runner->new();
    isa_ok( $runner, 'Dancer2::Core::Runner' );
    is(
        $runner->environment,
        'bar',
        'Successfully set environment using PLACK_ENV',
    );
}

done_testing;
EOF
