use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Test::Fatal:from<Perl5>;
use Test::Memory::Cycle:from<Perl5>;
use Plack::Test:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;

{

    package MyApp::Cycles;
    use Dancer2;

    set auto_page => 1;
    set serializer => 'JSON';

    get '/**' => sub {
        return { hello => 'world' };
    };
}

my $app = MyApp::Cycles->to_app;

my $runner = Dancer2->runner;
memory_cycle_ok( $runner, "runner has no memory cycles" );
memory_cycle_ok( $app, "App has no memory cycles" );

done_testing;
EOF
