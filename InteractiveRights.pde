// Title: Interactive Rights, Radial Bar Graph
// Description: Cross-Country Comparison of Adopted Constitutional Rights Across Time
// Developed By: Heriberto Nieto
//               Texas Advanced Computing Center

/* @pjs font='../data/MonoSpaced.ttf, ../data/MonoSpacedBold.ttf, ../data/Digital.ttf'; */

import java.util.Map;
HashMap<String, Country> countryMap = new HashMap<String, Country>();
ArrayList<Country> countryList = new ArrayList<Country>();
ArrayList<Category> categoryList = new ArrayList<Category>();
ArrayList<String> rightsColumns = new ArrayList<String>();

TimeController timecontroller;
int[] yearRange = { 1850, 2012 };
int currentCircumplex, numberOfRights;
float controllerRadius, circumplexRadius, shortestDistanceFromCenter;
float circumplexRotationAngle, mouseStartAngle;
float highlightRadius, highlightThickness, highlightedRightIndex;

PFont defaultFont, monoSpacedFont, monoSpacedBold, digitalFont;
int fontSize;

color[] categoryColors = new color[7];
color background_color, letter_color, wedgeBorder_color;

float sketchWidth, sketchHeight;

boolean stackRights = true;
boolean highlightRing = false;

/*********************************************/
/*            Initialization                 */
/*********************************************/
void setup() {
  // colors
  categoryColors[6] = #113C5D; // outer
  categoryColors[5] = #FEDC1C; 
  categoryColors[4] = #76A0D5; 
  categoryColors[3] = #D43266;
  categoryColors[2] = #0065A0;
  categoryColors[1] = #00A871;
  categoryColors[0] = #80304A; // inner
  background_color = color(0, 0, 0);        // black
  letter_color = color(255, 255, 255);      // white
  wedgeBorder_color = color(255, 255, 255); // black 

  // circumplex
  currentCircumplex = 0;
  numberOfRights = 0;
  circumplexRotationAngle = 0.0; 
  mouseStartAngle = 0.0;
  highlightRadius = 0.0;
  highlightThickness = 0.0;
  highlightedRightIndex = -1;
  
  // javascript function to set sketch size according to the width of the browser
  setCanvasSize();
  size(sketchWidth, sketchHeight);
  
  // font stuff
  fontSize = 7;//lerp(0,20, sketchWidth/(3840*0.46)); // 0.46 is percentage of canvas relative to browser window width
//  defaultFont = loadFont("./data/Helvetica.ttf");
  monoSpacedFont = createFont("../data/MonoSpaced.ttf", fontSize); 
  monoSpacedBold = createFont("../data/MonoSpacedBold.ttf", fontSize);
  digitalFont = createFont("../data/Digital.ttf", fontSize*4);
  textAlign(CENTER);
  
  // time controls
  shortestDistanceFromCenter =  min(width, height)/2;
  circumplexRadius = shortestDistanceFromCenter-(textAscent() + textDescent()); // account for letter height
  controllerRadius =  shortestDistanceFromCenter/3;
  timecontroller = new TimeController(controllerRadius, yearRange);
  timecontroller.init();
  
  // parsing
  parseCategories("../data/us_categorization_061814.csv");
  parseRights("../data/dj_rights_060214.csv");
  findCountriesInRange(yearRange[0], yearRange[1]);  
  
  // javascript function to create HTML buttons using the category titles as labels
  generateHTMLbuttons(categoryList.size()+1);
}

/*********************************************/
/*             MAIN DRAW LOOP                */
/*********************************************/
void draw() {  
  background(background_color);
  
  pushMatrix();
  translate(width/2, (height)/2);
  rotate(-HALF_PI);
  
  pushMatrix();
  rotate(circumplexRotationAngle);
  if (currentCircumplex == categoryList.size()) {
    drawCategoryCircumplex();
    highlightUS();
    drawCategoryBorders();
  } else {
    drawRightsCircumplex(categoryList.get(currentCircumplex));
    highlightUS();
    drawRightsBorders(categoryList.get(currentCircumplex));
  }
  drawCountryNames();
  popMatrix();
  
  pushStyle();
  if (currentCircumplex == categoryList.size()) drawCategoryNames();
  else drawRightNames();
  popStyle();
  
  if(highlightRing){
    pushStyle();
    noFill();
    stroke(200, 50);
    strokeWeight(highlightThickness);
    ellipse(0, 0, (highlightRadius-highlightThickness/2)*2, (highlightRadius-highlightThickness/2)*2);
    strokeWeight(1);
    popStyle(); 
  }

  timecontroller.draw(); 
  timecontroller.update();
  popMatrix();
}

