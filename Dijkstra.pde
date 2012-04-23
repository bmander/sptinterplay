class SPTEdge{
  Edge edge;
  SPTEdge parent;
  float trunkyness=0;
  float edgeweight=0; //cache edge.weight(), in case that's expensive
  float weight;
  boolean deferred=false;
  
  SPTEdge(Edge edge, float edgeweight, float weight){
    this.edge=edge;
    this.edgeweight=edgeweight;
    this.weight=weight;
  }
  
  SPTEdge(Edge edge, float edgeweight, float weight, SPTEdge parent){
    this.edge=edge;
    this.parent=parent;
    this.edgeweight=edgeweight;
    this.weight=weight;
  }
  
  String toString(){
    return "SPTEdge["+this.edge.toString()+"]";
  }
  
  void draw(float transx, float transy, float scalex, float scaley){
    this.deferred=false;
    if(this.edge!=null && this.edge.way!=null){
      //stroke(#AA0000);
      this.edge.way.draw(transx,transy,scalex,scaley,pow(this.trunkyness*TRUNK_LINE_WIDTH,0.5));
    }
  }
  
  void addTrunkyness(float delta){
    this.trunkyness+=delta;
    this.deferred=true;
  }
}

class DjQueueNode implements Comparable{
  SPTEdge sptedge;
  float weight;
  
  DjQueueNode(SPTEdge sptedge, float weight){
    this.sptedge=sptedge;
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
    return "DjQueueNode["+this.sptedge.toString()+"]";
  }
}

class Dijkstra{
  Graph graph;
  String startnode;
  PriorityQueue queue;
  boolean running;
  HashMap tree;
  float boundary;
  
  Dijkstra(Graph graph, String startnode){
    this.graph = graph;
    this.startnode = startnode;
    this.queue = new PriorityQueue();
    this.running = false;
    this.tree = new HashMap();
    this.boundary=0;
    
    this.queue.add( 
      new DjQueueNode( 
        new SPTEdge(
          new Edge(null,startnode,null),
          0,
          0), 
        0 
      ) 
    );
  }
  
  float get_weight(String id){
    SPTEdge sptedge = (SPTEdge)this.tree.get(id);
    if(sptedge==null){
      return INFINITY;
    }
    return sptedge.weight;
  }
  
  SPTEdge sptedge_to(String tov){
    return (SPTEdge)this.tree.get(tov);
  }
  
  void draw_to(String tov){
    SPTEdge curr = this.sptedge_to(tov);
    while(curr != null && curr.edge.way != null){
      stroke(0,0,255);
      curr.edge.way.draw(transx,transy,scalex,scaley,5);
      curr=curr.parent;
    }
  }
  
  void step(boolean defer_drawing, Object[] competitors){
    if( this.queue.size()==0 ){
      return;
    }
    
    DjQueueNode best_edge_pq_node = (DjQueueNode)this.queue.remove();

    
    this.boundary=best_edge_pq_node.weight;
    
    //println( "best edge from "+best_edge_pq_node.edge.orig+" to "+best_edge_pq_node.edge.dest+"("+best_edge_pq_node.weight+")" );
    if( tree.containsKey( best_edge_pq_node.sptedge.edge.tov ) ){
      //println( "already found a better route" );
      //println( "---" );
      return;
    }
    
    String tov = best_edge_pq_node.sptedge.edge.tov;
    
    tree.put( tov,
              best_edge_pq_node.sptedge
            );
    
    int tovppl;
    if( !popularity.containsKey(tov) ){
      tovppl=1;
      popularity.put( tov, tovppl );
    } else {
      tovppl=((Integer)popularity.get( tov )) + 1;
      popularity.put( tov, tovppl );
    }
              
    //draw the edge
    if( best_edge_pq_node.sptedge.edge != null ){
      stroke(#000000);
      best_edge_pq_node.sptedge.draw(transx,transy,scalex,scaley);
    }
    //trace up the tree adding the edge weight
    SPTEdge curr = best_edge_pq_node.sptedge.parent;
    while(curr!=null){
      curr.addTrunkyness( best_edge_pq_node.sptedge.edgeweight );
      if(!defer_drawing){curr.draw(transx,transy,scalex,scaley);}
      curr=curr.parent;
    }
    
    //find out if any competitor has a lower weight
    boolean winner=true;
    if(competitors!=null){
      for(int i=0; i<competitors.length; i++){
        Person competitor = (Person)competitors[i];
        if(competitor.dijkstra.equals(this)){ //this is the same as the competitor
          continue;
        }
        if(best_edge_pq_node.weight > competitor.dijkstra.get_weight(best_edge_pq_node.sptedge.edge.tov)){
          winner=false;
        }
      }
    }
    
    if(!winner){
      if(meetpoint_id==null && tovppl==people.size()){
        Edge edge = best_edge_pq_node.sptedge.edge;
        meetpoint_id=edge.tov;
        meetpoint = edge.endpoint();
      }
      return;
    }
    
    //for each outgoing edge
    ArrayList outgoing = graph.getadj( best_edge_pq_node.sptedge.edge.tov );
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
                        new SPTEdge( candidate_edge, 
                          cand_edge_weight, 
                          best_edge_pq_node.weight+cand_edge_weight,
                          best_edge_pq_node.sptedge ), 
                        best_edge_pq_node.weight+cand_edge_weight
                      ) 
                    );
    }
    //println("---");
    
    
  }
  
  void step_to(float boundary, boolean defer_drawing, Object[] competitors){
    while(boundary > this.boundary && this.queue.size()>0){
      this.step(defer_drawing, competitors);
    }
  }
  
  void draw(){
    for(Object item : this.tree.values()){
      SPTEdge edge = (SPTEdge)item;
      if(edge.edge!=null){
        edge.draw(transx,transy,scalex,scaley);
      }
    }
  }
  
  void draw_deferred(){
    for(Object item : this.tree.values()){
      SPTEdge edge = (SPTEdge)item;
      if(edge.edge!=null && edge.deferred){
        edge.draw(transx,transy,scalex,scaley);
      }
    }
  }
  
}
