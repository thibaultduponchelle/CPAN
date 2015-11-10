#!/usr/bin/env perl

# Project : XML-Minifier
# Author : Thibault Duponchelle
# xml-minifier.pl does what you expect from it ;)

use XML::LibXML; # To be installed from CPAN : sudo cpan -i XML::LibXML 
# CPAN rules !

use Pod::Usage qw(pod2usage);
use Getopt::Long;

GetOptions (
	"expand-entities" => \$opt_expand_entities,
	"remove-blanks-start"   => \$opt_remove_blanks_start,
	"remove-blanks-end"   => \$opt_remove_blanks_end,
	"remove-empty-text"   => \$opt_remove_empty_text,
	"remove-cr-lf-everywhere"   => \$opt_remove_cr_lf_everywhere,
	"keep-comments"   => \$opt_keep_comments,
	"keep-cdata"   => \$opt_keep_cdatas,
	"keep-pi"   => \$opt_keep_pi,
	"agressive"   => \$opt_agressive,
	"help"   => \$opt_help          
	) or die("Error in command line arguments (maybe \"$0 --help\" could help ?)\n");

if($opt_agressive) {
	(defined $opt_remove_empty_text) or $opt_remove_empty_text = 1;             # a bit agressive
	(defined $opt_remove_blanks_start) or $opt_remove_blanks_start = 1;         # agressive
	(defined $opt_remove_blanks_end) or $opt_remove_blanks_end = 1;             # agressive
	(defined $opt_remove_cr_lf_everywhere) or $opt_remove_cr_lf_everywhere = 1; # very agressive 
	# Others are either overriden or with the correct value (undefined is false)
}

=comment
print "expand-entities : " . $opt_expand_entities . "\n";
print "remove-blanks-start : " . $opt_remove_blanks_start . "\n";
print "remove-blanks-end : " . $opt_remove_blanks_end . "\n";
print "remove-empty-text : " . $opt_remove_empty_text . "\n";
print "remove-cr-lf-everywhere : " . $opt_remove_cr_lf_everywhere . "\n";
print "keep-comments : " . $opt_keep_comments . "\n";
print "keep-cdata : " . $opt_keep_cdatas . "\n";
print "keep-pi : " . $opt_keep_pi . "\n";
print "agressive : " . $opt_agressive . "\n";
print "help : " . $opt_help . "\n";
=cut

($opt_help) and pod2usage(1);

my $string;

while (<>) {
        $string .= $_;
}

# Should be configurable
# --expand-entities
my $parser = XML::LibXML->new(expand_entities => 0);
my $tree = $parser->parse_string($string);
$parser->process_xincludes($tree);

my $root = $tree->getDocumentElement;

# I disable automatic xml declaration as : 
# - It would be printed too late (after pi and subset) and produce broken output
# - I want to have full control on it
$XML::LibXML::skipXMLDeclaration = 1;
my $doc = XML::LibXML::Document->new();#'1.0', 'UTF-8');

# traverse the "main" tree ("main" means <root>...</root>)
sub traverse($$) {
        my $node = shift;
        my $outnode = shift;

        if(!$node) { # Useless I think
                return; 
        }

	my $name = $node->getName();
	$newnode = $doc->createElement($name);
	if($outnode) {
		$outnode->addChild($newnode);
	}
	$outnode = $newnode;

        my @as = $node->attributes ;
        foreach my $a (@as) { 
                $outnode->setAttribute($a->nodeName, $a->value); 
        }

        foreach my $child ($node->childNodes) {
		if($child->nodeType eq XML_TEXT_NODE) {
			# Should be configurable (?)
			# --keep-blanks
			my $str = $child->data;

			# Should be configurable 
			# --remove-blanks-start : remove extra space/lf/cr at the start of the string
			$str =~ s/^(\s|\R)*//g;
			# --remove-blanks-end : remove extra space/lf/cr at the end of the string
			$str =~ s/(\s|\R)*$//g;
			# --remove-cr-lf-everywhere : remove extra space/lf/cr everywhere
			$str =~ s/(\s|\R)*$//g;
			($str =~ /^\s*$/) or $outnode->appendText($str);
			#$outnode->appendText($str);
		} elsif($child->nodeType eq XML_ENTITY_REF_NODE) {
			# Configuration will be done above when creating document
			my $er = $doc->createEntityReference($child->getName());
			$outnode->addChild($er); 
		} elsif($child->nodeType eq XML_COMMENT_NODE) {
			# Should be configurable 
			# --keep-comments
			$outnode->addChild($child);
		} elsif($child->nodeType eq XML_CDATA_SECTION_NODE) {
			# Should be configurable 
			# --keep-cdata
			$outnode->addChild($child);
		} elsif($child->nodeType eq XML_ELEMENT_NODE) {
			$outnode->addChild(traverse($child, $outnode)); 
		}
	} 
	return $outnode;
}

