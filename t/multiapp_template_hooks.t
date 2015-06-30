use v6;
use Inline::Perl5;
use Test::More:from<Perl5>;

EVAL q:to/EOF/, :lang<perl5>;
plan tests => 32;
#!perl

use strict;
use warnings;

use File::Spec;
use File::Basename 'dirname';
use Plack::Test;
use HTTP::Request::Common;

# XXX JMG Added t/ here
my $views = File::Spec->rel2abs(
    File::Spec->catfile( dirname(__FILE__), 't/views' )
);

my %called_hooks = ();
my $hook_name    = 'engine.template.before_render';

{
    package App1;
    use Dancer2;

    set views => $views;

    hook before => sub { $called_hooks{'App1'}{'before'}++ };

    hook before_template => sub {
        my $tokens = shift;
        ::isa_ok( $tokens, 'HASH', '[App1] Tokens' );

        my $app = app;

        ::isa_ok( $app, 'Dancer2::Core::App', 'Got app object inside App1' );

        # we accept anything that goes to App1, even if not only to App1
        ::like(
            $tokens->{'request'}->param('to'),
            qr/^App1/,
            'Request reached to correct App (App1)',
        );

        ::is(
            scalar @{ $app->template_engine->hooks->{$hook_name} },
            1,
            'App1 has a single before_template hook defined',
        );

        $tokens->{'myname'} = 'App1';
        $called_hooks{'App1'}{'before_template'}++;
    };

    get '/' => sub {
        template beforetemplate => { it => 'App1' }, { layout => undef };
    };
}

{
    package App2;
    use Dancer2;

    set views => $views;

    hook before => sub { $called_hooks{'App2'}{'before'}++ };

    hook before_template => sub {
        my $tokens = shift;
        ::isa_ok( $tokens, 'HASH', '[App2] Tokens' );

        my $app = app;
        ::isa_ok( $app, 'Dancer2::Core::App', 'Got app object inside App2' );

        ::is(
            $tokens->{'request'}->param('to'),
            'App2',
            'Request reached to correct App (App2)',
        );

        ::is(
            scalar @{ $app->template_engine->hooks->{$hook_name} },
            1,
            'App2 has a single before_template hook defined',
        );

        $tokens->{'myname'} = 'App2';
        $called_hooks{'App2'}{'before_template'}++;
    };

    get '/' => sub {
        template beforetemplate => { it => 'App2' }, { layout => undef };
    };

    get '/2' => sub {
        template beforetemplate => { it => 'App2' }, { layout => undef };
    };
}

note 'Check App1 only calls first hook, not both'; {
    # clear
    %called_hooks = ();

    my $app = App1->to_app;
    isa_ok( $app, 'CODE', 'Got app for test' );

    test_psgi $app, sub {
        my $cb  = shift;
        my $res = $cb->( GET '/?to=App1' );

        is( $res->code, 200, '[GET /] Successful' );

        is(
            $res->content,
            "App is App1, again, it is App1\n",
            '[GET /] Correct content',
        );

        is_deeply(
            \%called_hooks,
            { App1 => { before => 1, before_template => 1 } },
            'Only App1\'s before_template hook was called',
        );
    };
}

note 'Check App2 only calls second hook, not both'; {
    # clear
    %called_hooks = ();

    my $app = App2->to_app;
    isa_ok( $app, 'CODE', 'Got app for test' );

    test_psgi $app, sub {
        my $cb  = shift;
        my $res = $cb->( GET '/?to=App2' );

        is( $res->code, 200, '[GET /] Successful' );

        is(
            $res->content,
            "App is App2, again, it is App2\n",
            '[GET /] Correct content',
        );

        is_deeply(
            \%called_hooks,
            { App2 => { before => 1, before_template => 1 } },
            'Only App2\'s before_template hook was called',
        );
    };
}

note 'Check both apps only call the first hook (correct app), not both'; {
    # clear
    %called_hooks = ();

    my $app = Dancer2->psgi_app;
    isa_ok( $app, 'CODE', 'Got app for test' );

    test_psgi $app, sub {
        my $cb  = shift;
        my $res = $cb->( GET '/?to=App1:App2' );

        is( $res->code, 200, '[GET /] Successful' );

        is(
            $res->content,
            "App is App1, again, it is App1\n",
            '[GET /] Correct content',
        );

        is_deeply(
            \%called_hooks,
            { App1 => { before => 1, before_template => 1 } },
            'Only App1\'s before_template hook was called (full PSGI app)',
        );
    };
}

note 'Check both apps only call the second hook (correct app), not both'; {
    # clear
    %called_hooks = ();

    my $app = Dancer2->psgi_app;
    isa_ok( $app, 'CODE', 'Got app for test' );

    test_psgi $app, sub {
        my $cb  = shift;
        my $res = $cb->( GET '/2?to=App2' );

        is( $res->code, 200, '[GET /2] Successful' );

        is(
            $res->content,
            "App is App2, again, it is App2\n",
            '[GET /2] Correct content',
        );

        # INFO: %called_hooks does not contain any counts for App1;
        #       no routes match, so no hooks are called.
        is_deeply(
            \%called_hooks,
            {
                App2 => { before => 1, before_template => 1 },
            },
            'Only App2\'s before_template hook was called (full PSGI app)',
        );
    };
}

done_testing;
EOF
