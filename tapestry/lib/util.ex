defmodule TapestrySimulator.Util do
  def getLevels(), do: 8
  def getDigits(), do: 6

  def maxHops(), do: 8

  def matchSuffix(_, _, 8) do
    8
  end

  def matchSuffix(node1, node2, n) do
    if(Enum.at(node1, n) == Enum.at(node2, n)) do
      matchSuffix(node1, node2, n + 1)
    else
      matchSuffix(node1, node2, 8)
      n
    end
  end

  def nextHop(source, dest, level, map) do
    {_, destHash} = dest
    if level == maxHops() do
      {source, level}
    else
      {index, _} = :string.to_integer(String.at(destHash, level))

      pi = map |> Enum.at(level) |> Enum.at(index)

      if pi == source do
        nextHop(source, dest, level + 1, map)
      else
        {pi, level + 1}
      end
    end
  end
end
