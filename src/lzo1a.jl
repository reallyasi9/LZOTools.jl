const LZO1A_WORKING_MEMORY_SIZE = 1<<15
const LZO1A_99_WORKING_MEMORY_SIZE = 1<<19 # not 1<<18, as documentation suggests

"""
    LZO1A

The LZO1A algorithm.

## Keyword arguments
- `working_memory::Vector{UInt8} = zeros(UInt8, LZO1A_WORKING_MEMORY_SIZE)`: a block of memory used for historical lookups.
"""
@kwdef struct LZO1A <:AbstractLZOAlgorithm
    working_memory::Vector{UInt8} = zeros(UInt8, LZO1A_WORKING_MEMORY_SIZE)
end

function _ccall_compress!(algo::LZO1A, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    @boundscheck checkbounds(algo.working_memory, LZO1A_WORKING_MEMORY_SIZE)
    fill!(algo.working_memory, UInt8(0))
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo1a_compress(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint
    return size_ptr[], err
end

function _ccall_unsafe_decompress!(algo::LZO1A, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo1a_decompress(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint # always returns LZO_E_OK or crashes!
    return size_ptr[], err
end

# special version: because LZO1A does not need working memory, save on the allocations
function unsafe_decompress!(::Type{LZO1A}, dest, src; kwargs...)
    algo = LZO1A(working_memory = UInt8[])
    return unsafe_decompress!(algo, dest, src)
end

"""
    LZO1A_99

The LZO1A_99 algorithm.

## Keyword arguments
- `working_memory::Vector{UInt8} = zeros(UInt8, LZO1A_99_WORKING_MEMORY_SIZE)`: a block of memory used for historical lookups.
"""
@kwdef struct LZO1A_99 <:AbstractLZOAlgorithm
    working_memory::Vector{UInt8} = zeros(UInt8, LZO1A_99_WORKING_MEMORY_SIZE)
end

function _ccall_compress!(algo::LZO1A_99, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    @boundscheck checkbounds(algo.working_memory, LZO1A_99_WORKING_MEMORY_SIZE)
    fill!(algo.working_memory, UInt8(0))
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo1a_99_compress(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint
    return size_ptr[], err
end

# all LZO1 algorithms use the same decompression algorithm
for algo = (:LZO1A_99,)
    @eval unsafe_decompress!(::$algo, dest::AbstractVector{UInt8}, src::AbstractVector{UInt8}) = unsafe_decompress!(LZO1A, dest, src)
end
