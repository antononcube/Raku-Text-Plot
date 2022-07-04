#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use Data::Generators;

use Text::Plot;


# Simple plot with y-values only
say text-list-plot( (^30).List>>.sqrt, width => 100, height => 30 );

# Plot with x- and y-values and axes labels
my @xs = (0, 0.4 ... 5).List;
say text-list-plot( @xs, @xs>>.sin, width => 100, height => 30, xLabel => 'some range', yLabel => 'sin value', title => 'SINE PLOT' );

# Another plot
say text-list-plot( @xs,-1 <<*>> @xs>>.sqrt, width => 100, height => 30, xLabel => 'some range', yLabel => 'sqrt value' );
