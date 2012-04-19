import netscape.javascript.*;
import org.json.*;

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
}

int scalex;
int scaley;
float transx;
float transy;
ArrayList tiles = new ArrayList();
Graph graph;

void drawtiles(float transx, float transy, int scalex, int scaley){
  for(int i=0; i<tiles.size(); i++){
    ((Tile)tiles.get(i)).draw(transx,transy,scalex,scaley);
  }
}

void setup(){
  size(1536,1024);
  
  smooth();
  strokeWeight(0.1);
  
  graph = new Graph();
  
  scalex=35000;
  scaley=40000;
  transx=-71.065;
  transy=42.336;
  
  String[] filenames = {//"-71.04-42.36.json",
    //"-71.04-42.34.json",
    //"-71.06-42.36.json",
    "-71.06-42.34.json",
    //"-71.08-42.36.json",
    //"-71.08-42.34.json"
  };
  for(int i=0; i<filenames.length; i++){
    print(i+"...");
    Tile tile = new Tile(filenames[i]);
    graph.add( tile );
    tiles.add( tile );
    println( "done" );
  }
  
  background(255);
  drawtiles(transx,transy,scalex,scaley);
  
  println( graph.adj );
  
}

void draw(){
  if(mousePressed){
    transx -= float(mouseX-pmouseX)/scalex;
    transy += float(mouseY-pmouseY)/scaley;
    
    background(255);
    drawtiles(transx,transy,scalex,scaley);
  }
}
