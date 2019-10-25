defmodule TapestrySimulator do

  def main(args) do
    if (Enum.count(args)!=2) do
      IO.puts" Illegal Arguments Provided"
      System.halt(1)
    else
      numNodesAll=Enum.at(args, 0)|>String.to_integer()
      numNodes = round(numNodesAll)

      allNodes = Enum.map((1..numNodes), fn(x) ->
        pid=TapestrySimulator.Insertion.start_node()
        TapestrySimulator.Insertion.setHash(pid,x)
        pid
      end)
      IO.inspect "allnodes"
      IO.inspect allNodes

      Enum.each(allNodes, fn(x) ->
        TapestrySimulator.Insertion.insertNode(x,allNodes)
       end)

       #IO.inspect TapestrySimulator.Util.matchSuffix(11123132, 30031323,0), label: "See"


     end



  end

  def infiniteLoop() do
    infiniteLoop()
  end
  def init(:ok) do
    {:ok, {0,[]}} #{hashId, neighborMap} , {hashId, neighborMap}
  end
end

TapestrySimulator.main(System.argv())
