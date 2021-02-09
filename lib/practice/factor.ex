defmodule Practice.Factor do
  def factor_helper(n, acc) do
    d = Enum.find(2..ceil(:math.sqrt(n)), fn x -> rem(n, x) == 0 end)
    cond do
      n == 1 -> acc
      d == nil -> [n | acc]
      true -> factor_helper(div(n, d), [d | acc])
    end
  end

  def factor(n) do
    if is_binary(n) do
      {n, _} = Integer.parse(n)
      Enum.reverse(factor_helper(n, []))
    else
      Enum.reverse(factor_helper(n, []))
    end
  end

end
