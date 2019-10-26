defmodule TapestrySimulator.Insertion do
  use GenServer

  @moduledoc """
  Documentation for Tapestry.
  """

  @doc """
  This takes care of creation of nodes.
  """
  def start_node() do
    {:ok, pid} = GenServer.start_link(__MODULE__, :ok, [])
    pid
  end

  def setHash(pid) do
    GenServer.call(pid, {:setHashId})
  end

  def insertNode(pid, allNodes) do
    GenServer.call(pid, {:fillNeighborMap, allNodes})
  end

  def getSurrogate(allNodes, pid) do
    GenServer.call(pid, {:getSurrogate, allNodes, pid})
  end

  def randomizer(length) do
    numbers = "012345"
    lists = numbers |> String.split("", trim: true)
    do_randomizer(length, lists)
  end

  defp get_range(length) when length > 1, do: 1..length
  defp get_range(_), do: [1]

  defp do_randomizer(length, lists) do
    get_range(length)
    |> Enum.reduce([], fn _, acc -> [Enum.random(lists) | acc] end)
    |> Enum.join("")
  end


  def notifyNeighbor(surrogateList, newNode) do
    Enum.map(surrogateList, fn s ->
      {max, {pid, _}} = s

      max =
        if max == TapestrySimulator.Util.maxHops() do
          TapestrySimulator.Util.maxHops() - 1
        else
          max
        end

      GenServer.cast(pid, {:notify, newNode, max})
    end)
  end

  def fillLevel(level, pid, hashID, allNodes) do
    # 0 1 2 5 6 5 6 7 8 9 A B C D E F
    n1 = String.graphemes(hashID)

    nodes =
      Enum.map(allNodes, fn ni ->
        nhash =
          if(ni != pid) do
            GenServer.call(ni, {:getHashId})
          else
            hashID
          end

        {ni, nhash}
      end)

    tempNodes =
      Enum.filter(nodes, fn node ->
        {_, nhash} = node
        n2 = String.graphemes(nhash)
        x = TapestrySimulator.Util.matchSuffix(n1, n2, 0)

        x >= level
      end)

    levelIds =

      Enum.map(0..5, fn digit ->
        levelNode =
          Enum.find(tempNodes, fn node ->
            {_, nhash} = node

            if Integer.to_string(digit, 10) != String.at(hashID, level) || hashID == nhash do
              Integer.to_string(digit, 10) == String.at(nhash, level)
            end
          end)

        node =
          if levelNode != nil do
            {ni, _} = levelNode
            ni
          end

        node
      end)

    # array at that level
    levelIds
  end

  def handle_call({:getLevel, level}, _from, state) do
    {_, neighborMap} = state
    levelNodes = Enum.at(neighborMap, level)
    {:reply, levelNodes, state}
  end

  def handle_call({:setHashId}, _from, state) do
    {_, neighborMap} = state
    # hashId = :crypto.hash(:sha, Integer.to_string(nodeID))|> Base.encode16
    hashId = randomizer(8)
    state = {hashId, neighborMap}
    {:reply, hashId, state}
  end

  def handle_call({:getHashId}, _from, state) do
    {hashId, _} = state
    {:reply, hashId, state}
  end

  def handle_call({:getNeighborMap}, _from, state) do
    {_, NeighborMap} = state
    {:reply, NeighborMap, state}
  end

  def handle_call({:fillNeighborMap, numNodes}, _from, state) do
    {hashId, _} = state

    # fillLevel will return list at each level, which is combined using map
    neighborMap =
      Enum.map(0..7, fn level ->
        fillLevel(level, self(), hashId, numNodes)
      end)

    state = {hashId, neighborMap}
    {:reply, hashId, state}
  end

  def handle_call({:getSurrogate, allNodes, pid}, _from, state) do
    {hashId, neighborMap} = state
    n1 = String.graphemes(hashId)

    nodes =
      Enum.map(allNodes, fn ni ->
        nhash =
          if(ni != pid) do
            GenServer.call(ni, {:getHashId})
          else
            hashId
          end

        {ni, nhash}
      end)

    max = 0
    surrogate = ""

    maxList =
      Enum.map(nodes, fn node ->
        {_, nhash} = node
        n2 = String.graphemes(nhash)
        x = TapestrySimulator.Util.matchSuffix(n1, n2, 0)

        {max, surrogate} =
          if(x >= max) do
            {x, node}
          else
            {max, surrogate}
          end

        {max, surrogate}
      end)

    {max, _} = Enum.max(maxList)

    surrogateList =
      Enum.map(maxList, fn s ->
        {m, _} = s

        if(m == max) do
          s
        else
        end
      end)

    notifyNeighbor(Enum.filter(surrogateList, &(!is_nil(&1))), pid)
    state = {hashId, neighborMap}
    {:reply, hashId, state}
  end

  def handle_cast({:updateCounter, hops}, state) do
    [{_, count}] = :ets.lookup(:table, "hops")

    if hops > count do
      :ets.update_counter(:table, "hops", hops - count)
    end

    {:noreply, state}
  end

  def handle_cast({:notify, newNode, max}, state) do
    {hashID, _} = state

    newNodeHash =
      if(newNode != self()) do
        GenServer.call(newNode, {:getHashId})
      else
        hashID
      end

    {hashId, neighborMap} = state

    index = String.to_integer(String.at(newNodeHash, max))
    # index = String.to_integer(String.at("50152125",max))

    levelList = Enum.at(neighborMap, max)
    levelListReplaced = List.replace_at(levelList, index, newNode)
    modifiedNeighborMap = List.replace_at(neighborMap, max, levelListReplaced)
    state = {hashId, modifiedNeighborMap}
    {:noreply, state}
  end

  def deliverMsg(source, dest, counter) do
    msg = Time.utc_now()
    Process.send_after(source, {:deliver, dest, msg, 0, counter}, 1)
  end

  def handle_info({:deliver, dest, msg, level, counter}, state) do
    {_, neighborMap} = state

    {pi, nextlevel} =
      TapestrySimulator.Util.nextHop(self(), dest, level, neighborMap)

    if pi == self() do
      hops = Time.utc_now().second - msg.second
      GenServer.cast(counter, {:updateCounter, hops})
      :ets.update_counter(:table, "tr", {2, 1})
    else
      scheduleRouting(pi, dest, msg, nextlevel, counter)
    end

    {:noreply, state}
  end

  defp scheduleRouting(pi, dest, msg, level, counter) do
    Process.send_after(pi, {:deliver, dest, msg, level, counter}, 1000)
  end

  def init(:ok) do
    # {hashId, neighborMap} , {hashId, neighborMap}
    {:ok, {0, []}}
  end
end
