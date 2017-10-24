using LargeColumns
using Base.Test

import LargeColumns:
    # internals
    fixed_Tuple_types, representative_value, write_layout, read_layout, meta_path

@testset "utilities" begin
    @test fixed_Tuple_types(Tuple{Int, Int}) ≡ (Int, Int)
    @test fixed_Tuple_types(Tuple{Int, Float64, Char}) ≡ (Int, Float64, Char)
    @test_throws ArgumentError fixed_Tuple_types(Tuple{Int, Vararg{Int}})

    @test representative_value(Int) isa Int
    @test representative_value(Float64) isa Float64
    @test representative_value(Date) isa Date
    @test representative_value(Tuple{Date,Int}) isa Tuple{Date,Int}
    @test_throws ArgumentError representative_value(Vector{Int})
end

@testset "layout information" begin
    dir = mktempdir()
    N = rand(1:10_000)
    S = Tuple{Date,Int}
    write_layout(dir, N, S)
    @test read_layout(dir) ≡ (N, S)
end

@testset "meta path" begin
    @test meta_path("/tmp/", "test") == "/tmp/test"
    @test_throws ArgumentError meta_path("/tmp/", LargeColumns.LAYOUT_FILE)
    @test_throws ArgumentError meta_path("/tmp/", "99.bin")
end

@testset "write values, get back as mmapped" begin
    dir = mktempdir()

    # write
    sink = SinkColumns(dir, Tuple{Int, Float64})
    for i in 1:9
        push!(sink, (i, Float64(i)))
    end
    push!(sink, (10, 10))       # test conversion
    @test length(sink) == 10
    @test eltype(sink) == Tuple{Int, Float64}
    flush(sink)     # NOTE calling both `flush` and `close` is not a strong test
    close(sink)

    # append
    sink = SinkColumns(dir, true)
    for i in 11:15
        push!(sink, (i, Float64(i)))
    end
    @test length(sink) == 15
    @test eltype(sink) == Tuple{Int, Float64}
    close(sink)

    # mmap
    cols = MmappedColumns(dir)
    @test eltype(cols) == Tuple{Int, Float64}
    @test length(cols) == 15
    @test cols[3] ≡ (3, 3.0)
    @test cols == [(i, Float64(i)) for i in 1:15]
end

@testset "mmap standalone, opened multiple times" begin
    dir = mktempdir()
    N = 39
    # create
    cols = MmappedColumns(dir, N, Tuple{Int}) # create
    col = cols.columns[1]
    col .= randperm(N)          # random permutation
    Mmap.sync!(cols)
    # reopen and sort
    cols = MmappedColumns(dir)
    sort!(cols.columns[1])
    # reopen and test
    cols = MmappedColumns(dir)
    @test cols == [(i,) for i in 1:N]
end
