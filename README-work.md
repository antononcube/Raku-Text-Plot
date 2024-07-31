# Raku Text::Plot

[![SparkyCI](http://ci.sparrowhub.io/project/gh-antononcube-Raku-Text-Plot/badge)](http://ci.sparrowhub.io)

This repository has a Raku package for textual (terminal) plots.

Here is the list of functions:

- [X] DONE DONE `text-list-plot`
- [X] DONE DONE `text-pareto-principle-plot`
- [X] DONE DONE `text-histogram`
- [ ] TODO TODO `text-plot`
- [ ] TODO TODO `text-bar-chart`

***Currently only `text-list-plot`, `text-pareto-principle-plot`, `text-histogram` are implemented.***

It would be nice to also have the function:

- [ ] TODO `text-box-plot`

But that would require dependency on a certain statistical package.
(I think it is best to keep this package simple.)

-------

## Installation

From zef-ecosystem:

```
zef install Text::Plot
```

From GitHub:

```
zef install https://github.com/antononcube/Raku-Text-Plot.git
```

------

## Usage examples

### `text-list-plot`

Simple plot with y-values only:

```perl6
use Text::Plot;
say text-list-plot((^30)>>.sqrt);
```

Plot using both x- and y-values, and with specified axes labels, y-tick-labels format, and plot width, height, and
title:

```perl6
my @xs = (0, 0.2 ... 5);
say text-list-plot(@xs, @xs>>.sin,
        x-label => 'x-points',
        y-label => 'value',
        y-tick-labels-format => '%10.2e',
        width => 80,
        height => 18,
        title => 'SINE PLOT');
```

Smallish plot with custom point character spec:

```perl6
my @xs = (0, 0.05 ... 10);
say text-list-plot(@xs, -1 <<*>> @xs>>.sqrt,
        point-char => '·',
        width => 40,
        height => 12);
```

Plot a list of two-element lists:

```perl6
say text-list-plot((^@xs.elems Z @xs>>.cos).List, title => 'Some list of lists'),
```

Here is a more complicated example using a randomly generated dataset, [AAp1, AAp2]:

```perl6
use Data::Generators;
use Data::Summarizers;
my @dsRand = random-tabular-dataset(70, <x y>,
        generators => [{ random-variate(NormalDistribution.new(4, 2), $_) },
                       { random-variate(NormalDistribution.new(12, 3), $_) }]);
records-summary(@dsRand);
```

```perl6
text-list-plot(@dsRand.map({ $_<x y> })>>.List,
        x-limit => (-2, 10), y-limit => (0, 25),
        title => 'Random Normal distribution variates')
```

**Remark:** The function `text-list-plot` has camel case aliases for the multi-word named arguments.
For example, `xLimit` for `x-limit` and `xTickLabelsFormat` for `x-tick-labels-format`.


Here is an example of a multi-list plot:

```perl6
say text-list-plot([([1,1], [2,5], [3,2], [4,5]),
                    ([1,1], [3,3], [3,2]),
                    ([1,3], [2,1], [5,2])], point-char => Whatever);
```

**Remark:** Note that the points `[1,1]` and `[3,2]` of the second list overlay the same points of first list.

### `text-pareto-principle-plot`

Assume we have a data vector with all numeric or with all string elements.
The adherence of the data vector to the Pareto principle can be easily verified with the plots of
`text-pareto-principle-plot`. 

Here is an example with a numeric vector: 

```perl6
text-pareto-principle-plot( random-real(10, 300), title => 'Random reals')
```

Here is an example with a vector of strings: 

```perl6
text-pareto-principle-plot( random-pet-name(500), title => 'Random pet names')
```

### `text-histogram`

Here is a vector with normal distribution numbers:

```perl6
my ($μ, $σ) = (5, 2);
my @data = (^500).map({ $μ + $σ * (2 * pi * (1 - rand)).cos * (- 2 * log rand).sqrt });

@data.elems
```

Here is a histogram with counts:

```perl6
text-histogram(@data, 30, type => 'count', :filled, point-char => <* *>);
```

Here is a histogram with density function estimate:

```perl6
text-histogram(@data, 30, type => 'cdf', height => 20, :filled, point-char => <* ⏺>);
```

**Remark:** The second argument is for the number of histogram bins.
The value of the option `:$type` is expected to be one of "count", "probability", "PDF", or "CDF".

-------

## Command Line Interface (CLI)

The package function `text-list-plot` can be used through the corresponding CLI:

```shell
text-list-plot --help
```

Here is an example of a simple, y-axis values only call:

```
text-list-plot 33 12 21 10 3 4 
```

Here is an example of 2D points call:

```
text-list-plot "22,32 10,39 13,32 14,20"
```

Here is an example pipeline:

```
raku -e 'say (^1000).roll(21)' | text-list-plot
```

**Remark:** Attempt is made plot's width and height are determined automatically, using terminal's number of columns and
lines. If that fails `width=60` is used. In the pipeline example above `text-list-plot` fails to automatically determine
the width and height. (The other example do succeed.)

-------

## Implementation notes

- The package functions and their signatures design are easy to come up with, but it is very helpful to have a "good
  example" to follow.

    - I consider the R-package "txtplot", [BB1], to be such good example.

    - There are at least three Python packages for text plots, but only tried them out once. None was as complete and "nice"
      as the R-package "txtplot".

- The points and ticks are rescaled with a version of the Mathematica-function
  [`Rescale`](https://reference.wolfram.com/language/ref/Rescale.html).

- The axes ticks are computed with a version of the R-function
  [`pretty`](https://stat.ethz.ch/R-manual/R-devel/library/base/html/pretty.html).

-------

## TODO

- [X] DONE Plotting a list of two-element lists.

- [X] DONE Optional tick labels format specs.

- [X] DONE CLI design and implementation.

- [X] DONE Make use kebab-case for named arguments and make corresponding camel-case aliases.

- [X] DONE Multi-list plot support.

- [X] DONE Plot title.

- [X] DONE `text-pareto-principle-plot`

- [X] DONE `text-histogram`

- [ ] TODO Proper respect of width and height.

    - Currently, the width and height are for the plot frame -- title, axes- and tick labels are "extra."

- [ ] TODO Make the axes ticks to be on the left.

    - It was just much easier to put them on the right.

    - BTW, this is probably a bug -- the width of the "total plot" is larger than the specified.

- [ ] TODO Optional placement of tick values.

- [ ] TODO `text-plot`

    - Easy to implement inlined with `text-plot`, but it might give a simpler interface.

- [ ] TODO `text-bar-chart`

-------

## References

[AAp0] Anton Antonov,
[Text::Plot Raku package](https://github.com/antononcube/Raku-Text-Plot),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp1] Anton Antonov,
[Data::Generators Raku package](https://github.com/antononcube/Raku-Data-Generators),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[Data::Summarizers Raku package](https://github.com/antononcube/Raku-Data-Summarizers),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[BB1] Bjoern Bornkamp,
[txtplot R package](https://github.com/bbnkmp/txtplot),
([CRAN](https://github.com/cran/txtplot)),
(2020),
[GitHub/bbnkmp](https://github.com/bbnkmp).