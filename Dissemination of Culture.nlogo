patches-own [culture walls cluster]
globals [this-cluster max-cluster num-cluster]

to setup
  clear-all
  setup-patches
  setup-links
  setup-walls
  setup-turtles
end

to go
  tick
  update-patch
  if ticks mod sample-interval = 0
    [
    update-plot
    if check-end? [stop]
    ]
end

to setup-patches
  let x 0
  let y 0
  set-default-shape turtles "square"
  repeat world-height
    [
    set x 0
    repeat world-height
      [
      ask patch x y
        [
        sprout 1 [setxy xcor ycor set color black set size 0.2]
        set pcolor white
        set culture []
        repeat num-features
          [
          set culture fput random num-traits culture
          ]
        ]
      set x x + 1
      ]
    set y y + 1
    ]
end

to setup-links
  ask turtles
    [
    create-links-with turtles-on neighbors4
      [
      set color black
      set thickness 0.2
      ]
    ]
end

to setup-walls
  let a1 0     ; 1..2
  let a2 0     ; ....
  let a3 0     ; 4..3
  let a4 0
  ask patches
    [
    ask turtles-here [set a2 who]
    ask turtles-at -1 0 [set a1 who]
    ask turtles-at 0 -1 [set a3 who]
    ask turtles-at -1 -1 [set a4 who]
    set walls (list link a1 a2 link a2 a3 link a3 a4 link a4 a1)
    update-walls
    ]
end

to setup-turtles
  ask turtles [setxy xcor + 0.5 ycor + 0.5]
end

to update-patch
  let neighbor-positions [[0 1] [1 0] [0 -1] [-1 0]]
  let neighbor random 4
  let culture-A []
  let culture-B []
  let patch-A 0
  let patch-B 0
  let P 0
  let n 0
  ask one-of patches
    [
    set culture-A culture
    set patch-A self
    ask patch-at item 0 (item neighbor neighbor-positions) item 1 (item neighbor neighbor-positions)
      [
      set culture-B culture
      set patch-B self
      ]
    set P similarity culture-A culture-B
    if (P > 0 and P < 1) and random-float 1 < P
      [
      set n difference culture-A culture-B
      set culture replace-item n culture (item n culture-B)
      update-walls
      ]
    ]
end

to update-walls
  let neighbor-positions [[0 1] [1 0] [0 -1] [-1 0]]
  let culture-A culture
  let culture-B []
  let n 0
  repeat 4
    [  
    ask patch-at item 0 (item n neighbor-positions) item 1 (item n neighbor-positions) [set culture-B culture]
    ask item n walls
      [
      set color 9.9 * similarity culture-A culture-B
      ]
    set n n + 1
    ]
end

to update-plot
  find-clusters
  set-current-plot "Connected Regions"
  set-plot-x-range 0 ticks
  set-plot-y-range 0 world-width * world-height
  set-current-plot-pen "Number"
  plotxy ticks num-cluster
  set-current-plot-pen "Largest"
  plotxy ticks max-cluster
end

to find-clusters
  set max-cluster 0
  set num-cluster 0
  let seed patch 0 0
  ask patches [set cluster nobody]
  while [seed != nobody]
    [
    ask seed
      [
      set cluster self
      set this-cluster 1
      set num-cluster num-cluster + 1
      grow-cluster
      ]
    if this-cluster > max-cluster [set max-cluster this-cluster]
    set seed one-of patches with [cluster = nobody]
    ]
end

to grow-cluster
  ask neighbors4 with [(cluster = nobody) and (culture = [culture] of myself)]
    [
    if cluster = nobody [set this-cluster this-cluster + 1]
    set cluster [cluster] of myself
    grow-cluster
    ]
end

to-report check-end?
  let end? true
  ask links
    [
    if color > 0 and color < 9.9 [set end? false]
    ]
  report end?    
end

to-report similarity [list-A list-B]
  let n 0
  let l length list-A
  let similarities 0
  repeat l
    [
    if item n list-A = item n list-B [set similarities similarities + 1]
    set n n + 1
    ]
  report similarities / l    
