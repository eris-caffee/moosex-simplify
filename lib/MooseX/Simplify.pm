package MooseX::Simplify;

use strict;
use warnings;

our $VERSION = '1.00';
our @ISA = qw( Exporter );
our @EXPORT = qw/ moosex_simplify /;

use Exporter;
use Moose::Util qw();

sub moosex_simplify {
    my $object = shift;

    my $hash = {};

    eval {
        my $metaclass = Moose::Util::find_meta( $object );
        if ( $metaclass ) {
            my @attributes = $metaclass->get_all_attributes();
            for my $attr ( @attributes ) {
                my $name = $attr->name;
                my $value = $object->$name;
                if ( ref($value) eq 'HASH'
                         or ref($value) eq 'ARRAY'
                         or ref($value) eq '' ) {
                    $hash->{$name} = $value;
                }
                else {
                    $hash->{$name} = moosex_simplify( $value );
                }

            }
        }
        else {
            # Not a Moose class.  Try a simple stringification.
            $hash = eval { "" . $object };
        }
    };
    # Ignore errors here.

    return $hash;
}


1;

=pod

=head1 NAME

MooseX::Simplify - A simple data converter for convenient debugging.

=head1 VERSION

Version 1.00

=head1 SYNOPSIS

The moosex_simplify() function returns a simplified representation of a Moose object as a hash of the attributes.  Attributes that are not themselves Moose objects are stringified.

Example:

        use NonMooseClass;
        use MooseClass;
        use Data::Dumper;

        my $obj = MooseClass->new( a => 1, b => NonMooseClass->new() );
        print Dumper( moosex_simplfiy( $obj ) );



        $VAR1 => {
                'a' => 1,
                'b' => 'NonMooseClass=HASH(0x12345678)'
        };

=head1 DESCRIPTION

Have you ever wanted to quickly print out the contents of a Moose object, say for debugging purposes?  You've probably tried using Data::Dumper only to discover that some of the attributes are non-Moose classes that have very complex structures.  Your intent of quickly seeing the attribute values is overwhelmed by all the dreck in the composed classes.

This simple module helps with that.  It returns a hash representation of a Moose object with only the object attributes represented in a simplified form.  For example consider this class:

        package ComplexMooseClass;

        use Moose;
        use DateTime;

        has 'a' => (
            is => 'ro',
            isa => 'Int',
            default => 1,
        );

        has 'date' => (
            is => 'ro',
            isa => 'DateTime',
            default => sub { return DateTime->now(); },
        );

        1;

That DateTime object is going to blow up the size of the print and make searching for the value of 'a' involve lots of scrolling and squinting of the eyes.

Now try it like this:

        use MooseX::Hashify;
        use Data::Dumper;
        my $obj = ComplexMooseClass->new();
        print Dumper(moosex_hashify($obj));

Your data print now looks like this:

        $VAR1 = {
                  'a' => 1,
                  'date' => '2019-02-14T03:37:22'
        };

Simple.  Easy to read.

=head1 HOW IT WORKS

MooseX::Simplify uses the Moose Meta Object Protocol to get the attributes of the object and walk through them.  For attributes that are hases, arrays, or scalars their values are used directly.  Attributes that are themselves Moose objects are examined recursively.  Attributes that are non-moose objects are stringified, which is why the DateTime object in the example above prints so nicely.

If you attempt to examine a non-Moose object that does not support stringification, you get back a standard type string like

        NonMooseObject=HASH(0x2ea6f70)

=head1 EXPORTED FUNCTIONS

=head2 moosex_simplify

Takes an object as it's sole argument.  Returns a simplified hash representation of the object (or a string if the object is not a Moose object).

=head1 BUGS

Please report bugs on GitHub: https://github.com/eris-caffee/moosex-simplify

=head1 LICENSE

Copyright (c) 2019, Sarah Eris Horsely Caffee
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut
