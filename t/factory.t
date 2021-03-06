use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Test::Fatal:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;

use Dancer2::Core;
use Dancer2::Core::Factory;

is Dancer2::Core::camelize('foo_bar_baz'), 'FooBarBaz';
is Dancer2::Core::camelize('FooBarBaz'),   'FooBarBaz';

like(
    exception { my $l = Dancer2::Core::Factory->create( unknown => 'stuff' ) },
    qr{Unable to load class for Unknown component Stuff:},
    'Failure to load nonexistent class',
);

my $l = Dancer2::Core::Factory->create( logger => 'console' );
isa_ok $l, 'Dancer2::Logger::Console';

done_testing;
EOF
