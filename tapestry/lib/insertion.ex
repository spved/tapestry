defmodule TapestrySimulator.Insertion do
  use GenServer
  @moduledoc """
  Documentation for Tapestry.
  """

  @doc """
  This takes care of creation of nodes.
  """
  def start_node() do
    {:ok,pid}=GenServer.start_link(__MODULE__, :ok,[])
    pid
  end

  def insertNode(pid, nodeID) do
    GenServer.call(pid, {:setHashId,nodeID})
    GenServer.call(pid, {:setNeighbourMap,nodeID})
     n1 = String.graphemes("356AY90B79")
     n2 = String.graphemes("356AY90B79")
    #list =  Enum.filter(print_multiple_times(n1,n2,0), & !is_nil(&1))
    IO.inspect (print_multiple_times(n1,n2,0))
    #IO.inspect list[length(list)-1]
    #IO.inspect Enum.at(list, length(list)-1)
  end

  def handle_call({:setHashId,nodeID}, _from ,state) do
   #IO.inspect state
    {_, neighborMap} = state
    hashId = :crypto.hash(:sha, Integer.to_string(nodeID))|> Base.encode16
    IO.inspect hashId
    state={hashId, neighborMap}
    {:reply,hashId, state}
    
  end
  def print_multiple_times(node1, node2, n) when n >= 40 do
    
  end

   def print_multiple_times(node1, node2, n) do
    if(Enum.at(node1, n) == Enum.at(node2,n)) do
      #(n+1)
      #IO.inspect n
      print_multiple_times(node1, node2, n + 1)
              
          else
              
             print_multiple_times(node1, node2, 40)
             n
            end
    
  end

  def matchSuffix(node1, node2) do
   n1 = String.graphemes(node1)
   n2 = String.graphemes(node2)
   len = 9
   
     Enum.map((0..len), fn(x) ->
          #IO.inspect Enum.at(n1, x)
          #IO.inspect Enum.at(n2, x)
          #IO.inspect flag
          
        
             if(Enum.at(n1, x) == Enum.at(n2,x)) do
              (x+1)
             
           else
             0
            end
            #IO.inspect f
        end)
  end
  def handle_call({:getHashId}, _from ,state) do
    {hashId, _} = state
    {:reply,hashId, state}
  end

  def handle_call({:getneighbourMap}, _from ,state) do
    {_, neighbourMap} = state
    {:reply, neighbourMap, state}
  end

  def handle_call({:setNeighbourMap,nodeID}, _from ,state) do
    {hashId, _} = state
    #neighborMap =
    #state={hashId, neighborMap}
    {:reply,hashId, state}
  end
  def init(:ok) do
    {:ok, {0,[]}} #{hashId, neighborMap} , {hashId, neighborMap}
  end
end
