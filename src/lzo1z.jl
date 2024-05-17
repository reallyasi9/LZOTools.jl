const LZO1Z_999_WORKING_MEMORY_SIZE = 14 * (1<<16)

"""
    LZO1Z_999

The LZO1Z_999 algorithm.

## Keyword arguments
- `compression_level::Int = 8`: compression level 1-8, with 8 producing the maximum compression ratio and 1 running the fastest.
- `working_memory::Vector{UInt8} = zeros(UInt8, LZO1Z_999_WORKING_MEMORY_SIZE)`: a block of memory used for historical lookups.
"""
@kwdef struct LZO1Z_999 <:AbstractLZOAlgorithm
    compression_level::Int = 8
    working_memory::Vector{UInt8} = zeros(UInt8, LZO1Z_999_WORKING_MEMORY_SIZE)
end

# alias
const LZO1Z = LZO1Z_999

function _ccall_compress!(algo::LZO1Z_999, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    @boundscheck checkbounds(algo.working_memory, LZO1Z_999_WORKING_MEMORY_SIZE)
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo1z_999_compress_level(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid}, C_NULL::Ptr{Cuchar}, 0::Csize_t, C_NULL::Ptr{Cuchar}, algo.compression_level::Cint)::Cint
    return size_ptr[], err
end

function _ccall_unsafe_decompress!(algo::LZO1Z_999, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo1z_decompress(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint # always returns LZO_E_OK or crashes!
    return size_ptr[], err
end

# special version: because LZO1Z_999 does not need working memory, save on the allocations
function unsafe_decompress!(::Type{LZO1Z_999}, dest, src; kwargs...)
    algo = LZO1Z_999(working_memory = UInt8[])
    return unsafe_decompress!(algo, dest, src)
end

function _ccall_safe_decompress!(algo::LZO1Z_999, dest::Ptr{UInt8}, dest_size::Integer, src::Ptr{UInt8}, src_size::Integer)
    size_ptr = Ref{Csize_t}(dest_size)
    err = @ccall liblzo2.lzo1z_decompress_safe(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint
    return size_ptr[], err
end

# special version: because LZO1Z_999 does not need working memory, save on the allocations
function decompress(::Type{LZO1Z_999}, src; kwargs...)
    algo = LZO1Z_999(working_memory = UInt8[])
    return decompress(algo, src)
end

compression_level(algo::LZO1Z_999) = algo.compression_level