use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;
use Plack::Test:from<Perl5>;
use HTTP::Request::Common:from<Perl5>;
use File::Spec:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;

use File::Basename 'dirname';

eval { require Template; Template->import(); 1 }
  or plan skip_all => 'Template::Toolkit probably missing.';

# XXX JMG had to modify path
my $views =
  File::Spec->rel2abs( File::Spec->catfile( dirname(__FILE__), 't/views' ) );

{

    package Foo;

    use Dancer2;
    set session => 'Simple';

    set views    => $views;
    set template => "template_toolkit";
    set foo      => "in settings";

    get '/view/:foo' => sub {
        var     foo => "in var";
        session foo => "in session";
        template "tokens";
    };
}

my $version = Dancer2->VERSION;
my $expected = "perl_version: $]
dancer_version: ${version}
settings.foo: in settings
params.foo: 42
session.foo in session
vars.foo: in var";

my $app = Foo->to_app;
is( ref $app, 'CODE', 'Got app' );

test_psgi $app, sub {
    my $cb = shift;

    like(
        $cb->( GET '/view/42' )->content,
        qr{$expected},
        'Response contains all expected tokens',
    );
};

done_testing;
EOF
