
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
Base.show(io::IO, interval::Interval) = interval.start == interval.finish ? print(io, "$(interval.start)") : print(io, "$(interval.start)-$(interval.finish)")

struct IntervalSet
  intervals::Vector{Interval}
end

to_intervalset(interval::Interval) = IntervalSet([interval])
is_empty(interval_set::IntervalSet) = length(interval_set.intervals) == 0
Base.:(length)(interval_set::IntervalSet) = !is_empty(interval_set) ? map(x -> length(x), interval_set.intervals) |> sum : 0
max(interval_set::IntervalSet) = maximum(length, interval_set.intervals; init=0)
nb_intervals(interval_set::IntervalSet) = length(interval_set.intervals)
Base.:(==)(is_left::IntervalSet, is_right::IntervalSet) = (nb_intervals(is_left) == nb_intervals(is_right)) && (zip(is_left.intervals, is_right.intervals) |> y -> map(x-> x[1]==x[2], y) |> all)
# Base.:(!=)(is_left::IntervalSet, is_right::IntervalSet) = zip(is_left.intervals, is_right.intervals) |> y -> map(x-> x[1]!=x[2], y) |> any

function Base.show(io::IO, interval_set::IntervalSet)
  ints = interval_set.intervals .|> repr
  print(io, join(ints, " "))
end

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

function find_spots(interval_set, desired_length)
  if desired_length > length(interval_set)
    IntervalSet([])
  else
    remaining_length = desired_length
    intervals = []
    for interval in interval_set.intervals
      if remaining_length > 0
        if length(interval) <= remaining_length
          push!(intervals, interval)
          remaining_length -= length(interval)
        else
          start_interval = get_inf(interval)
          push!(intervals, Interval(start_interval, start_interval + remaining_length - 1))
          remaining_length = 0
        end
      else
        break
      end
    end
    IntervalSet(intervals)
  end
end


function flatten_vec(interval_set)
  # map(x -> range(x), interval_set.intervals) |> Iterators.flatten |> collect
  map(x -> (get_inf(x), get_sup(x) + 1), interval_set.intervals) |> Iterators.flatten |> collect
end

function flatten_iter(interval_set)
  # map(x -> range(x), interval_set.intervals) |> Iterators.flatten
  map(x -> (get_inf(x), get_sup(x)) + 1, interval_set.intervals) |> Iterators.flatten
end

function unflatten(point_list)
  intervals = partition(point_list, 2) .|>  x -> Interval(x[1], x[2] - 1)
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


  flat_left_is  = flatten_vec(left_is)
  flat_right_is = flatten_vec(right_is)
  sentinel = maximum((get_sup(left_is), get_sup(right_is))) + 2
  flat_left_is = push!(flat_left_is, sentinel)
  flat_right_is = push!(flat_right_is, sentinel)

  result = []

  scan = minimum((flat_left_is[1], flat_right_is[1]))
  left_index = 1
  right_index = 1

  while scan < sentinel
    is_in_left  = !(xor(scan < flat_left_is[left_index], left_index % 2 != 1))
    is_in_right = !(xor(scan < flat_right_is[right_index], right_index % 2 != 1))

    is_in_result = op(is_in_left, is_in_right)

    if xor(is_in_result, length(result) % 2 != 0)
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

Base.:(-)(left_is, right_is) = interval_diff(left_is, right_is)

function interval_union(left_is, right_is)
  merge(left_is, right_is, (x, y) -> x || y)
end

Base.:(|)(left_is, right_is) = interval_union(left_is, right_is)

function interval_intersect(left_is, right_is)
  merge(left_is, right_is, (x, y) -> x && y)
end

Base.:(&)(left_is, right_is) = interval_intersect(left_is, right_is)
