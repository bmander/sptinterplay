import org.json.*;

import tsps.*;
TSPS tspsReceiver;

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
Person person3;

HashMap popularity; //vertex_id-># of trees that have reached it

float boundary=0;

PImage backdrop;

String meetpoint_id=null;
Point meetpoint=null;
color[] colors=new color[6];

void setup(){
  size(1024,1536);
  
  smooth();
  strokeWeight(0.1);
  ellipseMode(CENTER);
  
  scalex=11000;
  scaley=15000;
  transx=-71.15;
  transy=42.33;
  
  colors[0]=color(200,0,0);
  colors[1]=color(0,200,0);
  colors[2]=color(0,0,200);
  colors[3]=color(200,200,0);
  colors[4]=color(0,200,200);
  colors[5]=color(200,0,200);
  
  popularity = new HashMap();
  
  map = new Map();
  String[] filenames = {"-71.04-42.36.json",
    "-71.04-42.34.json",
    "-71.04-42.32.json",
    "-71.06-42.36.json",
    "-71.06-42.32.json",
    "-71.06-42.34.json", //this one
    "-71.08-42.36.json",
    "-71.08-42.34.json",
    "-71.08-42.32.json",
    "-71.04-42.38.json",
    "-71.06-42.38.json",
    "-71.08-42.38.json",
    "-71.10-42.32.json",
    "-71.10-42.34.json",
    "-71.10-42.36.json",
    "-71.10-42.38.json",
    "-71.12-42.32.json",
    "-71.12-42.34.json",
    "-71.12-42.36.json",
    "-71.12-42.38.json",
    "-71.14-42.32.json",
    "-71.14-42.34.json",
    "-71.14-42.36.json",
    "-71.14-42.38.json",
    "-71.02-42.32.json",
    "-71.02-42.34.json",
    "-71.02-42.36.json",
    "-71.02-42.38.json",
    "-71.16-42.32.json",
    "-71.16-42.34.json",
    "-71.16-42.36.json",
    "-71.16-42.38.json"
  };
  for(int i=0; i<filenames.length; i++){
    print(i+"...");
    map.addTile( filenames[i] );
    println( "done" );
  }
  
  graph = map.toGraph();
  
  people = new ArrayList();
  person1 = new Person( 100,100 );
  person1.setVertex();
  people.add( person1 );
  person2 = new Person( 500,500 );
  person2.setVertex();
  people.add( person2 );
  person3 = new Person( 100, 600 );
  person3.setVertex();
  people.add( person3 );
  
  person1.dijkstra = new Dijkstra( graph, person1.id );
  person2.dijkstra = new Dijkstra( graph, person2.id );
  person3.dijkstra = new Dijkstra( graph, person3.id );
  
  background(255);
  map.draw(transx,transy,scalex,scaley);
  
  save("background.tif");
  backdrop = loadImage("background.tif");
  //person1.draw(transx,transy,scalex,scaley);
  //person2.draw(transx,transy,scalex,scaley);
  
  tspsReceiver= new TSPS(this, 12000);
  
}

void keyPressed(){
  if( key==' ' ){
    person1.dijkstra.step(false, null);
  }
}

void update_people_with_tsps(){
  Set tsps_pids = new HashSet();
  
  for (Enumeration e = tspsReceiver.people.keys() ; e.hasMoreElements() ;) {
    
    int pid = (Integer) e.nextElement();
    TSPSPerson tperson = (TSPSPerson) tspsReceiver.people.get(pid);
    
    tsps_pids.add( pid );
    
    //look for associated person
    Person person = null;
    for(int i=0; i<people.size(); i++){
      Person cand = (Person)people.get(i);
      if(cand.tsps_id==pid){
        person = cand;
      }
    }
    
    if(person!=null){
      person.update( int(tperson.centroid.x*width), int(tperson.centroid.y*height) );
      person.draw(transx,transy,scalex,scaley);
    } else {
      person = new Person(int(tperson.centroid.x*width), int(tperson.centroid.y*height));
      person.tsps_id=pid;
      people.add( person );
      person.draw(transx,transy,scalex,scaley);
    }
               	
  };
  
  boolean someone_walked_out=false;
  //look for people with no assocaited tsps_pids;
  for(int i=0; i<people.size(); i++){
    Person person = (Person)people.get(i);
    if( !tsps_pids.contains( person.tsps_id ) ){
      people.remove( i );
      someone_walked_out=true;
    }
  }
  if(someone_walked_out){
    //image(backdrop,0,0);
  }
}

  
void draw(){
  
  tspsReceiver.update();
  /*for (Enumeration e = tspsReceiver.people.keys() ; e.hasMoreElements() ;) {
    
    int pid = (Integer) e.nextElement();
    TSPSPerson tperson = (TSPSPerson) tspsReceiver.people.get(pid);
    
    person1.update( int(tperson.centroid.x*width), int(tperson.centroid.y*height) );
    person1.draw(transx,transy,scalex,scaley);
               	
  };*/
  update_people_with_tsps();
  
  //println( people );
  
  Object[] peopleArr = people.toArray();
  
  //println( "people "+people );
  //println( "peopleArr "+peopleArr[0] );
  
  if( mousePressed ){
    int deltax=(mouseX-pmouseX);
    int deltay=(mouseY-pmouseY);
    
    for(int i=0; i<peopleArr.length; i++){
      Person person = (Person)peopleArr[i];
      if( person.within( pmouseX, pmouseY )){
        person.move(deltax,deltay);
      }
    }
  }
  
  boolean someone_moved_to_new_vertex=false;
  boolean everyone_still=true;
  for( int i=0; i<people.size(); i++){
    Person person = (Person)peopleArr[i];
    if( !person.still(0.75) ){
      someone_moved_to_new_vertex = someone_moved_to_new_vertex || person.setVertex();
      everyone_still=false;
    } 
  }
    
  if(someone_moved_to_new_vertex){
      meetpoint_id=null;
      popularity = new HashMap();
      
      for(int i=0; i<peopleArr.length; i++){
        Person person = (Person)peopleArr[i];
        person.dijkstra = new Dijkstra( graph, person.id );
      }

      boundary=150.0;
      for(float i=0.1; i<=boundary; i+=0.1){
        for(int j=0; j<peopleArr.length; j++){
          Person person = (Person)peopleArr[j];
          person.dijkstra.step_to(i,true,peopleArr);
        }
      }
      
      image(backdrop,0,0);
  } else if(everyone_still) {
    for(int i=0; i<40; i++){
      boundary += 0.1;
      for(int j=0; j<peopleArr.length; j++){
        Person person = (Person)peopleArr[j];
        person.dijkstra.step_to(boundary,true, peopleArr);
      }
    }
  }
  
  for(int i=0; i<min(peopleArr.length,colors.length); i++){
    stroke(colors[i]);
    ((Person)peopleArr[i]).dijkstra.draw_deferred();
  }
  
  if(meetpoint_id != null){
    for(int i=0; i<peopleArr.length;i++){
      ((Person)peopleArr[i]).dijkstra.draw_to( meetpoint_id );
    }
    
    stroke(0,0,255);
    fill(0,0,255);
    ellipse( width-meetpoint.screeny(), height-meetpoint.screenx(), 20, 20 );
  }
  
  fill(255,200,200,128);
  for(int i=0; i<peopleArr.length; i++){
    ((Person)peopleArr[i]).draw(transx,transy,scalex,scaley);
  }
}
