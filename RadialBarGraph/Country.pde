class Country {
    
  String          name;
  ArrayList<Year> years           = new ArrayList<Year>();
  color           emptyWedgeColor = color(30); //color(15);

  
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

  void drawRights(Category category, int year, float startTheta, float endTheta, float radius, float rightThickness) { 
    strokeCap(SQUARE);
    noFill();
    
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
    for (int i=0; i<category.rights.size(); i++) {
      String right = category.rights.get(i);
      
      if (yearIndex != -1 && years.get(yearIndex).rights.contains(right)) {
        float coloredWedgeRadius = currentRadius+rightThickness/2 + 2; // add 2 to compensate for grid thickness 
        strokeWeight(rightThickness); 
        stroke(category.rightsColors[i]);
        arc(0, 0, coloredWedgeRadius*2, coloredWedgeRadius*2, startTheta, endTheta);
      } 

      currentRadius += rightThickness;
    }
  }

  
  void drawCategories(int year, float startTheta, float endTheta, float radius, float rightThickness) { 
    strokeCap(SQUARE);  
    noFill();
    
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
    for (int i=0; i<categoryList.size(); i++) {
      Category category = categoryList.get(i);
      float categoryThickness = rightThickness*category.rights.size();
      
      int numberOfAdoptedRights = 0;
      for (int j=0; j<category.rights.size(); j++) {
        String right = category.rights.get(j);
        if (yearIndex != -1 && years.get(yearIndex).rights.contains(right)) {
          numberOfAdoptedRights++;
        }
      }

      if (numberOfAdoptedRights>0) {        
        float coloredWedgeThickness = categoryThickness*(numberOfAdoptedRights/category.rights.size());
        float coloredWedgeRadius    = currentRadius+coloredWedgeThickness/2 + 2; // add 2 to compensate for grid thickness 
        strokeWeight(coloredWedgeThickness);
        stroke(category.rightsColors[i]);
        arc(0, 0, coloredWedgeRadius*2, coloredWedgeRadius*2, startTheta, endTheta);    
      }   
      
      currentRadius += categoryThickness;
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

