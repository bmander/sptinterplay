

class Dijkstra{
  Graph graph;
  String startnode;
  PriorityQueue queue;
  boolean running;
  
  Dijkstra(Graph graph, String startnode){
    this.graph = graph;
    this.startnode = startnode;
    this.queue = new PriorityQueue();
    this.running = false;
  }
  
  void step(){
    println( "step" );
  }
  
}
