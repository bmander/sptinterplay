class Person{
  int x;
  int y;
  float t;
  float speed;
  float lastmoved;
  int r=50;
  
  String id;
  
  Person(int x, int y){
    this.x=x;
    this.y=y;
    this.t=millis()/1000.0;
    this.speed=0;
    this.lastmoved=t;
    
    this.id=null;
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
  
}
