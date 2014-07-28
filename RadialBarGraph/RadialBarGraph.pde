// Title: Interactive Rights, Radial Bar Graph
// Description: Cross-Country Comparison of Adopted Constitutional Rights Across Time
// Developed By: Heriberto Nieto
//               Texas Advanced Computing Center
// Modified by: Luis Francisco-Revilla

/* @pjs font='../data/RefrigeratorDeluxeLight.ttf, ../data/MonoSpaced.ttf, ../data/MonoSpacedBold.ttf, ../data/Digital.ttf'; */

import java.util.Map;
HashMap<String, Country> countryMap     = new HashMap<String, Country>();
ArrayList<Country>       countryList    = new ArrayList<Country>();
ArrayList<Category>      categoryList   = new ArrayList<Category>();
ArrayList<String>        rightsColumns  = new ArrayList<String>();

TimeController           timecontroller;
int[]                    yearRange      = { 1850, 2012 };
int                      currentCircumplex, numberOfRights;
float                    controllerRadius, circumplexRadius, shortestDistanceFromCenter, paddingTop;
float                    circumplexRotationAngle, mouseStartAngle;
float                    highlightRadius, highlightThickness, highlightedRightIndex;
int                      largestCategoryLength;
                         
PFont                    defaultFont, monoSpacedFont, monoSpacedBold, digitalFont;
int                      fontSize;

color[]                  categoryColors = new color[7];
color                    background_color, letter_color, wedgeBorder_color;

float                    sketchWidth, sketchHeight;
                         
boolean                  stackRights    = true;
boolean                  highlightRing  = false;

/*********************************************/
/*            Initialization                 */
/*********************************************/
void setup() {
  // colors
  categoryColors[6]          = #113C5D; // outer
  categoryColors[5]          = #FEDC1C; 
  categoryColors[4]          = #76A0D5; 
  categoryColors[3]          = #D43266;
  categoryColors[2]          = #0065A0;
  categoryColors[1]          = #00A871;
  categoryColors[0]          = #80304A; // inner
  background_color           = color(0, 0, 0);        // black
  letter_color               = color(255, 255, 255);  // white 
  wedgeBorder_color          = color(255, 255, 255);  // black 
                             
  // circumplex              
  numberOfRights             = 0;
  circumplexRotationAngle    = 0.0; 
  mouseStartAngle            = 0.0;
  highlightRadius            = 0.0;
  highlightThickness         = 0.0;
  highlightedRightIndex      = -1;
  
  // javascript function to set sketch size according to the width of the browser
  setCanvasSize();
  size(sketchWidth, sketchHeight);
  paddingTop                 = sketchHeight * 0.01; 

  // font stuff
  fontSize                   = lerp(0,20, sketchWidth/(3840*0.5)); // 0.5 is percentage of canvas relative to browser window width
  defaultFont                = createFont("../data/RefrigeratorDeluxeLight.ttf", fontSize);
  monoSpacedFont             = createFont("../data/MonoSpaced.ttf", fontSize); 
  monoSpacedBold             = createFont("../data/MonoSpacedBold.ttf", fontSize);
  digitalFont                = createFont("../data/Digital.ttf", fontSize*4);
  textAlign(CENTER);
  textFont(defaultFont);
  
  // time controls
  shortestDistanceFromCenter = min(width, height)/2;
  circumplexRadius           = shortestDistanceFromCenter-(textAscent() + textDescent())-paddingTop; // account for letter height and add some extra padding
  controllerRadius           = shortestDistanceFromCenter/3;
  timecontroller             = new TimeController(controllerRadius, yearRange);
  timecontroller.init();
  
  // parsing
  parseCategories("../data/us_categorization_061814.csv");
  parseRights("../data/dj_rights_060214.csv");
  findCountriesInRange(yearRange[0], yearRange[1]);  
  
  // determine number of rights in largest category
  // used to calculate font size for right description 
  largestCategoryLength = 0;
  for(int i=0; i<categoryList.size(); i++){
    int categorySize = categoryList.get(i).rights.size();
    if(categorySize > largestCategoryLength) largestCategoryLength = categorySize;
  }
  
  // javascript function to create HTML buttdons using the category titles as labels
  generateButtonTreeLinks(categoryList.size()+1, "#ffffff");
  generateButtonTree(categoryList.size()+1);
  
  // set "All Rights" view as default
  currentCircumplex          = categoryList.size();
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

  float delta          = TWO_PI/countryList.size(); 
  float theta          = delta/2; // shift by half the width of the US slice so as to center it
  float thickness      = (circumplexRadius-controllerRadius)/numberOfRights;
  float adjustedRadius = circumplexRadius-thickness/2; // wedge thickens up/down from current radius, we have to adjust for that

  for (int i=countryList.size()-1; i>=0; i--) {
    countryList.get(i).drawCategories(timecontroller.year, theta, theta+delta, delta, adjustedRadius, thickness, stackRights);
    theta += delta;
  }
}


