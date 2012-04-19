class SPTEdge{
  Edge edge;
  float edgeweight=0;
  float weight;
  float trunkyness=0;
  
  SPTEdge(Edge edge, float edgeweight){
    this.edge=edge;
    //this.edgeweight=edgeweight;
  }
  
  SPTEdge(Edge edge, float weight, float trunkyness){
    this.edge=edge;
    this.weight=weight;
    this.trunkyness=trunkyness;
  }
  
  String toString(){
    return "SPTEdge["+this.edge.toString()+"]";
  }
  
  void draw(float transx, float transy, float scalex, float scaley){
    if(this.edge!=null && this.edge.way!=null){
      this.edge.way.draw(transx,transy,scalex,scaley,2);
    }
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
    return "DjQueueNode["+this.edge.toString()+"]";
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
    
    this.queue.add( 
      new DjQueueNode( 
        new SPTEdge(
          new Edge(null,startnode,null),
          0), 
        startnode, 
        0 
      ) 
    );
  }
  
  void step(){
    if( this.queue.size()==0 ){
      return;
    }
    
    DjQueueNode best_edge_pq_node = (DjQueueNode)this.queue.remove();
    
    //println( "best edge from "+best_edge_pq_node.edge.orig+" to "+best_edge_pq_node.edge.dest+"("+best_edge_pq_node.weight+")" );
    if( tree.containsKey( best_edge_pq_node.edge.edge.tov ) ){
      //println( "already found a better route" );
      //println( "---" );
      return;
    }
    
    tree.put( best_edge_pq_node.edge.edge.tov, 
              new SPTEdge( 
                best_edge_pq_node.edge.edge,
                best_edge_pq_node.weight, 
                0
              ) 
            );
              
    //draw the edge
    if( best_edge_pq_node.edge.edge != null ){
      stroke(#000000);
      best_edge_pq_node.edge.draw(transx,transy,scalex,scaley);
    }
    //trace up the tree adding the edge weight
    
    
    //for each outgoing edge
    ArrayList outgoing = graph.getadj( best_edge_pq_node.edge.edge.tov );
    if(outgoing==null){
      return;
    }
    for( int i=0; i<outgoing.size(); i++ ){
      Edge candidate_edge = (Edge)outgoing.get(i);
      
      float cand_edge_weight = candidate_edge.weight();
      //println( "possible frontier edge to "+candidate_edge.tov+"("+cand_edge_weight+")" );
      if( cand_edge_weight < 0 ){
        continue;
      }
      if( tree.containsKey( candidate_edge.tov ) ){
        //println( "path already found" );
        continue;
      }
      
      //stroke(#ff0000);
      //candidate_edge.data.draw(transx,transy,scalex,scaley,2);
      //println( "added to queue with weight "+(best_edge_pq_node.weight+cand_edge_weight) );
      this.queue.add( new DjQueueNode( 
                        new SPTEdge(
                          candidate_edge,
                          cand_edge_weight), 
                        candidate_edge.tov, 
                        best_edge_pq_node.weight+cand_edge_weight
                      ) 
                    );
    }
    //println("---");
    
    
  }
  
  void draw(){
    for(Object item : this.tree.values()){
      SPTEdge edge = (SPTEdge)item;
      if(edge.edge!=null){
        edge.draw(transx,transy,scalex,scaley);
      }
    }
  }
  
}
