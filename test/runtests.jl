using LibLZO
using TestItemRunner

@testitem "Canterbury safe round-trip" begin
    using LazyArtifacts
    using Random

    let 
        algos = (
            LZO1X_1, LZO1X_1_11, LZO1X_1_12, LZO1X_1_15, LZO1X_999,
            LZO1B, LZO1B_99,
            LZO1C, LZO1C_99, LZO1C_999,
            LZO1F_1, LZO1F_999,
            LZO1Y_1, LZO1Y_999,
            LZO1Z_999,
            LZO2A_999,
        )
        cc_path = artifact"CanterburyCorpus"
        cpu_ghz = first(Sys.cpu_info()).speed / 1000 # not a great way to compute CPU speed in GHz, but it's only for logging purposes
        for fn in readdir(cc_path; sort=true, join=true)
            truth = read(fn)
            for algo in algos
                t1 = time_ns()
                c = compress(algo, truth)
                t2 = time_ns()
                @test length(c) < length(truth)
                t3 = time_ns()
                d = decompress(algo, c)
                t4 = time_ns()
                @test d == truth
                @info "safe round-trip complete" algorithm=algo file=last(splitpath(fn)) filesize=length(truth) ratio=length(c)/length(truth) compress_time_ns_per_byte=(t2-t1)/length(truth)*cpu_ghz decompress_time_ns_per_byte=(t4-t3)/length(truth)*cpu_ghz
            end
        end

        # true random
        random_data = rand(MersenneTwister(0), UInt8, 1_000_000)
        for algo in algos
            t1 = time_ns()
            c = compress(algo, random_data)
            t2 = time_ns()

            t3 = time_ns()
            d = decompress(algo, c)
            t4 = time_ns()
            @test d == random_data
            @info "safe round-trip complete" algorithm=algo file="random" filesize=length(random_data) ratio=length(c)/length(random_data) compress_time_ns_per_byte=(t2-t1)/length(random_data)*cpu_ghz decompress_time_ns_per_byte=(t4-t3)/length(random_data)*cpu_ghz
        end
    end
end

@testitem "Canterbury safe in-place round trip" begin
    using LazyArtifacts
    using Random

    let 
        algos = (
            LZO1X_1, LZO1X_1_11, LZO1X_1_12, LZO1X_1_15, LZO1X_999,
            LZO1B, LZO1B_99,
            LZO1C, LZO1C_99, LZO1C_999,
            LZO1F_1, LZO1F_999,
            LZO1Y_1, LZO1Y_999,
            LZO1Z_999,
            LZO2A_999,
        )
        cc_path = artifact"CanterburyCorpus"
        for fn in readdir(cc_path; sort=true, join=true)
            truth = read(fn)
            for algo in algos
                c = compress(algo, truth)
                d1 = zeros(UInt8, length(truth) + 1)
                l = decompress!(algo, d1, c)
                @test l == length(truth)
                @test first(d1, l) == truth
                d2 = zeros(UInt8, l-1)
                @test_throws OverflowError decompress!(algo, d2, c)
            end
        end

        # true random
        random_data = rand(MersenneTwister(0), UInt8, 1_000_000)
        for algo in algos
            c = compress(algo, random_data)
            d1 = zeros(UInt8, length(random_data) + 1)
            l = decompress!(algo, d1, c)
            @test l == length(random_data)
            @test first(d1, l) == random_data
            d2 = zeros(UInt8, l-1)
            @test_throws OverflowError decompress!(algo, d2, c)
        end
    end
end

