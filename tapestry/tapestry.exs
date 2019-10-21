defmodule TapestrySimulator do

  def main(args) do
    if (Enum.count(args)!=2) do
      IO.puts" Illegal Arguments Provided"
      System.halt(1)
    else
        numNodes=Enum.at(args, 0)|>String.to_integer()

        numRequests=Enum.at(args, 1)

        allNodes = Enum.map((1..numNodes), fn(x) ->
          pid=TapestrySimulator.Insertion.start_node()
          TapestrySimulator.Insertion.insertNode(pid,x)
          pid
        end)

        #infiniteLoop()
    end
  end
  def infiniteLoop() do
    infiniteLoop()
  end

end

TapestrySimulator.main(System.argv())
