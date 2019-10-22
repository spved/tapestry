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
    list =  Enum.filter(matchSuffix("356A192B79","356AYUO879"), & !is_nil(&1))
    IO.inspect Enum.filter(matchSuffix("356A192B79","356AYUO879"), & !is_nil(&1))
    #IO.inspect list[length(list)-1]
    IO.inspect Enum.at(list, length(list)-1)
  end

  def handle_call({:setHashId,nodeID}, _from ,state) do
   #IO.inspect state
    {_, neighborMap} = state
    hashId = :crypto.hash(:sha, Integer.to_string(nodeID))|> Base.encode16
    IO.inspect hashId
    state={hashId, neighborMap}
    {:reply,hashId, state}
    
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
