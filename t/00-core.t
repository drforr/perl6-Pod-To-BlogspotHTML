use v6;
use Pod::To::BlogspotHTML;
use Test;

plan 1;

#############################################################################

=begin pod
=end pod

ok Pod::To::BlogspotHTML.render( $=pod[0] );

done-testing;

# vim: ft=perl6
