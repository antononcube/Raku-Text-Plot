#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use Data::Generators;

use Text::Plot;

# Simple plot with y-values only
say text-plot( (^30).List>>.sqrt, width => 100, height => 30 );

# Plot with x- and y-values and axes labels
my @xs = (0, 0.4 ... 5).List;
say text-plot( @xs,  @xs>>.sin, width => 100, height => 30, xLabel => 'some range', yLabel => 'sin value' );

# Another plot
say text-plot( @xs, @xs>>.sqrt.map({ - $_ }).List, width => 100, height => 30, xLabel => 'some range', yLabel => 'sqrt value' );