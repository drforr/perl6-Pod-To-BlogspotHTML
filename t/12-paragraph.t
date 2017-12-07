use v6;
use Pod::To::BlogspotHTML;
use Test;

subtest 'Paragraph', {

=begin pod
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec a massa est. Integer ut semper metus, quis elementum nunc. Vivamus et mattis eros, quis varius velit. Cras elementum non ante quis semper. Vivamus vitae quam non leo ultrices elementum. Duis at faucibus orci. Donec vitae tincidunt est. In hac habitasse platea dictumst. Nulla eu neque pretium, eleifend turpis et, consequat turpis. Maecenas sollicitudin consequat lacinia. Praesent elementum purus eget risus pharetra convallis. Praesent accumsan turpis risus, sit amet pellentesque erat ultricies id. Vivamus condimentum enim purus, id aliquet turpis dictum lacinia. Ut bibendum ligula in justo ullamcorper, sed vehicula risus dapibus. Nunc ac dapibus erat. Maecenas id orci tortor.

Nulla ullamcorper, risus vitae aliquet commodo, leo libero accumsan nibh, non placerat erat dolor eu sem. Nunc congue semper ex vitae pulvinar. Mauris a lorem at arcu consectetur elementum ac at felis. Phasellus consectetur rhoncus risus, sit amet varius turpis pharetra eu. Duis gravida dignissim purus vitae accumsan. Proin luctus justo felis, sit amet tempor mi finibus id. Ut lacinia sodales nisl, eu tristique diam volutpat nec. Vivamus maximus lacinia lorem et hendrerit. Sed vestibulum id ex ut aliquet. Cras ultrices neque at blandit tincidunt.
=end pod

#die $=pod[0].perl;
	my $html = Pod::To::BlogspotHTML.render( $=pod[0] );

	like $html, /
		'<p>' 'Lorem ipsum' .+ '</p>'
		'<p>' 'Nulla ullamcorper' .+ '</p>'
	/, 'two unbroken paragraphs';
};

done-testing;

# vim: ft=perl6
