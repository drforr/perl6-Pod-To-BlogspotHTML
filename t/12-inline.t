use v6;
use Pod::To::BlogspotHTML;
use Test;

subtest 'all inline, no nesting', {

=begin pod
B<Bold inline>, C<Code>, D<Definition>, E<171> E<0b1011> E<laquo>, I<Italic>, K<Keyboard>, L<Link|http://example.com>, N<Footnote>, R<Replaceable>, T<Terminal output>, U<Underline>, Z<Zeroed-Out>
=end pod

	#die $=pod[0].perl;
	my $html = Pod::To::BlogspotHTML.render( $=pod[0] );
	#die $html;

	like $html, /
		^ '<b>' 'Bold inline' '</b>'
	/, 'Bold';
	like $html, /
		'<code>' 'Code' '</code>'
	/, 'Code';
	# XXX Where is Definition documented? Is it?
	like $html, /
		'<defn>' 'Definition' '</defn>'
	/, 'Definition'; # XXX break out?
	#like $html, / ', «,' /, 'Entity';
	subtest 'Entity', {
		like $html, / '&#171;' /, 'decimal';
		like $html, / '&#11;' /, 'binary converted';
		like $html, / '&laquo;' /, 'entity';
	};
	like $html, /
		'<i>' 'Italic' '</i>'
	/, 'Italic';
	like $html, /
		'<kbd>' 'Keyboard' '</kbd>'
	/, 'Keyboard';
	like $html, /
		'<a href="http://example.com">Link</a>'
	/, 'Link';
	# Note
	# XXX Where is Replaceable documented? Is it?
	like $html, /
		'<var>' 'Replaceable' '</var>'
	/, 'Replaceable';
	# Terminal output
	like $html, /
		'<u>' 'Underline' '</u>'
	/, 'Underline';
	like $html, /
		'<!--' \s* 'Zeroed-Out' \s* '-->'
	/, 'Zeroed-Out';
};

=begin pod
=item Some I<Italic> text
=end pod

subtest 'inline nesting', {
	#die $=pod[1].perl;
	my $html = Pod::To::BlogspotHTML.render( $=pod[1] );
	#die $html;

	like $html, /
		'<li>'
			'Some' \s+ '<i>' 'Italic' '</i>' \s+ 'text'
		'</li>'
	/, 'item with inline italics';
};

done-testing;

# vim: ft=perl6
