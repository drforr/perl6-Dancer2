use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 3;
use strict;
use warnings;

{
    package Handler;
    use Moo;
    with 'Dancer2::Core::Role::Handler';
    sub register {}
}

my $handler = Handler->new;
isa_ok( $handler, 'Handler' );
can_ok( $handler, qw<app>   ); # attributes
ok(
    $handler->DOES('Dancer2::Core::Role::Handler'),
    'Handler consumes Dancer2::Core::Role::Handler',
);

done_testing;
EOF
