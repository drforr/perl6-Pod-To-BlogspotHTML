use v6;
use Pod::To::BlogspotHTML;
use Test;

=begin foo
Lorem ipsum

Sed ut perspiciatis
=end foo

#die $=pod[0].perl;
my $html = Pod::To::BlogspotHTML.render( $=pod[0] );
#die $html;

like $html, / '<section>' '<h1>' 'foo' '</h1>' '<p>' 'Lorem ipsum' '</p>' '<p>' 'Sed ut perspiciatis' '</p>' '</section>' /, 'start section';

done-testing;

# vim: ft=perl6
