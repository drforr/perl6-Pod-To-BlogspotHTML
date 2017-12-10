use v6;
use Pod::To::BlogspotHTML;
use Test;

=begin pod
  my $code = "Hello world!";
=begin code
my $code = "Hello cruel world!";
=end code
=end pod

#die $=pod[0].perl;
my $html = Pod::To::BlogspotHTML.render( $=pod[0] );
#die $html;

like $html, /
	^ '<code>' .+ 'Hello world!' .+ '</code>'
/, 'Code';
like $html, /
	'</code>' '<code>'
/, 'Intermediate';
like $html, /
	'<code>' .+ 'Hello cruel world!' .+ '</code>'
/, 'Aussie';

done-testing;

# vim: ft=perl6