/*********************************************/
/*            RENDER CIRCUMPLEX              */
/*********************************************/
void drawCategoryCircumplex() {
  float delta = TWO_PI/countryList.size(); 
  float theta = delta/2; // shift by half the width of the US slice so as to center it
  float thickness = (circumplexRadius-controllerRadius)/numberOfRights;
  float adjustedRadius = circumplexRadius-thickness/2; // wedge thickens up/down from current radius, we have to adjust for that

  for (int i=countryList.size()-1; i>=0; i--) {
    countryList.get(i).drawCategories(timecontroller.year, theta, theta+delta, delta, adjustedRadius, thickness, stackRights);
    theta += delta;
  }
}

void drawRightsCircumplex(Category category) {
  float delta = TWO_PI/countryList.size(); // +2 to account for US taking up 3 slices
  float theta = delta/2; // shift by half the width of the US slice so as to center it
  float thickness = (circumplexRadius-controllerRadius)/category.rights.size();
  float adjustedRadius = circumplexRadius-thickness/2; // wedge thickens up/down from current radius, we have to adjust for that

  for (int i=countryList.size()-1; i>=0; i--) {
    countryList.get(i).drawRights(category, timecontroller.year, theta, theta+delta, delta, adjustedRadius, thickness);
    theta += delta;
  }
}

/*********************************************/
/*              OVERLAYS                     */
/*********************************************/
void highlightUS(){
  float delta = TWO_PI/countryList.size();
  float theta = -delta/2;
  
  pushStyle();
  fill(200, 100);
  arc(0, 0, circumplexRadius*2, circumplexRadius*2, theta, theta+delta);
  popStyle();  
}

void drawRightsBorders(Category category){
  int borderThickness = 1;
  int numberOfRings = category.rights.size();
  int numberOfSlices = countryList.size();
  
  pushStyle();
  noFill();
  stroke(20);
  strokeWeight(borderThickness);
  
  // create rings
  float thickness = (circumplexRadius-controllerRadius)/numberOfRings;
  float shrinkingRadius = circumplexRadius;
  for(int i=0; i<=numberOfRings; i++){
    ellipse(0, 0, shrinkingRadius*2, shrinkingRadius*2);
    shrinkingRadius -= thickness;
  }
  
  // create slices
  float delta = TWO_PI/numberOfSlices;
  float angle = delta/2;
  for(int i=0; i<numberOfSlices; i++){
    line(0, 0);
    line(circumplexRadius*cos(angle), circumplexRadius*sin(angle));
    angle += delta;
  } 
  
  shrinkingRadius += thickness;
  fill(0);
  ellipse(0, 0, shrinkingRadius*2, shrinkingRadius*2);
  popStyle();
}

void drawCategoryBorders(){
  int borderThickness = 1;
  int numberOfRings = categoryList.size();
  int numberOfSlices = countryList.size();
  
  pushStyle();
  noFill();
  stroke(20);
  strokeWeight(borderThickness);
  
  // create rings
  float individualRightThickness = (circumplexRadius-controllerRadius)/numberOfRights;
  float growingRadius = controllerRadius;
  for(int i=0; i<numberOfRings; i++){
    Category category = categoryList.get(i);
    ellipse(0, 0, growingRadius*2, growingRadius*2);
    growingRadius += individualRightThickness*category.rights.size();
  }
  ellipse(0, 0, growingRadius*2, growingRadius*2);
  
  // create slices
  float delta = TWO_PI/numberOfSlices;
  float angle = delta/2;
  for(int i=0; i<numberOfSlices; i++){
    line(0, 0);
    line(circumplexRadius*cos(angle), circumplexRadius*sin(angle));
    angle += delta;
  } 
  
  fill(0);
  ellipse(0, 0, controllerRadius*2, controllerRadius*2);
  popStyle();
}

