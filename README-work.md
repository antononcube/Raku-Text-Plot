# Raku Text::Plot

This repository has a Raku package for textual (terminal) plots.

Here is the list of functions:

- [X] `text-list-plot`
- [ ] `text-plot`
- [ ] `text-bar-chart`

***Currently only `text-list-plot` is implemented.***

It would be nice to also have the functions:

- [ ] `text-density-plot`
- [ ] `text-box-plot`

But that would require dependency on a certain statistical package.
(I think it is best to keep this package simple.)

-------

## Installation

From zef-ecosystem:

```shell
zef install Text::Plot
```

From GitHub:

```shell
zef install https://github.com/antononcube/Raku-Text-Plot.git
```

------

## Usage examples

Simple plot with y-values only:

```perl6
use Text::Plot;
say text-list-plot((^30)>>.sqrt);
```

Plot using both x- and y-values, and with specified axes labels, y-tick-labels format, and plot width, height, and title:

```perl6
my @xs = (0, 0.2 ... 5);
say text-list-plot(@xs, @xs>>.sin,
        xLabel => 'x-points',
        yLabel => 'value',
        yTickLabelsFormat => '%10.2e',
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

-------

## Command Line Interface (CLI)

The package function `text-list-plot` can be used through the corresponding CLI:

```shell
> text-list-plot --help
# Usage:
#   text-list-plot [--point-char=<Str>] [--width[=Int]] [--height[=Int]] [--title=<Str>] [--xLabel=<Str>] [--yLabel=<Str>] [--xTickLabelsFormat=<Str>] [--yTickLabelsFormat=<Str>] [<points> ...] -- Makes textual (terminal) plots.
#   text-list-plot [--point-char=<Str>] [--width[=Int]] [--height[=Int]] [--title=<Str>] [--xLabel=<Str>] [--yLabel=<Str>] [--xTickLabelsFormat=<Str>] [--yTickLabelsFormat=<Str>] <words> -- Makes textual (terminal) plots by splitting a string of data points.
#   text-list-plot [--point-char=<Str>] [--width[=Int]] [--height[=Int]] [--title=<Str>] [--xLabel=<Str>] [--yLabel=<Str>] [--xTickLabelsFormat=<Str>] [--yTickLabelsFormat=<Str>] -- Makes textual (terminal) plots from pipeline input
#   
#     [<points> ...]               Data points.
#     --point-char=<Str>           Plot points character. [default: '*']
#     --width[=Int]                Width of the plot. (-1 for Whatever.) [default: -1]
#     --height[=Int]               Height of the plot. (-1 for Whatever.) [default: -1]
#     --title=<Str>                Title of the plot. [default: '']
#     --xLabel=<Str>               Label of the X-axis. If Whatever, then no label is placed. [default: '']
#     --yLabel=<Str>               Label of the Y-axis. If Whatever, then no label is placed. [default: '']
#     --xTickLabelsFormat=<Str>    X-axis tick labels format. [default: '']
#     --yTickLabelsFormat=<Str>    Y-axis tick labels format. [default: '']
#     <words>                      String with data points.
```

Here is an example pipeline:

```shell
> raku -e 'say (^1000).roll(21)' | text-list-plot
# +---+------------+-----------+------------+------------+---+          
# |                                                          |          
# |     *                                                    |          
# +                *                        *            *   +  800.00  
# |                            *                    *        |          
# |                     *                         *          |          
# +                                                          +  600.00  
# |                          *                               |          
# |          *                       *                       |          
# +                               *    *                     +  400.00  
# |        *         *                                       |          
# |                       *               *            *     |          
# +   *         *                                            +  200.00  
# |                                            *             |          
# |                                                          |          
# +---+------------+-----------+------------+------------+---+          
#     0.00         5.00        10.00        15.00        20.00    
```


-------

## Implementation notes

- The package functions and their signatures design are easy to come up with, but it is very helpful to have a "good
  example" to follow.

    - I consider the R-package "txtplot", [BB1], to be such good example.

    - There at least three Python packages for text plots, but only tried them out once. None was as complete and "nice"
      as the R-package "txtplot".

- The points and ticks are rescaled with a version of the Mathematica-function
  [`Rescale`](https://reference.wolfram.com/language/ref/Rescale.html).

- The axes ticks are computed with a version of the R-function
  [`pretty`](https://stat.ethz.ch/R-manual/R-devel/library/base/html/pretty.html).

-------

## TODO

- [X] Plotting a list of two-element lists.

- [X] Optional tick labels format specs.

- [ ] Make the axes ticks to be on the left.

    - It was just much easier to put them on the right.

    - BTW, this is probably a bug -- the width of "total plot" is larger than the specified.

- [ ] Optional placement tick values.

- [ ] Plot title.

    - I am not sure is it needed.

- [ ] `text-plot`

    - Easy to implement inlined with `text-plot`, but it might give a simpler interface.

- [ ] `text-bar-chart`

- [ ] CLI design and implementation

- [ ] Multi-lines plot support.

-------

## References

[BB1] Bjoern Bornkamp,
[txtplot R package](https://github.com/bbnkmp/txtplot),
([CRAN](https://github.com/cran/txtplot)),
(2020),
[GitHub/bbnkmp](https://github.com/bbnkmp).