void drawRightsCircumplex(Category category) {

  float delta          = TWO_PI/countryList.size(); // +2 to account for US taking up 3 slices
  float theta          = delta/2; // shift by half the width of the US slice so as to center it
  float thickness      = (circumplexRadius-controllerRadius)/category.rights.size();
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
  int numberOfRings   = category.rights.size();
  int numberOfSlices  = countryList.size();
  
  pushStyle();
  noFill();
  stroke(20);
  strokeWeight(borderThickness);
  
  // create rings
  float thickness       = (circumplexRadius-controllerRadius)/numberOfRings;
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
  int numberOfRings   = categoryList.size();
  int numberOfSlices  = countryList.size();
  
  pushStyle();
  noFill();
  stroke(20);
  strokeWeight(borderThickness);
  
  // create rings
  float individualRightThickness = (circumplexRadius-controllerRadius)/numberOfRights;
  float growingRadius            = controllerRadius;
  
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

  float delta           = TWO_PI/countryList.size(); 
  float startTheta      = delta/2; // shift by half the width of the US slice so as to center it
  float thickness       = (circumplexRadius-controllerRadius)/numberOfRights;
  float adjustedRadius  = circumplexRadius-thickness/2; // wedge thickens up/down from current radius, we have to adjust for that

  for (int i=countryList.size()-1; i>=0; i--) {
  
    String name = countryList.get(i).name;
    if(name.equals("United States")) textSize(fontSize*1.5);
    else textSize(fontSize);
    
    float outerRadius   = adjustedRadius + thickness/2;
    float txtStartAngle = (startTheta+delta*0.5) - (getTextLength(name)/outerRadius)*0.5;
    float arclength     = 0; // We must keep track of our position along the curve
  
    for (int j=0; j<name.length(); j++) {
    
      // Instead of a constant width, we check the width of each character.
      String currentChar      = name.substring(j,j+1);
      float  currentCharWidth = textWidth(currentChar);
  
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

  Category category         = categoryList.get(currentCircumplex);
  float    delta            = TWO_PI/countryList.size(); 
  float    startTheta       = -delta/2; // shift by half the width of the US slice so as to center it
  float    thickness        = (circumplexRadius-controllerRadius)/category.rights.size();
  float    adjustedRadius   = circumplexRadius-thickness;
  float    adjustedFontSize = fontSize*15/category.rights.size(); // font size must be inversely proportional to the number of rings 
  String   rightText;
  
  for (int i=category.rights.size()-1; i>=0; i--) {
  
    if(i == highlightedRightIndex) {
      float descriptionFontSize = fontSize*22/largestCategoryLength;
      textFont(monoSpacedBold, descriptionFontSize);
      rightText = category.descriptions.get(i); 
    }
    else {
      textFont(monoSpacedFont, adjustedFontSize);
      rightText = category.rights.get(i);
    }
    
    float textHeight    = textAscent() + textDescent();
    float radius        = adjustedRadius;
    float txtStartAngle = (startTheta+delta*0.5) - (getTextLength(rightText)/radius)*0.5;
    float arclength     = 0; // We must keep track of our position along the curve
  
    for (int j=0; j<rightText.length(); j++) {
    
      // Instead of a constant width, we check the width of each character.
      String currentChar      = rightText.substring(j,j+1);//text.charAt(j);
      float  currentCharWidth = textWidth(currentChar);
  
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
  float delta               = TWO_PI/countryList.size(); 
  float startTheta          = -delta/2; // shift by half the width of the US slice so as to center it
  float rightThickness      = (circumplexRadius-controllerRadius)/numberOfRights;
  float categoryOuterRadius = circumplexRadius;
  float textHeight          = textAscent() + textDescent();

  for (int i=categoryList.size()-1; i>=0; i--) {
      
    String categoryText         = categoryList.get(i).name;
    float categoryThickness     = rightThickness*categoryList.get(i).rights.size();
    float categoryInnerRadius   = categoryOuterRadius-categoryThickness;
    float txtStartAngle         = (startTheta+delta*0.5) - (getTextLength(categoryText)/categoryInnerRadius)*0.5;
    float arclength             = 0; // We must keep track of our position along the curve
      
    for (int j=0; j<categoryText.length(); j++) {
    
      // Instead of a constant width, we check the width of each character.
      String currentChar      = categoryText.substring(j,j+1);
      float  currentCharWidth = textWidth(currentChar);
  
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


int getTextLength(String txt) {

  int totalLength = 0;
  if (txt.length() < 1) return 0;
  else {
    for (int i=0; i<txt.length(); i++) {
      String currentChar = txt.substring(i,i+1); //txt.charAt(i);
      totalLength += textWidth(currentChar);
    } 
    return totalLength;
  }
}


/*********************************************/
/*                PARSE CSVs                 */
/*********************************************/
void parseCategories(String csv) {

  String[] lines          = loadStrings(csv);
  String[] categoryTitles = split(lines[0].replaceAll("\"", ""), ',');

  for (int i=0; i<categoryTitles.length; i++) {
       
    Category category = new Category(categoryTitles[i], categoryColors[i]);
    categoryList.add(category);

    // add all rights to newly created Category object
    for(int j=1; j<lines.length; j++){
    
      String[] row       = split(lines[j], ',');
      String[] rightInfo = split(row[i], " : ");
      
      if(rightInfo[0].length() != 0) {
          String right       = rightInfo[0];
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
  String[] lines   = loadStrings(csv);
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
    String[] row     = split(lines[i], ',');
    String   keyword = row[countryColumnIndex]; // get string in column titled "country"
    Country  value   = countryMap.get(keyword);

    // first time this country was read in table
    if (value == null) {  
      value = new Country(keyword);
      countryMap.put(keyword, value);

      // find all rights available for this country on this year
      Year year      = new Year(int(row[yearColumnIndex]));
      int  naCounter = 0;
      
      for (int j=0, rightIterator=rightColumnIndex; j<rightsColumns.size(); j++, rightIterator++) {
      
        String right             = rightsColumns.get(j);
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
      Year year      = new Year(int(row[yearColumnIndex]));
      int  naCounter = 0;
      
      for (int j=0, rightIterator=rightColumnIndex; j<rightsColumns.size(); j++, rightIterator++) {
      
        String right             = rightsColumns.get(j);
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
    float r                 = circumplexRadius;
    float x                 = width/2;
    float y                 = height/2;
    
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

  float disX = width/2  - mouseX;
  float disY = height/2 - mouseY;
  
  // check if circumplex should be rotated
  if(sqrt(sq(disX) + sq(disY)) > controllerRadius && sqrt(sq(disX) + sq(disY)) < circumplexRadius) {
     // get the angle from the center to the mouse position
    mouseStartAngle = atan2(mouseY - height/2, mouseX - width/2);
  }
  
  // highlight right ring when clicked wedge is selected via mouse press
  if(currentCircumplex == categoryList.size()){
  
    float rightThickness = (circumplexRadius-controllerRadius)/numberOfRights;
    float r              = circumplexRadius;
    
    for(int i=categoryList.size()-1; i>=0; i--) {
    
      float categoryThickness = rightThickness*categoryList.get(i).rights.size();
      if (sqrt(sq(disX) + sq(disY)) > r-categoryThickness && sqrt(sq(disX) + sq(disY)) < r) {
        highlightRing      = true;
        highlightRadius    = r;
        highlightThickness = categoryThickness;
      } 
      r -= categoryThickness;
    }
  } 
  else {
    Category category       = categoryList.get(currentCircumplex);
    float    rightThickness = (circumplexRadius-controllerRadius)/category.rights.size();
    float    r              = circumplexRadius;
    
    for(int i=category.rights.size()-1; i>=0; i--) {
    
      if (sqrt(sq(disX) + sq(disY)) > r-rightThickness && sqrt(sq(disX) + sq(disY)) < r) {
        highlightRing         = true;
        highlightRadius       = r;
        highlightThickness    = rightThickness;
        highlightedRightIndex = i;
      } 
      r -= rightThickness;
    }
  }
  
  timecontroller.timelineTickClicked(width/2, height/2);
}


void mouseReleased(){

  timecontroller.timelineActive = false;
  highlightRing                 = false;
  highlightedRightIndex         = -1;
}


void mouseDragged(){

  // check if circumplex should be rotated
  float disX = width/2  - mouseX;
  float disY = height/2 - mouseY;
  
  if(sqrt(sq(disX) + sq(disY)) > controllerRadius && sqrt(sq(disX) + sq(disY)) < circumplexRadius) {
  
     // get the angle from the center to the mouse position
    float mouseEndAngle = atan2(mouseY - height/2, mouseX - width/2);
    float angleOffset   = mouseEndAngle - mouseStartAngle;
    
    circumplexRotationAngle += angleOffset;
    mouseStartAngle          = mouseEndAngle;  
  } 
}


/*********************************************/
/*       PDE/JAVASCRIPT COMMUNICATION        */
/*********************************************/
function generateButtonTreeLinks(listSize, borderColor){
  var buttonIframe = window.parent.document.getElementById('controlsDiv1');
  var buttonDiv = buttonIframe.contentWindow.document.getElementById('buttonDiv');
  var rootTable = document.createElement('TABLE');
  rootTable.style.width = "40%";
  var childTableCellHeight = 100/((listSize-1)*2); // as percentage
  rootTable.style.height = 100 - childTableCellHeight*2 + "%"; 
  rootTable.style.position = "absolute";
  rootTable.style.top = childTableCellHeight + "%"; 
  rootTable.style.left = "10%";
  rootTable.style.borderRight = "1px solid " + borderColor;
  
  var rootTableBody = document.createElement('TBODY');
  rootTable.appendChild(rootTableBody); 
  
  for (var i=0; i<6; i++){
     var tr = document.createElement('TR');
     rootTableBody.appendChild(tr);
     var td = document.createElement('TD');
     if(i==2) { td.style.borderBottom = "1px solid " + borderColor; }
     tr.appendChild(td);
  }
  buttonDiv.appendChild(rootTable);  
  
  var childrenTable = document.createElement('TABLE');
  childrenTable.style.width = "35%";
  childrenTable.style.height = "100%";
  childrenTable.style.position = "absolute";
  childrenTable.style.top = "0%";
  childrenTable.style.left = "50%";
  childrenTable.style.border = "none";
  
  var childrenTableBody = document.createElement('TBODY');
  childrenTable.appendChild(childrenTableBody);
    
  for (var i=0; i<(listSize-1)*2; i++){
     var tr = document.createElement('TR');
     childrenTableBody.appendChild(tr);
     var td = document.createElement('TD');
     if((i&1) == 0) { td.style.borderBottom = "1px solid " + borderColor; }
     tr.appendChild(td);
  }
  buttonDiv.appendChild(childrenTable);    
}

function generateButtonTree(listSize){      
  var buttonIframe = window.parent.document.getElementById('controlsDiv1');
  var buttonDiv = buttonIframe.contentWindow.document.getElementById('buttonDiv');
  
  // center root button within left div using table
  var rootTable = document.createElement('TABLE');
  rootTable.style.width = "35%";
  rootTable.style.height = "100%";
  rootTable.style.position = "absolute";
  rootTable.style.top = "0%";
  rootTable.style.left = "5%";
  rootTable.style.border = "none";
  
  var rootTableBody = document.createElement('TBODY');
  rootTable.appendChild(rootTableBody); 
  
  for (var i=0; i<3; i++){
     var tr = document.createElement('TR');
     rootTableBody.appendChild(tr);
     var td = document.createElement('TD');
     td.style.height = "33.33%";
     
     if(i == 1) {
       var rootButton = document.createElement('div');
       rootButton.appendChild(document.createTextNode("All Categories"));
       rootButton.setAttribute("id", "categoryButton" + (listSize-1));
       rootButton.setAttribute("class", "button");
       rootButton.setAttribute('onclick', 'window.parent.document.getElementById("visDiv1").contentWindow.changeCircumplex("'+(listSize-1)+'")');
       rootButton.style.width = "100%";
       rootButton.style.height = "100%";
       rootButton.style.position = "relative";
       td.appendChild(rootButton);
       
       // calculate svg size (in pixels) based off of button dimensions
       var rootButtonHeight = (buttonIframe.clientHeight)/3; // in px
       var rootButtonWidth  = ((buttonIframe.clientWidth) * 0.35);
       var iconWidth  = min(rootButtonWidth*0.9, rootButtonHeight*0.5);
       var iconHeight = min(rootButtonWidth*0.9, rootButtonHeight*0.5);
       var iconRadius = iconWidth * 0.45;
       var scaler = iconRadius/listSize;
       
       // create circle svgs to represent categories and add them to rootButton
       for(var j=listSize-2; j>=0; j--){
         // create svg to hold category icon
         var categorySVG = document.createElementNS("http://www.w3.org/2000/svg", "svg");
         categorySVG.setAttribute("height", iconHeight);
         categorySVG.setAttribute("width", iconWidth);
         categorySVG.setAttribute("display", "block");
         categorySVG.style.position = "absolute";
         categorySVG.style.top = (rootButtonHeight*0.25)+(rootButtonHeight*0.75-iconHeight)/2 + "px";
         categorySVG.style.left = (rootButtonWidth-iconWidth)/2 + "px";
         
         // add circle elelment to svg
         var categoryCircle = document.createElementNS("http://www.w3.org/2000/svg", "circle");
         categoryCircle.setAttribute("cx",iconWidth/2);
         categoryCircle.setAttribute("cy",iconHeight/2);
         categoryCircle.setAttribute("r", iconRadius);
         categoryCircle.setAttribute("stroke", "#000000");
         categoryCircle.setAttribute("stroke-width", "1");
         categoryCircle.setAttribute("fill", "#" + hex(categoryList.get(j).colour, 6));
         categorySVG.appendChild(categoryCircle);
    
         // add icon to button
         rootButton.appendChild(categorySVG);
         
         // shrink next circle to creat concentric icon
         iconRadius -= scaler;
       }
     }
     tr.appendChild(td);
  }
  buttonDiv.appendChild(rootTable);   
  
  // create table to hold category buttons
  var childrenTable = document.createElement('TABLE');
  childrenTable.style.width = "35%";
  childrenTable.style.height = "100%";
  childrenTable.style.position = "absolute";
  childrenTable.style.top = "0%";
  childrenTable.style.left = "60%";
  childrenTable.style.border = "none";
  
  var childrenTableBody = document.createElement('TBODY');
  childrenTable.appendChild(childrenTableBody);
    
  // generate a button for each category in the csv file
  for (var i=0; i<listSize-1; i++){
     var tr = document.createElement('TR');
     childrenTableBody.appendChild(tr);
     var td = document.createElement('TD');
     td.style.height = 100/(listSize-1) + "%";
     
     var childButton = document.createElement('div');
     childButton.appendChild(document.createTextNode(categoryList.get(i).name));
     childButton.setAttribute("id", "categoryButton" + (listSize-1));
     childButton.setAttribute("class", "button");
     childButton.setAttribute('onclick', 'window.parent.document.getElementById("visDiv1").contentWindow.changeCircumplex("'+i+'")');
     childButton.style.width = "100%";
     childButton.style.height = "50%";
     childButton.style.position = "relative";
     
     // calculate svg size (in pixels) based off of button dimensions
     var childButtonHeight = ((buttonIframe.clientHeight)/(listSize-1))*0.5; // in px
     var childButtonWidth  = ((buttonIframe.clientWidth) * 0.35);
     var iconWidth  = min(childButtonHeight * 0.5, childButtonWidth * 0.5);
     var iconHeight = min(childButtonHeight * 0.5, childButtonWidth * 0.5);
     var iconRadius = iconWidth * 0.4;
          
     // create svg to hold category icon
     var categorySVG = document.createElementNS("http://www.w3.org/2000/svg", "svg");
     categorySVG.setAttribute("height", iconHeight);
     categorySVG.setAttribute("width", iconWidth);
     categorySVG.setAttribute("display", "block");
     categorySVG.style.position = "absolute";
     categorySVG.style.top = "50%";
     categorySVG.style.left = (childButtonWidth-iconWidth)/2 + "px";
     
     // add circle elelment to svg
     var categoryCircle = document.createElementNS("http://www.w3.org/2000/svg", "circle");
     categoryCircle.setAttribute("cx",iconWidth/2);
     categoryCircle.setAttribute("cy",iconHeight/2);
     categoryCircle.setAttribute("r", iconRadius);
     categoryCircle.setAttribute("stroke", "#000000");
     categoryCircle.setAttribute("stroke-width", "1");
     categoryCircle.setAttribute("fill", "#" + hex(categoryList.get(i).colour, 6));
     categorySVG.appendChild(categoryCircle);

     // add icon to button
     childButton.appendChild(categorySVG);
     td.appendChild(childButton);
     tr.appendChild(td);
  }
  buttonDiv.appendChild(childrenTable);    
}
  
  
function setCanvasSize(){
  var browserWidth    = window.innerWidth;
  var browserHeight   = window.innerHeight;
  sketchWidth         = browserWidth;
  sketchHeight        = browserHeight * 0.99;  
}


void setCircumplexFromJS(int circumplexID){
  currentCircumplex = circumplexID;
}
