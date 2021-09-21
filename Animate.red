Red [
    title: "Animation dialect tests"
    author: "Galen Ivanov"
    needs: view
]

st-time: 0
pascal: none

;------------------------------------------------------------------------------------------------
; easing functions
; the argument must be in the range 0.0 - 1.0
;------------------------------------------------------------------------------------------------
ease-linear: func [x][x]

ease-steps: func [x n][round/to x 1 / n]

ease-in-sine: func [x][1 - cos x * pi / 2]
ease-out-sine: func [x][sin x * pi / 2]
ease-in-out-sine: func [x][(cos pi * x) - 1 / -2]

ease-in-out-power: func [x n][either x < 0.5 [x ** n * (2 ** (n - 1))][1 - (-2 * x + 2 ** n / 2)]]

ease-in-quad:      func [x][x ** 2]
ease-out-quad:     func [x][2 - x * x]  ; shorter for [1 - (1 - x ** 2)]
ease-in-out-quad:  func [x][ease-in-out-power x 2]

ease-in-cubic:     func [x][x ** 3]
ease-out-cubic:    func [x][1 - (1 - x ** 3)] 
ease-in-out-cubic: func [x][ease-in-out-power x 3]

ease-in-quart:     func [x][x ** 4]
ease-out-quart:    func [x][1 - (1 - x ** 4)]
ease-in-out-quart: func [x][ease-in-out-power x 4]

ease-in-quint:     func [x][x ** 5]
ease-out-quint:    func [x][1 - (1 - x ** 5)]
ease-in-out-quint: func [x][ease-in-out-power x 5]

ease-in-expo:      func [x][2 ** (10 * x - 10)]
ease-out-expo:     func [x][1 - (2 ** (-10 * x))]
ease-in-out-expo:  func [x][
    either x < 0.5 [
        2 ** (20 * x - 10) / 2
    ][
        2 - (2 ** (-20 * x + 10)) / 2
    ]
]

ease-in-circ: func [x][1 - sqrt 1 - (x * x)] 
ease-out-circ: func [x][sqrt 1 - (x - 1 ** 2)]
ease-in-out-circ: func [x][
    either x < 0.5 [
        (1 - sqrt 1 - (2 * x ** 2)) / 2
    ][
        (sqrt 1 - (-2 * x + 2 ** 2)) + 1 / 2
    ]
]

ease-in-back: func [x /local c1 c3][
    c1: 1.70158
    c3: c1 + 1
    x ** 3 * c3 - (c1 * x * x)
]
ease-out-back: func [x /local c1 c3][
    c1: 1.70158
    c3: c1 + 1
    x - 1 ** 3 * c3 + 1 + (x - 1 ** 2 * c1) 
]
ease-in-out-back: func [x /local c1 c2][
    c1: 1.70158           ; why two constants? 
    c2: c1 * 1.525
    either x < 0.5 [
        2 * x ** 2 * (c2 + 1 * 2 * x - c2) / 2
    ][
        2 * x - 2 ** 2 * (c2 + 1 * (x * 2 - 2) + c2) + 2 / 2
    ]
]

ease-in-elastic: func [x /local c][
    c: 2 * pi / 3
    negate 2 ** (10 * x - 10) * sin x * 10 - 10.75 * c
] 
ease-out-elastic: func [x /local c][
    c: 2 * pi / 3
    (2 ** (-10 * x) * sin 10 * x - 0.75 * c) + 1
]
ease-in-out-elastic: func [x /local c][
    c: 2 * pi / 4.5
    either x < 0.5 [
        2 ** ( 20 * x - 10) * (sin 20 * x - 11.125 * c) / -2
    ][
        2 ** (-20 * x + 10) * (sin 20 * x - 11.125 * c) / 2 + 1
    ]
]
 
ease-in-bounce: func [x][1 - ease-out-bounce 1 - x] 
ease-out-bounce: func [x /local n d][
    n: 7.5625
    d: 2.75
    case [
        x < (1.0 / d) [n * x * x]
        x < (2.0 / d) [n * (x: x - (1.5   / d)) * x + 0.75]
        x < (2.5 / d) [n * (x: x - (2.25  / d)) * x + 0.9375]
        true          [n * (x: x - (2.625 / d)) * x + 0.9984375]
    ]
]
ease-in-out-bounce: func [x][
    either x < 0.5 [
        (1 - ease-out-bounce -2 * x + 1) / 2
    ][
        (1 + ease-out-bounce  2 * x - 1) / 2
    ]
]
;------------------------------------------------------------------------------------------------

