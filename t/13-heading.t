use v6;
use Pod::To::BlogspotHTML;
use Test;

=begin pod
=head1 Top-level heading
=head2 Second-level heading
=head3 Tertiary heading
=end pod

#die $=pod[0].perl;
my $html = Pod::To::BlogspotHTML.render( $=pod[0] );
#die $html;

like $html, /
	^ '<h1>' 'Top-level heading' '</h1>'
/, 'h1';
like $html, /
	'<h2>' 'Second-level heading' '</h2>'
/, 'h2';
like $html, /
	'<h3>' 'Tertiary heading' '</h3>'
/, 'h3';

done-testing;

# vim: ft=perl6
