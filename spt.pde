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
Person person1;
Person person2;
//String id;

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
  String[] filenames = {//"-71.04-42.36.json",
    //"-71.04-42.34.json",
    //"-71.06-42.36.json",
    "-71.06-42.34.json", //this one
    //"-71.08-42.36.json",
    //"-71.08-42.34.json"
  };
  for(int i=0; i<filenames.length; i++){
    print(i+"...");
    map.addTile( filenames[i] );
    println( "done" );
  }
  
  person1 = new Person( 100,100 );
  person1.id="1330264333";
  person2 = new Person( 200,100 );
  
  graph = map.toGraph();
  dijkstra = new Dijkstra( graph, person1.id );
  
  background(255);
  map.draw(transx,transy,scalex,scaley);
  //loadPixels();
  save("background.tif");
  backdrop = loadImage("background.tif");
  person1.draw(transx,transy,scalex,scaley);
  person2.draw(transx,transy,scalex,scaley);
  
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
    
    person1.update( int(tperson.centroid.x*width), int(tperson.centroid.y*height) );
    person1.draw(transx,transy,scalex,scaley);
               	
  };*/
  
  if( mousePressed ){
    int deltax=(mouseX-pmouseX);
    int deltay=(mouseY-pmouseY);
    
    if( person1.within( pmouseX, pmouseY )){
      person1.move(deltax,deltay);
    }
    if( person2.within( pmouseX, pmouseY )){
      person2.move(deltax,deltay);
    }
  }
      
  if( !person1.still(0.75) ){
      
    Point pt = person1.getGeoCoord(transx,transy,scalex,scaley);
    String newid = map.nearest( pt ).id;
    if(!newid.equals(person1.id)){
      person1.id=newid;
      dijkstra = new Dijkstra( graph, person1.id );
      for(int i=0;i<500;i++){dijkstra.step_to(150.0,true);}
          
      image(backdrop,0,0);
      
    }

  }
  
  person1.draw(transx,transy,scalex,scaley);
  person2.draw(transx,transy,scalex,scaley);
  
  if( person1.still(0.75) ){
    for(int i=0; i<40; i++){
      dijkstra.step(true);
    }
  }
  dijkstra.draw_deferred();
}
