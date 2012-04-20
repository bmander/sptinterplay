class Person{
  int x;
  int y;
  int r=50;
  boolean selected=false;
  boolean moved=false;
  
  Person(int x, int y){
    this.x=x;
    this.y=y;
  }
  
  void move(int x, int y){
    this.x+=x;
    this.y+=y;
    this.moved=true;
  }
  
  void update(int x, int y){
    this.x=x;
    this.y=y;
    this.moved=true;
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
