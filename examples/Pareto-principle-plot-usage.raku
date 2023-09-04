#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use Data::Generators;
use Data::Summarizers;

use Text::Plot;

#`[
my $stime = now;
my @pnames = random-pet-name(4000, species => 'Any', method => &roll):weighted;
my $etime = now;
say "Generation time: {$etime - $stime}";

$stime = now;
my @pnames2 = random-pet-name(4000, species => 'Cat', method => &roll):weighted;
$etime = now;
say "Generation time: {$etime - $stime}";

records-summary(@pnames);
records-summary(@pnames2);

say tally(@pnames).sort({ -$_.value });
say tally(@pnames2).sort({ -$_.value });


say text-pareto-principle-plot(@pnames, title => 'Random pet names', width => 80):normalize;
say text-pareto-principle-plot(@pnames2, title => 'Random cat names', width => 80):normalize;

]
## 4
my %hash4 = ('a'..'z').roll(200) Z=> (^100).roll(200);

say text-pareto-principle-plot(%hash4);

## 5
my @arr5 = (^1000).roll(200) Z (^100).roll(200);

say @arr5.map({ $_[0] }).sum;
say @arr5.map({ $_[1] }).sum;
say @arr5;

say text-pareto-principle-plot(@arr5):!normalize;