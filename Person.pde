class Person{
  int x;
  int y;
  float t;
  float speed;
  float lastmoved;
  int r=50;
  
  String id;
  Dijkstra dijkstra;
  
  Person(int x, int y){
    this.x=x;
    this.y=y;
    this.t=millis()/1000.0;
    this.speed=0;
    this.lastmoved=t;
    
    this.id=null;
    this.dijkstra=null;
  }
  
  boolean still(float timeout){
    return ((millis()/1000.0)-this.lastmoved)>timeout;
  }
  
  void move(int x, int y){
    update(this.x+x,this.y+y);
  }
  
  void update(int x, int y){
    float now = millis()/1000.0;
    this.speed= dist(this.x,this.y,x,y)/(now-this.t);
    if(speed>300){
      this.lastmoved=now;
    }
    
    this.x=x;
    this.y=y;
    this.t=now;
  }
  
  void draw(float transx,float transy,float scalex,float scaley){
    strokeWeight(1);
    stroke(0);
    ellipse(x,y,r*2,r*2);
  }
  
  boolean within(int x,int y){
    return sq(x-this.x)+sq(y-this.y)<sq(r);
  }
  
  Point getGeoCoord(double transx, double transy,double scalex, double scaley){
    return new Point((new Double(height-this.y).doubleValue()/scalex)+transx, new Double(width-this.x).doubleValue()/scaley+transy);
  }
  
  boolean update_tree(float timeout){
    boolean newtree=false;
    
    if( !this.still(timeout) ){
      
      Point pt = this.getGeoCoord(transx,transy,scalex,scaley);
      String newid = map.nearest( pt ).id;
      if(!newid.equals(this.id)){
        this.id=newid;
        this.dijkstra = new Dijkstra( graph, this.id );
        this.dijkstra.step_to(150.0,true);
      
        newtree=true;
      }
    
    } else {
      for(int i=0; i<40; i++){
        this.dijkstra.step(true);
      }
    }
    
    return newtree;
  }
  
}
