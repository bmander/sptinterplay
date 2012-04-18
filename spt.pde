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

class Way{
  double rise;
  double fall;
  String id;
  ArrayList loc = new ArrayList();
  String fromv;
  String tov;
  String wayid;
  JSONObject wayinfo;
  
  Way( JSONObject data ) throws JSONException {
    this.rise = data.getDouble("rise");
    this.fall = data.getDouble("fall");
    this.id = data.getString("id");
    this.fromv = data.getString("fromv");
    this.tov = data.getString("tov");
    this.wayid = data.getString("wayid");
    
    JSONArray rawloc = data.getJSONArray( "loc" );
    JSONArray xs = rawloc.getJSONArray(0);
    JSONArray ys = rawloc.getJSONArray(1);
    double x=new Double(xs.getInt(0)).doubleValue()/1000000;
    double y=new Double(ys.getInt(0)).doubleValue()/1000000;
    this.loc.add( new Point( x, y ) );
    for(int i=1; i<xs.length(); i++){
      x += new Double(xs.getInt(i)).doubleValue()/1000000;
      y += new Double(ys.getInt(i)).doubleValue()/1000000;
      this.loc.add( new Point( x, y ) );
    }
  }
  
  String metadata(String key){
    try{
      return wayinfo.getString( key );
    } catch (JSONException ex){
      return null;
    }
  }
  
  void draw(double left, double bottom, double scalex, double scaley){
    if( this.metadata("highway").equals("motorway") ){
      strokeWeight(1);
    } else{
      strokeWeight(0.1);
    }
    //println( this.metadata( "highway" ) );
    
    for(int i=0; i<this.loc.size()-1; i++){
      Point pt1 = (Point)this.loc.get(i);
      Point pt2 = (Point)this.loc.get(i+1);
      
      float x1 = new Double((pt1.x-left)*scalex).floatValue();
      float y1 = new Double((pt1.y-bottom)*scaley).floatValue();
      float x2 = new Double((pt2.x-left)*scalex).floatValue();
      float y2 = new Double((pt2.y-bottom)*scaley).floatValue();
      
      line( x1, height-y1, x2, height-y2);
    }
  }
}

class Tile{
  String id;
  ArrayList ways;
  
  private void setWays( JSONArray ways, JSONObject wayinfo ) throws JSONException{
    for(int i=0; i<ways.length(); i++){
      Way way = new Way( ways.getJSONObject( i ) );
      way.wayinfo = wayinfo.getJSONObject( way.wayid );
      this.ways.add( way );
    }
  }
  
  Tile(String filename){
    this.ways = new ArrayList();
    
    try{
      // parse json blob
      print("start parsing...");
      BufferedReader rd = createReader( filename );
      JSONTokener tk = new JSONTokener( rd );//new JSONTokener( datastr );
      JSONObject data = new JSONObject( tk );
      println("done");
      
      // get tile id
      this.id = data.getString( "_id" );
      
      // get wayinfo, ways
      JSONObject value = data.getJSONObject( "value" );
      JSONObject wayinfo = value.getJSONObject( "wayinfo" );
      this.setWays( value.getJSONArray( "ways" ), wayinfo );
    } catch (JSONException ex){
      println( ex );
    }
  }
  
  void draw(double left, double bottom, double scalex, double scaley){
    for(int i=0; i<this.ways.size(); i++){
      Way way = (Way)this.ways.get(i);
      way.draw(left,bottom,scalex,scaley);
    }
  }
  
}

int scalex;
int scaley;
float transx;
float transy;
ArrayList tiles = new ArrayList();
Tile tile;

void drawtiles(float transx, float transy, int scalex, int scaley){
  for(int i=0; i<tiles.size(); i++){
    ((Tile)tiles.get(i)).draw(transx,transy,scalex,scaley);
  }
}

void setup(){
  size(1536,1024);
  
  smooth();
  strokeWeight(0.1);
  
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
    tiles.add( new Tile(filenames[i]) );
    println( "done" );
  }
  
  background(255);
  drawtiles(transx,transy,scalex,scaley);
  
}

void draw(){
  if(mousePressed){
    transx -= float(mouseX-pmouseX)/scalex;
    transy += float(mouseY-pmouseY)/scaley;
    
    background(255);
    drawtiles(transx,transy,scalex,scaley);
  }
}
