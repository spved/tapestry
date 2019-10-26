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
       neighborMap = Enum.map((0..7), fn(level) ->
         fillLevel(level, self(), hashId,numNodes)
        end)

        #IO.inspect neighborMap, label: hashId
    state={hashId, neighborMap}
    {:reply,hashId, state}
  end
def handle_call({:createNeigborMap,nodeID}, _from ,state) do
    {hashId, _} = state

      neighborMap = Enum.map((0..7), fn(x) ->
           lis = Enum.map((0..3), fn(y) ->
            nil
        end)
        end)
       #IO.inspect neighborMap
    state={hashId, neighborMap}
    {:reply,hashId, state}
  end

  def handle_call({:getSurrogate,allNodes,pid}, _from ,state) do
    #IO.inspect "came to surrogate"

    {hashId, neighborMap} = state
    #IO.inspect "hashId"
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

      {max,surrogate} = if(x>=max) do
         {x,node}
         else
          {max,surrogate}
      end
      {max,surrogate}
    end)


    {max, surrogate} = Enum.max(maxList)
     surrogateList = Enum.map((maxList), fn(s) ->
      {m, surrogate} = s
      if(m==max) do
         s
       else
       end
    end)

    notifyNeighbor(Enum.filter(surrogateList, & !is_nil(&1)), pid)
    state={hashId, neighborMap}
    {:reply,hashId, state}
  end

  def notifyNeighbor(surrogateList, newNode) do

     Enum.map((surrogateList), fn(s) ->
        {max, {pid, hashId}} = s
        max = if max == 8  do
          7
        else
          max
        end
        GenServer.cast(pid, {:notify,pid, newNode, hashId, max})
     end)
  end

   def handle_cast({:notify,s,newNode, sHash, max},state) do
    {hashID,_} = state
    newNodeHash = if(newNode != self()) do
      GenServer.call(newNode, {:getHashId})
    else
      hashID
    end


   {hashId, neighborMap} = state

   index = String.to_integer(String.at(newNodeHash,max))
   #index = String.to_integer(String.at("30132123",max))


   levelList =  Enum.at(neighborMap, max)
   levelListReplaced = List.replace_at(levelList, index, newNode)
   modifiedNeighborMap = List.replace_at(neighborMap, max, levelListReplaced)
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

     tempNodes = Enum.filter((nodes), fn(node) ->
       {ni, nhash} = node
       n2 = String.graphemes(nhash)
       x = TapestrySimulator.Util.matchSuffix(n1,n2,0)

       x >= level
     end)

     levelIds = Enum.map((0..3), fn(digit) ->
       levelNode = Enum.find((tempNodes), fn(node) ->
         {ni, nhash} = node
         if Integer.to_string(digit, 10) != String.at(hashID, level) || hashID == nhash do
           Integer.to_string(digit, 10) == String.at(nhash, level)
         end
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

  def handle_cast({:updateCounter, hops},state) do
    [{_, count}] = :ets.lookup(:table, "hops")
    if hops > count do
      :ets.update_counter(:table, "hops", hops-count)
      #[{_, count}] = :ets.lookup(:table, "hops")
      #IO.inspect count, label: "Updated Count"
    end
    {:noreply, state}
  end

  def deliverMsg(source, dest, counter) do
    msg = Time.utc_now()
    {destId, destHash} = dest
    Process.send_after(source, {:deliver, destId, destHash, msg, 0, counter},1)
  end

  def handle_info({:deliver, destId, destHash, msg, level, counter} ,state) do
    {hashID , neighborMap} = state
    {pi, nextlevel} = TapestrySimulator.Util.nextHop(self(), hashID, destId, destHash, level, neighborMap)
    if pi == self() do
      hops = Time.utc_now().second - msg.second
      #IO.inspect hops, label: "UpdateCounter"
      GenServer.cast(counter, {:updateCounter,hops})
      :ets.update_counter(:table, "tr", {2,1})

    else
      scheduleRouting(pi, destId, destHash, msg, nextlevel, counter)
      #GenServer.cast(pi, {:deliver, destId, destHash, msg, level})
    end
    {:noreply, state}
  end

  defp scheduleRouting(pi, destId, destHash, msg, level, counter) do
    Process.send_after(pi, {:deliver, destId, destHash, msg, level, counter}, 1000)
  end

  def init(:ok) do
    {:ok, {0,[]}} #{hashId, neighborMap} , {hashId, neighborMap}
  end
end
