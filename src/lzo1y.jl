const LZO1Y_1_WORKING_MEMORY_SIZE = 1<<16
const LZO1Y_999_WORKING_MEMORY_SIZE = 14 * (1<<16)

"""
    LZO1Y_1

The LZO1Y_1 algorithm.

## Keyword arguments
- `working_memory::Vector{UInt8} = zeros(UInt8, LZO1Y_1_WORKING_MEMORY_SIZE)`: a block of memory used for historical lookups.
"""
@kwdef struct LZO1Y_1 <:AbstractLZOAlgorithm
    working_memory::Vector{UInt8} = zeros(UInt8, LZO1Y_1_WORKING_MEMORY_SIZE)
end

# LZO1Y_1 is the default LZO1Y algorithm
const LZO1Y = LZO1Y_1

function _ccall_compress!(algo::LZO1Y_1, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    @boundscheck checkbounds(algo.working_memory, LZO1Y_1_WORKING_MEMORY_SIZE)
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo1y_1_compress(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint
    return size_ptr[], err
end

function _ccall_unsafe_decompress!(algo::LZO1Y_1, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo1y_decompress(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint # always returns LZO_E_OK or crashes!
    return size_ptr[], err
end

# special version: because LZO1Y_1 does not need working memory, save on the allocations
function unsafe_decompress!(::Type{LZO1Y_1}, dest, src; kwargs...)
    algo = LZO1Y_1(working_memory = UInt8[])
    return unsafe_decompress!(algo, dest, src)
end

function _ccall_safe_decompress!(algo::LZO1Y_1, dest::Ptr{UInt8}, dest_size::Integer, src::Ptr{UInt8}, src_size::Integer)
    size_ptr = Ref{Csize_t}(dest_size)
    err = @ccall liblzo2.lzo1y_decompress_safe(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint
    return size_ptr[], err
end

# special version: because LZO1Y_1 does not need working memory, save on the allocations
function decompress(::Type{LZO1Y_1}, src; kwargs...)
    algo = LZO1Y_1(working_memory = UInt8[])
    return decompress(algo, src)
end

function _ccall_optimize!(algo::LZO1Y_1, dest::Ptr{UInt8}, dest_size::Integer, src::Ptr{UInt8}, src_size::Integer)
    size_ptr = Ref{Csize_t}(dest_size)
    err = @ccall liblzo2.lzo1y_optimize(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint
    return size_ptr[], err
end

# special version: because LZO1Y_1 does not need working memory, save on the allocations
function unsafe_optimize!(::Type{LZO1Y_1}, dest, src; kwargs...)
    algo = LZO1Y_1(working_memory = UInt8[])
    return unsafe_optimize!(algo, dest, src)
end

# special version: because LZO1Y_1 does not need working memory, save on the allocations
function optimize(::Type{LZO1Y_1}, src; kwargs...)
    algo = LZO1Y_1(working_memory = UInt8[])
    return optimize(algo, src)
end

"""
    LZO1Y_999

The LZO1Y_999 algorithm.

## Keyword arguments
- `compression_level::Int = 8`: compression level 1-8, with 8 producing the maximum compression ratio and 1 running the fastest.
- `working_memory::Vector{UInt8} = zeros(UInt8, LZO1Y_999_WORKING_MEMORY_SIZE)`: a block of memory used for historical lookups.
"""
@kwdef struct LZO1Y_999 <:AbstractLZOAlgorithm
    compression_level::Int = 8
    working_memory::Vector{UInt8} = zeros(UInt8, LZO1Y_999_WORKING_MEMORY_SIZE)
end

function _ccall_compress!(algo::LZO1Y_999, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    @boundscheck checkbounds(algo.working_memory, LZO1Y_999_WORKING_MEMORY_SIZE)
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo1y_999_compress_level(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid}, C_NULL::Ptr{Cuchar}, 0::Csize_t, C_NULL::Ptr{Cuchar}, algo.compression_level::Cint)::Cint
    return size_ptr[], err
end

# all LZO1Y algorithms use the same decompression algorithm
for algo = (:LZO1Y_999,)
    @eval unsafe_decompress!(::$algo, dest::AbstractVector{UInt8}, src::AbstractVector{UInt8}) = unsafe_decompress!(LZO1Y_1, dest, src)
    @eval decompress(::$algo, src::AbstractVector{UInt8}) = decompress(LZO1Y_1, src)
end

# all LZO1Y algorithms use the same optimization algorithm
for algo = (:LZO1Y_999,)
    @eval unsafe_optimize!(::$algo, dest::AbstractVector{UInt8}, src::AbstractVector{UInt8}) = unsafe_optimize!(LZO1Y_1, dest, src)
    @eval optimize(::$algo, src::AbstractVector{UInt8}) = optimize(LZO1Y_1, src)
end