class Person{
  int x;
  int y;
  int r=50;
  boolean selected=false;
  
  Person(int x, int y){
    this.x=x;
    this.y=y;
  }
  
  void draw(float transx,float transy,float scalex,float scaley){
    ellipse(x,y,r*2,r*2);
  }
  
  boolean within(int x,int y){
    return sq(x-this.x)+sq(y-this.y)<sq(r);
  }
  
  Point getGeoCoord(double transx, double transy,double scalex, double scaley){
    return new Point((new Double(this.x).doubleValue()/scalex)+transx, new Double(height-this.y).doubleValue()/scaley+transy);
  }
  
}
