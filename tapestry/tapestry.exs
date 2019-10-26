defmodule TapestrySimulator do

  def main(args) do
    if (Enum.count(args)!=2) do
      IO.puts" Illegal Arguments Provided"
      System.halt(1)
    else
      numNodesAll=Enum.at(args, 0)|>String.to_integer()
      numRequests=Enum.at(args, 1)|>String.to_integer()

      numNodes = round(numNodesAll)

      ##Add nodes Statically
      allNodes = Enum.map((1..numNodes), fn(x) ->
        pid=TapestrySimulator.Insertion.start_node()
        TapestrySimulator.Insertion.setHash(pid)
        pid
      end)
      #IO.inspect allNodes, label: "AllNodes"

      Enum.each(allNodes, fn(x) ->
        TapestrySimulator.Insertion.insertNode(x,allNodes)
       end)

       ##Add nodes Dynamically


       ##Send numRequests
       nodes = Enum.map((allNodes), fn(ni) ->
         nhash = GenServer.call(ni, {:getHashId})
         {ni, nhash}
       end)
       #IO.inspect nodes, label: "Nodes"

       table = :ets.new(:table, [:named_table,:public])
               :ets.insert(table, {"hops", 0}) #max count
               :ets.insert(table, {"tr", 0}) #total requests completed
       ## counter is a process to update counter
       counter=TapestrySimulator.Insertion.start_node()

       Enum.map((allNodes), fn(source) ->
         Enum.map((1..numRequests), fn(r) ->
           #IO.inspect Enum.random(allNodes), label: "Dest"
           dest = Enum.random(nodes)
           TapestrySimulator.Insertion.deliverMsg(source, dest, counter)
         end)

       end)
       infiniteLoop(numRequests*numNodesAll)

     end


  end

  def infiniteLoop(count) do
    [{_, tr}] = :ets.lookup(:table, "tr")
    if tr >= count do
      [{_, maxHops}] = :ets.lookup(:table, "hops")
      IO.puts maxHops
    else
      infiniteLoop(count)
    end
  end

  def init(:ok) do
    {:ok, {0,[]}} #{hashId, neighborMap} , {hashId, neighborMap}
  end
end

TapestrySimulator.main(System.argv())