end

to-report difference [list-A list-B]
  let n 0
  let differences []
  repeat length list-A
    [
    if item n list-A != item n list-B [set differences lput n differences]
    set n n + 1
    ]
  report item (random length differences) differences
end
    
@#$#@#$#@
GRAPHICS-WINDOW
204
10
446
273
-1
-1
23.2
1
10
1
1
1
0
1
1
1
0
9
0
9
0
0
1
ticks

BUTTON
7
10
69
43
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
7
46
201
79
num-features
num-features
1
20
5
1
1
NIL
HORIZONTAL

SLIDER
7
82
201
115
num-traits
num-traits
1
20
10
1
1
NIL
HORIZONTAL

BUTTON
138
10
201
43
Step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
72
10
135
43
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

PLOT
449
46
765
273
Connected Regions
Time
Value
0.0
10.0
0.0
1.0
false
true
PENS
"Number" 1.0 0 -16777216 true
"Largest" 1.0 0 -2674135 true

SLIDER
449
10
621
43
sample-interval
sample-interval
10
1000
100
10
1
NIL
HORIZONTAL

@#$#@#$#@
WHAT IS IT?
-----------
This is a replication of Robert Axelrod's model of cultural dissemination, as presented in "The Dissemination of Culture: A Model with Local Convergence and Global Polarization".


HOW IT WORKS
------------
Patches are assigned a list of num-features integers which can each take on one of num-traits values. Each tag is called a feature, while it's value is called the trait.

The links in the view represent walls between patches where solid black walls mean there is no cultural similarity, and white walls mean the neighbors have the same culture.

The order of actions is as follows:
1) At random, pick a site to be active, and pick one of it's neighbors
2) With probability equal to their cultural similarity, these sites interact. The active site replaces one of the features on which they differ (if any) with the corresponding trait of the neighbor.

The model ends when no further interactions can take place.


HOW TO USE IT
-------------
Setup assigns the patches random culture based on the num-features and num-traits sliders, and updates the walls between them.

The plot "Connected Regions" has 2 pens. The black pen tracks the number of clusters of culturally identical patches, while the red pen tracks the size of the largest cluster. This is a time consuming algorithm for larger scale models, so the interval between updates is controlled by the sample-interval slider.


THINGS TO NOTICE
----------------
Q1) Try setting num-features to 5 and num-traits to 10. Under these settings, a typical culture list might be [9 6 0 3 4]. Run the model. How do the plots vary over time? Are changes gradual, or sudden?

Try running the model a few times. What different features can you see under these settings?

Q2) Try increasing num-traits to 15 and then to 20. How does this affect the final picture? Can you explain this?

Q3) With num-traits set at 20, try increasing num-features to 10. What happens now? More features means there is even more variety in culture, so the results may be surprising. What aspect of the model causes this behavior?

A1) These are the settings Axelrod uses in the paper referenced. Often, under these settings we find the culture becomes entirely uniform, and no more walls exist. The switch between generally separate cultures, and a large, connected cluster happens suddenly, where the number of clusters drops and the size of the largest cluster increases steeply.

Sometimes small islands form, and even small clusters isolated from the larger cluster by dramatic cultural differences.

A2) Increasing num-traits to 15 tends to mean the end result is several smaller clusters, through the majority of patches become connected. Further increase to 20 however tends to result in many small clusters, where the largest often occupies less than half of the total space.

A3) Though it may seem counter-intuitive, increasing num-features will tend to result in a larger cluster, and fewer islands. This is because with so many different features, the likelihood of neighbors having nothing in common is small compared with fewer features.


CREDITS AND REFERENCES
----------------------
Robert Axelrod, "The Dissemination of Culture: A Model with Local Convergence and Global Polarization"
Philip Ball - "Critical Mass"

Any suggestions or questions? e-mail: isw3@le.ac.uk
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.1
@#$#@#$#@
setup-square
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
