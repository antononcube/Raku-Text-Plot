use v6.d;

unit module Text::Plot;


#===========================================================
sub is-positional-of-numerics($obj) {
    return ($obj ~~ Positional) && ([and] $obj.map({ $_ ~~ Numeric }));
}

sub is-positional-of-numeric-pairs($obj) {
    return ($obj ~~ Positional) && ([and] $obj.map({ $_ ~~ Positional && $_.elems == 2 }));
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
#| Overlay text plots
proto text-plot-overlay(|) is export {*}

#| Overlay text plots
multi text-plot-overlay($tplot1, $tplot2) {
    my @p1 = $tplot1.comb.flat;
    my @p2 = $tplot2.comb.flat;

    if @p1.elems != @p2.elems {
        die "The given plots are expected to have the same number of characters.";
    }

    my @p3 = (@p1 Z @p2).map({ $_[0] eq ' ' ?? $_[1] !! $_[0] });

    return @p3.join();
}

#===========================================================
#| Make a string that represents a list-plot of the given arguments.
#| * C<$x> - Data points. If C<$y> is specified then C<$x> is interpreted as X-coordinates.
#| * C<$y> - Y-coordinates.
#| * C<$point-char> - Plot points character.
#| * C<$width> - Width of the plot.
#| * C<$height> - Height of the plot.
#| * C<$title> - Title of the plot.
#| * C<$x-label> - Label of the X-axis. If Whatever, then no label is placed.
#| * C<$y-label> - Label of the Y-axis. If Whatever, then no label is placed.
#| * C<$x-limit> - Limits for the X-axis.
#| * C<$y-limit> - Limits for the Y-axis.
#| * C<$x-tick-labels-format> - X-axis tick labels format.
#| * C<$y-tick-labels-format> - Y-axis tick labels format.
proto text-list-plot($x, |) is export {*}

multi text-list-plot($x, *%args) {
    if is-positional-of-numeric-pairs($x) {

        return text-list-plot($x.map(*[0]).List, $x.map(*[1]).List, |%args);

    } elsif $x ~~ Positional && ([&&] $x.map({ is-positional-of-numeric-pairs($_) })) {

        my @pchars;
        if %args<point-char>:exists && (%args<point-char>.isa(Whatever) || %args<point-char> ~~ Str) {
            if $x.elems ≤ 10 {
                @pchars = <* □ ❍ ▽ ◇ ◦ ☉ ♡ ♺ ✝︎>[^$x.elems];
            } elsif $x.elems ≤ 26 {
                @pchars = ('a'..'z')[^$x.elems];
            }
            if %args<point-char> ~~ Str { @pchars[0] = %args<point-char>; }

        } elsif %args<point-char>:exists {
            if %args<point-char> ~~ Positional && %args<point-char>.elems ≥ $x.elems {
                @pchars = |%args<point-char>;
            }
        }

        die "Please provide {$x.elems} point characters (for the argument 'point-char')." unless @pchars;

        @pchars = @pchars[^$x.elems];

        my $xRange = [Inf, -Inf];
        for $x.Array -> $x {
            my $r = get-range( $x.map({ $_[0] }) );
            $xRange[0] = min($xRange[0], $r[0]);
            $xRange[1] = max($xRange[1], $r[1]);
        }

        my $yRange = [Inf, -Inf];
        for $x.Array -> $x {
            my $r = get-range( $x.map({ $_[1] }) );
            $yRange[0] = min($yRange[0], $r[0]);
            $yRange[1] = max($yRange[1], $r[1]);
        }

        my @tplots = ($x.Array Z @pchars).map({ text-list-plot($_[0], |%args, point-char => $_[1], x-limit => $xRange, y-limit => $yRange) });
        my $res = @tplots[0];
        for @tplots[1..(*-1)] -> $tp { $res = text-plot-overlay($res, $tp) }
        return $res;

    }

    return text-list-plot((^$x.elems).List, $x.List, |%args);
}

multi text-list-plot($x is copy,
                     $y is copy,
                     Str :pointChar(:$point-char) = "*",
                     :$width is copy = 60,
                     :$height is copy = Whatever,
                     :$title = Whatever,
                     :xLimit(:$x-limit) is copy = Whatever,
                     :yLimit(:$y-limit) is copy = Whatever,
                     :xLabel(:$x-label) is copy = Whatever,
                     :yLabel(:$y-label) is copy = Whatever,
                     :xTickLabelsFormat(:$x-tick-labels-format) is copy = Whatever,
                     :yTickLabelsFormat(:$y-tick-labels-format) is copy = Whatever) {

    if !is-positional-of-numerics($x) {
        die "The first argument is expected to be a Positional with Numeric objects" ~
                " or a Positional with two-element Positional's of Numeric objects."
    }

    if !is-positional-of-numerics($y) {
        die "The second argument is expected to be a Positional with Numeric objects."
    }

    if $y.elems != $x.elems {
        die "If both first and second arguments are given, then they are expected to be the positionals with same number of elements."
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
    given $x-limit {
        when $_.isa(Whatever) { @xrange = get-range($x) }
        when $_ ~~ Numeric { @xrange = (0, $x-limit).sort.List; }
        when $_ ~~ Positional && $_.elems == 2 { @xrange = [|$_.sort] }
        default {
            die 'The value of the xLimit is expected a number, a list of two numbers, or Whatever.';
        }
    }

    my @yrange;
    given $y-limit {
        when $_.isa(Whatever) { @yrange = get-range($y) }
        when $_ ~~ Numeric { @yrange = (0, $y-limit).sort.List; }
        when $_ ~~ Positional && $_.elems == 2 { @yrange = [|$_.sort] }
        default {
            die 'The value of the yLimit is expected a number, a list of two numbers, or Whatever.';
        }
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

    my @xticksMarks = rescale(@xticks, (@xrange[0], @xrange[1]), (1, $width - 2))>>.round;

    if $x-tick-labels-format.isa(Whatever) {
        my $b = ceiling(log10(max(@xticks>>.abs)));
        $x-tick-labels-format = "%{$b+5}.2f"
    } elsif ! $x-tick-labels-format ~~ Str {
        die "The value of the argument xTickFormatLable is expected to be a string or Whatever."
    }

    my %xticksMarks = @xticks>>.fmt($x-tick-labels-format) Z=> @xticksMarks;

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

    my @yticksMarks = rescale(@yticks, (@yrange[0], @yrange[1]), ($height - 2, 1))>>.round;

    if $y-tick-labels-format.isa(Whatever) {
        my $b = ceiling(log10(max(@yticks>>.abs)));
        $y-tick-labels-format = "%{$b+5}.2f"
    } elsif ! $y-tick-labels-format ~~ Str {
        die "The value of the argument yTickFormatLable is expected to be a string or Whatever."
    }

    my %yticksMarks = @yticks>>.fmt($y-tick-labels-format) Z=> @yticksMarks;
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

    my @xplt = rescale($x, (@xrange[0], @xrange[1]), (1, $width - 2))>>.round;
    my @yplt = rescale($y, (@yrange[0], @yrange[1]), ($height - 2, 1))>>.round;

    for ^@xplt.elems -> $i {
        @res[@yplt[$i]][@xplt[$i]] = $point-char
    }

    #------------------------------------------------------
    # Place labels
    #------------------------------------------------------

    if $x-label ~~ Str {
        my @labelLine = ' ' xx $width;
        for ^$x-label.chars -> $i {
            @labelLine[$width / 2 - $x-label.chars / 2 + $i] = $x-label.comb[$i]
        }
        @res.append($(@labelLine));
    }

    if $y-label ~~ Str {
        my @labelLine = ' ' xx $height;
        for ^$y-label.chars -> $i {
            @labelLine[$height / 2 - $y-label.chars / 2 + $i] = $y-label.comb[$i]
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
        for ^($title.Str.chars) -> $i {
            @labelLine[$width / 2 - $title.chars / 2 + $i] = $title.comb[$i]
        }
        @res.unshift($(@labelLine));
    }

    #------------------------------------------------------
    return @res>>.join.join("\n");
}