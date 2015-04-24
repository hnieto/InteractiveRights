// Title: Interactive Rights, Radial Bar Graph
// Description: Cross-Country Comparison of Adopted Constitutional Rights Across Time
// Developed By: Heriberto Nieto
//               Texas Advanced Computing Center
// Modified by:  Luis Francisco-Revilla

/* @pjs font='../data/RefrigeratorDeluxeLight.ttf, ../data/MonoSpaced.ttf, ../data/MonoSpacedBold.ttf, ../data/Digital.ttf'; */

import java.util.Map;
HashMap<String, Country> countryMap          = new HashMap<String, Country>();
HashMap<String, ArrayList<Country>> groups   = new HashMap<String, ArrayList<Country>>();
ArrayList<Country>       visualizedCountries = new ArrayList<Country>();
ArrayList<Country>       allCountries        = new ArrayList<Country>();
ArrayList<Category>      categoryList        = new ArrayList<Category>();
ArrayList<String>        rightsColumns       = new ArrayList<String>();

TimeController           timecontroller;
int[]                    yearRange = new int[2];
int                      currentCircumplex, numberOfRights;
float                    controllerRadius, circumplexRadius, shortestDistanceFromCenter, paddingTop;
float                    circumplexRotationAngle, mouseStartAngle, canvasAngle;
float                    highlightRadius, highlightThickness, highlightedRightIndex, highlightedCategoryIndex;
int                      borderThickness, largestCategoryLength;

PFont                    defaultFont, monoSpacedFont, monoSpacedBold, digitalFont;
int                      fontSize;

color[]                  categoryColors = new color[7];
color                    background_color, letter_color, wedgeBorder_color;

float                    cursorX, cursorY; // generic variable to hold either touch or mouse location
float                    sketchWidth, sketchHeight;

boolean                  dragMode      = false;
boolean                  highlightRing = false;
boolean                  rotateVis     = false;
boolean                  longTouch     = false;
boolean                  onMobile      = false;
float                    mouseAngle    = 0.0;

/*********************************************/
/*            Initialization                 */
/*********************************************/
void setup() {
  // colors
  categoryColors[6]          = #113C5D; // outer
  categoryColors[5]          = #76A0D5; 
  categoryColors[4]          = #54A88D;      
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
  canvasAngle                = 0.0;
  mouseStartAngle            = 0.0;
  highlightRadius            = 0.0;
  highlightThickness         = 0.0;
  highlightedRightIndex      = -1;
  highlightedCategoryIndex   = -1;
  borderThickness            = 1;

  // javascript function to set sketch size according to the width of the browser
  setCanvasSize();
  size(sketchWidth, sketchHeight, P2D);
  paddingTop                 = sketchHeight * 0.05; 

  // font stuff
  fontSize                   = lerp(0, 20, sketchWidth/2596); // 2596 == 67% of 4K horizontal resolution
  defaultFont                = createFont("../data/RefrigeratorDeluxeLight.ttf", fontSize);
  monoSpacedFont             = createFont("../data/MonoSpaced.ttf", fontSize); 
  monoSpacedBold             = createFont("../data/MonoSpacedBold.ttf", fontSize);
  digitalFont                = createFont("../data/Digital.ttf", fontSize*9);
  textAlign(CENTER);
  textFont(defaultFont);

  // parsing
  if(onMobile) {
    parseCategories("../data/reduced_categorization_02232015.csv");
    parseRights("../data/rights_mobile.csv");
  }
  else {
    parseCategories("../data/substantive_categorization_021514.csv");
    parseRights("../data/rights.csv");
  }
  parseSnippets("../data/snippets_021514.csv");
  
  // time controls
  shortestDistanceFromCenter = min(width, height)/2;
  circumplexRadius           = shortestDistanceFromCenter-(textAscent() + textDescent())-paddingTop; // account for letter height and add some extra padding
  controllerRadius           = shortestDistanceFromCenter/3;
  timecontroller             = new TimeController(controllerRadius, yearRange);
  timecontroller.init();
  parseGroups("../data/region_group.csv"); // groups have different time ranges so we have to call this function once timecontroller has been initialized 

  // javascript function to create HTML elements
  generateAlphabetList();
  generateCountryList();
  generateDescription();

  // set "All Rights" view as default
  currentCircumplex          = categoryList.size();
 
  // let javascript know that this vis is ready to draw
  readyToDraw();
  
  // do not draw anything until vis is selected in html
  noLoop(); 
}

