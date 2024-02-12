"""
    unsafe_optimize!([algorithm], dest, src; [kwargs...])::Int

Optimize the already compressed `src` in-place by decompressing to `dest` using LZO algorithm `algorithm`.

The method is "unsafe" in that it does not check to see if the decompressed output can fit into `dest` before proceeding, and may write out of bounds or crash your program if the number of bytes required to decompress `src` is larger than the number of bytes available in `dest`. The method returns the number of bytes written to `dest`, which may be greater than `length(dest)`.

Both `dest` and `src` have to have `pointer` and `length` methods defined, and the memory of both have to be writable or else undefined behavior will occur.

The `algorithm` argument, if given, can be an instance of an `AbstractLZOAlgorithm`, a `Type{<:AbstractLZOAlgorithm}`, or a `Symbol` or `String` that names an LZO algorithm. The supported compression algorithm types are listed below--the symbol and string versions are the same, case-sensitive characters as the type name:

- `LZO1X_1`, `:LZO1X_1`, or `"LZO1X_1"` (also `LZO1X` or `LZO`, and is the default if no algorithm is given)
- `LZO1X_1_11`
- `LZO1X_1_12`
- `LZO1X_1_15`
- `LZO1X_999`
- `LZO1Y_1` (also `LZO1Y`)
- `LZO1Y_999`

!!! warn Match the compression algorithm with the optimization algorithm
    Undefined behavior occurs if the algorithm passed to `optimize` does not match the algorithm passed to `compress` when `src` was generated.

Keyword arguments `kwargs`, if given, are passed to the algorithm struct constructors. See the documentation for the specific algorithm type for more information about valid keyword arguments and defaults.
"""
function unsafe_optimize!(algo::AbstractLZOAlgorithm, dest::AbstractVector{UInt8}, src::AbstractVector{UInt8})
    output_size, err = GC.@preserve dest src _ccall_optimize!(algo, pointer(dest), pointer(src), length(src))
    if err != 0
        throw(ErrorException("lzo optimization error $e"))
    end
    return output_size
end

unsafe_optimize!(algo::Type{<:AbstractLZOAlgorithm}, src; kwargs...) = unsafe_optimize!(algo(; kwargs...), dest, src)
unsafe_optimize!(algo::Symbol, src; kwargs...) = unsafe_optimize!(_SYMBOL_LOOKUP[algo], dest, src; kwargs...)
unsafe_optimize!(algo::AbstractString, src; kwargs...) = unsafe_optimize!(Symbol(algo), dest, src; kwargs...)
unsafe_optimize!(src; kwargs...) = unsafe_optimize!(LZO1X_1, dest, src; kwargs...)

"""
    optimize!([algorithm], src::AbstractVector{UInt8}; [kwargs...])::Vector{UInt8}

Optimize the already compressed `src` in-place using LZO algorithm `algorithm`, returning the resized and optimized `src`.

The `algorithm` argument, if given, can be an instance of an `AbstractLZOAlgorithm`, a `Type{<:AbstractLZOAlgorithm}`, or a `Symbol` or `String` that names an LZO algorithm. The supported compression algorithm types are listed below--the symbol and string versions are the same, case-sensitive characters as the type name:

- `LZO1X_1`, `:LZO1X_1`, or `"LZO1X_1"` (also `LZO1X` or `LZO`, and is the default if no algorithm is given)
- `LZO1X_1_11`
- `LZO1X_1_12`
- `LZO1X_1_15`
- `LZO1X_999`
- `LZO1Y_1` (also `LZO1Y`)
- `LZO1Y_999`

!!! warn Match the compression algorithm with the optimization algorithm
    Undefined behavior occurs if the algorithm passed to `optimize` does not match the algorithm passed to `compress` when `src` was generated.

Keyword arguments `kwargs`, if given, are passed to the algorithm struct constructors. See the documentation for the specific algorithm type for more information about valid keyword arguments and defaults.

!!! note
    Optimizing compressed data rarely produces any marked difference in compression ratios or decompression speed.
"""
function optimize!(algo::AbstractLZOAlgorithm, src::AbstractVector{UInt8})
    isempty(src) && return UInt8[] # empty always compresses to empty
    # the length of the working data has to be able to hold the extracted literals, so estimate the largest size
    dest = zeros(UInt8, length(src) * 256)
    unsafe_optimize!(algo, dest, src)
    return src
end

optimize!(algo::Type{<:AbstractLZOAlgorithm}, src; kwargs...) = optimize!(algo(; kwargs...), src)
optimize!(algo::Symbol, src; kwargs...) = optimize!(_SYMBOL_LOOKUP[algo], src; kwargs...)
optimize!(algo::AbstractString, src; kwargs...) = optimize!(Symbol(algo), src; kwargs...)
optimize!(src; kwargs...) = optimize!(LZO1X_1, src; kwargs...)

# Call optimization library function from the algorithm struct
_ccall_optimize!(algo::AbstractLZOAlgorithm, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer) = nothing