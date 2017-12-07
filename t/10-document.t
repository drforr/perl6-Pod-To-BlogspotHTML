use v6;
use Pod::To::BlogspotHTML;
use Test;

subtest 'Declarations', {

=begin pod
=NAME Pod::To::BlogspotHTML
=AUTHOR Alan Smithee
=VERSION 3.14.15
=TITLE Blogspot-ready HTML
=SUBTITLE Or How I Learned To Love The Coredump
=SYNOPSIS
Lorem ipsum, dolor sic amet
=DESCRIPTION
This module
=end pod

	my $html = Pod::To::BlogspotHTML.render( $=pod[0] );

	like $html, /
		'<h1 id="NAME">' NAME '</h1>'
		'<p>' 'Pod::To::BlogspotHTML' '</p>'
	/, 'NAME';
	like $html, /
		'<h1 id="SYNOPSIS">' SYNOPSIS '</h1>'
		'<p>' 'Lorem ipsum, dolor sic amet' '</p>'
	/, 'SYNOPSIS';
	like $html, /
		'<h1 id="DESCRIPTION">' DESCRIPTION '</h1>'
		'<p>' 'This module' '</p>'
	/, 'SYNOPSIS';
	like $html, /
		'<h1 id="AUTHOR">' AUTHOR '</h1>'
		'<p>' 'Alan Smithee' '</p>'
	/, 'AUTHOR';
	like $html, /
		'<h1 id="VERSION">' VERSION '</h1>'
		'<p>' '3.14.15' '</p>'
	/, 'VERSION';
	like $html, /
		'<h1 id="TITLE">' TITLE '</h1>'
		'<p>' 'Blogspot-ready HTML' '</p>'
	/, 'TITLE';
	like $html, /
		'<h1 id="SUBTITLE">' SUBTITLE '</h1>'
		'<p>' .+ 'Coredump' .* '</p>'
	/, 'SUBTITLE';
};

done-testing;

# vim: ft=perl6
