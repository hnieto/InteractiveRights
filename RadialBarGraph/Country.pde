class Country {
    
  String                             name;
  String[]                           existence;
  boolean                            visualize;
  boolean                            recentlyAdded;
  boolean                            recentlyRemoved;
  int                                alpha;
  ArrayList<Year>                    years;
  HashMap<String, String>            snippets;
  HashMap<Integer, Year>             yearMap;
  int                                snippetRightIndex;
  
  // animation timer
  float                              savedTime;    
  float                              passedTime;  
  float                              timeToWait;

  
  Country(String name, String[] existence) {
    this.name            = name;
    this.existence       = existence;
    this.visualize       = false;
    this.recentlyAdded   = false; 
    this.recentlyRemoved = false;
    this.alpha           = 225;
    this.years           = new ArrayList<Year>()
    this.yearMap         = new HashMap<Integer, Year>();
    this.snippets        = new HashMap<String, String>();
    this.snippetRightIndex = -1;
    this.timeToWait      = 1500; // in milliseconds
  }


  void addYear(Year year) {
    years.add(year);
  }
  
  
  void addYear(Integer yearKey, Year yearObject) {
    yearMap.put(yearKey, yearObject);    
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
  
  
  void drawCategories(int year, float startTheta, float endTheta, float radius, float rightThickness) { 
    strokeCap(SQUARE);  
    noFill();
    
    //draw light green slice to notify user of newly added country
    passedTime = millis() - savedTime; 
    if(recentlyAdded && passedTime<timeToWait) {
      float categoryThickness = rightThickness*numberOfRights;
      float highlightWedgeRadius  = radius+categoryThickness/2;
      strokeWeight(categoryThickness); 
      stroke(168,255,142,alpha);
      arc(0, 0, highlightWedgeRadius*2, highlightWedgeRadius*2, startTheta, endTheta);    
      
      alpha -= timeToWait/225;
    } 
    
    // reset alpha for next time country is added
    // update country "+" and "-" anchor links
    // disable countryList overlay 
    else if(recentlyAdded && passedTime>timeToWait) {
      visualize     = true;
      recentlyAdded = false;
      alpha = 225;
      generateCountryList();
      document.getElementById('countryListOverlay').style.background = "rgba(0, 0, 0, 0)";
      document.getElementById('countryListOverlay').style.zIndex     = "1";
      document.getElementById('opentour').style.display              = "block";
      document.getElementById('clearAllCountries').style.background  = "rgba(245, 59, 59, 0.24)";
      document.getElementById('clearAllCountries').style.color       = "white";
      document.getElementById('clearAllCountries').addEventListener('touchstart', clearWheelButtonHandler, false); 
      document.getElementById('clearAllCountries').addEventListener('mousedown',  clearWheelButtonHandler, false); 
    }
    
    //draw light red slice to notify user of country's removal
    else if(recentlyRemoved && passedTime<timeToWait) {
      float categoryThickness = rightThickness*numberOfRights;
      float highlightWedgeRadius  = radius+categoryThickness/2;
      strokeWeight(categoryThickness); 
      stroke(255,141,141,alpha);
      arc(0, 0, highlightWedgeRadius*2, highlightWedgeRadius*2, startTheta, endTheta);    
      
      alpha -= timeToWait/225; 
    }
    
    // reset alpha for next time country is removed
    // update country "+" and "-" anchor links
    // disable countryList overlay     
    else if(recentlyRemoved && passedTime>timeToWait) {
      visualize       = false;
      recentlyRemoved = false;
      alpha = 225;
      
      // remove country from visualizedCountries arrayList
      for(int i=0; i<visualizedCountries.size(); i++){
        Country currentCountry = visualizedCountries.get(i);
        if(currentCountry.name.equals(name)){
          visualizedCountries.remove(i); 
          break;
        } 
      }
      
      generateCountryList();
      document.getElementById('countryListOverlay').style.background = "rgba(0, 0, 0, 0)";
      document.getElementById('countryListOverlay').style.zIndex     = "1";
      document.getElementById('opentour').style.display              = "block";
      document.getElementById('clearAllCountries').style.background  = "rgba(245, 59, 59, 0.24)";
      document.getElementById('clearAllCountries').style.color       = "white";
      document.getElementById('clearAllCountries').addEventListener('touchstart', clearWheelButtonHandler, false); 
      document.getElementById('clearAllCountries').addEventListener('mousedown',  clearWheelButtonHandler, false); 
    }
    
    else {
      
      // draw dark wedge if country doesn't exist yet
      if(year < int(existence[0]) || year > int(existence[1])) {
        float sliceThickness = rightThickness*numberOfRights;
        float sliceRadius    = radius+sliceThickness/2;
        strokeWeight(sliceThickness); 
        stroke(0);
        arc(0, 0, sliceRadius*2, sliceRadius*2, startTheta, endTheta);  
      }
      
      // check if Country had any rights during Year
//      int yearIndex = -1;
//      for (int i=0; i<years.size(); i++) {
//        if (years.get(i).number == year) {
//          yearIndex = i;
//          break;
//        }
//      }       
  
      // cross-reference each right in this year with categoryList
      // if they match up, then draw it, skip otherwise
      float currentRadius = radius;
      for (int i=0; i<categoryList.size(); i++) {
        Category category = categoryList.get(i);
        float categoryThickness = rightThickness*category.rights.size();
        
        int numberOfAdoptedRights = 0;
        for (int j=0; j<category.rights.size(); j++) {
          String right = category.rights.get(j);
//          if (yearIndex != -1 && years.get(yearIndex).rights.contains(right)) {
//            numberOfAdoptedRights++;
//          }

          if(yearMap.get((Integer)year) != null) { // does country have any rights this year
            if(yearMap.get((Integer)year).rights.contains(right)) { // if so, does its constitution have this particular right
              numberOfAdoptedRights++;
            }
          }
        }        
  
        if (numberOfAdoptedRights>0) {        
          float coloredWedgeThickness = categoryThickness*(numberOfAdoptedRights/category.rights.size());
          float coloredWedgeRadius    = currentRadius+coloredWedgeThickness/2;
          strokeWeight(coloredWedgeThickness);
          stroke(category.colour);
          arc(0, 0, coloredWedgeRadius*2, coloredWedgeRadius*2, startTheta, endTheta);    
        }   
       
        currentRadius += categoryThickness;
      }
      
    }    
   
    // draw borders
    float currentRadius = radius;
    for (int i=0; i<categoryList.size(); i++) {
      Category category = categoryList.get(i);
      float categoryThickness = rightThickness*category.rights.size();
      
      strokeWeight(borderThickness);
      stroke(255, 100);
      arc(0, 0, currentRadius*2, currentRadius*2, startTheta, endTheta);  
      arc(0, 0, (currentRadius+categoryThickness)*2, (currentRadius+categoryThickness)*2, startTheta, endTheta);  
      line(currentRadius*cos(startTheta), currentRadius*sin(startTheta), (currentRadius+categoryThickness)*cos(startTheta), (currentRadius+categoryThickness)*sin(startTheta));
      line(currentRadius*cos(endTheta),   currentRadius*sin(endTheta),   (currentRadius+categoryThickness)*cos(endTheta),   (currentRadius+categoryThickness)*sin(endTheta));
      
      currentRadius += categoryThickness;
    } 
  } 
  

  void drawRights(Category category, int year, float startTheta, float endTheta, float radius, float rightThickness) { 
        
    strokeCap(SQUARE);
    noFill();
    
    //draw light green slice to notify user of newly added country
    passedTime = millis() - savedTime; 
    if(recentlyAdded && passedTime<timeToWait) {
      float categoryThickness = circumplexRadius-controllerRadius;
      float highlightWedgeRadius  = radius+categoryThickness/2;
      strokeWeight(categoryThickness); 
      stroke(168,255,142,alpha);
      arc(0, 0, highlightWedgeRadius*2, highlightWedgeRadius*2, startTheta, endTheta);    
      
      alpha -= timeToWait/225;
    } 
    
    // reset alpha for next time country is added
    // update country "+" and "-" anchor links
    // disable countryList overlay 
    else if(recentlyAdded && passedTime>timeToWait) {
      visualize     = true;
      recentlyAdded = false;
      alpha = 225;
      generateCountryList();
      
      document.getElementById('countryListOverlay').style.background = "rgba(0, 0, 0, 0)";
      document.getElementById('countryListOverlay').style.zIndex     = "1";
      document.getElementById('opentour').style.display              = "block";
      document.getElementById('clearAllCountries').style.background  = "rgba(245, 59, 59, 0.24)";
      document.getElementById('clearAllCountries').style.color       = "white";
      document.getElementById('clearAllCountries').addEventListener('touchstart', clearWheelButtonHandler, false); 
      document.getElementById('clearAllCountries').addEventListener('mousedown',  clearWheelButtonHandler, false); 
    }
    
    //draw light red slice to notify user of country's removal
    else if(recentlyRemoved && passedTime<timeToWait) {
      float categoryThickness = circumplexRadius-controllerRadius;
      float highlightWedgeRadius  = radius+categoryThickness/2;
      strokeWeight(categoryThickness); 
      stroke(255,141,141,alpha);
      arc(0, 0, highlightWedgeRadius*2, highlightWedgeRadius*2, startTheta, endTheta);    
      
      alpha -= timeToWait/225;      
    }
    
    // reset alpha for next time country is removed
    // update country "+" and "-" anchor links
    // disable countryList overlay     
    else if(recentlyRemoved && passedTime>timeToWait) {
      visualize       = false;
      recentlyRemoved = false;
      alpha = 225;
      
      // remove country from visualizedCountries arrayList
      for(int i=0; i<visualizedCountries.size(); i++){
        Country currentCountry = visualizedCountries.get(i);
        if(currentCountry.name.equals(name)){
          visualizedCountries.remove(i); 
          break;
        } 
      }
      
      generateCountryList();
      document.getElementById('countryListOverlay').style.background = "rgba(0, 0, 0, 0)";
      document.getElementById('countryListOverlay').style.zIndex     = "1";
      document.getElementById('opentour').style.display              = "block";
      document.getElementById('clearAllCountries').style.background  = "rgba(245, 59, 59, 0.24)";
      document.getElementById('clearAllCountries').style.color       = "white";
      document.getElementById('clearAllCountries').addEventListener('touchstart', clearWheelButtonHandler, false); 
      document.getElementById('clearAllCountries').addEventListener('mousedown',  clearWheelButtonHandler, false); 
    }
    
    else {
      
      // draw dark wedge if country doesn't exist yet
      if(year < int(existence[0]) || year > int(existence[1])) {
        float sliceThickness = circumplexRadius-controllerRadius;
        float sliceRadius    = radius+sliceThickness/2;
        strokeWeight(sliceThickness); 
        stroke(0);
        arc(0, 0, sliceRadius*2, sliceRadius*2, startTheta, endTheta);  
      }
      
      // check if Country had any rights during Year
//      int yearIndex = -1;
//      for (int i=0; i<years.size(); i++) {
//        if (years.get(i).number == year) {
//          yearIndex = i;
//          break;
//        }
//      }
      
      float currentRadius = radius;     
      // compare every right in the Category object passed in with the rights listed for that Year for this Country
      for (int i=0; i<category.rights.size(); i++) {
        String right = category.rights.get(i);
        
        if(yearMap.get((Integer)year) != null) { // does country have any rights this year
          if(yearMap.get((Integer)year).rights.contains(right)) { // if so, does its constitution have this particular right
            float coloredWedgeRadius = currentRadius+rightThickness/2;
            strokeWeight(rightThickness); 
            stroke(category.colour);
            arc(0, 0, coloredWedgeRadius*2, coloredWedgeRadius*2, startTheta, endTheta);
          }
        }
        
//        if (yearIndex != -1 && years.get(yearIndex).rights.contains(right)) {
//          float coloredWedgeRadius = currentRadius+rightThickness/2;
//          strokeWeight(rightThickness); 
//          stroke(category.colour);
//          arc(0, 0, coloredWedgeRadius*2, coloredWedgeRadius*2, startTheta, endTheta);
//        } 
  
        currentRadius += rightThickness;
      }
 
    }
    
    // draw borders
    float currentRadius = radius;     
    for (int i=0; i<category.rights.size(); i++) {
      
      strokeWeight(borderThickness);
      stroke(255, 100);
      arc(0, 0, currentRadius*2, currentRadius*2, startTheta, endTheta);  
      arc(0, 0, (currentRadius+rightThickness)*2, (currentRadius+rightThickness)*2, startTheta, endTheta);  
      line(currentRadius*cos(startTheta), currentRadius*sin(startTheta), (currentRadius+rightThickness)*cos(startTheta), (currentRadius+rightThickness)*sin(startTheta));
      line(currentRadius*cos(endTheta),   currentRadius*sin(endTheta),   (currentRadius+rightThickness)*cos(endTheta),   (currentRadius+rightThickness)*sin(endTheta));

      currentRadius += rightThickness;
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

