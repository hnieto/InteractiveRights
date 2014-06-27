class Year{
  int number;
  
  // index i in both ArrayLists corresponds to the right<->category pair
  ArrayList<String> rights = new ArrayList<String>(); 
  ArrayList<Category> categories = new ArrayList<Category>();
   
  Year(int number){
    this.number = number; 
  }
  
  void addRight(String right){
    rights.add(right);
  }
  
  void addCateogry(Category category){
    categories.add(category); 
  }
  
}
