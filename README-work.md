# Raku Text::Plot

This repository has a Raku package for textual (terminal) plots.

Here is the list of functions:

- [X] `text-list-plot`
- [ ] `text-plot`
- [ ] `text-bar-chart`

**Currently only `text-plot` is implemented.**

It would be nice to also have the functions:

- [ ] `text-density-plot`
- [ ] `text-box-plot`

But that would require dependency on certain statistical package.
(I think it is best if this package is kept simple.)

(The list above is inspired by the R-package "txtplot", [BB1].)

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

Plot using both x- and y-values, and with specified axes labels and plot width and height:

```perl6
my @xs = (0, 0.1 ... 5);
say text-list-plot(@xs,  @xs>>.sin, xLabel => 'some range', yLabel => 'value', width => 100, height => 30, title => 'SINE PLOT');
```

Smallish plot with custom point character spec:

```perl6
my @xs = (0, 0.05 ... 10);
say text-list-plot(@xs, -1 <<*>> @xs>>.sqrt, point-char => '·', xLabel => 'some range', yLabel => 'sqrt', width => 40, height => 12);
```

-------

## Implementation notes

The axes ticks are computed with a version if R-function 
[`pretty`](https://stat.ethz.ch/R-manual/R-devel/library/base/html/pretty.html).

The points and ticks are rescaled with a version of Mathematica-function 
[`Rescale`](https://reference.wolfram.com/language/ref/Rescale.html).


-------

## TODO

- [ ] Make the axes ticks to be on the left.

   - It was just much easier to put them on the right.
   
   - BTW, this is probably a bug -- the width of "total plot" is larger than the specified.
   
- [ ] Optional placement tick values.

- [ ] Plot title. 
    
   - I am not sure is it needed.
   
- [ ] `text-plot`

   - Easy to implement inlined with `text-plot`, but it might give a simpler interface.
   
- [ ] `text-bar-chart`    
    

-------

## References

[BB1] Bjoern Bornkamp,
[txtplot R package](https://github.com/bbnkmp/txtplot),
([CRAN](https://github.com/cran/txtplot)),
(2020),
[GitHub/bbnkmp](https://github.com/bbnkmp).