@testitem "Canterbury unsafe round-trip" begin
    using LazyArtifacts
    using Random

    let 
        algos = (
            LZO1X_1, LZO1X_1_11, LZO1X_1_12, LZO1X_1_15, LZO1X_999,
            LZO1, LZO1_99,
            LZO1A, LZO1A_99,
            LZO1B, LZO1B_99,
            LZO1C, LZO1C_99, LZO1C_999,
            LZO1F_1, LZO1F_999,
            LZO1Y_1, LZO1Y_999,
            LZO1Z_999,
            LZO2A_999,
        )
        cc_path = artifact"CanterburyCorpus"
        cpu_ghz = first(Sys.cpu_info()).speed / 1000 # not a great way to compute CPU speed in GHz, but it's only for logging purposes
        for fn in readdir(cc_path; sort=true, join=true)
            truth = read(fn)
            for algo in algos
                c = zeros(UInt8, length(truth)*2)
                t1 = time_ns()
                nc = unsafe_compress!(algo, c, truth)
                t2 = time_ns()
                @test nc < length(truth)
                resize!(c, nc)
                d = zeros(UInt8, length(truth)*2) # just in case
                t3 = time_ns()
                nd = unsafe_decompress!(algo, d, c)
                t4 = time_ns()
                @test nd == length(truth)
                resize!(d, nd)
                @test d == truth
                @info "unsafe round-trip complete" algorithm=algo file=last(splitpath(fn)) filesize=length(truth) ratio=length(c)/length(truth) compress_time_cycles_per_byte=(t2-t1)/length(truth)*cpu_ghz decompress_time_cycles_per_byte=(t4-t3)/length(truth)*cpu_ghz
            end
        end

        # true random
        random_data = rand(MersenneTwister(0), UInt8, 1_000_000)
        for algo in algos
            c = zeros(UInt8, length(random_data)*2)
            t1 = time_ns()
            nc = unsafe_compress!(algo, c, random_data)
            t2 = time_ns()

            resize!(c, nc)
            d = zeros(UInt8, length(random_data)*2) # just in case
            t3 = time_ns()
            nd = unsafe_decompress!(algo, d, c)
            t4 = time_ns()
            @test nd == length(random_data)
            resize!(d, nd)
            @test d == random_data
            @info "unsafe round-trip complete" algorithm=algo file="random" filesize=length(random_data) ratio=length(c)/length(random_data) compress_time_cycles_per_byte=(t2-t1)/length(random_data)*cpu_ghz decompress_time_cycles_per_byte=(t4-t3)/length(random_data)*cpu_ghz
        end
    end
end

@testitem "aliases" begin
    using LazyArtifacts

    let 
        algo_aliases = Dict(
            LZO1X_1 => (LZO1X, LZO,),
            LZO1F_1 => (LZO1F,),
            LZO1Y_1 => (LZO1Y,),
            LZO1Z_999 => (LZO1Z,),
            LZO2A_999 => (LZO2A,),
        )
        cc_path = artifact"CanterburyCorpus"
        cc_dir = readdir(cc_path; sort=true, join=true)
        truth = read(first(cc_dir))

        for (algo, aliases) in algo_aliases
            algo_c = compress(algo, truth)
            for alias in aliases
                alias_c = compress(alias, truth)
                @test algo_c == alias_c
            end
        end
    end
end

@testitem "levels" begin
    using LazyArtifacts
    using Random

    let
        algos = (
            LZO1X_1, LZO1X_1_11, LZO1X_1_12, LZO1X_1_15,
            LZO1B_99,
            LZO1C_99, LZO1C_999,
            LZO1F_1, LZO1F_999,
            LZO1Y_1,
            LZO2A_999,
        )
        for algo in algos
            algo_obj = algo()
            @test compression_level(algo_obj) == 0
        end
    end

    let 
        algos = (
            LZO1B, LZO1C, LZO1X_999, LZO1Y_999, LZO1Z_999,
        )
        cc_path = artifact"CanterburyCorpus"
        cc_dir = readdir(cc_path; sort=true, join=true)
        truth = read(first(cc_dir))

        for algo in algos
            last_size = typemax(Int)
            for level in 1:9
                algo_obj = algo(; compression_level=level)
                @test compression_level(algo_obj) == level
                c = compress(algo_obj, truth)
                d = decompress(algo_obj, c)
                @info "level compression complete" algorithm=algo level=level ratio=length(c)/length(truth)
                @test length(c) <= length(truth)
                @test d == truth
                if length(c) > last_size
                    @warn "unexpectedly worse ratio" algorithm=algo level=level ratio=length(c)/length(truth) last_ratio=last_size/length(truth)
                end
                last_size = length(c)
            end
        end
    end
end

@testitem "optimize" begin
    using LazyArtifacts
    using Random

    let 
        algos = (
            LZO1X_1, LZO1X_1_11, LZO1X_1_12, LZO1X_1_15, LZO1X_999, LZO1Y_1, LZO1Y_999,
        )
        cc_path = artifact"CanterburyCorpus"
        for fn in readdir(cc_path; sort=true, join=true)
            truth = read(fn)
            for algo in algos
                c = compress(algo, truth)
                o = optimize!(algo, copy(c))
                smaller_size = min(length(c), length(o))
                ndiff = count(@view(c[begin:smaller_size]) .!= @view(o[begin:smaller_size])) + abs(length(c) - length(o))
                @info "optimization complete" algorithm=algo filename=last(splitpath(fn)) original_ratio=length(c)/length(truth) optimized_ratio=length(o)/length(truth) Δ=length(o)-length(c) diff_ratio=ndiff/length(truth)
                @test length(o) < length(truth)
                @test length(o) <= length(c)
            end
        end
    end
end

@run_package_tests verbose = true