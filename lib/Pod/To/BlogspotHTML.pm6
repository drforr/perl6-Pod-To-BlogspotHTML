use v6;

=begin pod

=head1 Pod::To::BlogspotHTML

Generate a bare-bones HTML fragment from your Pod6 code suitable for pasting into the Blogspot HTML editor.

Subclass this to do your own HTML styling.

=head1 Synopsis

    use Pod::To::BlogspotHTML;

    say Pod::To::BlogspotHTML.render( $=[0] );;

=head1 Documentation

=end pod

use Pod::TreeWalker;
use Pod::TreeWalker::Listener;

role Pod::To::BlogspotHTML::Mixins {
	method Bold( $node ) {
		qq[<b>{$node.contents}</b>];
	}
	method Code( $node ) {
		qq[<code>{$node.contents}</code>];
	}
	method Entity( $node ) {
		given $node.contents {
			when / ^ \d+ $ / {
				$node.contents.chr
			}
			when / ^ 0<[bB]> (.+) $ / {
				$0.base(2).chr
			}
			when 'laquo' { '«' } # XXX
			default {
				$node.contents
#die "missing Entity"
			}
		}
	}
	method Italic( $node ) {
		qq[<i>{$node.contents}</i>];
	}
	method Keyboard( $node ) {
		qq[<kbd>{$node.contents}</kbd>];
	}
	method Link( $node ) {
		qq[<a href="{$node.meta}">{$node.contents}</a>];
	}
	method Notes( $node ) {
		$node.contents;
	}
	method Terminal( $node ) {
		qq[<XXX>{$node.contents}</XXX>];
	}
	method Underline( $node ) {
		qq[<u>{$node.contents}</u>];
	}
	method Zeroed-Out( $node ) {
		qq[<!-- {$node.contents} -->];
	}
	# XXX This probably should go into @.meta, that can be decided later.
	method Meta( $node ) {
		my $name = $node.name;
		my $contents = $node.contents[0].contents[0];
		qq[<h1 id="$name">$name</h1><p>$contents</p>\n]
	}
}

class Pod::To::BlogspotHTML {
	also does Pod::To::BlogspotHTML::Mixins;
	also does Pod::TreeWalker::Listener;

	constant META-TAGS =
		< NAME AUTHOR VERSION TITLE SUBTITLE SYNOPSIS DESCRIPTION >;

	has %.meta;
	has $.preamble;
	has $.content;
	has $.postamble;

#multi method start (Pod::Block:D $node) {
#    return True;
#}
#
#multi method end (Pod::Block:D $node) {
#    return True;
#}
#
#multi method start (Pod::Block::Code $node) {  }
#multi method end (Pod::Block::Code $node) {  }
	multi method start ( Pod::Block::Comment $node ) {
		self.Zeroed-Out( $node );
	}
#multi method end (Pod::Block::Comment $node) {  }
#multi method start (Pod::Block::Declarator $node) {  }
#multi method end (Pod::Block::Declarator $node) {  }

	multi method start( Pod::Block::Named $node ) {
		given $node.name {
			when META-TAGS.any {
				$!preamble ~= self.Meta( $node );
			}
			when 'SYNOPSIS' {
die $node;
			}
			when 'pod' {
				# Maybe <div>.. here
			}
			default {
			}
		}
		True;
	}
	multi method end( Pod::Block::Named $node ) {
		given $node.name {
			when 'pod' {
				# Maybe </div> here...
			}
			default {
			}
		}
	}
#multi method end (Pod::Block::Named $node) {  }
	multi method start (Pod::Block::Para $node) {
		$!content ~= qq[<p>{$node.contents}</p>];
	}
	multi method end (Pod::Block::Para $node) {
	}
#multi method start (Pod::Block::Table $node) {  }
#multi method end (Pod::Block::Table $node) {  }
	multi method start (Pod::FormattingCode $node) {
		given $node.type {
			when 'B' {
				$!content ~= self.Bold( $node );
			}
			when 'C' {
				$!content ~= self.Code( $node );
			}
			when 'E' {
				$!content ~= self.Entity( $node );
			}
			when 'I' {
				$!content ~= self.Italic( $node );
			}
			when 'K' {
				$!content ~= self.Keyboard( $node );
			}
			when 'L' {
				$!content ~= self.Link( $node );
			}
			when 'N' {
				$!postamble ~= self.Notes( $node );
			}
			when 'T' {
				$!content ~= self.Terminal( $node );
			}
			when 'U' {
				$!content ~= self.Underline( $node );
			}
			when 'Z' {
				$!content ~= self.Zeroed-Out( $node );
			}
			default {
				die "Unknown formatting code '{$node.type}'"
			}
		}
	}
	multi method end (Pod::FormattingCode $node) {
	}
#multi method start (Pod::Heading $node) {  }
#multi method end (Pod::Heading $node) {  }
#multi method start (Pod::Item $node) {  }
#multi method end (Pod::Item $node) {  }
#multi method start (Pod::Raw $node) {  }
#multi method end (Pod::Raw $node) {  }

#method start-list (Int :$level, Bool :$numbered) { }
#method end-list (Int :$level, Bool :$numbered) { }
#method table-row (Array $row) { }
#method config (Pod::Config $node) {  }

	method render( $pod ) {
		my $listener = self.new;
		my $walker = Pod::TreeWalker.new( :listener( $listener ) );
		$walker.walk-pod( $pod );
#say $walker.text-contents-of( $pod );
		my $final-content;
#say $listener.perl;

		$final-content ~= $listener.preamble if $listener.preamble;
		$final-content ~= $listener.content if $listener.content;
		$final-content ~= $listener.postamble if $listener.postamble;
		$final-content;
	}
}

# vim: ft=perl6
