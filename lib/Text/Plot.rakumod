use v6.d;

unit module Text::Plot;


#===========================================================
sub is-positional-of-numerics($obj) {
    return ($obj ~~ Positional) && ([and] $obj.map({ $_ ~~ Numeric }));
}

sub is-positional-of-numeric-pairs($obj) {
    return ($obj ~~ Positional) && ([and] $obj.map({ is-positional-of-numerics($_) && $_.elems == 2 }));
}

sub is-positional-of-strings($obj) {
    return ($obj ~~ Positional) && ([and] $obj.map({ $_ ~~ Str }));
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
sub make-tick-text-line(@xticks is copy, @xrange, UInt $width, Str $x-tick-labels-format, &x-tick-labels-func = WhateverCode) {
    my @xticksMarks = rescale(@xticks, (@xrange[0], @xrange[1]), (1, $width - 2))>>.round;

    if ! &x-tick-labels-func.isa(WhateverCode) {
        @xticks = @xticks>>.&x-tick-labels-func
    }

    my %xticksMarks = @xticks>>.fmt($x-tick-labels-format) Z=> @xticksMarks;

    @xticksMarks = @xticksMarks.grep({ 1 ≤ $_ ≤ $width - 2 }).List;
    %xticksMarks = %xticksMarks.grep({ 1 ≤ $_.value ≤ $width - 2 }).List;

    my @tickTextLine = ' ' xx $width;
    for %xticksMarks.kv -> $k, $v {
        my $t = $k.trim;
        for ^($t.chars) -> $i {
            @tickTextLine[$v + $i] = $t.comb[$i]
        }
    }

    return %(:@tickTextLine, :@xticksMarks)
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

    my @p3 = (@p1 Z @p2).map({ ($_[1] eq ' ') ?? $_[0] !! $_[1] });

    return @p3.join();
}

#===========================================================
#| Make a string that represents a list-plot of the given arguments.
#| * C<$x> - Data points. If C<$y> is specified then C<$x> is interpreted as X-coordinates.
#| * C<$y> - Y-coordinates.
#| * C<:$point-char> - Plot points character.
#| * C<:$width> - Width of the plot.
#| * C<:$height> - Height of the plot.
#| * C<:$title> - Title of the plot.
#| * C<:$x-label> - Label of the X-axis. If Whatever, then no label is placed.
#| * C<:$y-label> - Label of the Y-axis. If Whatever, then no label is placed.
#| * C<:$x-limit> - Limits for the X-axis.
#| * C<:$y-limit> - Limits for the Y-axis.
#| * C<:$x-tick-labels-format> - X-axis tick labels format.
#| * C<:$y-tick-labels-format> - Y-axis tick labels format.
proto text-list-plot($x, |) is export {*}

multi text-list-plot(Seq $x, *%args) {
    return text-list-plot($x.List, |%args)
}

multi text-list-plot($x, *%args) {
    if is-positional-of-numeric-pairs($x) {

        return text-list-plot($x.map(*[0]).List, $x.map(*[1]).List, |%args);

    } elsif $x ~~ Positional && ([&&] $x.map({ is-positional-of-numeric-pairs($_) })) {

        my $pcharSpec = %args<point-char>:exists ?? %args<point-char> !! Whatever;

        my @pchars;
        if $pcharSpec.isa(Whatever) || $pcharSpec ~~ Str {
            if $x.elems ≤ 7 {
                @pchars = <* □ ▽ ❍ ◇ ▷ ☉>[^$x.elems];
            } elsif $x.elems ≤ 26 {
                @pchars = ('a'..'z')[^$x.elems];
            }
            if $pcharSpec ~~ Str { @pchars[0] = $pcharSpec; }

        } else {
            if $pcharSpec ~~ Positional && $pcharSpec.elems ≥ $x.elems {
                @pchars = |$pcharSpec;
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
        $xRange = %args<x-limit> // $xRange;

        my $yRange = [Inf, -Inf];
        for $x.Array -> $x {
            my $r = get-range( $x.map({ $_[1] }) );
            $yRange[0] = min($yRange[0], $r[0]);
            $yRange[1] = max($yRange[1], $r[1]);
        }
        $yRange = %args<y-limit> // $yRange;

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

    if $x ~~ Seq { $x = $x.List; }
    if $y ~~ Seq { $y = $y.List; }

    my @xrange;
    given $x-limit {
        when $_.isa(Whatever) { @xrange = get-range($x) }
        when $_ ~~ Numeric { @xrange = (0, $x-limit).sort.List; }
        when $_ ~~ Positional && $_.elems == 2 { @xrange = [|$_.sort] }
        default {
            die 'The value of the x-limit is expected a number, a list of two numbers, or Whatever.';
        }
    }

    my @yrange;
    given $y-limit {
        when $_.isa(Whatever) { @yrange = get-range($y) }
        when $_ ~~ Numeric { @yrange = (0, $y-limit).sort.List; }
        when $_ ~~ Positional && $_.elems == 2 { @yrange = [|$_.sort] }
        default {
            die 'The value of the y-limit is expected a number, a list of two numbers, or Whatever.';
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
    if $x-tick-labels-format.isa(Whatever) {
        my $b = ceiling(log10(max(@xticks>>.abs)));
        $x-tick-labels-format = "%{ $b + 5 }.2f"
    } elsif !$x-tick-labels-format ~~ Str {
        die "The value of the argument x-tick-labels-format is expected to be a string or Whatever."
    }

    my %ttlRes = make-tick-text-line(@xticks, @xrange, $width, $x-tick-labels-format);
    my @tickTextLine = |%ttlRes<tickTextLine>;
    my @xticksMarks = |%ttlRes<xticksMarks>;

    for @xticksMarks -> $i { @res[0][$i] = '+' }
    for @xticksMarks -> $i { @res[$height - 1][$i] = '+' }

    @res.append($(@tickTextLine));

    my @yticksMarks = rescale(@yticks, (@yrange[0], @yrange[1]), ($height - 2, 1))>>.round;

    if $y-tick-labels-format.isa(Whatever) {
        my $b = ceiling(log10(max(@yticks>>.abs)));
        $y-tick-labels-format = "%{$b+5}.2f"
    } elsif ! $y-tick-labels-format ~~ Str {
        die "The value of the argument y-tick-labels-format is expected to be a string or Whatever."
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
    # Remove occasional missing "pixels."
    # This should not be happening!
    # It seems to be because of rescaling -- debug with
    #   say text-list-plot(((^10) Z (^10)), width=>43);
    @res = do for @res -> @row {
        @row.map({ $_ // ' '})
    }

    #------------------------------------------------------
    return @res>>.join.join("\n");
}

#===========================================================
#| Make a string that represents a Pareto principle adherence list-plot of the given arguments.
#| Takes all optional arguments as C<&text-list-plot>.
#| * C<$x> - Data vector with elements that are numbers or strings.
#| * C<:$normalize> - Should the cumulative sum be normalized or not?
#| * C<:$point-char> - Plot points character.
#| * C<:$width> - Width of the plot.
#| * C<:$height> - Height of the plot.
#| * C<:$title> - Title of the plot.
#| * C<:$x-label> - Label of the X-axis. If Whatever, then no label is placed.
#| * C<:$y-label> - Label of the Y-axis. If Whatever, then no label is placed.
#| * C<:$x-limit> - Limits for the X-axis.
#| * C<:$y-limit> - Limits for the Y-axis.
#| * C<:$x-tick-labels-format> - X-axis tick labels format.
#| * C<:$y-tick-labels-format> - Y-axis tick labels format.
proto text-pareto-principle-plot($x, *%args) is export {*}

multi text-pareto-principle-plot($x, *%args) {

    my @tally;
    if $x ~~ Map {
        @tally = |$x.keys.BagHash.values;
    } elsif is-positional-of-numeric-pairs($x) {
        @tally = |$x.map({ $_[1] });
    } elsif is-positional-of-numerics($x) {
        @tally = |$x;
    } elsif is-positional-of-strings($x) {
        @tally = |$x.BagHash.values;
    } else {
        die "The first argument is expected to be a Positional with Numeric objects, Positional with Str objects, a Map, or Positional of Positionals.";
    }

    my %args2 = |%args.grep({ $_.key ne 'normalize' }).Hash;

    # Pareto statistic computations
    @tally = @tally.sort.reverse;

    my Bool $normalize = %args<normalize> // True;

    my @cumSum = produce(&[+], @tally);

    my $tsum = @tally.sum;
    if $normalize && $tsum != 0 {
        @cumSum = @cumSum X* 1/$tsum;
    }

    # Pareto axis ticks
    my @pRange = get-range((^@cumSum.elems).List);
    my @pTicks = get-ticks(@pRange);
    my %ttlRes = make-tick-text-line(@pTicks, @pRange, %args<width> // 60, '%3.2f', { $_ / @cumSum.elems} );

    # Base list-plot
    my $basePlot = text-list-plot(@cumSum, |%args2);

    # Hacky solution to add the Pareto ticks in case a title has been put in
    $basePlot ~~ s/ [ ^ | <?after \s> ] '+' ['-' | '+']+ '+' <?before \s>/{%ttlRes<tickTextLine>.join}\n$//;

    # Result
    return $basePlot;
}

#===========================================================
sub estimate-pdf(@data, $bins = 10, Str:D :$type = 'prob') {
    my $min = @data.min;
    my $max = @data.max;
    my $bin-width = ($max - $min) / $bins;
    my %histogram;

    for @data -> $value {
        my $bin = Int(($value - $min) / $bin-width);
        %histogram{$bin}++;
    }

    my %pdf;
    if $type.lc ∈ <count counts> {
        %pdf = %histogram
    } elsif $type.lc ∈ <probability probabilities prob probs> {
        for %histogram.kv -> $bin, $count {
            %pdf{$bin} = $count / @data.elems;
        }
    } elsif $type.lc ∈ <pdf cdf> {
        for %histogram.kv -> $bin, $count {
            %pdf{$bin} = $count / @data.elems / $bin-width;
        }
        if $type.lc eq 'cdf' {
            my @pairs = %histogram.kv.rotor(2).sort(*.head.Int);
            my @acc = [\+] @pairs.map(*.tail);
            %pdf = @pairs.map(*.head) Z=> (@acc >>/>> @acc.tail );
        }
    } else {
        die "Unknown histogram type."
    }

    return %(:%pdf, :$min, :$max, :$bin-width, :$bins);
}

#===========================================================
#| Make a string that represents a histogram for the given arguments.
#| Takes all optional arguments as C<&text-list-plot>.
#| * C<@data> - Data vector of numbers.
#| * C<:$type> - Type of the histogram one of "count", "probability", "PDF", or "CDF".
#| * C<:$bins> - Number of bins.
#| * C<:$point-char> - Plot points character.
#| * C<:$width> - Width of the plot.
#| * C<:$height> - Height of the plot.
#| * C<:$title> - Title of the plot.
#| * C<:$x-label> - Label of the X-axis. If Whatever, then no label is placed.
#| * C<:$y-label> - Label of the Y-axis. If Whatever, then no label is placed.
#| * C<:$x-limit> - Limits for the X-axis.
#| * C<:$y-limit> - Limits for the Y-axis.
#| * C<:$x-tick-labels-format> - X-axis tick labels format.
#| * C<:$y-tick-labels-format> - Y-axis tick labels format.
proto sub text-histogram(@data,
                         UInt:D $bins = 20,
                         Str:D :$type = 'counts',
                         Bool:D :$filled = True,
                         *%args) is export {*}

multi sub text-histogram(@data,
                         UInt:D $bins = 20,
                         Str:D :$type = 'counts',
                         Bool:D :$filled = True,
                         *%args ) {

    my %res = estimate-pdf(@data, $bins, :$type);

    my @points = %res<pdf>.sort({ $_.key.Int }).map({ [$_.key * %res<bin-width> + %res<min>, $_.value] });

    return do if $filled {
        my $width = %args<width> // 60;
        my $height = %args<height> // Whatever;
        if $height.isa(Whatever) {
            $height = floor(0.25 * $width);
        }
        my @fill = %res<pdf>.sort({ $_.key.Int }).map(-> $p { (0, $p.value / $height ... $p.value).map({ [$p.key * %res<bin-width> + %res<min>, $_] }) }).map(*.Slip);
        text-list-plot([@fill, @points], |%args)
    } else {
        text-list-plot(@points, |%args)
    }
}

#===========================================================
#| Make an HTML image ('<img ...>') spec from a Base64 string.
#| C<$b> : A Base64 string.
#| C<:$width> : Width of the image.
#| C<:$height> : Width of the image.
#| Returns a string.
proto from-base64(Str $from, $to = Whatever, :$width = Whatever, :$height = Whatever, |) is export {*}

multi from-base64(Str $b is copy,
                  $to where $to.isa(Whatever) || $to ~~ Str && $to eq 'html' = Whatever,
                  :$width = Whatever,
                  :$height = Whatever,
                  :$alt = Whatever,
                  :$kind is copy = Whatever,
                  Bool :$strip-md = True
        --> Str) is export {

    my $prefix = '<img';
    if $width ~~ Int { $prefix ~= ' width="' ~ $width.Str ~ '"';}
    if $height ~~ Int { $prefix ~= ' height="' ~ $height.Str ~ '"';}
    if $alt ~~ Str { $prefix ~= ' alt="' ~ $alt ~ '"';}
    if $kind.isa(Whatever) || $kind !~~ Str { $kind = 'png'; }

    if $strip-md && ($b ~~ / ^ '![](data:image/png;base64,' /) {
        $b = $b.subst(/ ^ '![](data:image/png;base64,' /, '').subst( /')' $/, '');
    }

    my $imgStr = $prefix ~ ' src="data:image/' ~ $kind ~ ';base64,$IMGB64">';
    return $imgStr.subst('$IMGB64',$b);
}