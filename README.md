[![Build Status](https://travis-ci.org/thibaultduponchelle/XML-Minify.svg?branch=master)](https://travis-ci.org/thibaultduponchelle/XML-Minify) [![Actions Status](https://github.com/thibaultduponchelle/XML-Minify/workflows/linux/badge.svg)](https://github.com/thibaultduponchelle/XML-Minify/actions) [![Actions Status](https://github.com/thibaultduponchelle/XML-Minify/workflows/macos/badge.svg)](https://github.com/thibaultduponchelle/XML-Minify/actions) [![Actions Status](https://github.com/thibaultduponchelle/XML-Minify/workflows/windows/badge.svg)](https://github.com/thibaultduponchelle/XML-Minify/actions) [![Kritika Status](https://kritika.io/users/thibaultduponchelle/repos/thibaultduponchelle+XML-Minify/heads/master/status.svg)](https://kritika.io/users/thibaultduponchelle/repos/thibaultduponchelle+XML-Minify)
# NAME

XML::Minify - It's a configurable XML minifier.

# WARNING

THIS IS A BETA VERSION, API (OPTION NAMES) IS NOT FULLY STABILIZED AND MAY CHANGE WITHOUT NOTICE.

# SYNOPSIS

```perl
use XML::Minify qw(minify);

my $xmlstr = "<person>   <name>tib   </name>   <level>  42  </level>  </person>";
minify($xmlstr);
```

## DEFAULT MINIFICATION

The minifier has a predefined set of options enabled by default. 

They were decided by the author as relevant but you can disable individually with **keep\_** options.

- Merge elements when empty
- Remove DTD (configurable).
- Remove processing instructions (configurable)
- Remove comments (configurable).
- Remove CDATA (configurable).

This is the default and should be perceived as lossyless minification in term of semantic. 

It's not completely if you consider these things as data, but in this case you simply can't minify as you can't touch anything ;)

## EXTRA MINIFICATION

In addition, you could be **brutal** and remove characters in the text nodes (sort of "cleaning") : 

### Aggressive

- Remove empty text nodes.
- Remove starting blanks (carriage return, line feed, spaces...).
- Remove ending blanks (carriage return, line feed, spaces...).

### Destructive

- Remove indentation.
- Remove invisible spaces and tabs at the end of line.

### Insane

- Remove carriage returns and line feed into text nodes everywhere.
- Remove spaces into text nodes everywhere.

## OPTIONS

You can give various options:

- **expand\_entities**

    Expand entities. An entity is like 

    ```
    &foo; 
    ```

- **remove\_blanks\_start**

    Remove blanks (spaces, carriage return, line feed...) in front of text nodes. 

    For instance 

    ```
    <tag>    foo bar</tag> 
    ```

    will become 

    ```
    <tag>foo bar</tag>
    ```

    It is aggressive and therefore lossy compression.

- **remove\_blanks\_end**

    Remove blanks (spaces, carriage return, line feed...) at the end of text nodes. 

    For instance 

    ```
    <tag>foo bar    
       </tag> 
    ```

    will become 

    ```
    <tag>foo bar</tag>
    ```

    It is aggressive and therefore lossy compression.

- **remove\_spaces\_line\_start** or **remove\_indent**

    Remove spaces and tabs at the start of each line in text nodes. 
    It's like removing indentation actually.

    For instance 

    ```
    <tag>
           foo 
           bar    
       </tag> 
    ```

    will become 

    ```
    <tag>
    foo 
    bar
    </tag>
    ```

- **remove\_spaces\_line\_end**

    Remove spaces and tabs at the end of each line in text nodes.
    It's like removing invisible things.

- **remove\_empty\_text**

    Remove (pseudo) empty text nodes (containing only spaces, carriage return, line feed...). 

    For instance 

    ```
    <tag>

    </tag>
    ```

    will become 

    ```
    <tag/>
    ```

- **remove\_cr\_lf\_everywhere**

    Remove carriage returns and line feed everywhere (inside text !). 

    For instance 

    ```
    <tag>foo
    bar
    </tag> 
    ```

    will become 

    ```
    <tag>foobar</tag>
    ```

    It is aggressive and therefore lossy compression.

- **keep\_comments**

    Keep comments, by default they are removed. 

    A comment is something like :

    ```
    <!-- comment -->
    ```

- **keep\_cdata**

    Keep cdata, by default they are removed. 

    A CDATA is something like : 

    ```perl
    <![CDATA[ my cdata ]]>
    ```

- **keep\_pi**

    Keep processing instructions. 

    A processing instruction is something like :

    ```
    <?xml-stylesheet href="style.css"/>
    ```

- **keep\_dtd**

    Keep DTD.

- **no\_prolog**

    Do not put prolog (having no prolog is aggressive for XML readers).

    Prolog is at the start of the XML file and look like this :

    ```
    <?xml version="1.0" encoding="UTF-8"?>";
    ```

- **version**

    Specify version.

- **encoding**

    Specify encoding.

- **aggressive**

    Enable aggressive mode. Enables options --remove-blanks-starts --remove-blanks-end --remove-empty-text if they are not defined only.
    Other options still keep their value.

- **destructive**

    Enable destructive mode. Enable options --remove-spaces-line-starts --remove-spaces-line-end if they are not defined only.
    Enable also aggressive mode.
    Other options still keep their value.

- **insane**

    Enable insane mode. Enables options --remove-cr-lf-everywhere --remove-spaces-everywhere if they are not defined only.
    Enable also destructive mode and insane mode.
    Other options still keep their value.

# LICENSE

Copyright (C) Thibault DUPONCHELLE.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Thibault DUPONCHELLE
