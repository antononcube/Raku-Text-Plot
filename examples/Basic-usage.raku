#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use Data::Generators;
use Data::Summarizers;

use Text::Plot;


# Simple plot with y-values only
say text-list-plot( (^30).List>>.sqrt, width => 100, height => 30 );

# Plot with x- and y-values and axes labels
my @xs = (0, 0.4 ... 5).List;
say text-list-plot( @xs, @xs>>.sin, width => 100, height => 30, xLabel => 'some range', yLabel => 'sin value', title => 'SINE PLOT' );

# Another plot
say text-list-plot( @xs,-1 <<*>> @xs>>.sqrt, width => 100, height => 30, xLabel => 'some range', yLabel => 'sqrt value' );

my @xs2 = (0, 0.4 ... 5).List;
say text-list-plot(@xs2, -1 <<*>> @xs2>>.sqrt, xLimit => (-1, 10), yLimit => (2, -5));

## More complicate data example
say "\n", '=' x 120, "\n";

my @dsRand = random-tabular-dataset(70, <x y>,
        generators => [{ random-variate(NormalDistribution.new(4, 2), $_) },
                       { random-variate(NormalDistribution.new(12, 3), $_) }]);

records-summary(@dsRand);

say text-list-plot(@dsRand.map({ $_<x y> })>>.List,
        x-limit => (-2, 10), y-limit => (0, 25),
        title => 'Random Normal distribution variates',
        y-tick-labels-format => '%9.1e');

say '=' xx 120;

say text-list-plot( random-real(10, (30, 2)).List );