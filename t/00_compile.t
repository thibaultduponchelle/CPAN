use strict;
use warnings;

use Test::More 0.98;

use_ok $_ for qw(
    XML::Minify
);

use XML::Minify;

is(minify("<tag/>"), minify("<tag/>"), "Test import by default");

# Test resiliency to empty or undefined parameter
is(minify(""), minify(""), "Test call with empty string");
is(minify(undef), minify(undef), "Test call with undefined string");

done_testing;

