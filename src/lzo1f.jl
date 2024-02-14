const LZO1F_1_WORKING_MEMORY_SIZE = 1<<17
const LZO1F_999_WORKING_MEMORY_SIZE = 5 * (1<<16)

"""
    LZO1F_1

The LZO1F_1 algorithm.

## Keyword arguments
- `working_memory::Vector{UInt8} = zeros(UInt8, LZO1F_1_WORKING_MEMORY_SIZE)`: a block of memory used for historical lookups.
"""
@kwdef struct LZO1F_1 <:AbstractLZOAlgorithm
    working_memory::Vector{UInt8} = zeros(UInt8, LZO1F_1_WORKING_MEMORY_SIZE)
end

# aliases
const LZO1F = LZO1F_1

function _ccall_compress!(algo::LZO1F_1, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    @boundscheck checkbounds(algo.working_memory, LZO1F_1_WORKING_MEMORY_SIZE)
    fill!(algo.working_memory, UInt8(0))
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo1f_1_compress(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint
    return size_ptr[], err
end

function _ccall_unsafe_decompress!(algo::LZO1F_1, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo1f_decompress(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint # always returns LZO_E_OK or crashes!
    return size_ptr[], err
end

function _ccall_safe_decompress!(algo::LZO1F_1, dest::Ptr{UInt8}, dest_size::Integer, src::Ptr{UInt8}, src_size::Integer)
    size_ptr = Ref{Csize_t}(dest_size)
    err = @ccall liblzo2.lzo1c_decompress_safe(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint
    return size_ptr[], err
end

# special version: because LZO1F does not need working memory, save on the allocations
function decompress(::Type{LZO1F_1}, src; kwargs...)
    algo = LZO1F_1(working_memory = UInt8[])
    return decompress(algo, src)
end

# special version: because LZO1F_1 does not need working memory, save on the allocations
function unsafe_decompress!(::Type{LZO1F_1}, dest, src; kwargs...)
    algo = LZO1F_1(working_memory = UInt8[])
    return unsafe_decompress!(algo, dest, src)
end

"""
    LZO1F_999

The LZO1F_999 algorithm.

## Keyword arguments
- `working_memory::Vector{UInt8} = zeros(UInt8, LZO1F_999_WORKING_MEMORY_SIZE)`: a block of memory used for historical lookups.
"""
@kwdef struct LZO1F_999 <:AbstractLZOAlgorithm
    working_memory::Vector{UInt8} = zeros(UInt8, LZO1F_999_WORKING_MEMORY_SIZE)
end

function _ccall_compress!(algo::LZO1F_999, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    @boundscheck checkbounds(algo.working_memory, LZO1F_999_WORKING_MEMORY_SIZE)
    fill!(algo.working_memory, UInt8(0))
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo1f_999_compress(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint
    return size_ptr[], err
end

# all LZO1F algorithms use the same decompression algorithm
for algo = (:LZO1F_999,)
    @eval unsafe_decompress!(::$algo, dest::AbstractVector{UInt8}, src::AbstractVector{UInt8}) = unsafe_decompress!(LZO1F_1, dest, src)
    @eval decompress(::$algo, src::AbstractVector{UInt8}) = decompress(LZO1F_1, src)
end
