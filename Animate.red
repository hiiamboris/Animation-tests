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
    t   [float!] {parameter in the range 0.0 - 1.0}
][
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

bezier-tangent: function [
    {Calculates the tangent angle for a Bezier curve
     defined with pts at point t}
    pts [block!] {a set of pairs}
    t   [float!] {parameter in the range 0.0 - 1.0}
][
    p1: bezier-n pts t
    p2: bezier-n pts t + 0.05
    arctangent2 p2/2 - p1/2 p2/1 - p1/1
]

;------------------------------------------------------------------------------------------------

fnt: make font! [name: "Verdana" size: 30 color: 255.255.255.255]

bez-test: make block! 100
tt: 0.0
lim: 40 ; fow many points to calculate in the be\ier curve
bez-pts: [500x1000 2500x3000 3500x500 5000x1000 6000x3000]  ; 10x for sub-pixel precision
append bez-test [line-width 10 fill-pen transparent scale 0.1 0.1]
append/only bez-test collect [
    keep 'line
    repeat n lim [
        set [bx by] bezier-n bez-pts tt
        tt: n / lim
        keep reduce [as-pair to integer! bx to integer! by + 3000]
    ]
]    
b-time: 0.0

view [
    title "Animate"
    base 650x600 teal rate 60
    draw compose [
        fill-pen yello
        slide: translate 0x0 [line-width 1 box 200x30 250x80] 
        font (fnt)
        txt: text 220x30 "Alpha test"
        fill-pen sky bx1: box 50x150 80x180
        bx2: box 50x200 80x230
        bx3: box 50x250 80x280
        bx4: box 50x300 80x330
        bz: (bez-test)
        line-width 2 fill-pen papaya 
        box5: translate 0x0 rotate 0 box -25x-15 25x15
    ]
    on-time [
        tm: to float! difference now/precise st-time
        tween 'slide/2/x   000 200 2.0 4.0 tm :ease-in-out-elastic
        tween 'bx1/3/x      80 600 1.0 2.0 tm :ease-in-out-quad
        tween 'bx2/3/x      80 600 1.0 2.0 tm :ease-in-out-cubic
        tween 'bx3/3/x      80 600 1.0 2.0 tm :ease-in-out-quart
        tween 'bx4/3/x      80 600 1.0 2.0 tm :ease-in-out-quint
        tween 'fnt/color/4 255   0 2.0 1.0 tm :ease-in-sine
        tween 'fnt/color/4   0 255 4.5 0.5 tm :ease-in-sine
        tween 'txt/2/x     220 700 4.0 1.0 tm :ease-in-quint
        tween 'b-time        0 100 1.0 2.0 tm :ease-in-out-cubic
        box5/4: bezier-tangent bez-pts b-time / 100.0
        box5/2: (0x3000 + to-pair bezier-n bez-pts b-time / 100.0) * 0.1 
    ]
    on-create [print "start" st-time: now/precise]
]
