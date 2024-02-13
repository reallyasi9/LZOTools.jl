using LZOTools
using TestItemRunner

@testitem "lzo1x compress Canterbury" begin
    using LazyArtifacts

    let 
        algos = (
            LZO1X_1, LZO1X_1_11, LZO1X_1_12, LZO1X_1_15, LZO1X_999,
            LZO1, LZO1_99,
            LZO1A, LZO1A_99,
        )
        cc_path = artifact"CanterburyCorpus"
        for fn in readdir(cc_path; sort=true, join=true)
            for algo in algos
                truth = read(fn)
                c = compress(algo, truth)
                @test length(c) < length(truth)
            end
        end
    end
end

@run_package_tests verbose = true