import netscape.javascript.*;
import org.json.*;

// 1024 px/15 ft = 68 px/ft

int scalex;
int scaley;
float transx;
float transy;

Map map;
Graph graph;
Dijkstra dijkstra;
Person person;
String id;
Point pperson;

PImage backdrop;

void setup(){
  size(1536,1024);
  
  smooth();
  strokeWeight(0.1);
  ellipseMode(CENTER);
  fill(255,200,200,128);
  
  scalex=17000;
  scaley=20000;
  transx=-71.085;
  transy=42.336;
  
  map = new Map();
  String[] filenames = {"-71.04-42.36.json",
    "-71.04-42.34.json",
    "-71.06-42.36.json",
    "-71.06-42.34.json", //this one
    "-71.08-42.36.json",
    "-71.08-42.34.json"
  };
  for(int i=0; i<filenames.length; i++){
    print(i+"...");
    map.addTile( filenames[i] );
    println( "done" );
  }
  
  id="1330264333";
  
  person = new Person( 100,100 );
  
  graph = map.toGraph();
  dijkstra = new Dijkstra( graph, id );
  
  background(255);
  map.draw(transx,transy,scalex,scaley);
  //loadPixels();
  save("background.tif");
  backdrop = loadImage("background.tif");
  person.draw(transx,transy,scalex,scaley);
  
}

void keyPressed(){
  if( key==' ' ){
    dijkstra.step(false);
  }
}


void draw(){
  if(mousePressed){
    if( person.within( pmouseX, pmouseY ) ){
      int deltax=(mouseX-pmouseX);
      int deltay=(mouseY-pmouseY);
      
      person.x += deltax;
      person.y += deltay;
      
      if(abs(deltax)>0 || abs(deltay)>0){
        Point pt = person.getGeoCoord(transx,transy,scalex,scaley);
        String newid = map.nearest( pt ).id;
        if(!newid.equals(id)){
          id=newid;
          dijkstra = new Dijkstra( graph, id );
          for(int i=0;i<300;i++){dijkstra.step(true);}
          
          image(backdrop,0,0);
          dijkstra.draw_deferred();
        }
        
        //background(255);
        //map.draw(transx,transy,scalex,scaley);

      }
      //updatePixels();
person.draw(transx,transy,scalex,scaley);
    }
    

  }
  
  for(int i=0; i<40; i++){
    dijkstra.step(true);
  }
  dijkstra.draw_deferred();
}
