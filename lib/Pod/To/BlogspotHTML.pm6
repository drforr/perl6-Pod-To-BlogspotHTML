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

=head1 METHODS

=end pod

use Pod::TreeWalker;
use Pod::TreeWalker::Listener;

my role Pod::To::BlogspotHTML::Mixins {
	method Bold-Start( $node ) { qq[<b>]; }
	method Bold-End( $node ) { qq[</b>]; }

	method Code-Start( $node ) { qq[<code>]; }
	method Code-End( $node ) { qq[</code>]; }

	method Code-Block-Start( $node ) { qq[<code>]; }
	method Code-Block-End( $node ) { qq[</code>]; }

	# XXX Is this documented? Is this even a thing?
	method Definition-Start( $node ) { qq[<defn>]; }
	method Definition-End( $node ) { qq[</defn>]; }

	method Entity( $node ) {
		given $node.meta {
			when / ^ \d / { qq[&#$_;] }
			default { qq[&$_;] }
		}
	}

	method Heading-Start( $node ) { qq[<h{$node.level}>]; }
	method Heading-End( $node ) { qq[</h{$node.level}>]; }

	method Item-Start( $node ) { qq[<li>]; }
	method Item-End( $node ) { qq[</li>]; }

	method Italic-Start( $node ) { qq[<i>]; }
	method Italic-End( $node ) { qq[</i>]; }

	method List-Start( Int $level, Bool $numbered ) {
		$numbered ?? qq[<ol>] !! qq[<ul>];
	}
	method List-End( Int $level, Bool $numbered ) {
		$numbered ?? qq[</ol>] !! qq[</ul>];
	}
	method Keyboard-Start( $node ) { qq[<kbd>]; }
	method Keyboard-End( $node ) { qq[</kbd>]; }

	method Link-Start( $node ) { qq[<a href="{$node.meta}">]; }
	method Link-End( $node ) { qq[</a>]; }

	method Notes( $node ) { $node.contents; }

	method Para-Start( $node ) { qq[<p>]; }
	method Para-End( $node ) { qq[</p>]; }

	# XXX Is this documented? Is this even a thing?
	method Replaceable-Start( $node ) { qq[<var>]; }
	method Replaceable-End( $node ) { qq[</var>]; }

	method Section-Start( $node ) { qq[<section><h1>{$node.name}</h1>]; }
	method Section-End( $node ) { qq[</section>]; }

	method Table-Start( $node ) { qq[<table>]; }
	method Table-End( $node ) { qq[</table>]; }

	method Table-Row-Start( $row ) { qq[<tr>]; }
	method Table-Row-End( $row ) { qq[</tr>]; }

	method Table-Data-Start( $column ) { qq[<td>]; }
	method Table-Data-End( $column ) { qq[</td>]; }

	method Table-Column( $column ) { $column; }

	method Terminal-Start( $node ) { qq[<samp>]; }
	method Terminal-End( $node ) { qq[</samp>]; }

	method Underline-Start( $node ) { qq[<u>]; }
	method Underline-End( $node ) { qq[</u>]; }

	method Zeroed-Out-Start( $node ) { qq[<!--]; }
	method Zeroed-Out-End( $node ) { qq[-->]; }

	# XXX This probably should go into @.meta, that can be decided later.
	method Meta( $node ) {
#		if $node.^can('contents') {
#			qq[<h1 id="{$node.name}">{$node.name}</h1><p>{$node.contents[0].contents[0]}</p>];
#		}
#		else {
#			qq[<h1 id="{$node.name}">{$node.name}</h1>];
#		}
''
	}
}

my class Pod::To::BlogspotHTML::TreeMunger {
#`(
	multi method prune( Pod::Block::Code $node ) {
		self.prune( $_ ) for $node.contents;
	}
	multi method prune( Pod::Block::Comment $node ) {
		self.prune( $_ ) for $node.contents;
	}
	multi method prune( Pod::Block::Declarator $node ) {
		self.prune( $_ ) for $node.contents;
	}
)
	multi method prune( Pod::Block::Named $node ) {
		if $node.name eq 'pod' | 'input' | 'output' &&
		   $node.contents.elems == 1 &&
		   $node.contents[0] ~~ Pod::Block::Para {
			$node.contents = $node.contents[0].contents;
		}
		self.prune( $_ ) for $node.contents;
	}
#`(
	multi method prune( Pod::Block::Para $node ) {
		self.prune( $_ ) for $node.contents;
	}
	multi method prune( Pod::Block::Table $node ) {
		self.prune( $_ ) for $node.contents;
	}
	multi method prune( Pod::Block:D $node ) {
		self.prune( $_ ) for $node.contents;
	}
	multi method prune( Pod::Config $node ) {
		self.prune( $_ ) for $node.contents;
	}
)
	multi method prune( Pod::Heading $node ) {
		if $node.contents.elems == 1 &&
		   $node.contents[0] ~~ Pod::Block::Para {
			$node.contents = $node.contents[0].contents;
		}
		self.prune( $_ ) for $node.contents;
	}
	multi method prune( Pod::Item $node ) {
		if $node.contents.elems == 1 &&
		   $node.contents[0] ~~ Pod::Block::Para {
			$node.contents = $node.contents[0].contents;
		}
		self.prune( $_ ) for $node.contents;
	}
#`(
	multi method prune( Pod::Raw $node ) {
		self.prune( $_ ) for $node.contents;
	}
)
	multi method prune( Str $node ) {
	}
	multi method prune( Array $node ) {
		self.prune( $_ ) for @( $node );
	}
	multi method prune( $node ) {
#		self.prune( $_ ) for $node.contents;
	}
}

