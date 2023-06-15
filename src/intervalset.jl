using IterTools

struct Interval
  start
  finish

  Interval(x::Real) = new(x, x)
  Interval(x) = new(x[1], x[2])
  Interval(x, y) = new(x, y)
end

length(interval::Interval) = interval.finish - interval.start + 1
get_inf(interval::Interval) = interval.start
get_sup(interval::Interval) = interval.finish
is_valid(interval::Interval) = (interval.start <= interval.finish)
range(interval::Interval) = interval.start == interval.finish ? [interval.start] : [interval.start, interval.finish] 

struct IntervalSet
  intervals::Vector{Interval}
end

to_intervalset(interval::Interval) = IntervalSet([interval])
is_empty(interval_set::IntervalSet) = Base.length(interval_set.intervals) == 0
length(interval_set::IntervalSet) = map(x -> length(x), interval_set.intervals) |> sum
max(interval_set::IntervalSet) = maximum(length, interval_set.intervals; init=0)

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

  flat_left_is  = enumerate(chain(flatten_iter(left_is),  [sentinel]))
  flat_right_is = enumerate(chain(flatten_iter(right_is), [sentinel]))

  result = []
  
  scan = minimum((get_inf(left_is), get_inf(right_is)))

  iter_left = iterate(flat_left_is)
  iter_right = iterate(flat_left_is)

  (left_index, left_element),   state_left  = iter_left
  (right_index, right_element), state_right = iter_right

  while scan < sentinel
    is_in_left  = !((scan < left_element)  ^ (left_index % 2 == 0))
    is_in_right = !((scan < right_element) ^ (right_index % 2 == 0))

    is_in_result = op(is_in_left, is_in_right)

    if is_in_result ^ (Base.length(result) % 2 == 0)
      push!(result, scan)
    end

    if scan == left_element
        (left_index, left_element), state_left    = iterate(flat_left_is, state_left)
    else
        (right_index, right_element), state_right = iterate(flat_right_is, state_right)
    end
    scan = minimum((left_element, right_element))
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

end
