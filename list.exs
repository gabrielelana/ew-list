defmodule EwList do

  @spec count(list) :: non_neg_integer
  def count([]), do: 0
  def count([_|l]), do: 1 + count(l)


  @spec reverse(list) :: list
  def reverse(l), do: do_reverse(l, [])

  defp do_reverse([], r), do: r
  defp do_reverse([h|t], r), do: do_reverse(t, [h|r])


  @spec map(list, (any -> any)) :: list
  def map(l, f), do: do_map(l, f, [])

  defp do_map([], _, r), do: reverse(r)
  defp do_map([h|t], f, r), do: do_map(t, f, [f.(h)|r])


  @spec filter(list, (any -> boolean)) :: list
  def filter(l, f), do: do_filter(l, f, [])

  defp do_filter([], _, r), do: reverse(r)
  defp do_filter([h|t], f, r), do: do_filter(t, f, (if f.(h), do: [h|r], else: r))


  @spec reduce(list, acc, ((any, acc) -> acc)) :: acc when acc: any
  def reduce([], acc, _), do: acc
  def reduce([h|t], acc, f), do: reduce(t, f.(h, acc), f)


  @spec append(list, list) :: list
  def append(l1, l2), do: do_append(reverse(l1), l2)

  defp do_append([], l2), do: l2
  defp do_append([h|t1], t2), do: do_append(t1, [h|t2])


  @spec concat([[any]]) :: [any]
  def concat(ll), do: do_concat(reverse(ll), [])

  defp do_concat([], r), do: r
  defp do_concat([h|t], r), do: do_concat(t, append(h, r))
end


ExUnit.start(exclude: :pending)

defmodule EwListTest do
  alias EwList, as: L

  use ExUnit.Case, async: true

  defp odd?(n), do: rem(n, 2) == 1

  test "count of empty list" do
    assert L.count([]) == 0
  end

  test "count of normal list" do
    assert L.count([1,3,5,7]) == 4
  end

  test "count of huge list" do
    assert L.count(Enum.to_list(1..1_000_000)) == 1_000_000
  end

  test "reverse of empty list" do
    assert L.reverse([]) == []
  end

  test "reverse of normal list" do
    assert L.reverse([1,3,5,7]) == [7,5,3,1]
  end

  test "reverse of huge list" do
    assert L.reverse(Enum.to_list(1..1_000_000)) == Enum.to_list(1_000_000..1)
  end

  test "map of empty list" do
    assert L.map([], &(&1+1)) == []
  end

  test "map of normal list" do
    assert L.map([1,3,5,7], &(&1+1)) == [2,4,6,8]
  end

  test "map of huge list" do
    assert L.map(Enum.to_list(1..1_000_000), &(&1+1)) ==
      Enum.to_list(2..1_000_001)
  end

  test "filter of empty list" do
    assert L.filter([], &odd?/1) == []
  end

  test "filter of normal list" do
    assert L.filter([1,2,3,4], &odd?/1) == [1,3]
  end

  test "filter of huge list" do
    assert L.filter(Enum.to_list(1..1_000_000), &odd?/1) ==
      Enum.map(1..500_000, &(&1*2-1))
  end

  test "reduce of empty list" do
    assert L.reduce([], 0, &(&1+&2)) == 0
  end

  test "reduce of normal list" do
    assert L.reduce([1,2,3,4], -3, &(&1+&2)) == 7
  end

  test "reduce of huge list" do
    assert L.reduce(Enum.to_list(1..1_000_000), 0, &(&1+&2)) ==
      Enum.reduce(1..1_000_000, 0, &(&1+&2))
  end

  test "reduce with non-commutative function" do
    assert L.reduce([1,2,3,4], 10, fn x, acc -> acc - x end) == 0
  end

  test "append of empty lists" do
    assert L.append([], []) == []
  end

  test "append of empty and non-empty list" do
    assert L.append([], [1,2,3,4]) == [1,2,3,4]
  end

  test "append of non-empty and empty list" do
    assert L.append([1,2,3,4], []) == [1,2,3,4]
  end

  test "append of non-empty lists" do
    assert L.append([1,2,3], [4,5]) == [1,2,3,4,5]
  end

  test "append of huge lists" do
    assert L.append(Enum.to_list(1..1_000_000), Enum.to_list(1_000_001..2_000_000)) ==
      Enum.to_list(1..2_000_000)
  end

  test "concat of empty list of lists" do
    assert L.concat([]) == []
  end

  test "concat of normal list of lists" do
    assert L.concat([[1,2],[3],[],[4,5,6]]) == [1,2,3,4,5,6]
  end

  test "concat of huge list of small lists" do
    assert L.concat(Enum.map(1..1_000_000, &[&1])) ==
      Enum.to_list(1..1_000_000)
  end

  test "concat of small list of huge lists" do
    assert L.concat(Enum.map(0..9, &Enum.to_list((&1*100_000+1)..((&1+1)*100_000)))) ==
      Enum.to_list(1..1_000_000)
  end
end
