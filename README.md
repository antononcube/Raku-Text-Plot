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
```
# +---+-------+--------+--------+--------+--------+--------+-+      
# |                                                          |      
# +                                               * * * **   +  5.00
# |                                      * * * **            |      
# +                               * * **                     +  4.00
# |                        * * **                            |      
# +                   ** *                                   +  3.00
# |               * *                                        |      
# +          ** *                                            +  2.00
# |        *                                                 |      
# +    * *                                                   +  1.00
# |                                                          |      
# +   *                                                      +  0.00
# |                                                          |      
# +---+-------+--------+--------+--------+--------+--------+-+      
#     0.00    5.00     10.00    15.00    20.00    25.00    30.00
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
```
# SINE PLOT                                    
# +---+-------------+-------------+-------------+-------------+-------------+----+            
# |                                                                              |            
# +                    *  *  *  * *                                              +  1.00e+00  
# |                 *                *                                           |            
# |               *                     *                                        |            
# +            *                           *                                     +  5.00e-01  
# |         *                                 *                                  |           v
# |      *                                                                       |           a
# |                                             *                                |           l
# +   *                                            *                             +  0.00e+00 u
# |                                                   *                          |           e
# |                                                                              |            
# +                                                      *                       + -5.00e-01  
# |                                                         *                    |            
# |                                                           *  *               |            
# +                                                                 *  *  * *    + -1.00e+00  
# |                                                                              |            
# +---+-------------+-------------+-------------+-------------+-------------+----+            
#     0.00          1.00          2.00          3.00          4.00          5.00            
#                                     x-points
```

Smallish plot with custom point character spec:

```perl6
my @xs = (0, 0.05 ... 10);
say text-list-plot(@xs, -1 <<*>> @xs>>.sqrt,
        point-char => '·',
        width => 40,
        height => 12);
```
```
# +--+-----+------+------+------+-----+--+      
# +  ·                                   +  0.00
# |  ·                                   |      
# +  ···                                 + -0.50
# +    ···                               + -1.00
# +       ····                           + -1.50
# |          ······                      |      
# +               ······                 + -2.00
# +                    ········          + -2.50
# +                           ········   + -3.00
# +                                   ·  + -3.50
# +--+-----+------+------+------+-----+--+      
#    0.00  2.00   4.00   6.00   8.00  10.00
```

Plot a list of two-element lists:

```perl6
say text-list-plot((^@xs.elems Z @xs>>.cos).List, title => 'Some list of lists'),
```
```
# Some list of lists                     
# +---+------------+-----------+------------+------------+---+      
# |                                                          |      
# +   ***                          *******                   +  1.00
# |      **                       **     ***                 |      
# +       **                    ***        **                +  0.50
# |        **                  **           **               |      
# |         **                 *             **              |      
# +          **               *               *              +  0.00
# |           **             *                 *             |      
# |            **           *                   *            |      
# +             **         *                     **          + -0.50
# |              ***     **                       **         |      
# +                *******                         *******   + -1.00
# |                                                          |      
# +---+------------+-----------+------------+------------+---+      
#     0.00         50.00       100.00       150.00       200.00
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