use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use File::Spec:from<Perl5>;
use File::Basename:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 11;

{
    package App;
    use Moo;
    with 'Dancer2::Core::Role::HasLocation';
}

note 'Defaults:'; {
    my $app = App->new();
    isa_ok( $app, 'App' );
    can_ok( $app, qw<caller location> ); # attributes
    can_ok( $app, '_build_location'   ); # methods

    ok(
        $app->DOES('Dancer2::Core::Role::HasLocation'),
        'App consumes Dancer2::Core::Role::HasLocation',
    );

    my $path = File::Spec->catfile(qw<
        t classes Dancer2-Core-Role-HasLocation with.t
    >);

SKIP: {
    skip "### XXX Fix this later", 1 if $] < 6;
    is(
        File::Spec->canonpath( $app->caller ),
        $path,
        'Default caller',
    );
}

}

my $basedir = dirname( File::Spec->rel2abs(__FILE__) );

note 'With lib/ and bin/:'; {
    my $app = App->new(
        caller => File::Spec->catfile(
            $basedir, qw<FakeDancerDir fake inner dir fakescript.pl>
        )
    );

    isa_ok( $app, 'App' );

    my $location = $app->location;
    $location =~ s/\/$//;

    my $path = File::Spec->rel2abs(
        File::Spec->catdir(
            File::Spec->curdir,
            qw<t classes Dancer2-Core-Role-HasLocation FakeDancerDir>,
        )
    );

SKIP: {
    skip "### XXX Fix this later", 1 if $] < 6;
    is(
        $location,
        $path,
        'Got correct location with lib/ and bin/',
    );
}
}

note 'With .dancer file:'; {
    my $app = App->new(
        caller => File::Spec->catfile(
            $basedir, qw<FakeDancerFile script.pl>
        )
    );

    isa_ok( $app, 'App' );

    my $location = $app->location;

    my $path = File::Spec->rel2abs(
        File::Spec->catdir(
            File::Spec->curdir,
            qw<t classes Dancer2-Core-Role-HasLocation FakeDancerFile>,
        )
    );

SKIP: {
    skip "### XXX Fix this later", 1 if $] < 6;
    is( $location, $path, 'Got correct location with .dancer file' );
}
}

note 'blib/ ignored:'; {
    my $app = App->new(
        caller => File::Spec->catfile(
            $basedir, qw<FakeDancerDir blib lib fakescript.pl>
        )
    );

    isa_ok( $app, 'App' );

    my $location = $app->location;
    $location =~ s/\/$//;

    my $path = File::Spec->rel2abs(
        File::Spec->catdir(
            File::Spec->curdir,
            qw<t classes Dancer2-Core-Role-HasLocation FakeDancerDir>,
        )
    );

SKIP: {
    skip "### XXX Fix this later", 1 if $] < 6;
    is( $location, $path, 'blib/ dir is ignored' );
}
}
done_testing;
EOF
