defmodule TapestrySimulator.Util do


  def  getLevels(), do: 8
  def  getDigits(), do: 4

  def  maxHops(), do: 8


  def matchSuffix(_, _, 8) do
    8
  end

   def matchSuffix(node1, node2, n) do
    if(Enum.at(node1, n) == Enum.at(node2,n)) do
      matchSuffix(node1, node2, n + 1)
    else
      matchSuffix(node1, node2, 8)
      n
    end
  end

  def nextHop(source, sourceHash, dest, destHash, level, map) do
    if level == maxHops() do
      {source, level}
    else
      {index, _} = :string.to_integer(String.at(destHash, level))

      if level == 8 do
        IO.inspect dest, label: destHash
        IO.inspect source, label: sourceHash
      end

      pi = map |> Enum.at(level)|> Enum.at(index)

      if pi == source do
        nextHop(source, sourceHash, dest, destHash, level+1, map)
      else
        {pi, level+1}
      end
    end
  end

end
