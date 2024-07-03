# LibLZO.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://reallyasi9.github.io/LibLZO.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://reallyasi9.github.io/LibLZO.jl/dev/)
[![Build Status](https://github.com/reallyasi9/LibLZO.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/reallyasi9/LibLZO.jl/actions/workflows/CI.yml?query=branch%3Amain)

A Julia interface to [liblzo2](https://www.oberhumer.com/opensource/lzo/).

## Synopsis

Install:

```julia
using Pkg
Pkg.add("LibLZO")
```

Compress and decompress bytes:

```julia
using LibLZO

const lorem = b"""Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor
in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur
sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est
laborum."""

c_default = compress(lorem) # default: LZO1X_1

@assert length(c_default) < length(lorem)

decompressed = decompress(c_default) # default: LZO1X

@assert decompressed == lorem
```

Specify the LZO algorithm:

```julia
# By Type
c_lzo1y = compress(LZO1Y, lorem)
d_lzo1y = decompress(LZO1Y, c_lzo1y)
@assert d_lzo1y == lorem

# By Symbol
c_lzo1z = compress(:LZO1Z, lorem)
d_lzo1z = decompress(:LZO1Z, c_lzo1z)
@assert d_lzo1z == lorem

# By String
c_lzo1f = compress("LZO1F", lorem)
d_lzo1f = decompress("LZO1F", c_lzo1f)
@assert d_lzo1f == lorem

# With kwargs (works with Type, Symbol, and String versions)
c_lzo1c = compress(LZO1C, lorem; compression_level=9)
d_lzo1c = decompress(LZO1C, c_lzo1c)
@assert d_lzo1c == lorem

# By struct (saves on working memory allocations)
lzo = LZO1X_999()
c_lzo1x = compress(lzo, lorem)
d_lzo1x = decompress(lzo, c_lzo1x)
@assert d_lzo1x == lorem
```

## Support Matrix

This package exports the following methods for interfacing with liblzo2:

- `compress(algo, src::AbstractVector{UInt8})`: compress data in `src` using algorithm `algo` and return the result.
- `unsafe_compress!(algo, dest::AbstractVector{UInt8}, src::AbstractVector{UInt8})`: compress data from `src` to `dest` using algorithm `algo` with no overflow checking and return the number of bytes overwritten at the front of `dest`.
- `decompress(algo, src::AbstractVector{UInt8})`: decompress data in `src` using algorithm `algo` and return the result.
- `decompress!(algo, dest::AbstractVector{UInt8}, src::AbstractVector{UInt8})`: decompress data in `src` to `dest` in-place using algorithm `algo` and return the number of bytes written, or throw an exception if `dest` is not large enough to hold the decompressed version of `src`.
- `unsafe_decompress!(algo, dest::AbstractVector{UInt8}, src::AbstractVector{UInt8})`: decompress data from `scr` to `dest` using algorithm `algo` with no overflow checking and return the number of bytes overwritten at the front of `dest`.
- `optimize!(algo, src::AbstractVector{UInt8})`: attempt to reduce the size of data in `src` that was compressed using algorithm `algo`, operating on `src` in-place.
- `unsafe_optimze!(algo, dest::AbstractVector{UInt8}, src::AbstractVector{UInt8})`: attempt to reduce the size of data in `src` that was compressed using algorithm `algo` by decompressing it into `dest` with no overflow checking, operating on `src` in-place.

The package also exports the following LZO algorithm types, representing all the compression, decompression, and optimization functions exported by liblzo2:

- LZO1X family:
  - `LZO1X_1` (also exported as `LZO1X` and `LZO`)
  - `LZO1X_1_11`
  - `LZO1X_1_12`
  - `LZO1X_1_15`
  - `LZO1X_999`
- LZO1Y family:
  - `LZO1Y_1` (also exported as `LZO1Y`)
  - `LZO1Y_999`
- LZO1Z family:
  - `LZO1Z_999` (also exported as `LZO1Z`)
- LZO1 family:
  - `LZO1`
  - `LZO1_99`
- LZO1A family:
  - `LZO1A`
  - `LZO1A_99`
- LZO1B family:
  - `LZO1B`
  - `LZO1B_99`
- LZO1C family:
  - `LZO1C`
  - `LZO1C_99`
  - `LZO1C_999`
- LZO1F family:
  - `LZO1F_1` (also exported as `LZO1F`)
  - `LZO1F_999`
- LZO2A family:
  - `LZO1A_999` (also exported as `LZO2A`)

The following matrix describes which methods are available for which LZO family types:

| Family | compress | unsafe_compress! | decompress/decompress! | unsafe_decompress! | optimize! | unsafe_optimize! |
|-------:|:--------:|:----------------:|:----------:|:------------------:|:---------:|:----------------:|
| LZO1X | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| LZO1Y | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| LZO1Z | ✅ | ✅ | ✅ | ✅ | ⛔ | ⛔ |
| LZO1 | ✅ | ✅ | ⛔ | ✅ | ⛔ | ⛔ |
| LZO1A | ✅ | ✅ | ⛔ | ✅ | ⛔ | ⛔ |
| LZO1B | ✅ | ✅ | ✅ | ✅ | ⛔ | ⛔ |
| LZO1C | ✅ | ✅ | ✅ | ✅ | ⛔ | ⛔ |
| LZO1F | ✅ | ✅ | ✅ | ✅ | ⛔ | ⛔ |
| LZO2A | ✅ | ✅ | ✅ | ✅ | ⛔ | ⛔ |

## Notes and Warnings

### "Unsafe" means UNSAFE!
The `unsafe_*` methods are truly unsafe: if the user-supplied destination vector is not large enough to hold the output, the [behavior is undefined](https://en.cppreference.com/w/c/language/behavior) and [very bad things could happen](https://devblogs.microsoft.com/oldnewthing/20140627-00/?p=633). Unless you are absolutely sure about what you are doing and are in complete control of the source data, use the `compress`, `decompress`/`decompress!`, and `optimize!` methods instead.

### Always use the same algorithm family that was used to compress data to decompress that data
This should go without saying, but if you attempt to decompress data with a different algorithm than was used to compress the data, undefined behavior will occur. This will typically result in an exception being thrown by the safe `decompress`/`decompress!` methods, but not always: for instance, data compressed by the LZO1X family can usually be decompressed using the LZO1Y family without throwing an exception, but the output will be gibberish. There is no good way for the `decompress`/`decompress!` methods to detect the algorithm used to compress the data, so it is up to the user to keep the compression and decompression algorithms aligned.

That being said, all algorithms in the same algorithm _family_ use the same underlying decompression function. You can, for instance, compress data using `LZO1X_1` and decompress it using `LZO1X_999` without any issues.

### Safe decompression may mean multiple attempts to decompress
The safe decompression method `decompress` works by attempting to decompress the source into a destination vector, catching the overrun exception returned by the liblzo2 library, then increasing the size of the destination and trying again until the decompression succeeds. This means the method may take several times longer and make more allocations than expected to successfully decompress data. If decompression speed or memory efficiency is paramount, use the in-place `decompress!` or `unsafe_decompress!` methods, but **be warned that "unsafe" means UNSAFE** (see above).

### Optimization doesn't do much, if anything at all
The optimization feature of the LZO1X and LZO1Y family of algorithms attempts to shuffle around literal copy commands to save on storage and potentially improve decompression speed. Because of the rarity of the special circumstances required to shuffle the literal copy commands around, optimization is expected to reduce the number of bytes necessary to store the compressed data by at most 0.01%, and benchmarks I have performed on modern processors show no difference in decompression speeds between optimized and unoptimized data. The methods are included for completeness' sake, but I do not recommend their use.

Because the compressed data have to be completely decompressed into memory during the optimization process, the safe `optimize!` method has to allocate enough memory to guarantee the decompressed data will fit, and that is typically 100 times more memory than necessary. If you insist on optimizing your data, I recommend running `unsafe_optimize!` immediately after `compress`, using the original source data as the destination for `unsafe_optimize!`. This guarantees that there will be just enough memory available to perform the optimization:

```julia
lorem_copy = copy(lorem) # just to prove everything works (not necessary in production)

compressed = compress(LZO1X, lorem)
unsafe_optimize!(LZO1X, lorem, compressed) # use the original data as the output location for the decompression
@assert lorem == lorem_copy # still the same
```