void drawCountryNames() {   
  float delta = TWO_PI/countryList.size(); 
  float startTheta = delta/2; // shift by half the width of the US slice so as to center it
  float thickness = (circumplexRadius-controllerRadius)/numberOfRights;
  float adjustedRadius = circumplexRadius-thickness/2; // wedge thickens up/down from current radius, we have to adjust for that

  for (int i=countryList.size()-1; i>=0; i--) {
    String name = countryList.get(i).name;
    if(name.equals("United States")) textSize(fontSize*1.5);
    else textSize(fontSize);
    
    float outerRadius = adjustedRadius + thickness/2;
    float txtStartAngle = (startTheta+delta*0.5) - (getTextLength(name)/outerRadius)*0.5;
    float arclength = 0; // We must keep track of our position along the curve
  
    for (int j=0; j<name.length(); j++) {
      // Instead of a constant width, we check the width of each character.
      String currentChar = name.substring(j,j+1);//name.charAt(j);
      float currentCharWidth = textWidth(currentChar);
  
      // Each box is centered so we move half the width
      arclength += currentCharWidth/2;
  
      // Angle in radians is the arclength divided by the radius
      // Starting on the left side of the circle by adding PI
      float theta = arclength / outerRadius;    
  
      pushMatrix();
      // position text starting from given angle
      rotate(txtStartAngle);
      // Polar to cartesian coordinate conversion
      translate(outerRadius*cos(theta), outerRadius*sin(theta));
      // Rotate the box
      rotate(theta+PI/2); // rotation is offset by 90 degrees
      
      // Display the character
      pushStyle();
      fill(letter_color);
      text(currentChar, 0, 0);
      popStyle();
      
      popMatrix();
      
      // Move halfway again
      arclength += currentCharWidth/2;
    }
    
    startTheta += delta;
  }
}

void drawRightNames() {
  Category category = categoryList.get(currentCircumplex);
  float delta = TWO_PI/countryList.size(); 
  float startTheta = -delta/2; // shift by half the width of the US slice so as to center it
  float thickness = (circumplexRadius-controllerRadius)/category.rights.size();
  float adjustedRadius = circumplexRadius-thickness/2; // wedge thickens up/down from current radius, we have to adjust for that
  float adjustedFontSize = fontSize*15/category.rights.size(); // font size must be inversely proportional to the number of rings 
  String rightText;
  
  for (int i=category.rights.size()-1; i>=0; i--) {
    if(i == highlightedRightIndex) {
      textFont(monoSpacedBold, adjustedFontSize*1.5);
      rightText = category.descriptions.get(i); 
    }
    else {
      textFont(monoSpacedFont, adjustedFontSize);
      rightText = category.rights.get(i);
    }
    
    float textHeight = textAscent() + textDescent();
    float radius = adjustedRadius-textHeight/2;
    float txtStartAngle = (startTheta+delta*0.5) - (getTextLength(rightText)/radius)*0.5;
    float arclength = 0; // We must keep track of our position along the curve
  
    for (int j=0; j<rightText.length(); j++) {
      // Instead of a constant width, we check the width of each character.
      String currentChar = rightText.substring(j,j+1);//text.charAt(j);
      float currentCharWidth = textWidth(currentChar);
  
      // Each box is centered so we move half the width
      arclength += currentCharWidth/2;
  
      // Angle in radians is the arclength divided by the radius
      // Starting on the left side of the circle by adding PI
      float theta = arclength / radius;    
  
      pushMatrix();
      // position text starting from given angle
      rotate(txtStartAngle);
      // Polar to cartesian coordinate conversion
      translate(radius*cos(theta), radius*sin(theta));
      // Rotate the box
      rotate(theta+PI/2); // rotation is offset by 90 degrees
      
      // Display the character
      pushStyle();
      if(i == highlightedRightIndex) fill(255, 255, 0, 150);
      else fill(letter_color, 150);
      text(currentChar, 0, 0);
      popStyle();
      
      popMatrix();
      
      // Move halfway again
      arclength += currentCharWidth/2;
    }
    
    adjustedRadius -= thickness;
  }
}