/*********************************************/
/*             MAIN DRAW LOOP                */
/*********************************************/
void draw() {  
  background(background_color);
  
  pushMatrix();
  translate(width/2, height/2);
  
  // render empty wheel. no countries, just rights
  if(visualizedCountries.size() == 0) {
    if (currentCircumplex == categoryList.size()) {
      drawEmptyCategoryCircumplex();
    }
    
    else {
      drawEmptyRightsCircumplex(categoryList.get(currentCircumplex));
      drawCategoryRing();
    }
  
    pushStyle();
    if(!rotateVis){
      if (currentCircumplex == categoryList.size()) drawCategoryNames();
      else drawRightNames();
    }
    popStyle();
    
    pushMatrix();
    rotate(-canvasAngle);
    timecontroller.drawEmpty(); 
    popMatrix();
  }
  
  // render populated wheel
  else {
    // draw grey circle behind slices 
    // used to show country existence
    fill(15);
    noStroke();
    ellipse(0, 0, circumplexRadius*2, circumplexRadius*2);
    
    // draw circle behind controller with same color as background
    // required to offset the grey circle drawn behind slices
    fill(background_color);
    noStroke();
    ellipse(0, 0, controllerRadius*2, controllerRadius*2);  
    
    if (currentCircumplex == categoryList.size()) {
      drawCategoryCircumplex();
    }
    
    else { 
      drawRightsCircumplex(categoryList.get(currentCircumplex));
      drawCategoryRing();
    } 
    drawCountryNames();
  
    pushStyle();
    if(!rotateVis){
      if (currentCircumplex == categoryList.size()) drawCategoryNames();
      else drawRightNames();
    }
    popStyle();
  
    if (highlightRing) {
      pushStyle();
      noFill();
      stroke(200, 50);
      strokeWeight(highlightThickness);
      ellipse(0, 0, (highlightRadius-highlightThickness/2)*2, (highlightRadius-highlightThickness/2)*2);
      popStyle();
    }
  
    pushMatrix();
    rotate(-canvasAngle);
    timecontroller.draw(); 
    timecontroller.update();
    popMatrix(); 
  }
  
  popMatrix();
   
}

/*********************************************/
/*            RENDER CIRCUMPLEX              */
/*********************************************/

