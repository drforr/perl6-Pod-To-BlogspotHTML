use v6;
use Test;
use Pod::To::BlogspotHTML;

my $pod-counter = 0;
my $html;

#`(
=begin pod
=for comment
foo foo
bla bla    bla

This isn't a comment
=end pod

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
die $html;

like $html, /
1
/;
)

#`(
# from S26
=comment
This file is deliberately specified in Perl 6 Pod format

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
die $html;

like $html, /
1
/;
)

#`(
# this happens to break hilighting in some editors,
# so I put it at the end
=begin comment
foo foo
=begin invalid pod
=as many invalid pod as we want
===yay!
=end comment

#die $=pod[$pod-counter].perl;
$html = Pod::To::BlogspotHTML.render( $=pod[$pod-counter++] );
die $html;

like $html, /
1
/;
)

done-testing;

# vim: ft=perl6
