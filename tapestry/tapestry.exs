defmodule TapestrySimulator do

  def main(args) do
    
        numNodes=Enum.at(args, 0)|>String.to_integer()

        

        allNodes = Enum.map((1..numNodes), fn(x) ->
          pid=TapestrySimulator.Insertion.start_node()
          TapestrySimulator.Insertion.insertNode(pid,x)
          pid
        end)

     
  end
   
  def infiniteLoop() do
    infiniteLoop()
  end
  def init(:ok) do
    {:ok, {0,[]}} #{hashId, neighborMap} , {hashId, neighborMap}
  end
end

TapestrySimulator.main(System.argv())
