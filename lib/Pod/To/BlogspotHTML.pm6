use v6;

=begin pod

=head1 Pod::To::BlogspotHTML

Generate a bare-bones HTML fragment from your Pod6 code suitable for pasting into the Blogspot HTML editor.

Subclass this to do your own HTML styling.

=head1 Synopsis

    use Pod::To::BlogspotHTML;

    say Pod::To::BlogspotHTML.render( $=[0] );;

=head1 Documentation

The methods you probably want to override are all declared as part of the L<Pod::To::BlogspotHTML::Mixins> role. 'Mixins' is probably a misnomer, but I just needed a way to separate them from the main code. Most of them get the original L<Pod::TreeWalker> node, so most of the time C<$node.contents> is what you'll want to work with.

I'm hiding a bit of the Pod structure here as well, look for example at the C<Heading> method. The outer object contains the nesting level, and there's an innerL<Pod::Block::Para> object inside the C<$node.contents> array that has the actual heading content, and I unpack that for you.

You'll be a bit at the mercy of L<Pod::TreeWalker> as I'm just passing the raw objects to these methods, but I might try to shield some of the method calls, if only for a bit more consistency. Right now pretty much every one of the C<Bold>, C<Italic>, etcetera methods get a different sort of object, but since I'm not (at the moment - 2017-12-08) sure what varieties of data that can unpack to, I'm just going to leave that generic and untouched. This may change.

=head1 METHODS

=item Bold( Pod::FormattingCode $node )

Called whenever a C<B<>> formatting code is encountered in the Pod tree. 

=item Code-Inline( Pod::FormattingCode $node )

Called whenever a C<C<>> inline declaration is encountered.

=item Code-Block( Pod::Block::Code $node )

Called whenever a paragraph of code (C<=begin code>..C<=end code>) is encountered. The basic HTML generated doesn't change, but you may want to distinguish between the two things.

=item Definition( Pod::FormattingCode $node )

Called whenever a C<D<>> inline declaration is encountered. This doesn't appear to be documented, at least on the main page as of 2017-12-08, but it may be somewhere in the wild.

=item Entity( Pod::FormattingCode $node )

Called whenever a C<E<>> inline declaration is encountered.

=item Heading( Pod::Heading $node )

Called whenever a C<=head1> through C<=headN> declaration is encountered.

=end pod

use Pod::TreeWalker;
use Pod::TreeWalker::Listener;

