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
  
  Point point(int ix){
    if(ix<0 || ix>=this.loc.size()){
      return null;
    }
    return (Point)this.loc.get(ix);
  }
  
  Point first(){
    return this.point(0);
  }
  Point last(){
    return this.point(this.loc.size()-1);
  }
  
  String metadata(String key){
    try{
      return wayinfo.getString( key );
    } catch (JSONException ex){
      return null;
    }
  }
  
  void draw(double left, double bottom, double scalex, double scaley){
    float weight;
    if( this.metadata("highway").equals("motorway") ){
      weight=HIGHWAY_WEIGHT;
    } else{
      weight=STREET_WEIGHT;
    }
    
    draw(left,bottom,scalex,scaley,weight);
  }
  
  void draw(double left, double bottom, double scalex, double scaley, float weight){
    strokeWeight(weight);
    
    for(int i=0; i<this.loc.size()-1; i++){
      Point pt1 = (Point)this.loc.get(i);
      Point pt2 = (Point)this.loc.get(i+1);
      
      float x1 = new Double((pt1.x-left)*scalex).floatValue();
      float y1 = new Double((pt1.y-bottom)*scaley).floatValue();
      float x2 = new Double((pt2.x-left)*scalex).floatValue();
      float y2 = new Double((pt2.y-bottom)*scaley).floatValue();
      
      line( width-y1, height-x1, width-y2, height-x2);
    }
  }
}
