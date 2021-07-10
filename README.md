# LWW Grapgh (LWW-Set)
This is a Last-Writer-Wins Element Set(lww-set) and also Element Graph(lww-graph) data structure implemented in Swift language. Conceptually, lww-set is an Operation-based Conflict-Free Replicated Date Type(CRDT). It can achieve strong eventual consistency and monotonicy. 
<br>We used to use applications such us calendar or Evernote for a long time. 
<br>They have something in common — at the same time all of them allow (in any combination)
- to work offline
- to access from different devices
- several people to modify the same data
<br>The task the developers of those systems have to solve is how to ensure “smooth” data synchronization in such cases.

## Operations
- add a vertex/edge
- remove a vertex/edge
- check if a vertex is in the graph
- query for all vertices connected to a vertex
- find any path between two vertices
- merge with concurrent changes from other graph/replica.