role Pod::To::BlogspotHTML::Mixins {
	method Bold( $node ) {
		qq[<b>{$node.contents}</b>];
	}
	method Code-Block( $node ) {
		qq[<code>{$node.contents}</code>];
	}
	method Code-Inline( $node ) {
		qq[<code>{$node.contents}</code>];
	}
	# XXX Is this documented? Is this even a thing?
	method Definition( $node ) {
		qq[<defn>{$node.contents}</defn>];
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
	method Heading( $node ) {
		qq[<h{$node.level}>{$node.contents[0].contents[0]}</h{$node.level}>];
	}
	method Item( $node ) {
		qq[<li>{$node.contents[0].contents[0]}</li>];
	}
	method Italic( $node ) {
		qq[<i>{$node.contents}</i>];
	}
	method List-Start( Int $level, Bool $numbered ) {
		$numbered ?? qq[<ol>] !! qq[<ul>];
	}
	method List-End( Int $level, Bool $numbered ) {
		$numbered ?? qq[</ul>] !! qq[</ul>];
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
	method Para( $node ) {
		qq[<p>{$node.contents}</p>];
	}
	# XXX Is this documented? Is this even a thing?
	method Replaceable( $node ) {
		qq[<var>{$node.contents}</var>];
	}
	method Section-Start( $node ) {
		qq[<section><h1>{$node.name}</h1>];
	}
	method Section-End( $node ) {
		qq[</section>];
	}
	method Terminal( $node ) {
		qq[<samp>{$node.contents}</samp>];
	}
	method Underline( $node ) {
		qq[<u>{$node.contents}</u>];
	}
	method Zeroed-Out( $node ) {
		qq[<!-- {$node.contents} -->];
	}
	# XXX This probably should go into @.meta, that can be decided later.
	method Meta( $node ) {
		qq[<h1 id="{$node.name}">{$node.name}</h1><p>{$node.contents[0].contents[0]}</p>];
	}
}

class Pod::To::BlogspotHTML {
	also does Pod::To::BlogspotHTML::Mixins;
	also does Pod::TreeWalker::Listener;

	constant META-TAGS =
		< NAME AUTHOR VERSION TITLE SUBTITLE SYNOPSIS DESCRIPTION >;

	has %.meta;
	has $.preamble;
	has $.contents;
	has $.postamble;

#multi method start (Pod::Block:D $node) {
#    return True;
#}
#
#multi method end (Pod::Block:D $node) {
#    return True;
#}
#
	multi method start ( Pod::Block::Code $node ) {
		$!contents ~= self.Code-Block( $node );
	}
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
			when 'input' {
				$!contents ~= self.Keyboard(
					$node.contents[0]
				);
				return False; # Bail out to skip the nested para
			}
			when 'output' {
				$!contents ~= self.Terminal(
					$node.contents[0]
				);
				return False; # Bail out to skip the nested para
			}
			when 'pod' {
				# For the moment, do nothing.
			}
			default {
				$!contents ~= self.Section-Start( $node );
			}
		}
		True;
	}
	multi method end (Pod::Block::Named $node) {
		given $node.name {
			when 'pod' {
				# For the moment, do nothing.
			}
			default {
				$!contents ~= self.Section-End( $node );
			}
		}
		True;
	}
	multi method start (Pod::Block::Para $node) {
		$!contents ~= self.Para( $node );
	}
#multi method end (Pod::Block::Para $node) { }
#multi method start (Pod::Block::Table $node) {  }
#multi method end (Pod::Block::Table $node) {  }
	multi method start (Pod::FormattingCode $node) {
		given $node.type {
			when 'B' { $!contents ~= self.Bold( $node ); }
			when 'C' { $!contents ~= self.Code-Inline( $node ); }
			when 'D' { $!contents ~= self.Definition( $node ); }
			when 'E' { $!contents ~= self.Entity( $node ); }
			when 'I' { $!contents ~= self.Italic( $node ); }
			when 'K' { $!contents ~= self.Keyboard( $node ); }
			when 'L' { $!contents ~= self.Link( $node ); }
			when 'N' { $!postamble ~= self.Notes( $node ); }
			when 'R' { $!contents ~= self.Replaceable( $node ); }
			when 'T' { $!contents ~= self.Terminal( $node ); }
			when 'U' { $!contents ~= self.Underline( $node ); }
			when 'Z' { $!contents ~= self.Zeroed-Out( $node ); }
			default {
				die "Unknown formatting code '{$node.type}'"
			}
		}
	}
#multi method end (Pod::FormattingCode $node) { }
	multi method start (Pod::Heading $node) {
		$!contents ~= self.Heading( $node );
		return False; # Bail out to skip the nested para
	}
#multi method end (Pod::Heading $node) {  }
	multi method start (Pod::Item $node) {
		$!contents ~= self.Item( $node );
		return False; # Bail out to skip the nested para
	}
#multi method end (Pod::Item $node) {  }
#multi method start (Pod::Raw $node) {  }
#multi method end (Pod::Raw $node) {  }

	method start-list (Int :$level, Bool :$numbered) {
		$!contents ~= self.List-Start( $level, $numbered );
	}
	method end-list (Int :$level, Bool :$numbered) {
		$!contents ~= self.List-End( $level, $numbered );
	}
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
		$final-content ~= $listener.contents if $listener.contents;
		$final-content ~= $listener.postamble if $listener.postamble;
		$final-content;
	}
}

# vim: ft=perl6
