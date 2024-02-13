const _SYMBOL_LOOKUP = Dict{Symbol,Type{<:AbstractLZOAlgorithm}}(
    :LZO1X_1 => LZO1X_1,
    :LZO1X => LZO1X_1, # alias
    :LZO => LZO1X_1, # alias
    :LZO1X_1_11 => LZO1X_1_11,
    :LZO1X_1_12 => LZO1X_1_12,
    :LZO1X_1_15 => LZO1X_1_15,
    :LZO1X_999 => LZO1X_999,
    :LZO1 => LZO1,
    :LZO1_99 => LZO1_99,
    :LZO1A => LZO1A,
    :LZO1A_99 => LZO1A_99,
    :LZO1B => LZO1B,
    :LZO1B_99 => LZO1B_99,
)