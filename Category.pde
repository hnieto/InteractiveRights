class Category{
  String name;
  color colour;
  ArrayList<String> rights = new ArrayList<String>();
  ArrayList<String> descriptions = new ArrayList<String>();
  color[] rightsColors;
  
  Category(String name, color colour){
    this.name = name; 
    this.colour = colour;
  }
  
  void addRight(String right){
    rights.add(right);
  }
  
  void addRightColor(int index, color rightColor){
    rightsColors[index] = rightColor;
  }
  
  void addRightDescription(String description){
    descriptions.add(description); 
  }
  
  void initColorArray(int len){
    rightsColors = new color[len];
  }
  
  void printRights(){
    for(int i=0; i<rights.size(); i++){
      println(rights.get(i) + " : " + descriptions.get(i));
    }
  }
}
