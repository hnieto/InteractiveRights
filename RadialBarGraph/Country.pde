class Country {
    
  String                             name;
  String[]                           existence;
  boolean                            visualize;
  boolean                            recentlyAdded;
  boolean                            recentlyRemoved;
  boolean                            snippetCreated;
  int                                alpha;
  ArrayList<Year>                    years;
  HashMap<String, String>            snippets;
  int                                snippetRightIndex;
  
  Country(String name, String[] existence, boolean visualize) {
    this.name            = name;
    this.existence       = existence;
    this.visualize       = visualize;
    this.recentlyAdded   = false; 
    this.recentlyRemoved = false;
    this.alpha           = 225;
    this.years           = new ArrayList<Year>()
    this.snippets        = new HashMap<String, String>();
    this.snippetCreated  = false;
    this.snippetRightIndex = -1;
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
    
    // if country was touched/clicked, then show the excerpt of its constitution that relates to the selected right (if available)
    float mouseAngle = circumplexRotationAngle > mouseStartAngle ? (TWO_PI + mouseStartAngle-circumplexRotationAngle) : (mouseStartAngle-circumplexRotationAngle);
    
    
    if(mouseAngle > startTheta && mouseAngle < endTheta && highlightedRightIndex > -1) {
      
      // country had not been selected yet
      if(!snippetCreated) {
        snippetCreated       = true;
        snippetRightIndex    = highlightedRightIndex;
        String selectedRight = category.rights.get(snippetRightIndex);
        String snippetText   = snippets.get(selectedRight);
        
        String snippet, snippetID;
        if(snippetText == null) {
          snippet = '<p style="font-size:1vw; margin:0; color:#cccc00;">' + name + '</p>' + 
                    '<p style="margin:0; color:#ffffbb;">' + selectedRight + '</p>' + 
                    '<p>Constitution Excerpt Unavailable</p>'; 
        }
        
        else {
          snippet = '<p style="font-size:1vw; margin:0; color:#cccc00;">' + name + '</p>' + 
                    '<p style="margin:0; color:#ffffbb;">' + selectedRight + '</p>' + 
                    snippetText;
        }
        
        snippetID = name + ":" + cursorX + ":" + cursorY;
        showSnippet(cursorX, cursorY, snippetID, snippet);
      }
      
      // country was already selected. user just clicked on different right
      else if(highlightedRightIndex != snippetRightIndex) {
        snippetRightIndex    = highlightedRightIndex;
        String selectedRight = category.rights.get(snippetRightIndex);
        String snippetText   = snippets.get(selectedRight);
        
        String snippet, snippetID;
        if(snippetText == null) {
          snippet = '<p style="font-size:1vw; margin:0; color:#cccc00;">' + name + '</p>' + 
                    '<p style="margin:0; color:#ffffbb;">' + selectedRight + '</p>' + 
                    '<p>Constitution Excerpt Unavailable</p>'; 
        }
        
        else {
          snippet = '<p style="font-size:1vw; margin:0; color:#cccc00;">' + name + '</p>' + 
                    '<p style="margin:0; color:#ffffbb;">' + selectedRight + '</p>' + 
                    snippetText;
        }
        
        snippetID = name + ":" + cursorX + ":" + cursorY;
        showSnippet(cursorX, cursorY, snippetID, snippet);
      }
      
    }
        
    strokeCap(SQUARE);
    noFill();
    
    //draw light yellow slice to notify user of newly added country
    if(recentlyAdded && alpha>0) {
      float categoryThickness = circumplexRadius-controllerRadius;
      float highlightWedgeRadius  = radius+categoryThickness/2;
      strokeWeight(categoryThickness); 
      stroke(168,255,142,alpha);
      arc(0, 0, highlightWedgeRadius*2, highlightWedgeRadius*2, startTheta, endTheta);    
      
      alpha -= 14;
    } 
    
    // reset alpha for next time country is added
    // update country "+" and "-" anchor links
    // disable countryList overlay 
    else if(recentlyAdded && alpha<=0) {
      visualize     = true;
      recentlyAdded = false;
      alpha = 225;
      generateCountryList();
      var countryListOverlay = document.getElementById('countryBoxOverlay');
      countryListOverlay.style.display = "none";
    }
    
    //draw light red slice to notify user of country's removal
    else if(recentlyRemoved && alpha>0) {
      float categoryThickness = circumplexRadius-controllerRadius;
      float highlightWedgeRadius  = radius+categoryThickness/2;
      strokeWeight(categoryThickness); 
      stroke(255,141,141,alpha);
      arc(0, 0, highlightWedgeRadius*2, highlightWedgeRadius*2, startTheta, endTheta);    
      
      alpha -= 14;      
    }
    
    // reset alpha for next time country is removed
    // update country "+" and "-" anchor links
    // disable countryList overlay     
    else if(recentlyRemoved && alpha<=0) {
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
      var countryListOverlay = document.getElementById('countryBoxOverlay');
      countryListOverlay.style.display = "none";
    }
    
    else {
      
       // draw dark wedge if country doesn't exist yet
      if(year < int(existence[0]) || year > int(existence[1])) {
        float categoryThickness = rightThickness*numberOfRights;
        float emptyWedgeRadius  = radius+categoryThickness/2;
        strokeWeight(categoryThickness); 
        stroke(0);
        arc(0, 0, emptyWedgeRadius*2, emptyWedgeRadius*2, startTheta, endTheta);      
      }
      
      else {
      
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
            stroke(category.colour);
            arc(0, 0, coloredWedgeRadius*2, coloredWedgeRadius*2, startTheta, endTheta);
          } 
    
          currentRadius += rightThickness;
        }
      }    
      
    }
    
  }

  
  void drawCategories(int year, float startTheta, float endTheta, float radius, float rightThickness) { 
    strokeCap(SQUARE);  
    noFill();
    
    //draw light yellow slice to notify user of newly added country
    if(recentlyAdded && alpha>0) {
      float categoryThickness = rightThickness*numberOfRights;
      float highlightWedgeRadius  = radius+categoryThickness/2;
      strokeWeight(categoryThickness); 
      stroke(168,255,142,alpha);
      arc(0, 0, highlightWedgeRadius*2, highlightWedgeRadius*2, startTheta, endTheta);    
      
      alpha -= 7;
    } 
    
    // reset alpha for next time country is added
    // update country "+" and "-" anchor links
    // disable countryList overlay 
    else if(recentlyAdded && alpha<=0) {
      visualize     = true;
      recentlyAdded = false;
      alpha = 225;
      generateCountryList();
      var countryListOverlay = document.getElementById('countryBoxOverlay');
      countryListOverlay.style.display = "none";
    }
    
    //draw light red slice to notify user of country's removal
    else if(recentlyRemoved && alpha>0) {
      float categoryThickness = rightThickness*numberOfRights;
      float highlightWedgeRadius  = radius+categoryThickness/2;
      strokeWeight(categoryThickness); 
      stroke(255,141,141,alpha);
      arc(0, 0, highlightWedgeRadius*2, highlightWedgeRadius*2, startTheta, endTheta);    
      
      alpha -= 7;      
    }
    
    // reset alpha for next time country is removed
    // update country "+" and "-" anchor links
    // disable countryList overlay     
    else if(recentlyRemoved && alpha<=0) {
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
      var countryListOverlay = document.getElementById('countryBoxOverlay');
      countryListOverlay.style.display = "none";
    }
    
    else {
      if(year < int(existence[0]) || year > int(existence[1])) {
        float categoryThickness = rightThickness*numberOfRights;
        float emptyWedgeRadius  = radius+categoryThickness/2;
        strokeWeight(categoryThickness); 
        stroke(0);
        arc(0, 0, emptyWedgeRadius*2, emptyWedgeRadius*2, startTheta, endTheta);      
      }
      
      else {
      
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
            stroke(category.colour);
            arc(0, 0, coloredWedgeRadius*2, coloredWedgeRadius*2, startTheta, endTheta);    
          }   
          
          currentRadius += categoryThickness;
        }
        
      } 
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

