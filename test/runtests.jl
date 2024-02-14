using LZOTools
using TestItemRunner

@testitem "lzo1x compress Canterbury" begin
    using LazyArtifacts

    let 
        algos = (
            LZO1X_1, LZO1X_1_11, LZO1X_1_12, LZO1X_1_15, LZO1X_999,
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

@testitem "lzo1 compress Canterbury" begin
    using LazyArtifacts

    let 
        algos = (
            LZO1, LZO1_99,
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

@testitem "lzo1a compress Canterbury" begin
    using LazyArtifacts

    let 
        algos = (
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

@testitem "lzo1b compress Canterbury" begin
    using LazyArtifacts

    let 
        algos = (
            LZO1B, LZO1B_99,
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

@testitem "lzo1c compress Canterbury" begin
    using LazyArtifacts

    let 
        algos = (
            LZO1C, LZO1C_99, LZO1C_999
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

@testitem "lzo1f compress Canterbury" begin
    using LazyArtifacts

    let 
        algos = (
            LZO1F_1, LZO1F_999
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

@testitem "lzo1y compress Canterbury" begin
    using LazyArtifacts

    let 
        algos = (
            LZO1Y_1, LZO1Y_999
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