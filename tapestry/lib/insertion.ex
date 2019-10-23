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
   GenServer.call(pid, {:setNeighbourMap,nodeID})
  end

  def insertNode(pid,allNodes) do
    
    GenServer.call(pid, {:fillNeighbourMap,pid,allNodes})
    test = Enum.map((1..2), fn(x) ->
           Enum.map((1..2), fn(y) ->
           test = %{
          x => %{y => ""}
          }
          end)
        end)
        IO.inspect test
        #IO.inspect List.replace_at(test, 2, List.replace_at(test, 2, "hello"))
         IO.inspect List.replace_at(test, 1,%{1 => %{2 => "k"}})
         # test = %{1 => %{2 => "k"}}
         IO.inspect test
     #n1 = String.graphemes("356AY78979")
     #n2 = String.graphemes("356AY90B79")
     #len = matchSuffix(n1,n2,0)
    #IO.inspect (len)
    
  end

  def handle_call({:setHashId,nodeID}, _from ,state) do
   #IO.inspect state
     
    {_, neighborMap} = state
    hashId = :crypto.hash(:sha, Integer.to_string(nodeID))|> Base.encode16
    IO.inspect hashId
    state={hashId, neighborMap}
    {:reply,hashId, state}
    
  end
  def matchSuffix(node1, node2, n) when n > 39 do
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
    
   

         neighborMap = Enum.map((1..40), fn(x) ->
           Enum.map((1..16), fn(y) ->
           neighborMap = %{
          x => %{y => ""}
          }
          end)
        end)

        


       # IO.inspect neighborMap
    #neighborMap =
    state={hashId, neighborMap}
    {:reply,hashId, state}
  end

  def handle_call({:fillNeighbourMap,nodeID,allNodes}, _from ,state) do
    {hashId, neighborMap} = state
    
       Enum.map((1..40), fn(x) ->
          neighborMap = fillLevel(x,neighborMap,self(),hashId,allNodes)
        end)


        #IO.inspect Enum.at(Enum.at(neighborMap, 1),1)
 
    state={hashId, neighborMap}
    {:reply,hashId, state}
  end


  def fillLevel(l,neighborMap,pid,hashID,allNodes) do
    # 0 1 2 3 4 5 6 7 8 9 A B C D E F
    diff = l - 1
    
    #IO.inspect currentList
    n1 = String.graphemes(hashID)
    #IO.inspect hashID
    Enum.map((1..16), fn(k) ->
     Enum.map((allNodes), fn(ni) -> 
     nid = if(ni != pid) do
      nid = GenServer.call(ni, {:getHashId})
      nid
      else
        nid = hashID
        nid
      end
      n2 = String.graphemes(nid)
      #IO.inspect nid
      x = matchSuffix(n1,n2,0)
      
      #IO.inspect "len matched"
      
      #IO.inspect x
     #IO.inspect "difference"
      
      #IO.inspect diff
      if(x == diff) do
       # IO.inspect "len matched"
        #IO.inspect diff
        #Enum.at(Enum.at(neighborMap, l),1) = ""
        #neighborMap = %{l => %{1 => "hello"}}
        #IO.inspect List.replace_at(neighborMap, 5, List.replace_at(neighborMap, 5, "hello"))
        #IO.inspect  List.replace_at(neighborMap, 5, "hello")
         #IO.inspect Enum.at(Enum.at(neighborMap, l),1)
       #IO.inspect neighborMap
        #Enum.reduce(neighborMap, str, fn {old, new}, str -> String.replace(str, old, new) end)
      end 
      #IO.inspect ni
      end)
    end)
  
      
    
   
    neighborMap
  end

  def init(:ok) do
    {:ok, {0,[]}} #{hashId, neighborMap} , {hashId, neighborMap}
  end
end