void drawCategoryNames() {
  textSize(fontSize*4);
  float delta = TWO_PI/countryList.size(); 
  float startTheta = -delta/2; // shift by half the width of the US slice so as to center it
  float rightThickness = (circumplexRadius-controllerRadius)/numberOfRights;
  float categoryOuterRadius = circumplexRadius;
  float textHeight = textAscent() + textDescent();

  for (int i=categoryList.size()-1; i>=0; i--) {    
    String categoryText = categoryList.get(i).name;
    float categoryThickness = rightThickness*categoryList.get(i).rights.size();
    float categoryInnerRadius = categoryOuterRadius-categoryThickness;
    float txtStartAngle = (startTheta+delta*0.5) - (getTextLength(categoryText)/categoryInnerRadius)*0.5;
    float arclength = 0; // We must keep track of our position along the curve
      
    for (int j=0; j<categoryText.length(); j++) {
      // Instead of a constant width, we check the width of each character.
      String currentChar = categoryText.substring(j,j+1);
      float currentCharWidth = textWidth(currentChar);
  
      // Each box is centered so we move half the width
      arclength += currentCharWidth/2;
  
      // Angle in radians is the arclength divided by the radius
      // Starting on the left side of the circle by adding PI
      float theta = arclength / categoryInnerRadius;    
  
      pushMatrix();
      // position text starting from given angle
      rotate(txtStartAngle);
      // Polar to cartesian coordinate conversion
      translate(categoryInnerRadius*cos(theta), categoryInnerRadius*sin(theta));
      // Rotate the box
      rotate(theta+PI/2); // rotation is offset by 90 degrees
      
      // Display the character
      pushStyle();
      fill(letter_color, 150);
      text(currentChar, 0, 0);
      popStyle();
      
      popMatrix();
      // Move halfway again
      arclength += currentCharWidth/2;
    }
    
    categoryOuterRadius -= categoryThickness;
  }
}

int getTextLength(String text) {
  int totalLength = 0;
  if (text.length() < 1) return 0;
  else {
    for (int i=0; i<text.length(); i++) {
      char currentChar = text.charAt(i);
      totalLength += textWidth(currentChar);
    } 
    return totalLength;
  }
}

/*********************************************/
/*                PARSE CSVs                 */
/*********************************************/
void parseCategories(String csv) {
  String[] lines = loadStrings(csv);
  String[] categoryTitles = split(lines[0].replaceAll("\"", ""), ',');

  for (int i=0; i<categoryTitles.length; i++) {     
    Category category = new Category(categoryTitles[i], categoryColors[i]);
    categoryList.add(category);

    // add all rights to newly created Category object
    for(int j=1; j<lines.length; j++){
      String[] row = split(lines[j], ',');
      String[] rightInfo = split(row[i], " : ");
      if(rightInfo[0].length() != 0) {
          String right = rightInfo[0];
          String description = rightInfo[1];
          if (right.length() != 0) {
            category.addRight(right);
            category.addRightDescription(description.replaceAll(";", ",")); // csv must use ';' instead of ',' in sentence because ',' are reserved for delimeter. replaceAll function swaps them back to ',' to render
            numberOfRights++;
          }
       }
     }

    category.initColorArray(category.rights.size());

    for (int j=0; j<category.rights.size(); j++) {
        category.addRightColor(j, category.colour);
    }
  }
}

