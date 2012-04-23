import org.json.*;

import tsps.*;
TSPS tspsReceiver;

// 1024 px/15 ft = 68 px/ft

int SPT_SPEED=60;
float TRUNK_LINE_WIDTH=0.035;
//int BACKGROUND_COLOR=255;
//color MAP_COLOR=color(0,0,0);
int BACKGROUND_COLOR=50;
color MAP_COLOR=color(255,255,255);
float HIGHWAY_WEIGHT=1.0;
float STREET_WEIGHT=0.5;//0.1;
color MEETUP_COLOR=color(255,255,255);
float INIT_BOUNDARY=200.0;

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

int tilesLoaded=0;

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

class LoaderThread extends Thread {
  LoaderThread(){
  }
  
  public void run(){

    for(int i=0; i<filenames.length; i++){
      tilesLoaded += 1;
      map.addTile( filenames[i] );
    }
    
    graph = map.toGraph();
  
    
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
  
    noLoop();
    background(BACKGROUND_COLOR);
    stroke(MAP_COLOR);
    map.draw(transx,transy,scalex,scaley);
    
  
    save("background.tif");
    backdrop = loadImage("background.tif");
    
    loop();
  }
}

PFont font;
LoaderThread lt;

void setup(){
  size(1024,1536);
  
  font = loadFont("LucidaSans-TypewriterBold-60.vlw");
  textFont(font);
    
  smooth();
  strokeWeight(0.1);
  ellipseMode(CENTER);
  
  scalex=11000;
  scaley=15000;
  transx=-71.15;
  transy=42.33;
  
  colors[0]=color(227,82,82);//color(200,0,0);
  colors[1]=color(82,227,82);//color(0,128,11);
  colors[2]=color(82,82,227);//color(0,13,138);
  colors[3]=color(227,227,82);//color(186,186,0);
  colors[4]=color(82,227,227);//color(0,150,135);
  colors[5]=color(227,82,227);//color(150,0,158);
  
  popularity = new HashMap();
  
  map = new Map();
  people = new ArrayList();

  lt = new LoaderThread();
  lt.start();

  
  tspsReceiver= new TSPS(this, 12000);
  
}

void keyPressed(){
  if( key==' ' ){
    person1.dijkstra.step(false);
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
  
  if( lt.isAlive() ){
    background(BACKGROUND_COLOR);
    text( tilesLoaded+"/"+filenames.length+" loaded", width/2-200, height/2 );
    
    fill(0,102,153);
    return;
  }
  
  tspsReceiver.update();

  update_people_with_tsps();
  
  Object[] peopleArr = people.toArray();
  
  
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

      boundary=INIT_BOUNDARY;
      for(float i=0.1; i<=boundary; i+=0.1){
        for(int j=0; j<peopleArr.length; j++){
          Person person = (Person)peopleArr[j];
          person.dijkstra.step_to(i,true);
        }
      }
      
      image(backdrop,0,0);
  } else if(everyone_still) {
    for(int i=0; i<SPT_SPEED; i++){
      boundary += 0.1;
      for(int j=0; j<peopleArr.length; j++){
        Person person = (Person)peopleArr[j];
        person.dijkstra.step_to(boundary,true);
      }
    }
  }
  
  for(int i=0; i<min(peopleArr.length,colors.length); i++){
    stroke(colors[i]);
    ((Person)peopleArr[i]).dijkstra.draw_deferred();
  }
  
  if(meetpoint_id != null && meetpoint !=null){
    stroke(MEETUP_COLOR);
    for(int i=0; i<peopleArr.length;i++){
      ((Person)peopleArr[i]).dijkstra.draw_to( meetpoint_id );
    }
    
    
    fill(MEETUP_COLOR);
    ellipse( width-meetpoint.screeny(), height-meetpoint.screenx(), 20, 20 );
  }
  
  fill(255,200,200,128);
  for(int i=0; i<peopleArr.length; i++){
    ((Person)peopleArr[i]).draw(transx,transy,scalex,scaley);
  }
  
}
