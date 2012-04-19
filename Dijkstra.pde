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
          null,
          startnode,
          null,
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
    
    DjQueueNode best_edge = (DjQueueNode)this.queue.remove();
    
    //println( "best edge from "+best_edge.edge.orig+" to "+best_edge.edge.dest+"("+best_edge.weight+")" );
    if( tree.containsKey( best_edge.edge.dest ) ){
      //println( "already found a better route" );
      //println( "---" );
      return;
    }
    
    tree.put( best_edge.edge.dest, 
              new SPTEdge( 
                best_edge.edge.orig, 
                best_edge.weight, 
                best_edge.edge.edgeweight, 
                0, 
                best_edge.edge.way 
              ) 
            );
              
    //draw the edge
    if( best_edge.edge.way != null ){
      stroke(#000000);
      best_edge.edge.way.draw(transx,transy,scalex,scaley,2);
    }
    //trace up the tree adding the edge weight
    
    
    //for each outgoing edge
    ArrayList outgoing = graph.getadj( best_edge.edge.dest );
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
      //println( "added to queue with weight "+(best_edge.weight+cand_edge_weight) );
      this.queue.add( new DjQueueNode( 
                        new SPTEdge(
                          best_edge.edge.dest,
                          candidate_edge.tov,
                          candidate_edge.way,
                          cand_edge_weight), 
                        candidate_edge.tov, 
                        best_edge.weight+cand_edge_weight
                      ) 
                    );
    }
    //println("---");
    
    
  }
  
  void draw(){
    for(Object item : this.tree.values()){
      SPTEdge edge = (SPTEdge)item;
      if(edge.way!=null){
        edge.way.draw(transx,transy,scalex,scaley,2);
      }
    }
  }
  
}
