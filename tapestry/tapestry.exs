defmodule TapestrySimulator do

  def main(args) do
    if (Enum.count(args)!=2) do
      IO.puts" Illegal Arguments Provided"
      System.halt(1)
    else
      numNodesAll=Enum.at(args, 0)|>String.to_integer()
      numNodes = round(numNodesAll*0.8)
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
      
      {dynamicNodes,allNodes} = Enum.map((numNodes..numNodesAll), fn(x) -> 

        pid=TapestrySimulator.Insertion.start_node()
        TapestrySimulator.Insertion.setHash(pid,x)
        TapestrySimulator.Insertion.createNeigborMap(pid)
        IO.inspect pid, label: "pid of new node"
        TapestrySimulator.Insertion.insertNode(pid,allNodes)
        TapestrySimulator.Insertion.getSurrogate(allNodes,pid)
        #TapestrySimulator.Insertion.insertNode(pid,allNodes)
        allNodes = allNodes ++ pid
        IO.inspect allNodes, label: "added d"
        #IO.inspect dynamicNodes, label: "dynamicNodes each time"
        {pid,pid}
      end)
      IO.inspect "dynamicNodes"
      IO.inspect dynamicNodes

      

       #IO.inspect Enum.at(allNodes, 0)
       #TapestrySimulator.Insertion.getSurrogate(allNodes,Enum.at(allNodes, 0))
       allNodes = allNodes ++ dynamicNodes
       IO.inspect "testing the update on static nodes"
      Enum.map(allNodes, fn(x) ->
         TapestrySimulator.Insertion.checkMap(x)
     end)
     IO.inspect "testing the update on dynamic nodes"
     Enum.map(dynamicNodes, fn(x) ->
         TapestrySimulator.Insertion.checkMap(x)
     end)
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
