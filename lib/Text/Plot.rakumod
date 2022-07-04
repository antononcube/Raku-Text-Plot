use v6.d;

use Stats;

unit module Text::Plot;


#===========================================================
sub is-positional-of-numerics($obj) {
    return ($obj ~~ Positional) && ([and] $obj.map({ $_ ~~ Numeric }));
}

#===========================================================
sub get-range(@x, $frac = 0.05) {
    my @ux = unique(@x).List;
    my @range;
    if @ux.elems == 1 {
        @range = @ux[0] ?? (-1, 1) !! (@ux X+ (-0.4, 0.4)) X* abs(@ux);
    } else {
        @range = (min(@x), max(@x));
        @range[0] = @range[0] - $frac * (@range[1] - @range[0]);
        @range[1] = @range[1] + $frac * (@range[1] - @range[0]);
    }
    return @range;
}

#===========================================================

## See https://gist.github.com/Frencil/aab561687cdd2b0de04a
## https://github.com/wch/r-source/blob/b156e3a711967f58131e23c1b1dc1ea90e2f0c43/src/appl/pretty.c
##

sub pretty(@range where *.elems == 2, UInt $n) {

    my $min_n = $n / 3;
    my $shrink_sml = 0.75;
    my $high_u_bias = 1.5;
    my $u5_bias = 0.5 + 1.5 * $high_u_bias;
    my $d = abs(@range[0] - @range[1]);

    # c(cell) := "scale" here
    my $c = $d / $n;
    if log10($d) < -2 {
        $c = (max(abs($d)) * $shrink_sml) / $min_n;
    }

    ## NB: the power can be negative and this relies on exact calculation.
    my $base = 10 ** floor(log10($c));
    my $base_toFixed = 0;
    if $base < 1 {
        $base_toFixed = abs(round(log10($base)));
    }

    ## unit : from { 1,2,5,10 } * base
    ##	 such that |u - cell| is small,
    ## favoring larger (if h > 1, else smaller)  u  values;
    ## favor '5' more than '2'  if h5 > h  (default h5 = .5 + 1.5 h) */
    my $unit = $base;
    if ((2 * $base) - $c) < ($high_u_bias * ($c - $unit)) {
        $unit = 2 * $base;
        if ((5 * $base) - $c) < ($u5_bias * ($c - $unit)) {
            $unit = 5 * $base;
            if ((10 * $base) - $c) < ($high_u_bias * ($c - $unit)) {
                $unit = 10 * $base;
            }
        }
    }
    ## Result: c := cell,  u := unit,  b := base
    ## c in [	1,	         (2+ h) /(1+h) ] b ==> u=  b
    ## c in ( (2+ h)/(1+h),  (5+2h5)/(1+h5)] b ==> u= 2b
    ## c in ( (5+2h)/(1+h), (10+5h) /(1+h) ] b ==> u= 5b
    ## c in ((10+5h)/(1+h),	            10 ) b ==> u=10b
    ##
    ## ===>	2/5 *(2+h)/(1+h)  <=  c/u  <=  (2+h)/(1+h)

    my @ticks;
    my $i = 0;
    #if @range[0] > $unit {
    $i = floor(@range[0] / $unit) * $unit;
    $i = round($i, $unit);
    #}
    while $i < @range[1] {
        @ticks.push($i);
        $i += $unit;
        $i = round($i, $unit);
    }
    @ticks.push($i);

    return @ticks;
}

#===========================================================
sub get-ticks(@range) {
    #return (@range[0], @range[0] + (@range[1] - @range[0]) / 5 ... @range[1]).List;
    return pretty(@range, 5);
}

#===========================================================
multi rescale(@x) {
    return rescale(@x, (min(@x), max(@x)), (0, 1));
}
multi rescale(@x, @vrng where @vrng.elems == 2) {
    return rescale(@x, @vrng, (0, 1));
}

multi rescale(@x,
              @rng where @rng.elems == 2,
              @vrng where @vrng.elems == 2) {
    rescale(@x, @rng[0], @rng[1], @vrng[0], @vrng[1])
}

multi rescale(@x,
              Numeric $min,
              Numeric $max,
              Numeric $vmin,
              Numeric $vmax) {

    if $max != $min {
        my @res = (@x X- $min) X/ ($max - $min);
        return (@res X* ($vmax - $vmin)) X+ $vmin;
    }

    return @x X- $min;
}

#===========================================================
proto text-list-plot($x, |) is export {*}

multi text-list-plot($x, *%args) {
    return text-list-plot((^$x.elems).List, $x.List, |%args);
}

