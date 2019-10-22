defmodule TapestrySimulator do

  def main(args) do
         if (Enum.count(args)!=2) do
           IO.puts" Illegal Arguments Provided"
            System.halt(1)
         else
         numNodes=Enum.at(args, 0)|>String.to_integer()

        

        allNodes = Enum.map((1..numNodes), fn(x) ->
          pid=TapestrySimulator.Insertion.start_node()
          TapestrySimulator.Insertion.insertNode(pid,x,numNodes)
          pid
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
