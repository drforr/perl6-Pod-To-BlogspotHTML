use v6;
use Pod::To::BlogspotHTML;
use Test;

=begin pod
=begin input
Keyboard input
=end input
=begin output
Terminal output
=end output
=end pod

#die $=pod[0].perl;
my $html = Pod::To::BlogspotHTML.render( $=pod[0] );

subtest 'Input', {
	like $html, / '<kbd>' 'Keyboard input' '</kbd>' /, 'HTML';
	unlike $html, / '</kbd>' \s* '<p>' /, 'No para after <kbd>';
};
like $html, / '</kbd>' '<samp>' /, 'Intermediate';
subtest 'Output', {
	like $html, / '<samp>' 'Terminal output' '</samp>' /, 'HTML';
	unlike $html, / '</samp>' \s* '<p>' /, 'No para after <samp>';
};

done-testing;

# vim: ft=perl6
