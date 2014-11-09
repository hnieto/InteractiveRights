class Category{
        
    String            name;
    color             colour;
    ArrayList<String> rights       = new ArrayList<String>();
    ArrayList<String> descriptions = new ArrayList<String>();
    
    Category(String name, color colour){
        this.name   = name; 
        this.colour = colour;
    }
    
    void addRight(String right){
        rights.add(right);
    }
    
    void addRightDescription(String description){
        descriptions.add(description); 
    }
    
    void printRights(){
        for(int i=0; i<rights.size(); i++){
            println(rights.get(i) + " : " + descriptions.get(i));
        }
    }
}
