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

class Map{
  ArrayList tiles;
  
  Map(){
    tiles = new ArrayList();
  }
  
  void addTile(Tile tile){
    tiles.add( tile );
  }
  
  void addTile(String filename){
    Tile tile = new Tile(filename);
    this.addTile(tile);
  }
  
  Graph toGraph(){
    Graph gg = new Graph();
    for(int i=0; i<this.tiles.size(); i++){
      gg.add( (Tile)this.tiles.get(i) );
    }
    return gg;
  }
  
  void draw(float transx, float transy, int scalex, int scaley){
    for(int i=0; i<tiles.size(); i++){
      ((Tile)tiles.get(i)).draw(transx,transy,scalex,scaley);
    }
  }
  
}
