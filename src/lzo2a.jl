const LZO2A_999_WORKING_MEMORY_SIZE = 8 * (1<<16)

"""
    LZO2A_999

The LZO2A_999 algorithm.

## Keyword arguments
- `working_memory::Vector{UInt8} = zeros(UInt8, LZO2A_999_WORKING_MEMORY_SIZE)`: a block of memory used for historical lookups.
"""
@kwdef struct LZO2A_999 <:AbstractLZOAlgorithm
    working_memory::Vector{UInt8} = zeros(UInt8, LZO2A_999_WORKING_MEMORY_SIZE)
end

# alias
const LZO2A = LZO2A_999

function _ccall_compress!(algo::LZO2A_999, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    @boundscheck checkbounds(algo.working_memory, LZO2A_999_WORKING_MEMORY_SIZE)
    fill!(algo.working_memory, UInt8(0))
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo2a_999_compress(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid}, C_NULL::Ptr{Cuchar}, 0::Csize_t, C_NULL::Ptr{Cuchar})::Cint
    return size_ptr[], err
end

function _ccall_unsafe_decompress!(algo::LZO2A_999, dest::Ptr{UInt8}, src::Ptr{UInt8}, src_size::Integer)
    size_ptr = Ref{Csize_t}()
    err = @ccall liblzo2.lzo2a_decompress(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint # always returns LZO_E_OK or crashes!
    return size_ptr[], err
end

# special version: because LZO2A_999 does not need working memory, save on the allocations
function unsafe_decompress!(::Type{LZO2A_999}, dest, src; kwargs...)
    algo = LZO2A_999(working_memory = UInt8[])
    return unsafe_decompress!(algo, dest, src)
end

function _ccall_safe_decompress!(algo::LZO2A_999, dest::Ptr{UInt8}, dest_size::Integer, src::Ptr{UInt8}, src_size::Integer)
    size_ptr = Ref{Csize_t}(dest_size)
    err = @ccall liblzo2.lzo2a_decompress_safe(src::Ptr{Cuchar}, src_size::Csize_t, dest::Ptr{Cuchar}, size_ptr::Ptr{Csize_t}, algo.working_memory::Ptr{Cvoid})::Cint
    return size_ptr[], err
end

# special version: because LZO2A_999 does not need working memory, save on the allocations
function decompress(::Type{LZO2A_999}, src; kwargs...)
    algo = LZO2A_999(working_memory = UInt8[])
    return decompress(algo, src)
end
