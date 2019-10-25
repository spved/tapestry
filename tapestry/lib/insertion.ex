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
  end

  def insertNode(pid,allNodes) do

    GenServer.call(pid, {:fillNeighborMap,pid,allNodes})
    
  end

   def createNeigborMap(pid) do

    GenServer.call(pid, {:createNeigborMap,pid})
    
  end

  def checkMap(pid) do

    GenServer.call(pid, {:checkMap,pid})
    
  end
   def handle_call({:checkMap,pid}, _from ,state) do
    {hashId, neighborMap} = state
    IO.inspect pid
    IO.inspect hashId
    IO.inspect neighborMap
    {:reply,hashId, state}

  end
   def getSurrogate(allNodes,pid) do

    GenServer.call(pid, {:getSurrogate,allNodes, pid})
    
  end
   def randomizer(length) do
       numbers = "0123"
       lists =numbers |> String.split("", trim: true)
       do_randomizer(length, lists)
    end
    defp get_range(length) when length > 1, do: (1..length)
    defp get_range(_), do: [1]
    defp do_randomizer(length, lists) do
       get_range(length)
       |> Enum.reduce([], fn(_, acc) -> [Enum.random(lists) | acc] end)
       |> Enum.join("")
    end

  def handle_call({:setHashId,nodeID}, _from ,state) do
    {_, neighborMap} = state
    #hashId = :crypto.hash(:sha, Integer.to_string(nodeID))|> Base.encode16
    hashId = randomizer(8)
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

  def handle_call({:fillNeighborMap,nodeID,numNodes}, _from ,state) do
    {hashId, _} = state

      #fillLevel will return list at each level, which is combined using map
       neighborMap = Enum.map((1..8), fn(level) ->
         fillLevel(level-1, self(), hashId,numNodes)
        end)

        IO.inspect neighborMap, label: hashId
        #IO.inspect neighborMap
    state={hashId, neighborMap}
    {:reply,hashId, state}
  end
def handle_call({:createNeigborMap,nodeID}, _from ,state) do
    {hashId, _} = state

      neighborMap = Enum.map((1..8), fn(x) ->
           lis = Enum.map((1..4), fn(y) ->
            nil  
        end)
        end)
       IO.inspect neighborMap
    state={hashId, neighborMap}
    {:reply,hashId, state}
  end

  def handle_call({:getSurrogate,allNodes,pid}, _from ,state) do
    #IO.inspect "came to surrogate"
    
    {hashId, neighborMap} = state
    IO.inspect "hashId"
    #IO.inspect "30132123"
    n1 = String.graphemes(hashId)
    IO.inspect hashId
    nodes = Enum.map((allNodes), fn(ni) ->
      nhash = if(ni != pid) do
        GenServer.call(ni, {:getHashId})
      else
        hashId
      end
      {ni, nhash}
    end)

     max = 0
    surrogate = ""
    
    maxList = Enum.map((nodes), fn(node) ->
      {ni, nhash} = node
      n2 = String.graphemes(nhash)
      x = TapestrySimulator.Util.matchSuffix(n1,n2,0)
      IO.inspect "x"
      IO.inspect x

      {max,surrogate} = if(x>=max) do
        
         {x,node}
         else
          {max,surrogate}
      end
       
      {max,surrogate}
    end)


    IO.inspect "surrogate"
    IO.inspect maxList
    IO.inspect "max of all"
    IO.inspect Enum.max(maxList)
    {max, surrogate} = Enum.max(maxList)
    IO.inspect max  
     surrogateList = Enum.map((maxList), fn(s) ->
      {m, surrogate} = s
      if(m==max) do
         s
       else
       end
    end)
    IO.inspect "surrogateList"
    IO.inspect Enum.filter(surrogateList, & !is_nil(&1))
    notifyNeighbor(Enum.filter(surrogateList, & !is_nil(&1)), pid)
    state={hashId, neighborMap}
    {:reply,hashId, state}
  end

  def notifyNeighbor(surrogateList, newNode) do
     #IO.inspect "surrogateList in notifyneighbor"
     #IO.inspect surrogateList
     Enum.map((surrogateList), fn(s) ->
        {max, {pid, hashId}} = s
        IO.inspect pid, label: "pid"
        GenServer.cast(pid, {:notify,pid, newNode, hashId, max})
     end)
  end

   def handle_cast({:notify,s,newNode, sHash, max},state) do
    #{a,b} = state
    IO.inspect newNode, label: "newNode"
    newNodeHash = GenServer.call(newNode, {:getHashId})
    IO.inspect newNodeHash, label: "newNodeHash"
    IO.inspect s, label: "s"
    #sHash = GenServer.call(s, {:getHashId})
    IO.inspect sHash, label: "sHash"
    IO.inspect "just state"
    IO.inspect state
   {hashId, neighborMap} = state
   IO.inspect newNodeHash, label: "test_newNode"
   IO.inspect max, label: "max"
   index = String.to_integer(String.at(newNodeHash,max))
   #index = String.to_integer(String.at("30132123",max))

   IO.inspect index, label: "index"
   IO.inspect "checking neighbor map"
   IO.inspect neighborMap
   levelList =  Enum.at(neighborMap, max)
   IO.inspect levelList, label: "is level list right?"
   levelListReplaced = List.replace_at(levelList, index, newNode)
   IO.inspect levelListReplaced
   modifiedNeighborMap = List.replace_at(neighborMap, max, levelListReplaced)
   IO.inspect neighborMap, label: "map before"
   IO.inspect modifiedNeighborMap, label: "map modified"
   state = {hashId, modifiedNeighborMap}
   {:noreply,state}
   end

  def fillLevel(level, pid, hashID, allNodes) do
  # 0 1 2 3 4 5 6 7 8 9 A B C D E F
    n1 = String.graphemes(hashID)

    nodes = Enum.map((allNodes), fn(ni) ->
      nhash = if(ni != pid) do
        GenServer.call(ni, {:getHashId})
      else
        hashID
      end
      {ni, nhash}
    end)

    tempNodes = Enum.take_while((nodes), fn(node) ->
      {ni, nhash} = node
      n2 = String.graphemes(nhash)
      x = TapestrySimulator.Util.matchSuffix(n1,n2,0)
      x == level
    end)
    #IO.inspect levelNodes, label: hashID

    levelIds = Enum.map((0..3), fn(digit) ->
      levelNode = Enum.find((tempNodes), fn(node) ->
        {ni, nhash} = node
        Integer.to_string(digit, 4) == String.at(nhash, level)
      end)
      node = if levelNode != nil do
        {ni, _} = levelNode
        ni
      end
      node
    end)
    #array at that level
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