class Pod::To::BlogspotHTML {
	also does Pod::To::BlogspotHTML::Mixins;
	also does Pod::TreeWalker::Listener;

	constant META-TAGS = <
		 NAME AUTHOR VERSION TITLE SUBTITLE SYNOPSIS DESCRIPTION
	>;

	has %.meta;
	has $.preamble;
	has $.contents;
	has $.postamble;

	#multi method start ( Pod::Block:D $node ) { }
	#multi method end ( Pod::Block:D $node ) { }

	multi method start( Pod::Block::Code $node ) {
		$!contents ~= self.Code-Block-Start( $node );
	}
	multi method end( Pod::Block::Code $node ) {
		$!contents ~= self.Code-Block-End( $node );
	}
	multi method start( Pod::Block::Comment $node ) {
		self.Zeroed-Out( $node );
	}
	#multi method end( Pod::Block::Comment $node ) {  }
	#multi method start( Pod::Block::Declarator $node ) {  }
	#multi method end( Pod::Block::Declarator $node ) {  }

	multi method start( Pod::Block::Named $node ) {
		given $node.name {
			when META-TAGS.any {
				$!preamble ~= self.Meta( $node );
			}
			when 'input' {
				$!contents ~= self.Keyboard-Start( $node );
			}
			when 'output' {
				$!contents ~= self.Terminal-Start( $node );
			}
			when 'pod' {
				# For the moment, do nothing.
			}
			default {
				$!contents ~= self.Section-Start( $node );
			}
		}
		return True;
	}
	multi method end( Pod::Block::Named $node ) {
		given $node.name {
			when 'pod' {
				# For the moment, do nothing.
			}
			when 'input' {
				$!contents ~= self.Keyboard-End( $node );
			}
			when 'output' {
				$!contents ~= self.Terminal-End( $node );
			}
			default {
				$!contents ~= self.Section-End( $node );
			}
		}
		return True;
	}
	multi method start( Pod::Block::Para $node ) {
		$!contents ~= self.Para-Start( $node );
		return True;
	}
	multi method end( Pod::Block::Para $node ) {
		$!contents ~= self.Para-End( $node );
	}

	multi method start( Pod::Block::Table $node ) {
		$!contents ~= self.Table-Start( $node );
		return True;
	}
	multi method end( Pod::Block::Table $node ) {
		$!contents ~= self.Table-End( $node );
		return True;
	}

