package SimpleMooseClass;

use Moose;

has 'a' => (
    is => 'ro',
    isa => 'Int',
    default => 1,
);

has 'b' => (
    is => 'ro',
    isa => 'Int',
    default => 2,
);

sub print_a {
    my $self = shift;
    print $self->a."\n";
}

1;

package ComplexMooseClass;

use Moose;

has 'a' => (
    is => 'ro',
    isa => 'Int',
    default => 1,
);

has 'b' => (
    is => 'ro',
    isa => 'Int',
    default => 2,
);

has 'simple' => (
    is => 'ro',
    isa => 'SimpleMooseClass',
    default => sub { return SimpleMooseClass->new(); },
);

has 'date' => (
    is => 'ro',
    isa => 'DateTime',
    default => sub { return DateTime->now(); },
);

sub print_a {
    my $self = shift;
    print $self->a."\n";
}

1;

package main;

use Test::More;
use Test::Exception;

use Data::Dumper;
use DateTime;
use MooseX::Simplify;

use SimpleMooseClass;
use ComplexMooseClass;

subtest 'simplify simple moose object' => sub {

    my $object = SimpleMooseClass->new();

    my $hash;
    lives_ok {
        $hash = moosex_simplify( $object );
    } 'Lives through simplify';

    if ( cmp_ok( ref($hash), 'eq', 'HASH', 'Got back a hashref' ) ) {
        note( Dumper($hash) );
        my @keys = keys %{$hash};
        cmp_ok( scalar(@keys), '==', 2, 'Hash has two entries' );
    }
};

subtest 'simplify complex moose object' => sub {

    my $object = ComplexMooseClass->new();

    my $hash;
    lives_ok {
        $hash = moosex_simplify( $object );
    } 'Lives through simplify';

    if ( cmp_ok( ref($hash), 'eq', 'HASH', 'Got back a hashref' ) ) {
        note( Dumper($hash) );
        my @keys = keys %{$hash};
        cmp_ok( scalar(@keys), '==', 4, 'Hash has four entries' );
        if ( cmp_ok( ref($hash->{simple}), 'eq', 'HASH', 'simple attribute is a hash' ) ) {
            @keys = keys %{$hash->{simple}};
            cmp_ok( scalar(@keys), '==', 2, 'simple object was hashified' );
        }
        my $today = DateTime->today->ymd;
        like( $hash->{date}, qr/$today/, 'Datetime converted to string' );
    }
};



done_testing;