# Should be configurable
# --no-version : do not put version (agressive for readers) 
# --version=1.0 --encoding=UTF-8 : choose values
print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";

my $rootnode;

# Parsing first level 
foreach my $flc ($tree->childNodes()) {

	if(($flc->nodeType eq XML_DTD_NODE) or ($flc->nodeType eq XML_DOCUMENT_TYPE_NODE)) { # second is synonym but deprecated
		# Should be configurable
		# --keep-dtd and even --keep-dtd-format
		my $str = $flc->toString();
		# alternative : my $internaldtd = $tree->internalSubset(); my $str = $internaldtd->toString();
		$str =~ s/\R//g;
		print $str;
	
		# XML_ELEMENT_DECL
		# XML_ATTRIBUTE_DECL
		# XML_ENTITY_DECL 
		# XML_NOTATION_DECL
		
		# If I try to iterate over childNodes, I never see XML_NOTATION_DECL (why?!)
		# So I won't try to do that until I fully understand what to do or what's the problem

		# One word about DTD and XML::LibXML : 
		# It seems like something is wrong or partially implemented or I'm just stupid (probably :D)
		# DTD validation works like a charm of course... 
		# But reading from one xml and set to another with experimental function seems just broken or works very weirdly

	} elsif($flc->nodeType eq XML_PI_NODE) {
		# Should be configurable
		# --keep-pi
		print $flc->toString();
	} elsif($flc->nodeType eq XML_COMMENT_NODE) {
		# Should be configurable
		# --keep-comments
	} elsif($flc->nodeType eq XML_ELEMENT_NODE) { # Actually document node as if we do getDocumentNode
		# "main" tree, only one (parser is protecting us)
		$rootnode = traverse($root, $doc);
		# XML_ATTRIBUTE_NODE
		# XML_TEXT_NODE
		# XML_ENTITY_REF_NODE
		# XML_COMMENT_NODE
		# XML_CDATA_SECTION_NODE

		# Ignore 
		# XML_XINCLUDE_START
		# XML_XINCLUDE_END
		
		# Will stay hidden in any case
		# XML_NAMESPACE_DECL

		# Not Applicable 
		# XML_DOCUMENT_NODE 
		# XML_DOCUMENT_FRAG_NODE
		# XML_HTML_DOCUMENT_NODE
		
		# What is it ?
		# XML_ENTITY_NODE
		
	} else {
		# Should I print these unattended things ?
		# Should it be configurable ?
	}
		
}
	
# XML_ELEMENT_NODE            => 1
# E.G. : <tag></tag> or <tag/>

# XML_ATTRIBUTE_NODE          => 2
# E.G. : <tag attribute="value">

# XML_TEXT_NODE               => 3
# E.G. : This is a piece of text

# XML_CDATA_SECTION_NODE      => 4
# E.G. : <![CDATA[<sender>John Smith</sender>]]>
# CDATA section (not for parsers)

# XML_ENTITY_REF_NODE         => 5
# Entities like &entity;

