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

ArrayList people;
Person person1;
Person person2;

float boundary=0;

PImage backdrop;

String meetpoint_id=null;
Point meetpoint=null;

void setup(){
  size(1024,1536);
  
  smooth();
  strokeWeight(0.1);
  ellipseMode(CENTER);
  
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
  
  people = new ArrayList();
  person1 = new Person( 100,100 );
  person1.setVertex();
  person2 = new Person( 500,500 );
  person2.setVertex();
  
  graph = map.toGraph();
  person1.dijkstra = new Dijkstra( graph, person1.id );
  person2.dijkstra = new Dijkstra( graph, person2.id );
  
  background(255);
  map.draw(transx,transy,scalex,scaley);
  
  save("background.tif");
  backdrop = loadImage("background.tif");
  //person1.draw(transx,transy,scalex,scaley);
  //person2.draw(transx,transy,scalex,scaley);
  
  //tspsReceiver= new TSPS(this, 12000);
  
}

void keyPressed(){
  if( key==' ' ){
    person1.dijkstra.step(false, null);
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
  
  boolean someone_moved=false;
      
  if( !person1.still(0.75) ){
    
    someone_moved = someone_moved || person1.setVertex();

  } 
  
  if( !person2.still(0.75) ){
    
    someone_moved = someone_moved || person2.setVertex();

  } 
    
  if(someone_moved){
      meetpoint_id=null;
      person1.dijkstra = new Dijkstra( graph, person1.id );
      person2.dijkstra = new Dijkstra( graph, person2.id );

      boundary=150.0;
      for(float i=0.1; i<=boundary; i+=0.1){
        person1.dijkstra.step_to(i,true, person2.dijkstra);
        person2.dijkstra.step_to(i,true, person1.dijkstra);
      }
      
      image(backdrop,0,0);
  } else if(person1.still(0.75) && person2.still(0.75)) {
    for(int i=0; i<40; i++){
      boundary += 0.1;
      //println( person1.dijkstra.boundary + "vs" + person2.dijkstra.boundary );
      person1.dijkstra.step_to(boundary,true, person2.dijkstra);
      person2.dijkstra.step_to(boundary,true, person1.dijkstra);
    }
  }
  
  stroke(200,0,0);
  person1.dijkstra.draw_deferred();
  stroke(0,200,0);
  person2.dijkstra.draw_deferred();
  
  if(meetpoint_id != null){
    person1.dijkstra.draw_to( meetpoint_id );
    person2.dijkstra.draw_to( meetpoint_id );
    
    stroke(0,0,255);
    fill(0,0,255);
    ellipse( width-meetpoint.screeny(), height-meetpoint.screenx(), 20, 20 );
  }
  
  fill(255,200,200,128);
  person1.draw(transx,transy,scalex,scaley);
  person2.draw(transx,transy,scalex,scaley);
}
