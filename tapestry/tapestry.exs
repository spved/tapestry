defmodule TapestrySimulator do

  def main(args) do
    if (Enum.count(args)!=2) do
      IO.puts" Illegal Arguments Provided"
      System.halt(1)
    else
      numNodes=Enum.at(args, 0)|>String.to_integer()
      allNodes = Enum.map((1..numNodes), fn(x) ->
        #key = TapestrySimulator.Insertion.randomizer(8)
        
        #IO.inspect "key"
        #IO.inspect key

        pid=TapestrySimulator.Insertion.start_node()
        TapestrySimulator.Insertion.setHash(pid,x)
        pid
      end)
      IO.inspect "allnodes"
      IO.inspect allNodes

      Enum.map(allNodes, fn(x) ->
        TapestrySimulator.Insertion.insertNode(x,allNodes)
       end)

       IO.inspect Enum.at(allNodes, 0)
       TapestrySimulator.Insertion.getSurrogate(allNodes,Enum.at(allNodes, 0))
     end

      Enum.map(allNodes, fn(x) ->
         TapestrySimulator.Insertion.insertNode(x,allNodes)
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
