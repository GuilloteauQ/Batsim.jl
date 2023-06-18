using Test
include("../src/intervalset.jl")

@testset "Interval" begin
  @testset "Interval-eq" begin
    @test Interval(0, 1) == Interval(0, 1)
    @test Interval(0, 0) == Interval(0)
    @test Interval([0, 1]) == Interval(0, 1)
    @test Interval(0, 0) != Interval(0, 1)
  end

  @testset "Interval-length" begin
    @test length(Interval(0, 0)) == 1
    @test length(Interval(0)) == 1
    @test length(Interval((0, 0))) == 1
    @test length(Interval([0, 0])) == 1 
    @test length(Interval(0, 1)) == 2
  end

  @testset "Interval-is_valid" begin
    @test is_valid(Interval(0, 0))
    @test is_valid(Interval(0, 1))
    @test is_valid(Interval(-1, 0))
    @test !is_valid(Interval(0, -1))
  end

  @testset "Interval-get_inf_sup" begin
    @test get_inf(Interval(0, 1)) == 0
    @test get_sup(Interval(0, 1)) == 1
  end
end

@testset "IntervalSet" begin
  @testset "IntervalSet-creation" begin
    @test length(to_intervalset(Interval(0, 0))) == 1
    @test length(IntervalSet([Interval(0, 0)])) == 1
    @test length(IntervalSet([Interval(0, 0), Interval(1, 2)])) == 3
    @test length(IntervalSet([Interval(0, 0), Interval(2, 2)])) == 2
  end

  @testset "IntervalSet-eq" begin
    @test IntervalSet([]) == IntervalSet([])
    @test IntervalSet([Interval(0, 0)]) != IntervalSet([])
    @test IntervalSet([Interval(0, 0)]) != IntervalSet([Interval(0, 1)])
    @test IntervalSet([Interval(0, 0)]) == IntervalSet([Interval(0, 0)])
    @test IntervalSet([Interval(0, 0), Interval(1, 1)]) != IntervalSet([Interval(0, 0)])
  end

  @testset "IntervalSet-flatten" begin
    @test flatten_vec(IntervalSet([Interval(0, 10), Interval(15, 20)])) == [0, 11, 15, 21] 
    @test flatten_vec(IntervalSet([Interval(0, 10)])) == [0, 11] 
  end

  @testset "IntervalSet-unflatten" begin
    @test IntervalSet([Interval(0, 10), Interval(15, 20)]) == unflatten([0, 11, 15, 21])
    @test IntervalSet([Interval(0, 10)]) == unflatten([0, 11])
  end

  @testset "IntervalSet-empty" begin
    @test !is_empty(IntervalSet([Interval(0, 0)]))
    @test is_empty(IntervalSet([]))
  end

  @testset "IntevalSet-merge-union" begin
    @test interval_union(IntervalSet([Interval(5, 10)]), IntervalSet([Interval(5, 10), Interval(15, 20)])) == IntervalSet([Interval(5, 10), Interval(15, 20)])
    @test interval_union(IntervalSet([Interval(5, 10), Interval(15, 20)]), IntervalSet([Interval(5, 10), Interval(15, 20)])) == IntervalSet([Interval(5, 10), Interval(15, 20)])
    @test interval_union(IntervalSet([Interval(5, 10), Interval(15, 20)]), IntervalSet([])) == IntervalSet([Interval(5, 10), Interval(15, 20)])
    @test interval_union(IntervalSet([Interval(0, 100)]), IntervalSet([Interval(5, 10), Interval(15, 20)])) == IntervalSet([Interval(0, 100)])
    @test interval_union(IntervalSet([Interval(0, 0), Interval(2, 2), Interval(3, 3)]), IntervalSet([Interval(1, 1)])) == IntervalSet([Interval(0, 3)])
    @test interval_union(IntervalSet([]), IntervalSet([])) == IntervalSet([])
  end

  @testset "IntevalSet-merge-diff" begin
    @test interval_diff(IntervalSet([Interval(5, 10)]), IntervalSet([Interval(5, 10), Interval(15, 20)])) == IntervalSet([])
    @test interval_diff(IntervalSet([Interval(0, 100)]), IntervalSet([Interval(5, 10), Interval(15, 20)])) == IntervalSet([Interval(0, 4), Interval(11, 14), Interval(21, 100)])
    @test interval_diff(IntervalSet([]), IntervalSet([])) == IntervalSet([])
  end

  @testset "IntevalSet-merge-intersect" begin
    @test interval_intersect(IntervalSet([Interval(5, 10)]), IntervalSet([Interval(5, 10), Interval(15, 20)])) == IntervalSet([Interval(5, 10)])
    @test interval_intersect(IntervalSet([]), IntervalSet([Interval(5, 10), Interval(15, 20)])) == IntervalSet([])
    @test interval_intersect(IntervalSet([Interval(5, 10), Interval(15, 20)]), IntervalSet([])) == IntervalSet([])
    @test interval_intersect(IntervalSet([Interval(0, 100)]), IntervalSet([Interval(5, 10), Interval(15, 20)])) == IntervalSet([Interval(5, 10), Interval(15, 20)])
    @test interval_intersect(IntervalSet([]), IntervalSet([])) == IntervalSet([])
  end
end
