# Raku Text::Plot

This repository has a Raku package for textual (terminal) plots.

Here is the list of functions:

- [X] `text-plot`
- [ ] `text-density`
- [ ] `text-curve`
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
 
Simple plot with y-values only

```perl6
use Text::Plot;
say text-plot( (^30)>>.sqrt);
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
say text-plot( @xs,  @xs>>.sin, xLabel => 'some range', yLabel => 'sin value', width => 100, height => 30);
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
say text-plot( @xs, (-1 X* @xs>>.sqrt).List, xLabel => 'some range', yLabel => 'sqrt value', width => 50, height => 16);
```
```
# ++--------+---------+--------+---------+--------++        
# +*                                               +  0.00  
# |                                                |        
# +                                                + -0.50 s
# |  *                                             |       q
# +    *                                           + -1.00 r
# |      * *                                       |       t
# +         * *                                    + -1.50  
# |             * *                                |       v
# +                 * *                            + -2.00 a
# |                     * **                       |       l
# +                          * * *                 + -2.50 u
# |                                * * *           |       e
# +                                      ** * *    + -3.00  
# |                                             * *|        
# ++--------+---------+--------+---------+--------++        
#  0.00     2.00      4.00     6.00      8.00     10.00   
#                     some range
```

-------

## References

[BB1] Bjoern Bornkamp,
[txtplot R package](https://github.com/bbnkmp/txtplot),
([CRAN](https://github.com/cran/txtplot)),
(2020),
[GitHub/bbnkmp](https://github.com/bbnkmp).