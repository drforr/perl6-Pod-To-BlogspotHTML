use v6;
use Pod::To::BlogspotHTML;
use Test;

=begin pod
=item I. 1
=item II. 2
=item2 A. 3
=item2 B. 4
=item III. 5
=item2 A. 6
=item3 1. 7
=end pod

#die $=pod[0].perl;
my $html = Pod::To::BlogspotHTML.render( $=pod[0] );
#die $html;

like $html, / ^ '<ul>' '<li>' 'I. 1' '</li>' /, 'start top';
like $html, /
	'<li>' 'I. 1' '</li>'
/, 'I';
like $html, /
	'<li>' 'II. 2' '</li>'
/, 'II';
subtest 'secondary #1', {
	like $html, /
		'<li>' 'A. 3' '</li>'
	/, 'A';
	like $html, /
		'<li>' 'B. 4' '</li>'
	/, 'B';
};
like $html, /
	'<li>' 'III. 5' '</li>'
/, 'III';
subtest 'secondary #2', {
	like $html, /
		'<li>' 'A. 6' '</li>'
	/, 'A';
	subtest 'tertiary #1', {
		like $html, /
			'<li>' '1. 7' '</li>'
		/, '1';
	};
};
like $html, / '1. 7' '</li>' '</ul>' /, 'end top';

done-testing;

# vim: ft=perl6
