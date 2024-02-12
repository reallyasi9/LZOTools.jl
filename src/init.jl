function __init__()
    # The LZO library initialization method takes parameters that check that the following values are consistent between the compiled library and the code calling it:
    # 1. the version of the library (must be != 0)
    # 2. sizeof(short)
    # 3. sizeof(int)
    # 4. sizeof(long)
    # 5. sizeof(lzo_uint32_t) (required to be 4 bytes, irrespective of machine architecture)
    # 6. sizeof(lzo_uint) (required to be 8 bytes, irrespective of machine architecture)
    # 7. lzo_sizeof_dict_t (size of a pointer)
    # 8. sizeof(char *)
    # 9. sizeof(lzo_voidp) (size of void *)
    # 10. sizeof(lzo_callback_t) (size of a complex callback struct)
    # If any of these arguments except the first is -1, the check is skipped.
    e = ccall((:__lzo_init_v2, liblzo2),
        Cint,
        (Cuint, Cint, Cint, Cint, Cint, Cint, Cint, Cint, Cint, Cint),
        1, -1, -1, -1, -1, -1, -1, -1, -1, -1)
    if e != 0
        throw(ErrorException("initialization of liblzo2 failed: $e"))
    end
end