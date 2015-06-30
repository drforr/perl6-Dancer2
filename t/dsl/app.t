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
    package App;
    use Dancer2;
    get '/' => sub {
        my $app = app;
        ::isa_ok( $app, 'Dancer2::Core::App' );
        ::is( $app->name, 'App', 'Correct app name' );
    };
}

Plack::Test->create( App->to_app )->request( GET '/' );

done_testing;
EOF
