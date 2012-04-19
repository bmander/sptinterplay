class SPTEdge{
  String orig;
  String dest;
  Way way;
  float edgeweight;
  float weight;
  float trunkyness;
  
  SPTEdge(String orig, String dest, Way way, float edgeweight){
    this.orig=orig;
    this.dest=dest;
    this.way=way;
    this.edgeweight=edgeweight;
  }
  
  SPTEdge(String orig, float weight, float edgeweight, float trunkyness, Way way){
    this.orig=orig;
    this.weight=weight;
    this.edgeweight=edgeweight;
    this.trunkyness=trunkyness;
    this.way=way;
  }
  
  String toString(){
    return orig+"->"+dest;
  }
}

class DjQueueNode implements Comparable{
  SPTEdge edge;
  String startnode;
  float weight;
  
  DjQueueNode(SPTEdge edge, String startnode, float weight){
    this.edge=edge;
    this.startnode=startnode;
    this.weight=weight;
  }
  
  
  
  int compareTo(Object o){
    if( this.weight < ((DjQueueNode)o).weight ){
      return -1;
    } else if( this.weight == ((DjQueueNode)o).weight ){
      return 0;
    } else{
      return 1;
    }
  }
  
  
  String toString(){
    return this.edge.toString();
  }
}

class Dijkstra{
  Graph graph;
  String startnode;
  PriorityQueue queue;
  boolean running;
  HashMap tree;
  
  Dijkstra(Graph graph, String startnode){
    this.graph = graph;
    this.startnode = startnode;
    this.queue = new PriorityQueue();
    this.running = false;
    this.tree = new HashMap();
    
    this.queue.add( new DjQueueNode( new SPTEdge(null,startnode,null,0), startnode, 0 ) );
  }
  
  void step(){
    if( this.queue.size()==0 ){
      return;
    }
    
    DjQueueNode best_edge = (DjQueueNode)this.queue.remove();
    String best_edge_orig = best_edge.edge.orig;
    String best_edge_dest = best_edge.edge.dest;
    float best_edge_weight = best_edge.weight;
    
    println( "best edge from "+best_edge_orig+" to "+best_edge_dest+"("+best_edge_weight+")" );
    if( tree.containsKey( best_edge_dest ) ){
      println( "already found a better route" );
      println( "---" );
      return;
    }
    
    tree.put( best_edge.edge.dest, 
              new SPTEdge( best_edge_orig, best_edge_weight, best_edge.edge.edgeweight, 0, best_edge.edge.way ) );
              
    //draw the edge
    if( best_edge.edge.way != null ){
      stroke(#000000);
      best_edge.edge.way.draw(transx,transy,scalex,scaley,2);
    }
    //trace up the tree adding the edge weight
    
    
    //for each outgoing edge
    ArrayList outgoing = graph.getadj( best_edge_dest );
    for( int i=0; i<outgoing.size(); i++ ){
      Edge candidate_edge = (Edge)outgoing.get(i);
      String cand_dest_node = candidate_edge.tov;
      Way cand_edge_data = candidate_edge.way;
      float cand_edge_weight = candidate_edge.weight();
      println( "possible frontier edge to "+candidate_edge.tov+"("+cand_edge_weight+")" );
      if( cand_edge_weight < 0 ){
        continue;
      }
      if( tree.containsKey( cand_dest_node ) ){
        println( "path already found" );
        continue;
      }
      //stroke(#ff0000);
      //cand_edge_data.draw(transx,transy,scalex,scaley,2);
      println( "added to queue with weight "+(best_edge_weight+cand_edge_weight) );
      this.queue.add( new DjQueueNode( 
                        new SPTEdge(
                          best_edge_dest,
                          cand_dest_node,
                          cand_edge_data,
                          cand_edge_weight), 
                        cand_dest_node, 
                        best_edge_weight+cand_edge_weight
                      ) 
                    );
    }
    println("---");
    
    
  }
  
}