multi text-list-plot($x is copy,
                     $y is copy,
                     Str :$point-char = "*",
                     :$width is copy = 60,
                     :$height is copy = Whatever,
                     :$xLabel is copy = Whatever, :$yLabel is copy = Whatever,
                     :$xlim is copy = Whatever, :$ylim is copy = Whatever,
                     :$title = Whatever) {

    if !is-positional-of-numerics($x) {
        die "The first argument is expected to be a Positional with Numeric objects."
    }

    if !is-positional-of-numerics($y) {
        die "The second argument is expected to be a Positional with Numeric objects."
    }

    if $y.elems != $x.elems {
        die "If both first and second arguments are given they are expected to be the positionals with same number of elements."
    }

    if !($width ~~ Numeric || $height ~~ Numeric) {
        die "At least one of the arguments width and height has to be numeric."
    } elsif $height.isa(Whatever) {
        $height = 0.25 * $width
    } elsif $width.isa(Whatever) {
        $width = 4 * $height
    }

    # Removing NaN's and Inf's
    # TBD...

    my @xrange;
    if $xlim.isa(Whatever) {
        @xrange = get-range($x)
    } else {
        # TBD...
    }

    my @yrange;
    if $ylim.isa(Whatever) {
        @yrange = get-range($y)
    } else {
        # TBD...
    }

    #------------------------------------------------------
    # Initialize plot array
    #------------------------------------------------------
    my @res = (' ' xx $width * $height).rotor($width)>>.Array.Array;

    #------------------------------------------------------
    # Create axes
    #------------------------------------------------------

    # Top
    for ^$width -> $i { @res[0][$i] = '-' }

    # Bottom
    for ^$width -> $i { @res[$height - 1][$i] = '-' }

    # Left
    for ^$height -> $i { @res[$i][0] = '|' }

    # Right
    for ^$height -> $i { @res[$i][$width - 1] = '|' }

    @res[0][0] = '+';
    @res[0][$width - 1] = '+';
    @res[$height - 1][0] = '+';
    @res[$height - 1][$width - 1] = '+';

    #------------------------------------------------------
    # Get tick marks
    #------------------------------------------------------
    my @xticks = get-ticks(@xrange);
    my @yticks = get-ticks(@yrange);

    #------------------------------------------------------
    # Place tick marks
    #------------------------------------------------------

    my @xticksMarks = rescale(@xticks, (min(|$x), max(|$x)), (1, $width - 2))>>.round;
    my %xticksMarks = @xticks>>.fmt('%6.2f') Z=> @xticksMarks;
    @xticksMarks = @xticksMarks.grep({ 1 ≤ $_ ≤ $width - 2 }).List;
    %xticksMarks = %xticksMarks.grep({ 1 ≤ $_.value ≤ $width - 2 }).List;

    for @xticksMarks -> $i { @res[0][$i] = '+' }
    for @xticksMarks -> $i { @res[$height - 1][$i] = '+' }
    my @tickTextLine = ' ' xx $width;
    for %xticksMarks.kv -> $k, $v {
        my $t = $k.trim;
        for ^($t.chars) -> $i {
            @tickTextLine[$v + $i] = $t.comb[$i]
        }
    }
    @res.append($(@tickTextLine));

    my @yticksMarks = rescale(@yticks, (min(|$y), max(|$y)), ($height - 2, 1))>>.round;
    my %yticksMarks = @yticks>>.fmt('%6.2f') Z=> @yticksMarks;
    @yticksMarks = @yticksMarks.grep({ 1 ≤ $_ ≤ $height - 2 }).List;
    %yticksMarks = %yticksMarks.grep({ 1 ≤ $_.value ≤ $height - 2 }).List;

    for @yticksMarks -> $i { @res[$i][0] = '+' }
    for @yticksMarks -> $i { @res[$i][$width - 1] = '+' }
    for %yticksMarks.kv -> $k, $v { @res[$v].append($k.comb) }

    # Pad for max - y-ticks
    my $maxResLine = max(@res>>.elems);
    for ^@res.elems -> $i {
        @res[$i].append((' ' xx ($maxResLine - @res[$i].elems)))
    }

    #------------------------------------------------------
    # Plot points
    #------------------------------------------------------

    my @xplt = rescale($x, (min(|$x), max(|$x)), (1, $width - 2))>>.round;
    my @yplt = rescale($y, (min(|$y), max(|$y)), ($height - 2, 1))>>.round;

    for ^@xplt.elems -> $i {
        @res[@yplt[$i]][@xplt[$i]] = $point-char
    }

    #------------------------------------------------------
    # Place labels
    #------------------------------------------------------

    if $xLabel ~~ Str {
        my @labelLine = ' ' xx $width;
        for ^$xLabel.chars -> $i {
            @labelLine[$width / 2 - $xLabel.chars / 2 + $i] = $xLabel.comb[$i]
        }
        @res.append($(@labelLine));
    }

    if $yLabel ~~ Str {
        my @labelLine = ' ' xx $height;
        for ^$yLabel.chars -> $i {
            @labelLine[$height / 2 - $yLabel.chars / 2 + $i] = $yLabel.comb[$i]
        }
        for ^@labelLine.elems -> $i {
            @res[$i].append(' ').append(@labelLine[$i]);
        }
    }

    #------------------------------------------------------
    # Place title
    #------------------------------------------------------

    if $title ~~ Str {
        my @labelLine = ' ' xx $width;
        for ^$title.chars -> $i {
            @labelLine[$width / 2 - $xLabel.chars / 2 + $i] = $title.comb[$i]
        }
        @res.unshift($(@labelLine));
    }

    #------------------------------------------------------
    return @res>>.join.join("\n");
}