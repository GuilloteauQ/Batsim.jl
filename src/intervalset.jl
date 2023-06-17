using IterTools

struct Interval
  # [start, finish[
  start
  finish

  Interval(x::Real) = new(x, x)
  Interval(x) = new(x[1], x[2])
  Interval(x, y) = new(x, y)
end

Base.:(length)(interval::Interval) = interval.finish - interval.start + 1
get_inf(interval::Interval) = interval.start
get_sup(interval::Interval) = interval.finish
is_valid(interval::Interval) = (interval.start <= interval.finish)
range(interval::Interval) = interval.start == interval.finish ? [interval.start] : [interval.start, interval.finish] 
Base.:(==)(interval_left::Interval, interval_right::Interval) = interval_left.start == interval_right.start && interval_left.finish == interval_right.finish
Base.:(!=)(interval_left::Interval, interval_right::Interval) = interval_left.start != interval_right.start || interval_left.finish != interval_right.finish

struct IntervalSet
  intervals::Vector{Interval}
end

to_intervalset(interval::Interval) = IntervalSet([interval])
is_empty(interval_set::IntervalSet) = length(interval_set.intervals) == 0
Base.:(length)(interval_set::IntervalSet) = map(x -> length(x), interval_set.intervals) |> sum
max(interval_set::IntervalSet) = maximum(length, interval_set.intervals; init=0)
nb_intervals(interval_set::IntervalSet) = length(interval_set.intervals)
Base.:(==)(is_left::IntervalSet, is_right::IntervalSet) = (nb_intervals(is_left) == nb_intervals(is_right)) && (zip(is_left.intervals, is_right.intervals) |> y -> map(x-> x[1]==x[2], y) |> all)
# Base.:(!=)(is_left::IntervalSet, is_right::IntervalSet) = zip(is_left.intervals, is_right.intervals) |> y -> map(x-> x[1]!=x[2], y) |> any

function get_sup(interval_set)
  if is_empty(interval_set)
    -1
  else
    get_sup(last(interval_set.intervals))
  end
end

function get_inf(interval_set)
  if is_empty(interval_set)
    -1
  else
    get_inf(first(interval_set.intervals))
  end
end


function flatten_vec(interval_set)
  # map(x -> range(x), interval_set.intervals) |> Iterators.flatten |> collect
  map(x -> (get_inf(x), get_sup(x)), interval_set.intervals) |> Iterators.flatten |> collect
end

function flatten_iter(interval_set)
  # map(x -> range(x), interval_set.intervals) |> Iterators.flatten
  map(x -> (get_inf(x), get_sup(x)), interval_set.intervals) |> Iterators.flatten
end

function unflatten(point_list)
  intervals = partition(point_list, 2) .|>  x -> Interval(x)
  IntervalSet(intervals)
end

 # pub fn insert(&mut self, element: Interval) {
 #        let mut newinf = element.0;
 #        let mut newsup = element.1;

 #        // Because we may remove one interval from self while we loop through its clone, we need to
 #        // adjuste the position.
 #        let mut idx_shift = 0;
 #        for (pos, intv) in self.intervals.clone().iter().enumerate() {
 #            if newinf > intv.1 + 1 {
 #                continue;
 #            }
 #            if newsup + 1 < intv.0 {
 #                break;
 #            }

 #            self.intervals.remove(pos - idx_shift);
 #            idx_shift += 1;

 #            newinf = cmp::min(newinf, intv.0);
 #            newsup = cmp::max(newsup, intv.1);
 #        }
 #        self.intervals.push(Interval::new(newinf, newsup));
 #        self.intervals.sort();
 #    }


function merge(left_is, right_is, op)
  if is_empty(left_is) && is_empty(right_is)
    return left_is
  end

  sentinel = maximum((get_sup(left_is), get_sup(right_is))) + 1

  flat_left_is  = flatten_vec(left_is)
  flat_right_is = flatten_vec(right_is)
  flat_left_is = push!(flat_left_is, sentinel)
  flat_right_is = push!(flat_right_is, sentinel)
  println(flat_left_is)
  println(flat_right_is)

  result = []

  left_index = 1
  right_index = 1
  scan = minimum((flat_left_is[left_index], flat_right_is[right_index]))

  while scan < sentinel
    is_in_left  = !((scan < flat_left_is[left_index])   ^ (left_index % 2 == 1))
    is_in_right = !((scan < flat_right_is[right_index]) ^ (right_index % 2 == 1))

    is_in_result = op(is_in_left, is_in_right)

    if is_in_result ^ (Base.length(result) % 2 != 0)
      push!(result, scan)
    end

    if scan == flat_left_is[left_index]
      left_index += 1
    end
    if scan == flat_right_is[right_index]
      right_index += 1
    end
    scan = minimum((flat_left_is[left_index], flat_right_is[right_index]))
  end
  unflatten(result)
end

function interval_diff(left_is, right_is)
  merge(left_is, right_is, (x, y) -> x && !y)
end

function interval_union(left_is, right_is)
  merge(left_is, right_is, (x, y) -> x || y)
end

function interval_intersect(left_is, right_is)
  merge(left_is, right_is, (x, y) -> x && y)
end

using Test

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
    @test flatten_vec(IntervalSet([Interval(0, 1), Interval(5, 9)])) == [0, 1, 5, 9] 
    @test flatten_vec(IntervalSet([Interval(0, 0), Interval(5, 9)])) == [0, 0, 5, 9] 
  end

  @testset "IntervalSet-unflatten" begin
    @test IntervalSet([Interval(0, 1), Interval(5, 9)]) == unflatten([0, 1, 5, 9])
    @test IntervalSet([Interval(0, 0), Interval(5, 9)]) == unflatten([0, 0, 5, 9])
  end

  @testset "IntervalSet-empty" begin
    @test !is_empty(IntervalSet([Interval(0, 0)]))
    @test is_empty(IntervalSet([]))
  end

  @testset "IntevalSet-merge-union" begin
    @test 1 == 1
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
