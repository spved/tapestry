defmodule TapestrySimulator do
  def main(args) do
    if Enum.count(args) != 2 do
      IO.puts(" Illegal Arguments Provided")
      System.halt(1)
    else
      numNodesAll = Enum.at(args, 0) |> String.to_integer()
      numRequests = Enum.at(args, 1) |> String.to_integer()

      numNodes = round(numNodesAll * 0.8)

      allNodes =
        Enum.map(1..numNodes, fn _ ->
          pid = TapestrySimulator.Insertion.start_node()
          TapestrySimulator.Insertion.setHash(pid)
          pid
        end)

      # IO.inspect allNodes, label: "All Nodes"
      Enum.map(allNodes, fn x ->
        TapestrySimulator.Insertion.insertNode(x, allNodes)
      end)

      table = :ets.new(:table, [:named_table, :public])
      :ets.insert(table, {"dynamicNode", []})

      dynamicNodes =
        Enum.map((numNodes + 1)..numNodesAll, fn _ ->
          [{_, dynamicNodeList}] = :ets.lookup(table, "dynamicNode")
          newNode = dynamicNodeInsertion(allNodes ++ dynamicNodeList)
          dynamicNodeList = dynamicNodeList ++ [newNode]
          :ets.insert(table, {"dynamicNode", dynamicNodeList})
          newNode
        end)

      # IO.inspect TapestrySimulator.Util.matchSuffix(String.graphemes("12345789"), String.graphemes("12345780"), 0)

      allNodes = dynamicNodes ++ allNodes
      #### Routing####
      ## Send numRequests
      nodes =
        Enum.map(allNodes, fn ni ->
          nhash = GenServer.call(ni, {:getHashId})
          {ni, nhash}
        end)

      # IO.inspect nodes, label: "Nodes"

      # max count
      :ets.insert(table, {"hops", 0})
      # total requests completed
      :ets.insert(table, {"tr", 0})
      ## counter is a process to update counter
      counter = TapestrySimulator.Insertion.start_node()

      Enum.map(allNodes, fn source ->
        Enum.map(1..numRequests, fn _ ->
          # IO.inspect Enum.random(allNodes), label: "Dest"
          dest = Enum.random(nodes)
          TapestrySimulator.Insertion.deliverMsg(source, dest, counter)
        end)
      end)

      infiniteLoop(numRequests * numNodesAll)
    end
  end

  def dynamicNodeInsertion(allNodes) do
    pid = TapestrySimulator.Insertion.start_node()
    TapestrySimulator.Insertion.setHash(pid)
    allNodes = allNodes ++ [pid]
    TapestrySimulator.Insertion.insertNode(pid, allNodes)
    TapestrySimulator.Insertion.getSurrogate(List.delete(allNodes, pid), pid)
    pid
  end

  def infiniteLoop(count) do
    [{_, tr}] = :ets.lookup(:table, "tr")

    if tr >= count do
      [{_, maxHops}] = :ets.lookup(:table, "hops")
      IO.puts(maxHops)
    else
      infiniteLoop(count)
    end
  end

  def init(:ok) do
    # {hashId, neighborMap} , {hashId, neighborMap}
    {:ok, {0, []}}
  end
end

TapestrySimulator.main(System.argv())
