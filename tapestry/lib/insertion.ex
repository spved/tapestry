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

  def insertNode(pid, nodeID, table) do
    GenServer.call(pid, {:setHashId,nodeID,table})
    GenServer.call(pid, {:setNeighbourMap,nodeID})
     n1 = String.graphemes("356AY78979")
     n2 = String.graphemes("356AY90B79")
     len = matchSuffix(n1,n2,0)
    IO.inspect (len)
    
  end

  def handle_call({:setHashId,nodeID,table}, _from ,state) do
   #IO.inspect state
    {_, neighborMap} = state
    hashId = :crypto.hash(:sha, Integer.to_string(nodeID))|> Base.encode16
    IO.inspect hashId
    [{_, currentList}] = :ets.lookup(table, "count")
    currentList = currentList ++ [hashId]
    :ets.insert(table, {"count",currentList})
    IO.inspect "currentList"
    IO.inspect currentList
    state={hashId, neighborMap}
    {:reply,hashId, state}
    
  end
  def matchSuffix(node1, node2, n) when n > 9 do
    n
  end

   def matchSuffix(node1, node2, n) do
    if(Enum.at(node1, n) == Enum.at(node2,n)) do
      matchSuffix(node1, node2, n + 1)
              
          else
              
             matchSuffix(node1, node2, 40)
             n
            end
    
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
    
    #neighborMap = Enum.map((1..40), fn(x) ->
     #      neighborMap = %{
      #    x => %{0 => hashId, 1 => hashId, 2 => hashId}
       #   }
        #end)

         neighborMap = Enum.map((1..40), fn(x) ->
           Enum.map((1..16), fn(y) ->
           neighborMap = %{
          x => %{y => hashId}
          }
          end)
        end)

        #Enum.map((1..16), fn(y) ->
           
       #   y => hashId
          
      #  end)


        IO.inspect neighborMap
    #neighborMap =
    state={hashId, neighborMap}
    {:reply,hashId, state}
  end
  def init(:ok) do
    {:ok, {0,[]}} #{hashId, neighborMap} , {hashId, neighborMap}
  end
end