void parseRights(String csv) {
  // reads CSV header column and returns only the Right strings
  String[] lines = loadStrings(csv);
  String[] columns = split(lines[0].replaceAll("\"", ""), ',');
  int countryColumnIndex, rightColumnIndex, yearColumnIndex;
  
  // find the index for the column titled "country"
  for (countryColumnIndex=0; countryColumnIndex<columns.length; countryColumnIndex++) {
    if (columns[countryColumnIndex].equals("country")) break;
  }

  // find the index for the column titled "Human Dignity"
  for (rightColumnIndex=0; rightColumnIndex<columns.length; rightColumnIndex++) {
    if (columns[rightColumnIndex].equals("Human Dignity")) break;
  }

  // get all column headers that follow the column "Human Dignity"
  for (int i=rightColumnIndex; i<columns.length; i++) {
    rightsColumns.add(columns[i]);
  }
  
  // find the index for the column titled "year"
  for (yearColumnIndex=0; yearColumnIndex<columns.length; yearColumnIndex++) {
    if (columns[yearColumnIndex].equals("year")) break;
  }

  // parse dj_rights.csv and use rightsColumn array to filter results
  for (int i=2; i<lines.length; i++) {
    String[] row = split(lines[i], ',');
    String keyword = row[countryColumnIndex]; // get string in column titled "country"
    Country value = countryMap.get(keyword);

    // first time this country was read in table
    if (value == null) {  
      value = new Country(keyword);
      countryMap.put(keyword, value);

      // find all rights available for this country on this year
      Year year = new Year(int(row[yearColumnIndex]));
      int naCounter = 0;
      for (int j=0, rightIterator=rightColumnIndex; j<rightsColumns.size(); j++, rightIterator++) {
        String right = rightsColumns.get(j);
        String rightAvailability = row[rightIterator];
        if (rightAvailability.equals("1. yes") || rightAvailability.equals("2. full")) {
          year.addRight(right);
          year.addCateogry(findCategoryForRight(right));
        } 

        if (rightAvailability.equals("NA")) naCounter++;
      }

      if (naCounter != rightsColumns.size()) value.addYear(year);
    } 

    // country already exists in hashmap, just add another Year object to it
    else {
      // find all rights available for this country on this year
      Year year = new Year(int(row[yearColumnIndex]));
      int naCounter = 0;
      for (int j=0, rightIterator=rightColumnIndex; j<rightsColumns.size(); j++, rightIterator++) {
        String right = rightsColumns.get(j);
        String rightAvailability = row[rightIterator];
        if (rightAvailability.equals("1. yes")  || rightAvailability.equals("2. full")) {
          year.addRight(right);
          year.addCateogry(findCategoryForRight(right));
        }

        if (rightAvailability.equals("NA")) naCounter++;
      }

      if (naCounter != rightsColumns.size()) value.addYear(year);
    }
  }
}

// find the category that a right belongs to
Category findCategoryForRight(String rightToSearch) {
  for (int i=0; i<categoryList.size(); i++) {
    Category category = categoryList.get(i);
    if (category.rights.contains(rightToSearch)) return category;
  }
  return null;
}

// searches for countries that have existed in the given time frame
void findCountriesInRange(int startYear, int endYear) {
  for (Map.Entry me : countryMap.entrySet()) {
    Country countryObject = (Country)me.getValue();
    if (countryObject.checkConstitutionExistence(startYear, endYear)) {
      // check for US and move it to start of list 
      if (countryObject.name.equals("United States") && countryList.size()>0) {
        // swap objects in list
        Country temp = countryList.get(0);
        countryList.add(0, countryObject);
        countryList.add(temp);
      } 
      else countryList.add(countryObject);
    }
  }
}

/*********************************************/
/*       MOUSE/KEYBOARD INTERACTION          */
/*********************************************/
void keyPressed() {
  if (key == 's') stackRights = !stackRights;
}

void mouseClicked() {
  timecontroller.playButtonClicked(width/2, height/2);
  timecontroller.ffButtonClicked(width/2, height/2);
  timecontroller.rewindButtonClicked(width/2, height/2);
  
  // if in "All Rights" circumplex, check for category selection via mouse click
  if(currentCircumplex == categoryList.size()){
    float categoryThickness = (circumplexRadius-controllerRadius)/categoryList.size();
    float r = circumplexRadius;
    float x = width/2;
    float y = height/2;
    for(int i=categoryList.size()-1; i>=0; i--) {
      float disX = x - mouseX;
      float disY = y - mouseY;
      if (sqrt(sq(disX) + sq(disY)) > r-categoryThickness && sqrt(sq(disX) + sq(disY)) < r) {
        currentCircumplex = i;
      } 
      r -= categoryThickness;
    }
  } 
}

