const LZO1_WORKING_MEMORY_SIZE = 1<<17
const LZO1_99_WORKING_MEMORY_SIZE = 1<<20

"""
    LZO1

The LZO1 algorithm.

## Keyword arguments
- `working_memory::Vector{UInt8} = zeros(UInt8, LZO1_WORKING_MEMORY_SIZE)`: a block of memory used for historical lookups.
"""
@kwdef struct LZO1 <:AbstractLZOAlgorithm
    working_memory::Vector{UInt8} = zeros(UInt8, LZO1_WORKING_MEMORY_SIZE)
end

function _ccall_compress!(algo::LZO1, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    @boundscheck checkbounds(algo.working_memory, LZO1_WORKING_MEMORY_SIZE)
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo1_compress(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint
    return size_ptr[], err
end

function _ccall_unsafe_decompress!(algo::LZO1, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo1_decompress(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint # always returns LZO_E_OK or crashes!
    return size_ptr[], err
end

# special version: because LZO1 does not need working memory, save on the allocations
function unsafe_decompress!(::Type{LZO1}, dest, src; kwargs...)
    algo = LZO1(working_memory = UInt8[])
    return unsafe_decompress!(algo, dest, src)
end

"""
    LZO1_99

The LZO1_99 algorithm.

## Keyword arguments
- `working_memory::Vector{UInt8} = zeros(UInt8, LZO1_99_WORKING_MEMORY_SIZE)`: a block of memory used for historical lookups.
"""
@kwdef struct LZO1_99 <:AbstractLZOAlgorithm
    working_memory::Vector{UInt8} = zeros(UInt8, LZO1_99_WORKING_MEMORY_SIZE)
end

function _ccall_compress!(algo::LZO1_99, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    @boundscheck checkbounds(algo.working_memory, LZO1_99_WORKING_MEMORY_SIZE)
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo1_99_compress(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint
    return size_ptr[], err
end

# all LZO1 algorithms use the same decompression algorithm
for algo = (:LZO1_99,)
    @eval unsafe_decompress!(::$algo, dest::AbstractVector{UInt8}, src::AbstractVector{UInt8}) = unsafe_decompress!(LZO1, dest, src)
end
