class Country {
    
  String          name;
  ArrayList<Year> years           = new ArrayList<Year>();
  color           emptyWedgeColor = color(15);

  
  Country(String name) {
    this.name = name;
  }

  
  void addYear(Year year) {
    years.add(year);
  }

  
  void printRights() {
    for (int i=0; i<years.size(); i++) {
      Year thisYear = years.get(i);
      println(thisYear.number + " (total=" + thisYear.rights.size() + "): ");
      for (int j=0; j<thisYear.rights.size(); j++) {
        String right    = thisYear.rights.get(j);
        String category = thisYear.categories.get(j).name;
        println(right + ", " + category);
      }
      println();
    }
  }

  // returns false if no constitutional data (NA in table for all rights)
  // exists before searchYear1
  boolean checkConstitutionExistence(int searchYear1, int searchYear2) {
    if (years.size() > 0) {
      int firstYear = years.get(0).number;
      int lastYear = years.get(years.size()-1).number;

      if (firstYear <= searchYear1 && lastYear >= searchYear2) return true;
    } 
    return false;
  }

  void drawRights(Category category, int year, float startTheta, float endTheta, float delta, float radius, float thickness) { 
    // check if Country had any rights during Year
    int yearIndex = -1;
    for (int i=0; i<years.size(); i++) {
      if (years.get(i).number == year) {
        yearIndex = i;
        break;
      }
    }
    
    float currentRadius = radius;
    // compare every right in the Category object passed in with the rights listed for that Year for this Country
    for (int i=category.rights.size()-1; i>=0; i--) {
      String right = category.rights.get(i);
      
      strokeCap(SQUARE);     
      if (yearIndex != -1 && years.get(yearIndex).rights.contains(right)) {
        strokeWeight(thickness*0.9); // if using grid then use => strokeWeight(thickness)
        stroke(category.rightsColors[i]);
        arc(0, 0, currentRadius*2, currentRadius*2, startTheta, endTheta);
      } 
     
      // fill in empty space with dark wedge
      else {
        strokeWeight(thickness*0.9);
        stroke(emptyWedgeColor);
        arc(0, 0, currentRadius*2, currentRadius*2, startTheta, endTheta);        
      }
     
      strokeWeight(1);
      noFill();
      currentRadius -= thickness;
    }
  }

  
  void drawCategories(int year, float startTheta, float endTheta, float delta, float radius, float thickness, boolean stack) { 
    // check if Country had any rights during Year
    int yearIndex = -1;
    for (int i=0; i<years.size(); i++) {
      if (years.get(i).number == year) {
        yearIndex = i;
        break;
      }
    }

    // cross-reference each right in this year with categoryList
    // if they match up, then draw it, skip otherwise
    float currentRadius = radius;
    for (int i=categoryList.size()-1; i>=0; i--) {
      Category category = categoryList.get(i);
      float categoryThickness = thickness*category.rights.size();
      float stackRadius = currentRadius+thickness-categoryThickness;
      strokeCap(SQUARE);
      
      // compare every right in the Category object passed in with the rights listed for that Year for this Country
      if(stack){        
        
        int numberOfActiveRights = 0;
        for (int j=category.rights.size()-1; j>=0; j--) {
          String right = category.rights.get(j);
          if (yearIndex != -1 && years.get(yearIndex).rights.contains(right)) {
            numberOfActiveRights++;
            strokeWeight(thickness*0.9);
            stroke(category.colour);
            arc(0, 0, stackRadius*2, stackRadius*2, startTheta, endTheta);
            stackRadius += thickness;
          }
        }
        
        // fill in empty space with dark wedge
        for (int k=0; k<(category.rights.size()-numberOfActiveRights); k++){
          strokeWeight(thickness*0.9);
          stroke(emptyWedgeColor);
          arc(0, 0, stackRadius*2, stackRadius*2, startTheta, endTheta);
          stackRadius += thickness;        
        }
        
        currentRadius -= categoryThickness;
      } 
      
      else {
        for (int j=category.rights.size()-1; j>=0; j--) {
          String right = category.rights.get(j);
          if (yearIndex != -1 && years.get(yearIndex).rights.contains(right)) {
            strokeWeight(thickness*0.9);
            stroke(category.colour);
            arc(0, 0, currentRadius*2, currentRadius*2, startTheta, endTheta);
          }
          
          // fill in empty space with dark wedge
          else {
            strokeWeight(thickness*0.9);
            stroke(emptyWedgeColor);
            arc(0, 0, currentRadius*2, currentRadius*2, startTheta, endTheta);            
          }
          currentRadius -= thickness;
        }        
      }
      
      strokeWeight(1);
      noFill();
    }
  } 

  
  int countIncludedRightsFromCategory(Category category, int yearIndex) {
    int counter = 0;
    ArrayList<String> rightsInThisYear = years.get(yearIndex).rights;
    for (int i=0; i<category.rights.size(); i++) {
      String rightInCategory = category.rights.get(i);
      if (rightsInThisYear.contains(rightInCategory)) counter++;
    }
    return counter;
  } 
}