	multi method start( Pod::FormattingCode $node ) {
		given $node.type {
			when 'B' { $!contents ~= self.Bold-Start( $node ); }
			when 'C' { $!contents ~= self.Code-Start( $node ); }
			when 'D' {
				$!contents ~= self.Definition-Start( $node );
			}
			when 'E' {
				$!contents ~= self.Entity( $node );
				return False;
			}
			when 'I' { $!contents ~= self.Italic-Start( $node ); }
			when 'K' {
				$!contents ~= self.Keyboard-Start( $node );
			}
			when 'L' { $!contents ~= self.Link-Start( $node ); }
			when 'N' {
				$!postamble ~= self.Notes( $node );
				return False;
			}
			when 'R' {
				$!contents ~= self.Replaceable-Start( $node );
			}
			when 'T' {
				$!contents ~= self.Terminal-Start( $node );
			}
			when 'U' {
				$!contents ~= self.Underline-Start( $node );
			}
			when 'Z' {
				$!contents ~= self.Zeroed-Out-Start( $node );
			}
			default {
				die "Unknown formatting code '{$node.type}'"
			}
		}
		return True;
	}
	multi method end( Pod::FormattingCode $node ) {
		given $node.type {
			when 'B' { $!contents ~= self.Bold-End( $node ); }
			when 'C' { $!contents ~= self.Code-End( $node ); }
			when 'D' {
				$!contents ~= self.Definition-End( $node );
			}
			when 'I' { $!contents ~= self.Italic-End( $node ); }
			when 'K' {
				$!contents ~= self.Keyboard-End( $node );
			}
			when 'L' { $!contents ~= self.Link-End( $node ); }
#			when 'N' { $!postamble ~= self.Notes( $node ); }
			when 'R' {
				$!contents ~= self.Replaceable-End( $node );
			}
			when 'T' {
				$!contents ~= self.Terminal-End( $node );
			}
			when 'U' {
				$!contents ~= self.Underline-End( $node );
			}
			when 'Z' {
				$!contents ~= self.Zeroed-Out-End( $node );
			}
#			default {
#				die "Unknown formatting code '{$node.type}'"
#			}
		}
		return False;
	}
	multi method start( Pod::Heading $node ) {
		$!contents ~= self.Heading-Start( $node );
	}
	multi method end( Pod::Heading $node ) {
		$!contents ~= self.Heading-End( $node );
	}
	multi method start( Pod::Item $node ) {
		$!contents ~= self.Item-Start( $node );
	}
	multi method end( Pod::Item $node ) {
		$!contents ~= self.Item-End( $node );
	}

	#multi method start( Pod::Raw $node ) { }
	#multi method end( Pod::Raw $node ) { }

	method start-list( Int :$level, Bool :$numbered ) {
		$!contents ~= self.List-Start( $level, $numbered );
	}
	method end-list( Int :$level, Bool :$numbered ) {
		$!contents ~= self.List-End( $level, $numbered );
	}

	method table-row( Array $row ) {
		$!contents ~= self.Table-Row-Start( $row );
		for @( $row ) -> $element {
			$!contents ~= self.Table-Data-Start( $element );
			$!contents ~= self.Table-Column(
				$element.contents[0].contents[0]
			);
			$!contents ~= self.Table-Data-End( $element );
		}
		$!contents ~= self.Table-Row-End( $row );
		return True;
	}
	#method config( Pod::Config $node ) {  }

	method text( Str:D $text ) {
		$!contents ~= $text;
	}

	method render( $pod ) {
		my $listener = self.new;
		my $walker = Pod::TreeWalker.new( :listener( $listener ) );
		Pod::To::BlogspotHTML::TreeMunger.new.prune( $pod );
		$walker.walk-pod( $pod );
#say $walker.text-contents-of( $pod );
		my $final-content;

		$final-content ~= $listener.preamble if $listener.preamble;
		$final-content ~= $listener.contents if $listener.contents;
		$final-content ~= $listener.postamble if $listener.postamble;
		$final-content;
	}
}

# vim: ft=perl6
