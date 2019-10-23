defmodule TapestrySimulator.Util do


  def  getLevels(), do: 40
  def  getDigits(), do: 16

  def matchSuffix(node1, node2, n) when n > 39 do
    n
  end

   def matchSuffix(node1, node2, n) do
    if(Enum.at(node1, n) == Enum.at(node2,n)) do
      matchSuffix(node1, node2, n + 1)
          else
             matchSuffix(node1, node2, 40)
             n
            end
  end



end