tween: func [
    {Interpolates a value between value1 and value2 at time t
    in the stretch start .. start + duration using easing function ease}
    target   [word! path!] {}
    value1   [number!]     {Value to interpolate from}
    value2   [number!]     {Value to interpolate to}
    start    [float!]      {Start of the time period}
    duration [float!]      {Duration of the time period}
    t        [float!]      {Current time}
    ease     [function!]   {Easing function}
    /local
][
    if all [t >= start t < (start + duration)][
        ; not only integer! - should be a parameter!
        set target to integer! (ease t - start / duration) * (value2 - value1) + value1 
    ]
]

;------------------------------------------------------------------------------------------------
pascals-triangle: has [
    {Creates the first 30 rows of the Pascal's triangle, referenced by nCk}
    PT row
][
    row: make vector! [1]
    PT: make block! 30
    append/only PT copy row
    collect/into [
        loop 30 [
            row: add append copy row 0 head insert copy row 0
            keep/only copy row
        ]
    ] PT
]

pascal: pascals-triangle ; stores the precalculated values for the first 30 rows  

nCk: function [
    {Calculates the binomial coefficient, n choose k}
    n k
][
    pascal/(n + 1)/(k + 1)
]

bezier-n: function [
    {Calculates a point in the Bezier curve, defined by pts, at t}
    pts [block!] {a set of pairs}
    t   [float!] {offset in the curve, from 0.0 to 1.0}
][
    ; !!! The points around 0.0 and 1.00 are much sparsely located!
    ;     This leads to uneven placement of objects along the curve !!!
    ; https://dev.to/zergon321/dividing-a-bezier-curve-into-equal-segments-2hh8
    n: (length? pts) - 1
    bx: by: i: 0
    foreach p pts [
        c: (nCk n i) * ((1 - t) ** (n - i)) * (t ** i)
        bx: c * p/x + bx
        by: c * p/y + by
        i: i + 1
    ]
    reduce [bx by]
]

bezier-tangent: function [  ; needs a better name!
    {Calculates the tangent angle for a Bezier curve
     defined with pts at point t}
    pts [block!] {a set of pairs}
    t   [float!] {offset in the curve, from 0.0 to 1.0}
][
    p1: bezier-n pts t
    p2: bezier-n pts t + 0.01
    arctangent2 p2/2 - p1/2 p2/1 - p1/1
]

bezier-lengths: function [
    {Returns a block of accumulated lengths of the linear segments
     a bezier curve can be simplified to}
    pts  [block!]   {a set of 2d points defining a Bezier curve}
    segn [integer!] {number of linear segments to divide the curve into}
][
    t: 0.0
    length: 0.0
    p0: bezier-n pts t
    collect [
        repeat n segn [
           t: 1.0 + n / segn
           p1: bezier-n pts t
           keep length: length + sqrt p1/1 - p0/1 ** 2 + (p1/2 - p0/2 ** 2)
           p0: copy p1
        ]
    ]
]

half: func [a b][to integer! a + b / 2]

b-search: function [
    {Returns the index of the largest element of src 
    that is less than or equal to target}
    src    [block!]  {block of numbers}
    target [number!] {the number to be searched}
][
    L: 1
    R: length? src
    M: half L R
    while [L < R][
        case [
            src/:M < target [L: M + 1]
            src/:M > target [R: M - 1]
        ]
        M: half L R
    ]
    M
]

bezier-lerp: function [
    {Returns a point in a Bezier curve. The distance from the 
    starting point is linearly interpolated.}
    pts  [block!] {a set of 2d points defining a Bezier curve}
    u    [float!] {parameter of the interpolation, from 0.0 to 1.0}
    seg  [block!] {a precalculated block of segment lengths}
][
    len: to integer! u * last seg ; the target length. We need to obtain t from it
    either len = idx: b-search seg len [
        to float! idx / last seg
    ][
        l1: seg/:idx
        l2: any [seg/(idx + 1) last seg] 
        seg-t: len - l1 / (l2 - l1)
        to float! idx + seg-t / length? seg
    ]
]

char-offsets: function [
    {Calculates the offsets of the characters
    in a text for a given font settings}
    src [string!]
    fnt [object!]
][
    ; the size must be proportional to the src length times font size!
    txt: make face! compose [size: 30000X500 type: 'rich-text text: (src)]
    txt/font: copy fnt
    collect [
        repeat n length? src [
            keep (caret-to-offset txt n) / 10x10
        ]
    ]
]

text-along-curve: function [
    {Calculates the positions and orientatons
    of characters in a string along a curve
    and returns a draw block ready to be used}
    src     [string!] {source, text to display}
    offs    [block!]  {a block of starting offsets for each character}
    spacing [float!]  {multiplier for the space between the characters}
    dst     [block!]  {destination, a set of 2d points defining a Bezier curve}
    seg     [block!]  {a block of bezier segment lengths}
    t       [float!]  {offset in the curve, from 0.0 to 1.0}
    fix?    [logic!]  {apply normalization?} 
][
    len: last offs
    ;ww: copy offs ;test
    move offs tail offs
    
    draw-bl: make block! 5 * length? src
    append draw-bl [scale 0.1 0.1]
    tt: t
    collect/into [
        repeat n length? src [
            ttt: either fix? [bezier-lerp dst tt seg][tt]
            c-offs: to-pair bezier-n dst ttt
            angle: bezier-tangent dst ttt
            
            ;d: to integer! (pick (any [ww/(n + 1) 0x0]) - ww/:n 1) / 2 ;test
            
            keep compose/deep [
                translate (c-offs) [
                    rotate (angle) ;(as-pair d -200)
                    ;scale 10 10
                    text 0x-180 (to-string src/:n )  ; y is arbitrary here - must change it!
                    ;text (as-pair d -200) (to-string src/:n) 
                ]
            ]
            tt: t + to-float offs/:n/x / len/x * spacing ;the text is stretched 
            if tt >= 1.0 [break]
         ]
    ] draw-bl
]


;------------------------------------------------------------------------------------------------

fnt: make font! [name: "Verdana" size: 30 color: 255.255.255.255]
fnt2: make font! [name: "Verdana" size: 200 color: red]
text1: "The Red stack consists of two main layers"
ofs: char-offsets text1 fnt2

bez-test: make block! 100
tt: 0.0
lim: 100 ; fow many points to calculate in the be\ier curve
bez-pts: [500x1000 1500x3000 2800x-2000 4500x3000 6000x500]  ; 10x for sub-pixel precision
bez-segs: bezier-lengths bez-pts 500

st-txt: 0.001
bez-text: text-along-curve text1 copy ofs 0.95 bez-pts  bez-segs 0.01 false
bez-text2: text-along-curve text1 copy ofs 0.92 bez-pts  bez-segs 0.01 true

append bez-test [line-width 350 fill-pen transparent scale 0.1 0.1]
append/only bez-test collect [
    keep 'line
    repeat n lim [
        set [bx by] bezier-n bez-pts tt
        tt: n / lim
        keep reduce [as-pair to integer! bx to integer! by]
    ]

]    

b-time: 0.0

view [
    title "Animate"
    ;elapsed: text "0.0"
    base 650x350 teal rate 60
    draw compose [
        ;fill-pen yello
        ;slide: translate 0x0 [line-width 1 box 200x30 250x80] 
        ;font fnt
        ;txt: text 220x30 "Alpha test"
        ;fill-pen sky bx1: box 50x150 80x180
        ;bx2: box 50x200 80x230
        ;bx3: box 50x250 80x280
        ;bx4: box 50x300 80x330
        pen yello
        line-width 30 
        bz: (bez-test)
        
        font fnt2
        ;translate 0x300
        bzt: (bez-text)
        translate 0x1000
        scale 10 10
        (bez-test)
        (bez-text2)
        ;box5: translate 0x0 rotate 0 box -25x-15 25x15
        
    ]
    on-time [
        tm: to float! difference now/precise st-time
        ;elapsed/data: round/to tm 0.01
        ;tween 'slide/2/x   000 200 2.0 4.0 tm :ease-in-out-elastic
        ;tween 'bx1/3/x      80 600 1.0 2.0 tm :ease-in-out-quad
        ;tween 'bx2/3/x      80 600 1.0 2.0 tm :ease-in-out-cubic
        ;tween 'bx3/3/x      80 600 1.0 2.0 tm :ease-in-out-quart
        ;tween 'bx4/3/x      80 600 1.0 2.0 tm :ease-in-out-quint
        ;tween 'fnt/color/4 255   0 2.0 1.0 tm :ease-in-sine
        ;tween 'fnt/color/4   0 255 4.5 0.5 tm :ease-in-sine
        ;tween 'txt/2/x     220 700 4.0 1.0 tm :ease-in-quint
        ;tween 'b-time        0 100 1.0 2.0 tm :ease-in-out-cubic
        ;tween 'st-txt        100 1 2.0 6.0 tm :ease-in-out-sine
        
        ;clear find face/draw 'bzt
        ;append face/draw text-along-curve text1 ofs 1.0 bez-pts st-txt / 100.0
        
        ;box5/4: bezier-tangent bez-pts b-time / 100.0
        ;box5/2: (0x3000 + to-pair bezier-n bez-pts b-time / 100.0) * 0.1 
    ]
    on-create [print "start" st-time: now/precise]
]
