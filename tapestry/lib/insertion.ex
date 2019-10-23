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
  def setHash(pid, nodeID) do
   GenServer.call(pid, {:setHashId,nodeID})
   GenServer.call(pid, {:setNeighborMap,nodeID})
  end

  def insertNode(pid,allNodes) do

    GenServer.call(pid, {:fillNeighborMap,pid,allNodes})
    test = Enum.map((1..2), fn(x) ->
           Enum.map((1..2), fn(y) ->
           test = %{
          x => %{y => ""}
          }
          end)
        end)
  end

  def handle_call({:setHashId,nodeID}, _from ,state) do
    {_, neighborMap} = state
    hashId = :crypto.hash(:sha, Integer.to_string(nodeID))|> Base.encode16
    IO.inspect hashId
    state={hashId, neighborMap}
    {:reply,hashId, state}

  end

  def handle_call({:getHashId}, _from ,state) do
    {hashId, _} = state
    {:reply,hashId, state}
  end

  def handle_call({:getNeighborMap}, _from ,state) do
    {_, NeighborMap} = state
    {:reply, NeighborMap, state}
  end

  def handle_call({:setNeighborMap,nodeID}, _from ,state) do
    {hashId, _} = state
    neighborMap = Enum.map((1..40), fn(x) ->
           Enum.map((1..16), fn(y) ->
           neighborMap = %{
          x => %{y => ""}
          }
          end)
    end)
    state={hashId, neighborMap}
    {:reply,hashId, state}
  end

  def handle_call({:fillNeighborMap,nodeID,numNodes}, _from ,state) do
    {hashId, neighborMap} = state

       neighborMap = Enum.map((1..40), fn(x) ->
         fillLevel(x,neighborMap, self(), hashId,numNodes)
        end)

        #IO.inspect neighborMap

    state={hashId, neighborMap}
    {:reply,hashId, state}
  end

  def fillLevel(level, neighborMap, pid, hashID, allNodes) do
  # 0 1 2 3 4 5 6 7 8 9 A B C D E F
  diff = level - 1
  n1 = String.graphemes(hashID)
  #IO.inspect hashID
  levelIds = Enum.map((1..16), fn(k) ->
    node = Enum.each((allNodes), fn(ni) ->
      nid = if(ni != pid) do
        nid = GenServer.call(ni, {:getHashId})
        nid
      else
        hashID
      end

    n2 = String.graphemes(nid)
    #IO.inspect nid
    x = TapestrySimulator.Util.matchSuffix(n1,n2,0)
    node = if(x == diff) do
      IO.inspect ni
      ni
    end
    end)  
    #IO.inspect node
    node
  end)
  #IO.inspect levelIds
  levelIds
end

  def handle_call({:getLevel, level}, _from ,state) do
    {_, neighborMap} = state
    levelNodes = Enum.at(neighborMap, level)
    {:reply,levelNodes, state}
  end

  def handle_cast({:notifyNodes, Ni, diff},state) do
    {hashId, _} = state
    i = String.at(hashId, diff)
  end

  def init(:ok) do
    {:ok, {0,[]}} #{hashId, neighborMap} , {hashId, neighborMap}
  end
end
