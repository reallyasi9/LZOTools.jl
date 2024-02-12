"""
    unsafe_compress!([algorithm], dest, src; [kwargs...])::Int

Compress `src` to `dest` using LZO algorithm `algorithm`, returning the number of bytes loaded into `dest`.

The method is "unsafe" in that it does not check to see if the compressed output can fit into `dest` before proceeding, and may write out of bounds or crash your program if the number of bytes required to compress `src` is larger than the number of bytes available in `dest`. The method returns the number of bytes written to `dest`, which may be greater than `length(dest)`.

Both `dest` and `src` must have `pointer` and `length` methods defined, and the memory of `dest` has to be writable or else undefined behavior will occur.

The `algorithm` argument, if given, can be an instance of an `AbstractLZOAlgorithm`, a `Type{<:AbstractLZOAlgorithm}`, or a `Symbol` or `String` that names an LZO algorithm. The supported compression algorithm types are listed below--the symbol and string versions are the same, case-sensitive characters as the type name:

- `LZO1X_1`, `:LZO1X_1`, or `"LZO1X_1"` (also `LZO1X` or `LZO`, and is the default if no algorithm is given)
- `LZO1`, etc.
- `LZO1_99`
- `LZO1A`
- `LZO1A_99`
- `LZO1B_1` (also `LZO1B`)
- `LZO1B_2`
- `LZO1B_3`
- `LZO1B_4`
- `LZO1B_5`
- `LZO1B_6`
- `LZO1B_7`
- `LZO1B_8`
- `LZO1B_9`
- `LZO1B_99`
- `LZO1B_999`
- `LZO1C_1` (also `LZO1C`)
- `LZO1C_2`
- `LZO1C_3`
- `LZO1C_4`
- `LZO1C_5`
- `LZO1C_6`
- `LZO1C_7`
- `LZO1C_8`
- `LZO1C_9`
- `LZO1C_99`
- `LZO1C_999`
- `LZO1F_1` (also `LZO1F`)
- `LZO1F_999`
- `LZO1X_1_11`
- `LZO1X_1_12`
- `LZO1X_1_15`
- `LZO1X_999`
- `LZO1Y_1` (also `LZO1Y`)
- `LZO1Y_999`
- `LZO1Z_999`
- `LZO2A_999`

Keyword arguments `kwargs`, if given, are passed to the algorithm struct constructors. See the documentation for the specific algorithm type for more information about valid keyword arguments and defaults.
"""
function unsafe_compress!(algo::AbstractLZOAlgorithm, dest::AbstractVector{UInt8}, src::AbstractVector{UInt8})
    output_size, err = GC.@preserve dest src _ccall_compress!(algo, pointer(dest), pointer(src), length(src))
    if err != 0
        throw(ErrorException("lzo compression error $e"))
    end
    return output_size
end

unsafe_compress!(algo::Type{<:AbstractLZOAlgorithm}, dest, src; kwargs...) = unsafe_compress!(algo(; kwargs...), dest, src)
unsafe_compress!(algo::Symbol, dest, src; kwargs...) = unsafe_compress!(_SYMBOL_LOOKUP[algo], dest, src; kwargs...)
unsafe_compress!(algo::AbstractString, dest, src; kwargs...) = unsafe_compress!(Symbol(algo), dest, src; kwargs...)
unsafe_compress!(dest, src; kwargs...) = unsafe_compress!(LZO1X_1, dest, src; kwargs...)

"""
    compress([algorithm], src::AbstractVector{UInt8}; [kwargs...])::Vector{UInt8}

Compress `src` using LZO algorithm `algorithm`.

Returns a `Vector{UInt8}` loaded with the compressed version of `src`.

The `algorithm` argument, if given, can be an instance of an `AbstractLZOAlgorithm`, a `Type{<:AbstractLZOAlgorithm}`, or a `Symbol` or `String` that names an LZO algorithm. The supported compression algorithm types are listed below--the symbol and string versions are the same, case-sensitive characters as the type name:

- `LZO1X_1`, `:LZO1X_1`, or `"LZO1X_1"` (also `LZO1X` or `LZO`, and is the default if no algorithm is given)
- `LZO1`, etc.
- `LZO1_99`
- `LZO1A`
- `LZO1A_99`
- `LZO1B_1` (also `LZO1B`)
- `LZO1B_2`
- `LZO1B_3`
- `LZO1B_4`
- `LZO1B_5`
- `LZO1B_6`
- `LZO1B_7`
- `LZO1B_8`
- `LZO1B_9`
- `LZO1B_99`
- `LZO1B_999`
- `LZO1C_1` (also `LZO1C`)
- `LZO1C_2`
- `LZO1C_3`
- `LZO1C_4`
- `LZO1C_5`
- `LZO1C_6`
- `LZO1C_7`
- `LZO1C_8`
- `LZO1C_9`
- `LZO1C_99`
- `LZO1C_999`
- `LZO1F_1` (also `LZO1F`)
- `LZO1F_999`
- `LZO1X_1_11`
- `LZO1X_1_12`
- `LZO1X_1_15`
- `LZO1X_999`
- `LZO1Y_1` (also `LZO1Y`)
- `LZO1Y_999`
- `LZO1Z_999`
- `LZO2A_999`

Keyword arguments `kwargs`, if given, are passed to the algorithm struct constructors. See the documentation for the specific algorithm type for more information about valid keyword arguments and defaults.
"""
function compress(algo::AbstractLZOAlgorithm, src::AbstractVector{UInt8})
    isempty(src) && return UInt8[] # empty always compresses to empty
    dest = zeros(UInt8, max_compressed_length(algo, length(src)))
    new_size = unsafe_compress!(algo, dest, src)
    resize!(dest, new_size)
    return dest
end

compress(algo::Type{<:AbstractLZOAlgorithm}, src; kwargs...) = compress(algo(; kwargs...), src)
compress(algo::Symbol, src; kwargs...) = compress(_SYMBOL_LOOKUP[algo], src; kwargs...)
compress(algo::AbstractString, src; kwargs...) = compress(Symbol(algo), src; kwargs...)
compress(src; kwargs...) = compress(LZO1X_1, src; kwargs...)

# Call compression library function from the algorithm struct
_ccall_compress!(algo::AbstractLZOAlgorithm, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer) = nothing

"""
    max_compressed_length(algo, n)::Int

Compute the maximum length that will result from compressing `n` bytes using LZO algorithm `algo`.

The worst-case scenario is a single super-long literal, in which case the input has to be emitted in its entirety (n bytes) plus the appropriate commands to start a long literal (n/255 bytes + a constant depending on n) plus the end of stream command (3 bytes). However, the liblzo2 authors suggest the following formula for most algorithms.
"""
function max_compressed_length(::AbstractLZOAlgorithm, n::Integer)
    n == 0 && return 0 # nothing compresses to nothing
    # return (n <= 18 ? 1 : (((n - 18) ÷ 255) + 2)) + n + 3
    return n + (n ÷ 16) + 64 + 3
end