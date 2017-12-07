use v6;
use Pod::To::BlogspotHTML;
use Test;

=begin pod
B<Bold inline>, C<Code>, E<laquo>, I<Italic>, K<Keyboard>, L<Link|http://example.com>, N<Footnote>, T<Terminal output>, U<Underline>, Z<Zeroed-Out>
=end pod

#die $=pod[0].perl;
my $html = Pod::To::BlogspotHTML.render( $=pod[0] );

like $html, / '<b>' 'Bold inline' '</b>' /, 'Bold';
like $html, / '<code>' 'Code' '</code>' /, 'Code';
#like $html, / ', «,' /, 'Entity';
like $html, / '<i>' 'Italic' '</i>' /, 'Italic';
like $html, / '<kbd>' 'Keyboard' '</kbd>' /, 'Keyboard';
like $html, / '<a href="http://example.com">Link</a>' /, 'Link';
# Note
# Terminal output
like $html, / '<u>' 'Underline' '</u>' /, 'Underline';
like $html, /:s '<!--' 'Zeroed-Out' '-->' /, 'Zeroed-Out';

done-testing;

# vim: ft=perl6
