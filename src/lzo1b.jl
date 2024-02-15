const LZO1B_WORKING_MEMORY_SIZE = 1<<17
const LZO1B_99_WORKING_MEMORY_SIZE = 1<<20

"""
    LZO1B

The LZO1B algorithm.

## Keyword arguments
- `compression_level::Int = -1`: compression level 1-9, with 9 producing the maximum compression ratio and 1 running the fastest, and where -1 chooses the default (1).
- `working_memory::Vector{UInt8} = zeros(UInt8, LZO1B_WORKING_MEMORY_SIZE)`: a block of memory used for historical lookups.
"""
@kwdef struct LZO1B <:AbstractLZOAlgorithm
    compression_level::Int = -1
    working_memory::Vector{UInt8} = zeros(UInt8, LZO1B_WORKING_MEMORY_SIZE)
end

function _ccall_compress!(algo::LZO1B, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    @boundscheck checkbounds(algo.working_memory, LZO1B_WORKING_MEMORY_SIZE)
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo1b_compress(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid}, algo.compression_level::Cint)::Cint
    return size_ptr[], err
end

function _ccall_unsafe_decompress!(algo::LZO1B, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo1b_decompress(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint # always returns LZO_E_OK or crashes!
    return size_ptr[], err
end

# special version: because LZO1B does not need working memory, save on the allocations
function unsafe_decompress!(::Type{LZO1B}, dest, src; kwargs...)
    algo = LZO1B(working_memory = UInt8[])
    return unsafe_decompress!(algo, dest, src)
end

function _ccall_safe_decompress!(algo::LZO1B, dest::Ptr{UInt8}, dest_size::Integer, src::Ptr{UInt8}, src_size::Integer)
    size_ptr = Ref{Csize_t}(dest_size)
    err = @ccall liblzo2.lzo1b_decompress_safe(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint
    return size_ptr[], err
end

# special version: because LZO1B does not need working memory, save on the allocations
function decompress(::Type{LZO1B}, src; kwargs...)
    algo = LZO1B(working_memory = UInt8[])
    return decompress(algo, src)
end

"""
    LZO1B_99

The LZO1B_99 algorithm.

## Keyword arguments
- `working_memory::Vector{UInt8} = zeros(UInt8, LZO1B_99_WORKING_MEMORY_SIZE)`: a block of memory used for historical lookups.
"""
@kwdef struct LZO1B_99 <:AbstractLZOAlgorithm
    working_memory::Vector{UInt8} = zeros(UInt8, LZO1B_99_WORKING_MEMORY_SIZE)
end

function _ccall_compress!(algo::LZO1B_99, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    @boundscheck checkbounds(algo.working_memory, LZO1B_99_WORKING_MEMORY_SIZE)
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo1b_99_compress(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint
    return size_ptr[], err
end

# all LZO1B algorithms use the same decompression algorithm
for algo = (:LZO1B_99,)
    @eval unsafe_decompress!(::$algo, dest::AbstractVector{UInt8}, src::AbstractVector{UInt8}) = unsafe_decompress!(LZO1B, dest, src)
    @eval decompress(::$algo, src::AbstractVector{UInt8}) = decompress(LZO1B, src)
end
