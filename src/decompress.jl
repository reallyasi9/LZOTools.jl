"""
    unsafe_decompress!([algorithm], dest, src; [kwargs...])::Int

Decompress `src` to `dest` using LZO algorithm `algorithm`, returning the number of bytes loaded into `dest`.

The method is "unsafe" in that it does not check to see if the decompressed output can fit into `dest` before proceeding, and may write out of bounds or crash your program if the number of bytes required to decompress `src` is larger than the number of bytes available in `dest`. The method returns the number of bytes written to `dest`, which may be greater than `length(dest)`.

Both `dest` and `src` have to have `pointer` and `length` methods defined, and the memory of `dest` has to be writable or else undefined behavior will occur.

The `algorithm` argument, if given, can be an instance of an `AbstractLZOAlgorithm`, a `Type{<:AbstractLZOAlgorithm}`, or a `Symbol` or `String` that names an LZO algorithm. The supported decompression algorithm types are listed below--the symbol and string versions are the same, case-sensitive characters as the type name:

- `LZO1X_1`, `:LZO1X_1`, or `"LZO1X_1"` (also `LZO1X`, `LZO`, `LZO1X_1_11`, `LZO1X_1_12`, `LZO1X_1_15`, or `LZO1X_999`, and is the default if no algorithm is given)
- `LZO1` (also `LZO1_99`)
- `LZO1A` (also `LZO1A_99`)
- `LZO1B_1` (also `LZO1B`, `LZO1B_2`, `LZO1B_3`, `LZO1B_4`, `LZO1B_5`, `LZO1B_6`, `LZO1B_7`, `LZO1B_8`, `LZO1B_9`, `LZO1B_99`, or `LZO1B_999`)
- `LZO1C_1` (also `LZO1C`, `LZO1C_2`, `LZO1C_3`, `LZO1C_4`, `LZO1C_5`, `LZO1C_6`, `LZO1C_7`, `LZO1C_8`, `LZO1C_9`, `LZO1C_99`, or `LZO1C_999`)
- `LZO1F_1` (also `LZO1F` or `LZO1F_999`)
- `LZO1Y_1` (also `LZO1Y` or `LZO1Y_999`)
- `LZO1Z_999`
- `LZO2A_999`

Keyword arguments `kwargs`, if given, are passed to the algorithm struct constructors. See the documentation for the specific algorithm type for more information about valid keyword arguments and defaults.
"""
function unsafe_decompress!(algo::AbstractLZOAlgorithm, dest, src)
    output_size, err = GC.@preserve dest src _ccall_unsafe_decompress!(algo, pointer(dest), pointer(src), length(src))
    if err != 0
        throw(ErrorException("lzo decompression error $e"))
    end
    return output_size
end

unsafe_decompress!(algo::Type{<:AbstractLZOAlgorithm}, dest, src; kwargs...) = unsafe_decompress!(algo(; kwargs...), dest, src)
unsafe_decompress!(algo::Symbol, dest, src; kwargs...) = unsafe_decompress!(_SYMBOL_LOOKUP[algo], dest, src; kwargs...)
unsafe_decompress!(algo::AbstractString, dest, src; kwargs...) = unsafe_decompress!(Symbol(algo), dest, src; kwargs...)
unsafe_decompress!(dest, src; kwargs...) = unsafe_decompress!(LZO1X_1, dest, src; kwargs...)

"""
    decompress([algorithm], src::AbstractVector{UInt8}; [kwargs...])::Vector{UInt8}

Decompress `src` using LZO algorithm `algorithm`.

Returns a `Vector{UInt8}` loaded with the decompressed version of `src`.

The `algorithm` argument, if given, can be an instance of an `AbstractLZOAlgorithm`, a `Type{<:AbstractLZOAlgorithm}`, or a `Symbol` or `String` that names an LZO algorithm. The supported decompression algorithm types are listed below--the symbol and string versions are the same, case-sensitive characters as the type name:

- `LZO1X_1`, `:LZO1X_1`, or `"LZO1X_1"` (also `LZO1X`, `LZO`, `LZO1X_1_11`, `LZO1X_1_12`, `LZO1X_1_15`, or `LZO1X_999`, and is the default if no algorithm is given)
- `LZO1` (also `LZO1_99`)
- `LZO1A` (also `LZO1A_99`)
- `LZO1B_1` (also `LZO1B`, `LZO1B_2`, `LZO1B_3`, `LZO1B_4`, `LZO1B_5`, `LZO1B_6`, `LZO1B_7`, `LZO1B_8`, `LZO1B_9`, `LZO1B_99`, or `LZO1B_999`)
- `LZO1C_1` (also `LZO1C`, `LZO1C_2`, `LZO1C_3`, `LZO1C_4`, `LZO1C_5`, `LZO1C_6`, `LZO1C_7`, `LZO1C_8`, `LZO1C_9`, `LZO1C_99`, or `LZO1C_999`)
- `LZO1F_1` (also `LZO1F` or `LZO1F_999`)
- `LZO1Y_1` (also `LZO1Y` or `LZO1Y_999`)
- `LZO1Z_999`
- `LZO2A_999`

Keyword arguments `kwargs`, if given, are passed to the algorithm struct constructors. See the documentation for the specific algorithm type for more information about valid keyword arguments and defaults.
"""
function decompress(algo::AbstractLZOAlgorithm, src::AbstractVector{UInt8})
    isempty(src) && return UInt8[]
    dest = zeros(UInt8, length(src)) # just a guess
    output_size = length(dest)
    while true
        output_size, err = GC.@preserve dest src _ccall_safe_decompress!(algo, pointer(dest), length(dest), pointer(src), length(src))
        if err == -5 # destination overrun, must resize
            resize!(dest, length(dest)*2) # guarantee O(log(length(src))/log(2)) attempts
        elseif err == 0
            break
        else
            throw(ErrorException("lzo decompression error $err"))
        end
    end
    resize!(dest, output_size)
    return dest
end

decompress(algo::Type{<:AbstractLZOAlgorithm}, src; kwargs...) = decompress(algo(; kwargs...), src)
decompress(algo::Symbol, src; kwargs...) = decompress(_SYMBOL_LOOKUP[algo], src; kwargs...)
decompress(algo::AbstractString, src; kwargs...) = decompress(Symbol(algo), src; kwargs...)
decompress(src; kwargs...) = decompress(LZO1X_1, src; kwargs...)

# Call unsafe decompression library function from the algorithm struct
_ccall_unsafe_decompress!(algo::AbstractLZOAlgorithm, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer) = nothing

# Call safe decompression library function from the algorithm struct
_ccall_safe_decompress!(algo::AbstractLZOAlgorithm, dest::Ptr{UInt8}, dest_size::Integer, src::Ptr{UInt8}, src_size::Integer) = nothing