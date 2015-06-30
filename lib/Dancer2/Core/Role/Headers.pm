# ABSTRACT: Role for handling headers

package Dancer2::Core::Role::Headers;
$Dancer2::Core::Role::Headers::VERSION = '0.160003';
use Moo::Role;
use Dancer2::Core::Types;
use HTTP::Headers::Fast;
use Scalar::Util qw(blessed);

has headers => (
    is     => 'rw',
    isa    => AnyOf[ InstanceOf ['HTTP::Headers::Fast'], InstanceOf ['HTTP::Headers'] ],
    lazy   => 1,
    coerce => sub {
        my ($value) = @_;
        # HTTP::Headers::Fast reports that it isa 'HTTP::Headers',
        # but there is no actual inheritance.
        return $value if blessed($value) && $value->isa('HTTP::Headers');
        HTTP::Headers::Fast->new( @{$value} );
    },
    default => sub {
        HTTP::Headers::Fast->new();
    },
    handles => [qw<header push_header>],
);

sub headers_to_array {
    my $self = shift;

    my $headers = [
        map {
            my $k = $_;
            map {
                my $v = $_;
                $v =~ s/^(.+)\r?\n(.*)$/$1\r\n $2/;
                ( $k => $v )
            } $self->headers->header($_);
          } $self->headers->header_field_names
    ];

    return $headers;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dancer2::Core::Role::Headers - Role for handling headers

=head1 VERSION

version 0.160003

=head1 DESCRIPTION

When a class consumes this role, it gets a C<headers> attribute and all the
helper methods to manipulate it.

This logic is contained in this role in order to reuse the code between
L<Dancer2::Core::Response> and L<Dancer2::Core::Request> objects.

=head1 ATTRIBUTES

=head2 headers

The attribute that store the headers in a L<HTTP::Headers::Fast> object.

That attribute coerces from ArrayRef and defaults to an empty L<HTTP::Headers::Fast>
instance.

=head1 METHODS

=head2 header($name)

Return the value of the given header, if present. If the header has multiple
values, returns the list of values if called in list context, the first one
if in scalar context.

=head2 push_header

Add the header no matter if it already exists or not.

    $self->push_header( 'X-Wing' => '1' );

It can also be called with multiple values to add many times the same header
with different values:

    $self->push_header( 'X-Wing' => 1, 2, 3 );

=head2 headers_to_array

Convert the C<headers> attribute to an ArrayRef.

=head1 AUTHOR

Dancer Core Developers

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Alexis Sukrieh.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
