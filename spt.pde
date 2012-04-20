import netscape.javascript.*;
import org.json.*;

//import tsps.*;
//TSPS tspsReceiver;

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
  size(1024,1536);
  
  smooth();
  strokeWeight(0.1);
  ellipseMode(CENTER);
  fill(255,200,200,128);
  
  scalex=17000;
  scaley=20000;
  transx=-71.095;
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
  
  //tspsReceiver= new TSPS(this, 12000);
  
}

void keyPressed(){
  if( key==' ' ){
    dijkstra.step(false);
  }
}

  
void draw(){
  /*
  tspsReceiver.update();
  for (Enumeration e = tspsReceiver.people.keys() ; e.hasMoreElements() ;) {
    
    int pid = (Integer) e.nextElement();
    TSPSPerson tperson = (TSPSPerson) tspsReceiver.people.get(pid);
    
    person.update( int(tperson.centroid.x*width), int(tperson.centroid.y*height) );
    person.draw(transx,transy,scalex,scaley);
               	
  };*/
  
  if( mousePressed && person.within( pmouseX, pmouseY ) ){
    int deltax=(mouseX-pmouseX);
    int deltay=(mouseY-pmouseY);
    person.move(deltax,deltay);
  }
  
  println( person.still(0.75) );
    
  if( !person.still(0.75) ){
      
    Point pt = person.getGeoCoord(transx,transy,scalex,scaley);
    String newid = map.nearest( pt ).id;
    if(!newid.equals(id)){
      id=newid;
      dijkstra = new Dijkstra( graph, id );
      for(int i=0;i<500;i++){dijkstra.step_to(150.0,true);}
          
      image(backdrop,0,0);
      
    }

  }
  
  person.draw(transx,transy,scalex,scaley);
  
  if( person.still(0.75) ){
    for(int i=0; i<40; i++){
      dijkstra.step(true);
    }
  }
  dijkstra.draw_deferred();
}
