float INFINITY=100000000.0;

class Point{
  double x;
  double y;
  
  Point(double x,double y){
    this.x=x;
    this.y=y;
  }
  
  String toString(){
    return "["+this.x+","+this.y+"]";
  }
  
  boolean equals(Point pt){
    if(pt==null){return false;}
    return x==pt.x&&y==pt.y;
  }
  
  float screenx(){
    return new Double((this.x-transx)*scalex).floatValue();
  }
  
  float screeny(){
    return new Double((this.y-transy)*scaley).floatValue();
  }
}

float dist(double x1,double y1,double x2,double y2){
  return sqrt(sq(new Double(x2-x1).floatValue())+sq(new Double(y2-y1).floatValue()));
}