# XML_ENTITY_NODE             => 6
# XML_PI_NODE                 => 7 
# Processing Instructions like <?xml-stylesheet href="style.css"> 

# XML_COMMENT_NODE            => 8
# Comments like <!-- comment -->

# XML_DOCUMENT_NODE           => 9
# The document itself

# XML_DOCUMENT_TYPE_NODE      => 10
# E.G. : Deprecated, use XML_DOCUMENT_TYPE_NODE

# XML_DOCUMENT_FRAG_NODE      => 11
# E.G. : Never read, for use, should be created as element node

# XML_NOTATION_NODE           => 12
# E.G. : <!NOTATION GIF SYSTEM "GIF"> seems not working

# XML_HTML_DOCUMENT_NODE      => 13
# E.G. : <catalog></catalog>
# In HTML context, for us, should be treated as a document node

# XML_DTD_NODE                => 14
# E.G. : <!DOCTYPE book PUBLIC "blahblah" "http://www.example.com/docbookx.dtd" [

# XML_ELEMENT_DECL            => 15
# E.G. : <!ELEMENT element-name EMPTY>

# XML_ATTRIBUTE_DECL          => 16
# E.G. : <!ATTLIST image height CDATA #REQUIRED>

# XML_ENTITY_DECL             => 17
# E.G. : <!ENTITY Entity2 "<strong>Entity</strong>">

# XML_NAMESPACE_DECL          => 18
# E.G. : <catalog xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> 

# XML_XINCLUDE_START          => 19
# <xi:include href="inc.xml"/> if we process includes

# XML_XINCLUDE_END            => 20
# <xi:include href="inc.xml"/> if we process includes

$doc->setDocumentElement($rootnode);

print $doc->toString();

__END__

=head1 NAME

xml-minifier - Minify XML files

=head1 SYNOPSIS

xml-minifier 

Options:

--expand-entities            expand entities 

--remove-blanks-start        remove blanks before text

--remove-blanks-end          remove blanks after text

--remove-empty-text          remove (pseudo) empty text

--remove-cr-lf-everywhere    remove cr and lf everywhere

--keep-comments              keep comments

--keep-cdata                 keep cdata

--keep-pi                    keep processing instructions

--agressive                  short alias for agressive mode 

--help                       brief help message

=head1 OPTIONS

=over 4

=item B<--expand-entities>

Expand entities. AN entity is like &foo; 

=item B<--remove-blanks-start>

Remove blanks (spaces, carriage return, line feed...) in front of text nodes. 
For instance <tag>    foo bar</tag> will become <tag>foo bar</tag>
Agressive and therefore lossy compression.

=item B<--remove-blanks-end>

Remove blanks (spaces, carriage return, line feed...) at the end of text nodes. 
For instance <tag>foo bar    </tag> will become <tag>foo bar</tag>
Agressive and therefore lossy compression.

=item B<--remove-empty-text>

Remove (pseudo) empty text nodes (spaces, carriage return, line feed...). 
For instance <tag>foo\nbar</tag> will become <tag>foobar</tag>
Agressive and therefore lossy compression.

=item B<--remove-cr-lf-everywhere>

Remove carriage returns and line feed everywhere (inside text !). Very agressive and therefore lossy compression.

=item B<--keep-comments>

Keep comments, by default they are removed. A comment is like <!-- comment -->

=item B<--keep-cdata>

Keep cdata, by default they are removed. A CDATA is like <![CDATA[ my cdata ]]>

=item B<--keep-pi>

Keep processing instructions. A processing instruction is like <?xml-stylesheet href="style.css"/>

=item B<--agressive>

Short alias for agressive mode. Enables options --remove-blanks-starts --remove-blanks-end --remove-empty-text --remove-cr-lf-eveywhere if they are not defined only.
Other options still keep their value.

=item B<--help>

Print a brief help message and exits.

=back

=head1 DESCRIPTION
B<This program> will read the standard output and minify it :
=over 4


=cut


