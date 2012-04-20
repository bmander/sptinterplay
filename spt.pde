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

Person person1;
Person person2;

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
  
  person1 = new Person( 100,100 );
  person1.id="1330264333";
  person2 = new Person( 200,100 );
  person2.id="1330264333";
  
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
    person1.dijkstra.step(false);
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
  
  boolean newtree=false;
  
  newtree = newtree || person1.update_tree(0.75);
  newtree = newtree || person2.update_tree(0.75);
  
  //if(newtree){
    image(backdrop,0,0);
    stroke(#AA0000);
    person1.dijkstra.draw(person2.dijkstra);
    stroke(#00AA00);
    person2.dijkstra.draw(person1.dijkstra);
  //} else {
  //  stroke(#AA0000);
  //  person1.dijkstra.draw_deferred();
  //  stroke(#00AA00);
  //  person2.dijkstra.draw_deferred();
  //}
  
  person1.draw(transx,transy,scalex,scaley);
  person2.draw(transx,transy,scalex,scaley);
}