void drawCategoryRing() {
  float delta          = TWO_PI/(categoryList.size()+1);  // add slice for "All Categories" button
  float angle          = 0.0; 
  float ringThickness  = (controllerRadius-timecontroller.containerRadius) * 0.45;
  float ringRadius     = controllerRadius*0.95 - ringThickness/2;
  
  // Ring Geometry
  pushStyle();
  for (int i=0; i<=categoryList.size(); i++) {
    if(i == categoryList.size()) {
      color categoryColor = #DBD62C;
      strokeCap(SQUARE);
      strokeWeight(ringThickness);
      stroke(categoryColor, 100);
      arc(0, 0, ringRadius*2, ringRadius*2, angle+0.1, angle+delta-0.1);  
      angle += delta;
    }
    
    else {                   
      color categoryColor = categoryList.get(i).colour;
      strokeCap(SQUARE);
      strokeWeight(ringThickness);
      stroke(categoryColor, 100);
      arc(0, 0, ringRadius*2, ringRadius*2, angle, angle+delta);  
      angle += delta;
    }
  }  
  angle = 0.0; // reset for category label calculations
  popStyle(); 
  
  // Category Labels
  textSize(fontSize);
  float textHeight    = textAscent() + textDescent();
  float  labelRadius   = (ringRadius - ringThickness/2) + (ringThickness - textHeight)/2; //ringRadius - ringThickness/2;
  for (int i=0; i<=categoryList.size(); i++) {
    if(i == categoryList.size()) String label = "ALL CATEGORIES";
    else                         String label = categoryList.get(i).name;

    float  txtStartAngle = (angle+delta*0.5) - (getTextLength(label)/ringRadius)*0.5;
    float  arclength     = 0.0; // We must keep track of our position along the curve
    for (int k=0; k<label.length(); k++) {

      // Instead of a constant width, we check the width of each character.
      String currentChar      = label.substring(k, k+1);
      float  currentCharWidth = textWidth(currentChar);

      // Each box is centered so we move half the width
      arclength += currentCharWidth/2;

      // Angle in radians is the arclength divided by the radius
      // Starting on the left side of the circle by adding PI
      float theta = arclength / labelRadius;    

      pushMatrix();

      // position text starting from given angle
      rotate(txtStartAngle);

      // Polar to cartesian coordinate conversion
      translate(labelRadius*cos(theta), labelRadius*sin(theta));

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
    
    angle += delta;        
  } 
}

void drawEmptyCategoryCircumplex() {
  
  // styles
  fill(background_color);
  stroke(255, 100);
  
  // circle separating time controller and first category ring
  ellipse(0,0,circumplexRadius*2, circumplexRadius*2);

  float rightThickness = (circumplexRadius-controllerRadius)/numberOfRights;
  float currentRadius    = circumplexRadius;
  for (int i=categoryList.size()-1; i>=0; i--) {
    Category category       = categoryList.get(i);
    float categoryThickness = rightThickness*category.rights.size();
    currentRadius           = currentRadius - categoryThickness;
    ellipse(0, 0, currentRadius*2, currentRadius*2);
  }
}


void drawEmptyRightsCircumplex(Category category) {

  // styles
  fill(background_color);
  stroke(255, 100);
  
  // circle separating time controller and first category ring
  ellipse(0,0,circumplexRadius*2, circumplexRadius*2);

  float rightThickness = (circumplexRadius-controllerRadius)/category.rights.size();
  float currentRadius  = circumplexRadius;
  for (int i=0; i<category.rights.size(); i++) {
    currentRadius      = currentRadius - rightThickness;
    ellipse(0, 0, currentRadius*2, currentRadius*2);
  }
}

void drawCategoryCircumplex() {
  
  float delta          = TWO_PI/visualizedCountries.size();  
  float theta          = 0.0; 
  float rightThickness = (circumplexRadius-controllerRadius)/numberOfRights;

  for (int i=0; i<visualizedCountries.size(); i++) {
    Country countryObject = visualizedCountries.get(i);
    countryObject.drawCategories(timecontroller.year, theta, theta+delta, controllerRadius, rightThickness); 
    theta += delta;
  }
}


void drawRightsCircumplex(Category category) {

  float delta          = TWO_PI/visualizedCountries.size(); 
  float theta          = 0.0;
  float rightThickness = (circumplexRadius-controllerRadius)/category.rights.size();

  for (int i=0; i<visualizedCountries.size(); i++) {
    Country countryObject = visualizedCountries.get(i);
    countryObject.drawRights(category, timecontroller.year, theta, theta+delta, controllerRadius, rightThickness); 
    theta += delta;
  }
}


/*********************************************/
/*              OVERLAYS                     */
/*********************************************/

void drawCountryNames() {   
  if(visualizedCountries.size()>30) textSize(fontSize);
  else textSize(fontSize*2);
  float delta           = (visualizedCountries.size() > 1) ? TWO_PI/visualizedCountries.size() : 3*PI; 
  float startTheta      = 0.0;
  float thickness       = (circumplexRadius-controllerRadius)/numberOfRights;
  
  for (int i=0; i<visualizedCountries.size(); i++) {
    Country countryObject = visualizedCountries.get(i);
    String[] name = (visualizedCountries.size()>30) ? {countryObject.name.toUpperCase()} : {countryObject.name.toUpperCase(), countryObject.existence[0] + " - " + countryObject.existence[1]};
    float outerRadius         = circumplexRadius + thickness*4;
    float outerRadiusReversed = circumplexRadius + thickness*9;

    for (int j=0; j<name.length; j++) {
      float txtStartAngle = (startTheta+delta*0.5) - (getTextLength(name[j])/outerRadius)*0.5;
      float arclength     = 0; // We must keep track of our position along the curve
      
      // compensate for html canvas rotation
      float adjustedTxtStartAngle = txtStartAngle;
      if(canvasAngle > 0) adjustedTxtStartAngle = (adjustedTxtStartAngle+canvasAngle > TWO_PI) ? (adjustedTxtStartAngle+canvasAngle)-TWO_PI : adjustedTxtStartAngle+canvasAngle;
      else                adjustedTxtStartAngle = (adjustedTxtStartAngle+canvasAngle < 0)      ? TWO_PI-(adjustedTxtStartAngle+canvasAngle) : adjustedTxtStartAngle+canvasAngle;
    
      // flip text if country is on lower hemisphere
      if(adjustedTxtStartAngle > 0 && adjustedTxtStartAngle < PI) {
        for (int k=name[j].length(); k>=0; k--) {
    
          // Instead of a constant width, we check the width of each character.
          String currentChar      = name[j].substring(k, k+1);
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
          translate(outerRadiusReversed*cos(theta), outerRadiusReversed*sin(theta));
    
          // Rotate the box
          rotate(theta-PI/2);
    
          // Display the character
          pushStyle(); //<>//
          if(j==0 && name.length>1) textSize(fontSize*2); //<>// //<>//
          else textSize(fontSize);
          fill(letter_color);
          text(currentChar, 0, 0);
          popStyle();
    
          popMatrix();
    
          // Move halfway again
          arclength += currentCharWidth/2;
          
        }   
        // reduce radius to draw year under country name
        outerRadiusReversed -= thickness*6;          
      }
      
      else {
        for (int k=0; k<name[j].length(); k++) {
    
          // Instead of a constant width, we check the width of each character.
          String currentChar      = name[j].substring(k, k+1);
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
          if(j==0 && name.length>1) textSize(fontSize*2);
          else textSize(fontSize);
          fill(letter_color);
          text(currentChar, 0, 0);
          popStyle();
    
          popMatrix();
    
          // Move halfway again
          arclength += currentCharWidth/2;
          
        }  
        // reduce radius to draw year under country name
        outerRadius -= thickness*3.5;        
      }       
    }

    startTheta += delta;
  }
  
}


void drawCategoryNames() {

  textSize(fontSize*3);
  float delta                = (visualizedCountries.size() > 0) ? TWO_PI/visualizedCountries.size() : TWO_PI; 
  float startTheta           = -HALF_PI - delta/2 - canvasAngle; 
  float rightThickness       = (circumplexRadius-controllerRadius)/numberOfRights;
  float categoryInnerRadius  = controllerRadius + borderThickness; // compensate for border thickness
  float textHeight           = textAscent() + textDescent();

  for (int i=0; i<categoryList.size(); i++) {

    String categoryText         = categoryList.get(i).name;
    float  categoryThickness    = rightThickness*categoryList.get(i).rights.size();
    float  txtStartAngle        = (startTheta+delta*0.5) - (getTextLength(categoryText)/categoryInnerRadius)*0.5;
    float  arclength            = 0; // We must keep track of our position along the curve

    for (int j=0; j<categoryText.length(); j++) {

      // Instead of a constant width, we check the width of each character.
      String currentChar      = categoryText.substring(j, j+1);
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

      if (i == highlightedCategoryIndex) fill(255, 255, 0, 150);
      else fill(letter_color, 150);

      text(currentChar, 0, 0);
      popStyle();

      popMatrix();

      // Move halfway again
      arclength += currentCharWidth/2;
    }

    categoryInnerRadius += categoryThickness;
  }
}


void drawRightNames() {

  Category category         = categoryList.get(currentCircumplex);
  float    delta            = (visualizedCountries.size() > 0) ? TWO_PI/visualizedCountries.size() : TWO_PI; 
  float    startTheta       = -HALF_PI - delta/2 - canvasAngle; 
  float    thickness        = (circumplexRadius-controllerRadius)/category.rights.size();
  float    innerRadius      = controllerRadius;
  float    adjustedFontSize = fontSize*26/largestCategoryLength; 
  String   rightText;

  for (int i=0; i<category.rights.size(); i++) {

    textSize(adjustedFontSize);
    if (i == highlightedRightIndex) rightText = category.descriptions.get(i);
    else rightText = category.rights.get(i);
    
    float textHeight    = textAscent() + textDescent();
    float radius        = innerRadius + (thickness - textHeight)/2;
    float txtStartAngle = (startTheta+delta*0.5) - (getTextLength(rightText)/radius)*0.5;
    float arclength     = 0; // We must keep track of our position along the curve

    for (int j=0; j<rightText.length(); j++) {

      // Instead of a constant width, we check the width of each character.
      String currentChar      = rightText.substring(j, j+1);//text.charAt(j);
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

      if (i == highlightedRightIndex) fill(255, 255, 0, 150);
      else fill(letter_color, 150);

      text(currentChar, 0, 0);
      popStyle();

      popMatrix();

      // Move halfway again
      if(onMobile) arclength += currentCharWidth/2;
      else arclength += currentCharWidth;
    }

    innerRadius += thickness;
  }
}


int getTextLength(String txt) {

  int totalLength = 0;
  if (txt.length() < 1) return 0;
  else {
    for (int i=0; i<txt.length(); i++) {
      String currentChar = txt.substring(i, i+1); //txt.charAt(i);
      totalLength += textWidth(currentChar);
    } 
    return totalLength;
  }
}


/*********************************************/
/*                PARSE CSVs                 */
/*********************************************/

void parseCategories(String csv) {  
  largestCategoryLength   = 0;
  String[] lines          = loadStrings(csv);
  String[] categoryTitles = split(lines[0], '|');

  for (int i=0; i<categoryTitles.length; i++) {

    Category category = new Category(categoryTitles[i], categoryColors[i]);
    categoryList.add(category);

    // add all rights to newly created Category object
    for (int j=1; j<lines.length; j++) {
      String[] row       = split(lines[j], '|');
      String[] rightInfo = split(row[i], " : ");

      if (rightInfo[0].length() != 0) {
        String right       = rightInfo[0];
        String description = rightInfo[1];
        if (right.length() != 0) {
          category.addRight(right);
          category.addRightDescription(description); 
          numberOfRights++;
        }
      }
    }

    // determine number of rights in largest category, used to calculate font size for right description 
    if (category.rights.size() > largestCategoryLength) largestCategoryLength = category.rights.size();
    
  }
}


void parseRights(String csv) {
  // reads CSV header column and returns only the Right strings
  String[] rows                = loadStrings(csv);
  String[] columns             = split(rows[0].replaceAll("\"", ""), ',');
  int countryColumnIndex       = 0;
  int yearColumnIndex          = 1;
  int endYearColumnIndex       = 2;
  int adoptedRightsColumnIndex = 3;
  int rightColumnIndex         = 4;
  
  // get all column headers that follow the column "Human Dignity"
  for (int i=rightColumnIndex; i<columns.length; i++) {
    rightsColumns.add(columns[i]);
  }

  // parse rights.csv and use rightsColumn array to filter results
  for (int i=1; i<rows.length; i++) {
    String[] row                = split(rows[i], ',');
    int      numOfAdoptedRights = int(row[adoptedRightsColumnIndex]);
    int      currentYear        = int(row[yearColumnIndex]);
           
    String   countryName        = row[countryColumnIndex]; // get string in column titled "country"
    Country  countryObject      = countryMap.get(countryName);

    // first time this country was read in table
    if (countryObject == null) {  
      String[] yearsOfExistence = { row[yearColumnIndex], row[endYearColumnIndex] };
      countryObject             = new Country(countryName, yearsOfExistence);
      countryMap.put(countryName, countryObject);
      allCountries.add(countryObject);
    }
      
    // find all rights available for this country on this year
    Year year = new Year(currentYear);

    if(numOfAdoptedRights > 0) { // skip years that have no rights
      for (int j=0, rightIterator = rightColumnIndex; j<rightsColumns.size(); j++, rightIterator++) {

        String right              = rightsColumns.get(j);
        String rightAvailability  = row[rightIterator];

        if (rightAvailability.equals("1. yes") || rightAvailability.equals("2. full") || rightAvailability.equals("1. conditional")) {
          year.addRight(right);
          year.addCateogry(findCategoryForRight(right));
        }     
      }
      
      countryObject.addYear(year);
      countryObject.addYear((Integer)currentYear, year);
    }            
  }  
}


void parseGroups(String csv) {
  // get the HTML table ready
  // we'll populate it with the group names
  var table = document.getElementById("groupTable");
  ArrayList<String> groupNames = new ArrayList<String>();
  
  String rows[] = loadStrings(csv);
  for (int i = 0 ; i < rows.length; i++) {
    String cols = split(rows[i], ',');
    String groupName = cols[0];
    ArrayList<Country> groupEntries = new ArrayList<Country>();
    for (int j = 1; j < cols.length; j++) {
      Country countryObject = countryMap.get(cols[j]);
      if (countryObject != null) groupEntries.add(countryObject);
    }
    groupNames.add(groupName);
    groups.put(groupName, groupEntries);
    
    // add a new cell to the table for every group in the csv
    var newRow      = table.insertRow(-1);
    var newCell     = newRow.insertCell(-1);
    newCell.innerHTML = groupName;    
  }
  
  // set random group as default
  String randGroup = groupNames.get((int)random(groupNames.size()));
  loadNewGroup(groups.get(randGroup));
}


void parseSnippets(String csv) {
  int startTime = millis();
  
  String[] rows           = loadStrings(csv);

  for (int i=1; i<rows.length; i++) {
    String constitution   = split(rows[i], '|')[3];
    String right          = split(rows[i], '|')[1];
    String snippetText    = split(rows[i], '|')[4];
    //String countryName    = split(constitution, '_')[0];
    String[] detailedCountryName = split(constitution, '_');
    String simpleCountryName = detailedCountryName[0]; //join(subset(detailedCountryName, 0, detailedCountryName.length-1), " ");
    
    Country countryObject = countryMap.get(simpleCountryName);
    if (countryObject != null) {
      String snippet = countryObject.snippets.get(right);
      if (snippet == null) {
         countryObject.snippets.put(right, snippetText);
      }
    }      
  }
  
//  println("Parse Categories - Elapsed Time: " + (millis()-startTime)/1000);
}


// find the category that a right belongs to
Category findCategoryForRight(String rightToSearch) {

  for (int i=0; i<categoryList.size(); i++) {
    Category category = categoryList.get(i);
    if (category.rights.contains(rightToSearch)) return category;
  }
  return null;
}


/*********************************************/
/*       MOUSE/KEYBOARD INTERACTION          */
/*********************************************/

void cursorDown(float x, float y){
 
  cursorX    = x;
  cursorY    = y;
  
  float disX = width/2  - cursorX;
  float disY = height/2 - cursorY;

  if(visualizedCountries.size() > 0) {
    // highlight Category  
    if (currentCircumplex == categoryList.size()) {
  
      float rightThickness = (circumplexRadius-controllerRadius)/numberOfRights;
      float r              = circumplexRadius;
  
      for (int i=categoryList.size()-1; i>=0; i--) {
  
        float categoryThickness = rightThickness*categoryList.get(i).rights.size();
        if (sqrt(sq(disX) + sq(disY)) > r-categoryThickness && sqrt(sq(disX) + sq(disY)) < r) {
          highlightRing            = true;
          highlightRadius          = r;
          highlightThickness       = categoryThickness;
          highlightedCategoryIndex = i;
        } 
        r -= categoryThickness;
      }
    } 
    
    // highlight Right  
    else {
      Category category       = categoryList.get(currentCircumplex);
      float    rightThickness = (circumplexRadius-controllerRadius)/category.rights.size();
      float    r              = circumplexRadius;
  
      for (int i=category.rights.size()-1; i>=0; i--) {
  
        if (sqrt(sq(disX) + sq(disY)) > r-rightThickness && sqrt(sq(disX) + sq(disY)) < r) {
          highlightRing         = true;
          highlightRadius       = r;
          highlightThickness    = rightThickness;
          highlightedRightIndex = i;
        } 
        r -= rightThickness;
      }
    }
  }
  
  // check for category change via radial menu
  float _ringThickness          = (controllerRadius-timecontroller.containerRadius) * 0.45;

  if (sqrt(sq(disX) + sq(disY)) <= controllerRadius*0.95 && sqrt(sq(disX) + sq(disY)) >= controllerRadius*0.95-_ringThickness) {
    // turn highlighted ring off when switching circumplexes 
    highlightRing            = false;
    highlightedRightIndex    = -1;
    highlightedCategoryIndex = -1;
    
    float delta          = TWO_PI/(categoryList.size()+1);  // add slice for "All Categories" button
    float ringAngle      = 0.0; 

    // determine which button on ring menu was selected
    for (int i=0; i<=categoryList.size(); i++) {
       if(mouseAngle > ringAngle && mouseAngle < ringAngle+delta) {
         if(i == categoryList.size()) currentCircumplex = categoryList.size();
         else currentCircumplex = i;
         break;
       }
       ringAngle += delta;
    }  
  } 

  timecontroller.timelineTickClicked(width/2, height/2);
}

void cursorMove(float x, float y){
  cursorX    = x;
  cursorY    = y;
}


void cursorUp(float x, float y){

  cursorX    = x;
  cursorY    = y;

  float disX = width/2 - cursorX;
  float disY = height/2 - cursorY;

  timecontroller.playButtonClicked(width/2, height/2);
  timecontroller.ffButtonClicked(width/2, height/2);
  timecontroller.rewindButtonClicked(width/2, height/2);

  // if in "All Rights" circumplex, check for category selection via mouse click
  if (currentCircumplex == categoryList.size() && !dragMode) {

    float rightThickness    = (circumplexRadius-controllerRadius)/numberOfRights;
    float r                 = circumplexRadius;

    for (int i=categoryList.size()-1; i>=0; i--) {
      float categoryThickness = rightThickness*categoryList.get(i).rights.size();
      if (sqrt(sq(disX) + sq(disY)) > r-categoryThickness && sqrt(sq(disX) + sq(disY)) < r) {
        highlightRing = false; // no need to keep ring highlighted if changing to different circumplex
        currentCircumplex = i;
      } 
      r -= categoryThickness;
    }
  }
  
  dragMode                      = false;
  timecontroller.timelineActive = false;
}


/*********************************************/
/*         PDE/JAVASCRIPT FUNCTIONS          */
/*********************************************/  

function setCanvasSize() {
  var browserWidth     = window.innerWidth;
  var browserHeight    = window.innerHeight;
  sketchWidth          = browserWidth * 0.5;
  sketchHeight         = browserHeight;
  
  var fourK = 8294400;
  if(screen.width*screen.height < fourK) onMobile = true; 
}


function generateAlphabetList() {
  var lettersDiv   = document.getElementById('letters');
  
  int  letterCount = 0;
  char prevLetter  = '';
  char currLetter;
  
  for (int i=0; i<allCountries.size(); i++) {
    Country countryObject = allCountries.get(i);
    
    currLetter = countryObject.name.charAt(0);
    if(prevLetter != currLetter) {
       var letterButton  = document.createElement('div');
       letterButton.className = "letter";
       letterButton.appendChild(document.createTextNode(str(currLetter)));
       lettersDiv.appendChild(letterButton);
       prevLetter = currLetter;
       letterCount++;
    }
  } 
 
  var letterHeight = (lettersDiv.offsetHeight-letterCount)/letterCount;
  var allLetters = document.querySelectorAll(".letter");
   
  for (var i = 0; i < allLetters.length; i++) {
      allLetters[i].style.height     = letterHeight + "px";
      allLetters[i].style.lineHeight = letterHeight + "px";
  } 
}

function goToLetter(id) {
    console.log(id);
    document.getElementById(id).scrollIntoView();
}


function generateCountryList () {
  var list = document.getElementById('countryList'); 
  list.innerHTML = "";
  
  char prevLetter = '';
  char currLetter;
  
  for (int i=0; i<allCountries.size(); i++) {
    Country countryObject = allCountries.get(i);
    
    // insert letter indicator 
    currLetter = countryObject.name.charAt(0);
    if(prevLetter != currLetter) {
       var letterElement = document.createElement('li');
       letterElement.id = str(currLetter);
       letterElement.style.backgroundColor = "rgba(18,18,18,0.8)";
       letterElement.innerHTML = '<p id="letterIndicator">' + str(currLetter) + '</p>'; //'<p id="' + str(currLetter) + '" name="' + str(currLetter) + '"> ' + str(currLetter) + '</p>';
       list.appendChild(letterElement);
       prevLetter = currLetter;
    }
    
    // Create the list item
    var item     = document.createElement('li'); 
    
    // Create addition button
    var plusLink        = document.createElement('a');
    var plusSign        = document.createTextNode('+');
    plusLink.className  = "plus";
    plusLink.appendChild(plusSign);
    plusLink.href = "javascript:addCountry('" + countryObject.name + "');";
    item.appendChild(plusLink);
    
    // Disable addition button if country is already in pie
    if(countryObject.visualize) {
        plusLink.style.background = "rgba(18, 18, 18, 0.4)";
        plusLink.style.color      = "rgba(128, 128, 128, 0.61)";
        plusLink.onclick          = null;
    }
    
    // Create deletion button
    var minusLink        = document.createElement('a');
    var minusSign        = document.createTextNode('-');
    minusLink.className  = "minus";
    minusLink.appendChild(minusSign);
    minusLink.href = "javascript:removeCountry('" + countryObject.name + "');";
    item.appendChild(minusLink);
    
    // Disable deletion button if country is NOT yet in pie
    if(!countryObject.visualize) {
        minusLink.style.background = "rgba(18, 18, 18, 0.4)";
        minusLink.style.color      = "rgba(128, 128, 128, 0.61)";
        minusLink.onclick          = null;
    }

    // country name
    var textElement = document.createElement('p');
    var text    = document.createTextNode(countryObject.name);
    textElement.appendChild(text);
    item.appendChild(textElement);

    // Add it to the list:
    list.appendChild(item);
  }
}


function generateDescription() {
  String[] descriptionText = loadStrings("../web/description.html");
  String   joinedText      = join(descriptionText, " ");
  
  var descriptionDiv = document.getElementById('description'); 
  descriptionDiv.innerHTML = joinedText;
}


void setCircumplexFromJS(int circumplexID) {
  // turn highlighted ring off when switching circumplexes 
  highlightRing            = false;
  highlightedRightIndex    = -1;
  highlightedCategoryIndex = -1;
  
  // change circumplex
  currentCircumplex = circumplexID;
}

void loadNewGroupFromCircle(String groupName) {
  loadNewGroup(groups.get(groupName));
}

void loadNewGroupFromBubbles(String[] groupArray, int categoryID, int newYear, String bubbleRight) {
  setCircumplexFromJS(categoryID);
  timecontroller.year = newYear;
  
  ArrayList<Country> groupList = new ArrayList<Country>();
  for(int i=0; i<groupArray.length; i++) {
    Country countryObject = countryMap.get(groupArray[i]);
    if (countryObject != null) groupList.add(countryObject);
  }
  loadNewGroup(groupList);
}

void loadNewGroup(ArrayList<Country> countryGroup) {    
  
  // no need to do this on the first time around since visualizedCountries hasn't been initialized yet
  if(visualizedCountries != null) {
    // set 'visualize' variable in all country's in current group to 'false'
    // this is needed to properly update the countryList DIV
    for(int i=0; i<visualizedCountries.size(); i++) {
       visualizedCountries.get(i).visualize = false;
    }
  }
    
  // update visualizedCountries w/ newly selected group
  visualizedCountries = countryGroup;
  
  // used to find optimal time range
  int earliestStartYear = 2012;
  int latestEndYear     = 2012;
  
  for(int j=0; j<visualizedCountries.size(); j++) {
    Country countryObject = visualizedCountries.get(j);
    
    int yearCount = countryObject.years.size();
    // only consider the country if it contains at least 1 year with rights
    // new zealand for example has none for every year ?
    if(yearCount > 0) {
      int firstYear = countryObject.years.get(0).number;
      int lastYear  = countryObject.years.get(yearCount-1).number;
     
      if (firstYear < earliestStartYear) earliestStartYear = firstYear; 
      if (lastYear  < latestEndYear)     latestEndYear     = lastYear;
    }
  
    countryObject.visualize = true;
  }
  
  yearRange[0] = earliestStartYear;
  yearRange[1] = latestEndYear;
  timecontroller.updateTimeLine();
  
  generateCountryList();
}


void insertNewCountry(String country) {
  Country  countryObject = countryMap.get(country);
  
  if(!countryObject.visualize) {
     countryObject.recentlyAdded = true; 
     countryObject.savedTime     = millis();
     
     // enable overlays to prevent mulitple country addtitions before animation completes
     // and to disable interrupting the animation by touching the canvas
     document.getElementById('canvasOverlay').style.zIndex          = "1";
     document.getElementById('countryListOverlay').style.background = "rgba(18, 18, 18, 0.4)";
     document.getElementById('countryListOverlay').style.zIndex     = "2";
      
     // disable "Clear All Countries" button
     document.getElementById('clearAllCountries').style.background = "rgba(240, 169, 169, 0.24)";
     document.getElementById('clearAllCountries').style.color      = "gray";
     document.getElementById('clearAllCountries').removeEventListener("touchstart", clearWheelButtonHandler);
     document.getElementById('clearAllCountries').removeEventListener("mousedown",  clearWheelButtonHandler);
     
     // hide "Tutorial" button
     // if not, users may be tempted to click on it as add/remove animation is going on. 
     // this could cause some strange behavior
     document.getElementById('opentour').style.display = "none";
     
     // update year range
     if (countryObject.existence[0] < yearRange[0]) yearRange[0] = countryObject.existence[0]; 
     if (countryObject.existence[1] > yearRange[1]) yearRange[1] = countryObject.existence[1];  
   
     visualizedCountries = insertAndSort(countryObject);  
  }  
}


void deleteCountry(String country) {
  Country  countryObject = countryMap.get(country);
  
  if(countryObject.visualize) {
     countryObject.recentlyRemoved = true;
     countryObject.savedTime     = millis();
     
     // enable overlays to prevent mulitple country deletions before animation completes
     // and to disable interrupting the animation by touching the canvas
     document.getElementById('canvasOverlay').style.zIndex          = "1";
     document.getElementById('countryListOverlay').style.background = "rgba(18, 18, 18, 0.4)";
     document.getElementById('countryListOverlay').style.zIndex     = "2";
     
     // disable "Clear All Countries" button
     document.getElementById('clearAllCountries').style.background = "rgba(240, 169, 169, 0.24)";
     document.getElementById('clearAllCountries').style.color      = "gray";
     document.getElementById('clearAllCountries').removeEventListener("touchstart", clearWheelButtonHandler);
     document.getElementById('clearAllCountries').removeEventListener("mousedown",  clearWheelButtonHandler);
     
     // hide "Tutorial" button
     // if not, users may be tempted to click on it as add/remove animation is going on. 
     // this could cause some strange behavior
     document.getElementById('opentour').style.display = "none";
     
     // update year range after removing country 
//     if (countryObject.existence[0] < yearRange[0]) yearRange[0] = countryObject.existence[0]; 
//     if (countryObject.existence[1] < yearRange[1]) yearRange[1] = countryObject.existence[1];
  }  
}

void clearCircumplex() {
  // turn highlighted ring off when switching circumplexes 
  highlightRing            = false;
  highlightedRightIndex    = -1;
  highlightedCategoryIndex = -1;
  
  for (int i=0; i<visualizedCountries.size(); i++) {
    Country countryObject = visualizedCountries.get(i);
    deleteCountry(countryObject.name);
  }  
}

void rotationOn(float angle) {
  rotateVis   = true; 
  dragMode    = true;
  canvasAngle = angle;
  // noLoop will be called in TimeController class
  // we have to wait until the next draw loop for the time controller to be replaced by arrows  
}

void rotationOff(float angle) {
  rotateVis   = false; 
  if(angle == 0) dragMode = false;
  canvasAngle = angle;  
}

void updateMouseAngle(float angle) {
  mouseAngle = angle;
}

void longTouchTrue(){
  longTouch = true; 
  
  float    delta           = TWO_PI/visualizedCountries.size();  
  float    theta           = 0.0; 
  int      currentYear     = timecontroller.year;
  Category currentCategory = categoryList.get(currentCircumplex);

  for (int i=0; i<visualizedCountries.size(); i++) {
    Country countryObject = visualizedCountries.get(i);
    
    // if country was touched/clicked, then show the excerpt of its constitution that relates to the selected right (if available)
    if(mouseAngle > theta && mouseAngle < theta+delta && highlightedRightIndex > -1 && longTouch) {
      
      snippetRightIndex     = highlightedRightIndex;
      String selectedRight  = currentCategory.rights.get(snippetRightIndex);
      String snippetText    = countryObject.snippets.get(selectedRight);
              
      String snippetTitle, snippet, snippetID, snippetColor;
      
      // country DID NOT exist during this current year. therefore, no consitution exists either
      if(currentYear < int(countryObject.existence[0]) || currentYear > int(countryObject.existence[1])) {
        snippetTitle = '<p id="countryName">' + countryObject.name + ' :&nbsp;' + '</p>' + 
                       '<p id="rightName">' + selectedRight + '</p>';
                       
        snippet      = '<p class="warningTitle">Constitution Excerpt Unavailable</p><p class="warningDetail">' + countryObject.name + '<br>did NOT exist in ' + currentYear + '.</p>';            
      }
    
      // country DID exists during this current year
      else {
        
        // country has rights during this year
        if(countryObject.yearMap.get((Integer)currentYear) != null) { 
          
           // country has selected right during this year
           if (countryObject.yearMap.get((Integer)currentYear).rights.contains(selectedRight)) { 
             
             // unfortunately, we are missing the excerpt 
             if(snippetText == null) {
               snippetTitle = '<p id="countryName">' + countryObject.name + ' :&nbsp;' + '</p>' + 
                             '<p id="rightName">' + selectedRight + '</p>';
                             
               snippet      = '<p class="warningTitle">Constitution Excerpt Unavailable</p><p class="warningDetail">This right is included in ' + countryObject.name + '&#96;s constitution. Unfortunately, our dataset is missing the excerpt.</p>';          
             } 
             
             // excerpt found so show it!
             else {
               snippetTitle = '<p id="countryName">' + countryObject.name + ' :&nbsp;' + '</p>' + 
                             '<p id="rightName">' + selectedRight + '</p>';
                        
               snippet      = snippetText;  
             }         
          }   
    
          // country does NOT have this right during the current year
          else {
            
            // check if maybe the constitution introduced the right later
            int yearIntroduced = -1;
            for (Map.Entry entry : countryObject.yearMap.entrySet()) {
              if(entry.getValue().rights.contains(selectedRight)) {
                yearIntroduced = entry.getKey();
                snippetTitle   = '<p id="countryName">' + countryObject.name + ' :&nbsp;' + '</p>' + 
                                 '<p id="rightName">' + selectedRight + '</p>';
                          
                snippet        = '<p class="warningTitle">Constitution Excerpt Unavailable</p><p class="warningDetail">This right was not introduced until<br>' + yearIntroduced + '.</p>';  
                break;                
              }
            }
            
            // nope. right was never introduced
            if(yearIntroduced == -1) {
              snippetTitle   = '<p id="countryName">' + countryObject.name + ' :&nbsp;' + '</p>' + 
                               '<p id="rightName">' + selectedRight + '</p>';
                        
              snippet        = '<p class="warningTitle">Constitution Excerpt Unavailable</p><p class="warningDetail">This right was was never introduced into<br>' + countryObject.name + '&#96;s constitution.</p>';               
            }
          }      
        } 
        
        // country has NO rights during this year
        else {
          snippetTitle = '<p id="countryName">' + countryObject.name + ' :&nbsp;' + '</p>' + 
                         '<p id="rightName">' + selectedRight + '</p>';
                         
          snippet      = '<p class="warningTitle">Constitution Excerpt Unavailable</p><p class="warningDetail">' + countryObject.name + '<br>does NOT contain any rights during ' + currentYear + '.</p>';  
        }

      }
      
      snippetID    = countryObject.name + ":" + selectedRight;
      showSnippet(cursorX, cursorY, red(currentCategory.colour), green(currentCategory.colour), blue(currentCategory.colour), snippetID, snippetTitle, snippet);
      
      longTouch = false;
      break;
    }
  
    theta += delta;
  }
}

int getNumberOfCategories() {
  return categoryList.size()+1;
}

String getCurrentCircumplex() {
  if(currentCircumplex == categoryList.size()) return "Category Wheel"
  else return "Rights Wheel";
}


String getMode() {
  if(onMobile) return "Mobile";
  else return "Lasso";
}


float getControllerRadius() {
  return controllerRadius; 
}


float getCircumplexRadius() {
  return circumplexRadius; 
}


String getCurrentCategoryColor() {
  return hex(categoryList.get(currentCircumplex).colour, 6);
}


float getSketchWidth() {
  return sketchWidth; 
}


float getSketchHeight() {
  return sketchHeight; 
}

int getNumberOfVisualizedCountries() {
  return visualizedCountries.size(); 
}


ArrayList<Country> insertAndSort(Country newCountry){
  String[] array = new String[visualizedCountries.size()+1]; // increase array length by 1 to accomdate new element passed to function
  
  // copy arraylist to array
  for(int i=0; i<visualizedCountries.size(); i++){
    array[i] = visualizedCountries.get(i).name;
  }
  array[array.length-1] = newCountry.name; // add newElement to end of array
    
  array = sort(array);
  
  // create copy of visualizedCountries list for sorting purposes
  ArrayList<Country> unsortedList = visualizedCountries;
  unsortedList.add(newCountry);
  
  ArrayList<Country> sortedList = new ArrayList<Country>();
  for(int j=0; j<array.length; j++){
    for(int k=0; k<unsortedList.size(); k++){
      if(array[j].equals(unsortedList.get(k).name)) {
         sortedList.add(unsortedList.get(k));
         break;
      }
    }
  }
  
  return sortedList;
}
