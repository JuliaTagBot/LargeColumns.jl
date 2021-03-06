# LargeColumns

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![Build Status](https://travis-ci.org/tpapp/LargeColumns.jl.svg?branch=master)](https://travis-ci.org/tpapp/LargeColumns.jl)
[![Coverage Status](https://coveralls.io/repos/github/tpapp/LargeColumns.jl/badge.svg?branch=master)](https://coveralls.io/github/tpapp/LargeColumns.jl?branch=master)
[![codecov.io](http://codecov.io/github/tpapp/LargeColumns.jl/coverage.svg?branch=master)](http://codecov.io/github/tpapp/LargeColumns.jl?branch=master)

Manage large vectors of bits types in Julia. A thin wrapper for
mmapped binary data, with a few sanity checks and convenience
functions.

## Specification

For each dataset, the columns (vectors of equal length) and metadata
are stored in a directory like this:

```
dir/
├── layout.jld2
├── meta/
│   └ ...
├── 1.bin
├── 2.bin
├── ...
├── ...
└── ...
```

The file `layout.jld2` specifies the number and types of columns (using
[JLD2.jl](https://github.com/simonster/JLD2.jl), and the total number of
elements. The `$i.bin` files contain the data for each column, which
can be [memory mapped](https://en.wikipedia.org/wiki/Memory-mapped_file).

Additional metadata can be saved as in files in the directory
`meta`. This is ignored by this library; use the function `meta_path`
to calculate paths relative to `dir/meta`.

## Interfaces

Two interfaces are provided. Use `SinkColumns` for an *ex ante*
unknown number of elements, written sequentially. This is useful for
ingesting data.

`MmappedColumns` is useful when the number of records is known and
fixed.

Types for the columns are specified as `Tuple`s. See the docstrings
for both interfaces and the unit tests for examples.

# Acknowledgments

Work on this library was supported by the Austrian National Bank
Jubiläumsfonds grant #17378.
