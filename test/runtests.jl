using LZOTools
using TestItemRunner

@testitem "Canterbury safe round-trip" begin
    using LazyArtifacts


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
            for algo in algos
                truth = read(fn)
                t1 = time_ns()
                c = compress(algo, truth)
                t2 = time_ns()
                @test length(c) < length(truth)
                t3 = time_ns()
                d = decompress(algo, c)
                t4 = time_ns()
                @test d == truth
                @info "safe round-trip complete" algorithm=algo file=last(splitpath(fn)) filesize=length(truth) ratio=length(c)/length(truth) compress_time_ns_per_byte=(t2-t1)/length(truth) decompress_time_ns_per_byte=(t4-t3)/length(truth)
            end
        end
    end
end

@testitem "Canterbury unsafe round-trip" begin
    using LazyArtifacts


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
        for fn in readdir(cc_path; sort=true, join=true)
            for algo in algos
                truth = read(fn)
                c = zeros(UInt8, length(truth))
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
                @info "unsafe round-trip complete" algorithm=algo file=last(splitpath(fn)) filesize=length(truth) ratio=length(c)/length(truth) compress_time_ns_per_byte=(t2-t1)/length(truth) decompress_time_ns_per_byte=(t4-t3)/length(truth)
            end
        end
    end
end

@run_package_tests verbose = true