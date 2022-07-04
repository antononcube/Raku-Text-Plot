# Raku Text::Plot

This repository has a Raku package for textual (terminal) plots.

Here is the list of functions:

- [X] `text-list-plot`
- [ ] `text-plot`
- [ ] `text-density-plot`
- [ ] `text-bar-chart`
- [ ] `text-box-plot`

**Currently only `text-plot` is implemented.**

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
```
# ++---------+---------+--------+---------+---------+--------+      
# |                                                     * * *|      
# +                                             * * * *      +  5.00
# |                                     * * * *              |      
# +                             * * * *                      +  4.00
# |                        * * *                             |      
# +                  * * *                                   +  3.00
# |              * *                                         |      
# |          * *                                             |      
# +      * *                                                 +  2.00
# |    *                                                     |      
# +  *                                                       +  1.00
# |                                                          |      
# +*                                                         +  0.00
# ++---------+---------+--------+---------+---------+--------+      
#  0.00      5.00      10.00    15.00     20.00     25.00
```

Plot using both x- and y-values, and with specified axes labels and plot width and height:

```perl6
my @xs = (0, 0.1 ... 5);
say text-list-plot(@xs,  @xs>>.sin, xLabel => 'some range', yLabel => 'sin value', width => 100, height => 30);
```
```
# ++------------------+-------------------+------------------+-------------------+------------------++        
# +                         * * * * * *                                                              +  1.00  
# |                     * *             * *                                                          |        
# |                   *                     *                                                        |        
# |                 *                         * *                                                    |        
# |                *                              *                                                  |        
# |              *                                  *                                                |        
# |            *                                                                                     |        
# +          *                                       *                                               +  0.50  
# |        *                                           *                                             |        
# |                                                      *                                           |       s
# |      *                                                 *                                         |       i
# |    *                                                                                             |       n
# |  *                                                       *                                       |        
# +*                                                           *                                     +  0.00 v
# |                                                              *                                   |       a
# |                                                                                                  |       l
# |                                                                *                                 |       u
# |                                                                  *                               |       e
# |                                                                    *                             |        
# |                                                                      *                           |        
# +                                                                                                  + -0.50  
# |                                                                        *                         |        
# |                                                                          *                       |        
# |                                                                            *                     |        
# |                                                                              *                   |        
# |                                                                                **                |        
# |                                                                                   * *           *|        
# +                                                                                       * * * * *  + -1.00  
# ++------------------+-------------------+------------------+-------------------+------------------++        
#  0.00               1.00                2.00               3.00                4.00               5.00    
#                                              some range
```

Smallish plot:

```perl6
my @xs = (0, 0.4 ... 10);
say text-list-plot(@xs, -1 <<*>> @xs>>.sqrt, xLabel => 'some range', yLabel => 'sqrt value', width => 40, height => 12);
```
```
# ++------+-------+------+-------+------++        
# +*                                     +  0.00 s
# +                                      + -0.50 q
# | *                                    |       r
# +   **                                 + -1.00 t
# +      ** *                            + -1.50  
# |          * **                        |       v
# +               ** **                  + -2.00 a
# +                     ** **            + -2.50 l
# |                           ** ** *    |       u
# +                                  * **+ -3.00 e
# ++------+-------+------+-------+------++        
#  0.00   2.00    4.00   6.00    8.00   10.00   
#                some range
```

-------

## References

[BB1] Bjoern Bornkamp,
[txtplot R package](https://github.com/bbnkmp/txtplot),
([CRAN](https://github.com/cran/txtplot)),
(2020),
[GitHub/bbnkmp](https://github.com/bbnkmp).