# Tapestry

##Description
1. Problem Definition
We talked extensively in class about the overlay networks and how they can be used to provide services. The goal of this project is to implement in Elixir using the actor model the Tapestry Algorithm and a simple object access service to prove its usefulness. The specification of the Tapestry protocol can be found in the paper-
Tapestry: A Resilient Global-Scale Overlay for Service Deployment by Ben Y. Zhao, Ling Huang, Jeremy Stribling, Sean C. Rhea, Anthony D. Joseph and John D. Kubiatowicz. Link to paper- https://pdos.csail.mit.edu/~strib/docs/tapestry/tapestry_jsac03.pdf. You can also refer to Wikipedia page: https://en.wikipedia.org/wiki/Tapestry_(DHT) . Here is other useful link: https://heim.ifi.uio.no/michawe/teaching/p2p-ws08/p2p-5-6.pdf . Here is a survey paper on comparison of peer-to-peer overlay network schemes- https://zoo.cs.yale.edu/classes/cs426/2017/bib/lua05survey.pdf.
You have to implement the network join and routing as described in the Tapestry paper (Section 3: TAPESTRY ALGORITHMS). You can change the message type sent and the specific activity as long as you implement it using a similar API to the one described in the paper.
2. Requirements
Input: The input provided (as command line to your program will be of the form:
mix run project3.exs numNodes numRequests
Where numNodes is the number of peers to be created in the peer to peer system and numRequests the number of requests each peer has to make. When all peers performed
that many requests, the program can exit. Each peer should send a request/second.
Output: Print the maximum number of hops (node connections) that must be traversed for all requests for all nodes.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `tapestry` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tapestry, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/tapestry](https://hexdocs.pm/tapestry).