void mousePressed(){ 
  float disX = width/2 - mouseX;
  float disY = height/2 - mouseY;
  
  // check if circumplex should be rotated
  if(sqrt(sq(disX) + sq(disY)) > controllerRadius && sqrt(sq(disX) + sq(disY)) < circumplexRadius) {
     // get the angle from the center to the mouse position
    mouseStartAngle = atan2(mouseY - height/2, mouseX - width/2);
  }
  
  // highlight right ring when clicked wedge is selected via mouse press
  if(currentCircumplex == categoryList.size()){
    float rightThickness = (circumplexRadius-controllerRadius)/numberOfRights;
    float r = circumplexRadius;
    for(int i=categoryList.size()-1; i>=0; i--) {
      float categoryThickness = rightThickness*categoryList.get(i).rights.size();
      if (sqrt(sq(disX) + sq(disY)) > r-categoryThickness && sqrt(sq(disX) + sq(disY)) < r) {
        highlightRing = true;
        highlightRadius = r;
        highlightThickness = categoryThickness;
      } 
      r -= categoryThickness;
    }
  } 
  
  else {
    Category category = categoryList.get(currentCircumplex);
    float rightThickness = (circumplexRadius-controllerRadius)/category.rights.size();
    float r = circumplexRadius;
    for(int i=category.rights.size()-1; i>=0; i--) {
      if (sqrt(sq(disX) + sq(disY)) > r-rightThickness && sqrt(sq(disX) + sq(disY)) < r) {
        highlightRing = true;
        highlightRadius = r;
        highlightThickness = rightThickness;
        highlightedRightIndex = i;
      } 
      r -= rightThickness;
    }
  }
  
  timecontroller.timelineTickClicked(width/2, height/2);
}

void mouseReleased(){
  timecontroller.timelineActive = false;
  highlightRing = false;
  highlightedRightIndex = -1;
}

void mouseDragged(){
  // check if circumplex should be rotated
  float disX = width/2 - mouseX;
  float disY = height/2 - mouseY;
  if(sqrt(sq(disX) + sq(disY)) > controllerRadius && sqrt(sq(disX) + sq(disY)) < circumplexRadius) {
     // get the angle from the center to the mouse position
    float mouseEndAngle = atan2(mouseY - height/2, mouseX - width/2);
    float angleOffset = mouseEndAngle - mouseStartAngle;
    circumplexRotationAngle += angleOffset;
    mouseStartAngle = mouseEndAngle;  
  } 
}

/*********************************************/
/*       PDE/JAVASCRIPT COMMUNICATION        */
/*********************************************/
function generateHTMLbuttons(listSize){    
  // loop through categories array and create a button for each entry
  for (var i=0; i<listSize; i++) {
    if(i == listSize-1) {
      var button = document.createElement('button');
      var text = document.createTextNode("All Rights");
      button.appendChild(text);
      button.setAttribute("id", "categoryButton" + i);
      button.setAttribute('onclick', 'changeCircumplex("'+i+'")');
      button.style.width = "100%";
      document.getElementById('parent').appendChild(button); 
    }
    
    else {
      var button = document.createElement('button');
      var text = document.createTextNode(categoryList.get(i).name);
      button.appendChild(text);
      button.setAttribute("id", "categoryButton" + i);
      button.setAttribute('onclick', 'changeCircumplex("'+i+'")');
      button.style.width = 100/(listSize-1) + "%"
      document.getElementById('children').appendChild(button); 
    }
  }
}
  
function setCanvasSize(){
  var buttonDivHeight =  document.getElementById('buttonContainer').clientHeight;
  var browserWidth = window.innerWidth;
  var browserHeight = window.innerHeight;
  sketchWidth = browserWidth * 0.46;
  sketchHeight = browserHeight * 0.95 - buttonDivHeight;
  
  document.getElementById('visDiv').setAttribute("style","width:"+sketchWidth+"px");
}

void setCircumplexFromJS(int circumplexID){
  currentCircumplex = circumplexID;
}
