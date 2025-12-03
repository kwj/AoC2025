# Advent of Code 2025

URL: https://adventofcode.com/2025

## Requirement

I used the Julia programming language.

* [Julia](https://julialang.org/) (confirmed to work with Julia v1.12.2)

<!--
The following external package was used.

- [DataStructures.jl](https://github.com/JuliaCollections/DataStructures.jl) v0.19.3

And then, Julia's standard libraries:

- Statistics
-->
## Solutions

* [Day 1: Secret Entrance](./src/day_01/d01.jl) d01_p1(), d01_p2()
* [Day 2: Gift Shop](./src/day_02/d02.jl) d02_p1(), d02_p2()
* [Day 3: Lobby](./src/day_03/d03.jl) d03_p1(), d03_p2()
<!--
* [Day 4: ](./src/day_04/d04.jl) d04_p1(), d04_p2()
* [Day 5: ](./src/day_05/d05.jl) d05_p1(), d05_p2()
* [Day 6: ](./src/day_06/d06.jl) d06_p1(), d06_p2()
* [Day 7: ](./src/day_07/d07.jl) d07_p1(), d07_p2()
* [Day 8: ](./src/day_08/d08.jl) d08_p1(), d08_p2()
* [Day 9: ](./src/day_09/d09.jl) d09_p1(), d09_p2()
* [Day 10: ](./src/day_10/d10.jl) d10_p1(), d10_p2()
* [Day 11: ](./src/day_11/d11.jl) d11_p1(), d11_p2()
* [Day 12: ](./src/day_12/d12.jl) d12_p1(), d12_p2()
-->

## How to use

### [First time only] Setup dependencies for this project

```console
$ sh solve.sh init
```

### Place puzzle input data files into each solution folder in advance

For example, if the input file for Day 1 is `input`:

```console
$ ls src/day_01/
d01.jl  input
$
```

### Start Julia REPL

```console
$ sh solve.sh
               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.12.2 (2025-11-20)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org release
|__/                   |

julia>
```

### Run solutions

For example, both parts of Day 1 have their own solutions.

```julia
julia> d01_p1("input")
****

julia> d01_p2("input")
****
```


## Note

There are no puzlle input data files in this repository.
Please get them from the AoC 2025 site.

Please see [here](https://adventofcode.com/about#faq_copying) for the reasons.
