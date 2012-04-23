

class Edge{
  String fromv;
  String tov;
  Way way;
  
  Edge(String fromv, String tov, Way way){
    this.fromv=fromv;
    this.tov=tov;
    this.way=way;
  }
  
  float weight(){
    float ret = 0;
    
    Point pt0 = (Point)this.way.loc.get(0);
    for(int i=1; i<this.way.loc.size(); i++){
      Point pt1 = (Point)this.way.loc.get(i);
      ret += dist(pt0.x,pt0.y,pt1.x,pt1.y);
      pt0=pt1;
    }
    
    return ret*10000;
  }
  
  String toString(){
    if(this.way!=null)
      return "["+this.fromv+" -("+this.weight()+")-> "+this.tov+"]";
    else
      return "["+this.fromv+" -(null)-> "+this.tov+"]";
  }
  
  Point startpoint(){
    if(fromv.equals(way.fromv)){
      return (Point)this.way.loc.get(0);
    } else {
      return (Point)this.way.loc.get(this.way.loc.size()-1);
    }
  }
  
  Point endpoint(){
    if(fromv.equals(way.fromv)){
      return (Point)this.way.loc.get(this.way.loc.size()-1);
    } else {
      return (Point)this.way.loc.get(0);
    }
  }
}

class Graph{
  HashMap adj; //nodeid -> list of (outgoing ways)
  
  Graph(){
    this.adj = new HashMap();
  }
  
  void add(String fromv, String tov, Way way){
    ArrayList edges = (ArrayList)this.adj.get(fromv);
    if(edges==null){
      edges=new ArrayList();
      this.adj.put(fromv,edges);
    }
    
    edges.add( new Edge(fromv, tov, way) );
  }
  
  void add(Way way){
    this.add( way.fromv, way.tov, way );

    String oneway = way.metadata("oneway");
    if(oneway==null || !(oneway.equals("true") || oneway.equals("yes"))){
      this.add( way.tov, way.fromv, way );
    }
  }
  
  void add(Tile tile){
    for(int i=0; i<tile.ways.size(); i++){
      this.add( (Way)tile.ways.get(i) );
    }
  }
  
  ArrayList getadj(String fromv){
    return (ArrayList)this.adj.get(fromv);
  }
}
