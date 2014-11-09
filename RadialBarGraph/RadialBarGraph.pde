// Title: Interactive Rights, Radial Bar Graph
// Description: Cross-Country Comparison of Adopted Constitutional Rights Across Time
// Developed By: Heriberto Nieto
//               Texas Advanced Computing Center
// Modified by:  Luis Francisco-Revilla

/* @pjs font='../data/RefrigeratorDeluxeLight.ttf, ../data/MonoSpaced.ttf, ../data/MonoSpacedBold.ttf, ../data/Digital.ttf'; */

import java.util.Map;
HashMap<String, Country> countryMap          = new HashMap<String, Country>();
ArrayList<Country>       allCountries        = new ArrayList<Country>();
ArrayList<Country>       visualizedCountries = new ArrayList<Country>();
ArrayList<Category>      categoryList        = new ArrayList<Category>();
ArrayList<String>        rightsColumns       = new ArrayList<String>();

TimeController           timecontroller;
int[]                    yearRange = new int[2];
int                      currentCircumplex, numberOfRights;
float                    controllerRadius, circumplexRadius, shortestDistanceFromCenter, paddingTop;
float                    circumplexRotationAngle, mouseStartAngle;
float                    highlightRadius, highlightThickness, highlightedRightIndex, highlightedCategoryIndex;
int                      largestCategoryLength;

PFont                    defaultFont, monoSpacedFont, monoSpacedBold, digitalFont;
int                      fontSize;

color[]                  categoryColors = new color[7];
color                    background_color, letter_color, wedgeBorder_color;

float                    cursorX, cursorY, cursorR; // generic variable to hold either touch or mouse location
float                    sketchWidth, sketchHeight;

boolean                  dragMode             = false;
boolean                  highlightRing        = false;

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
  highlightedCategoryIndex   = -1;

  // javascript function to set sketch size according to the width of the browser
  setCanvasSize();
  size(sketchWidth, sketchHeight, P2D);
  paddingTop                 = sketchHeight * 0.01; 

  // font stuff
  fontSize                   = lerp(0, 20, sketchWidth/2596); // 2596 == 67% of 4K horizontal resolution
  defaultFont                = createFont("../data/RefrigeratorDeluxeLight.ttf", fontSize);
  monoSpacedFont             = createFont("../data/MonoSpaced.ttf", fontSize); 
  monoSpacedBold             = createFont("../data/MonoSpacedBold.ttf", fontSize);
  digitalFont                = createFont("../data/Digital.ttf", fontSize*4);
  textAlign(CENTER);
  textFont(defaultFont);

  // parsing
  parseCategories("../data/substantive_categorization_110414.csv");
  parseRights("../data/rights.csv");
  parseSnippets("../data/snippets_110514.csv");
  
  // time controls
  shortestDistanceFromCenter = min(width, height)/2;
  circumplexRadius           = shortestDistanceFromCenter-(textAscent() + textDescent())-paddingTop; // account for letter height and add some extra padding
  controllerRadius           = shortestDistanceFromCenter/3;
  timecontroller             = new TimeController(controllerRadius, yearRange);
  timecontroller.init();

  // javascript function to create HTML elements
  generateButtonTreeLinks();
  generateButtonTree();
  generateAlphabetList();
  generateCountryList();
  generateDescription();

  // set "All Rights" view as default
  currentCircumplex          = categoryList.size();
 
  // let javascript know that this vis is ready to draw
  readyToDraw();
}

/*********************************************/
/*             MAIN DRAW LOOP                */
/*********************************************/
void draw() {

  background(background_color);

  pushMatrix();
  translate(width/2, height/2);
  
  // draw grey circle behind slices
  fill(15);
  noStroke();
  ellipse(0, 0, circumplexRadius*2, circumplexRadius*2);

  pushMatrix();
  rotate(circumplexRotationAngle);
  if (currentCircumplex == categoryList.size()) { 
    drawCategoryCircumplex(); 
    drawCategoryBorders(); 
  } 
  else { 
    drawRightsCircumplex(categoryList.get(currentCircumplex)); 
    drawRightBorders(); 
  }
  drawCountryNames();
  popMatrix();

  pushStyle();
  if (currentCircumplex == categoryList.size()) drawCategoryNames();
  else drawRightNames();
  popStyle();

  if (highlightRing) {
    pushStyle();
    noFill();
    stroke(200, 50);
    strokeWeight(highlightThickness-4); // subtract 4 to account for the thickness of the borders between wedges
    ellipse(0, 0, (highlightRadius-highlightThickness/2)*2, (highlightRadius-highlightThickness/2)*2);
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
  
  float delta          = TWO_PI/visualizedCountries.size();  
  float theta          = 0.0; 
  float rightThickness = (circumplexRadius-controllerRadius)/numberOfRights;

  for (int i=0; i<visualizedCountries.size(); i++) {
    Country countryObject = visualizedCountries.get(i);
    countryObject.drawCategories(timecontroller.year, theta+0.009, theta+delta, controllerRadius, rightThickness); // add 0.009 to compensate for arcs overflowing past borders
    theta += delta;
  }
}


void drawRightsCircumplex(Category category) {

  float delta          = TWO_PI/visualizedCountries.size(); 
  float theta          = 0.0;
  float rightThickness = (circumplexRadius-controllerRadius)/category.rights.size();

  for (int i=0; i<visualizedCountries.size(); i++) {
    Country countryObject = visualizedCountries.get(i);
    countryObject.drawRights(category, timecontroller.year, theta+0.009, theta+delta, controllerRadius, rightThickness); // add 0.009 to compensate for arcs overflowing past borders
    theta += delta;
  }
}


/*********************************************/
/*              OVERLAYS                     */
/*********************************************/

void drawCountryNames() {   

  textSize(fontSize);
  float delta           = TWO_PI/visualizedCountries.size(); 
  float startTheta      = 0.0;
  float thickness       = (circumplexRadius-controllerRadius)/numberOfRights;
  float adjustedRadius  = circumplexRadius-thickness/2; // wedge thickens up/down from current radius, we have to adjust for that

  for (int i=0; i<visualizedCountries.size(); i++) {
    Country countryObject = visualizedCountries.get(i);
    String name = countryObject.name + " " + "(" + countryObject.existence[0] + " - " + countryObject.existence[1] + ")";
    float outerRadius   = adjustedRadius + thickness;
    float txtStartAngle = (startTheta+delta*0.5) - (getTextLength(name)/outerRadius)*0.5;
    float arclength     = 0; // We must keep track of our position along the curve

    for (int j=0; j<name.length(); j++) {

      // Instead of a constant width, we check the width of each character.
      String currentChar      = name.substring(j, j+1);
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
  float    delta            = TWO_PI/visualizedCountries.size(); 
  float    startTheta       = -HALF_PI - delta/2; 
  float    thickness        = (circumplexRadius-controllerRadius)/category.rights.size();
  float    innerRadius      = controllerRadius;
  float    adjustedFontSize = fontSize*15/category.rights.size(); // font size must be inversely proportional to the number of rings 
  String   rightText;

  for (int i=0; i<category.rights.size(); i++) {

    if (i == highlightedRightIndex) {
      float descriptionFontSize = fontSize*22/largestCategoryLength;
      textFont(monoSpacedBold, descriptionFontSize);
      rightText = category.descriptions.get(i);
    }
    else {
      textFont(monoSpacedFont, adjustedFontSize);
      rightText = category.rights.get(i);
    }

    float textHeight    = textAscent() + textDescent();
    float radius        = innerRadius + 2; //add 2 to account for the width of the borders between wedges
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
      arclength += currentCharWidth/2;
    }

    innerRadius += thickness;
  }
}


void drawCategoryNames() {

  textSize(fontSize*3);
  float delta                = TWO_PI/visualizedCountries.size(); 
  float startTheta           = -HALF_PI - delta/2; 
  float rightThickness       = (circumplexRadius-controllerRadius)/numberOfRights;
  float categoryInnerRadius  = controllerRadius + 2; //add 2 to account for the width of the borders between wedges
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


void drawCategoryBorders() {
  float delta          = TWO_PI/visualizedCountries.size(); 
  float theta          = 0.0; 
  float rightThickness = (circumplexRadius-controllerRadius)/numberOfRights;
  float adjustedRadius = controllerRadius; 

  pushStyle();
  noFill();
  strokeWeight(5);
  stroke(4);
  
  for (int i=0; i<categoryList.size(); i++) {
    Category category = categoryList.get(i);
    float categoryThickness = rightThickness*category.rights.size();
    ellipse(0, 0, adjustedRadius*2, adjustedRadius*2);
    adjustedRadius += categoryThickness;
  }
  
  for (int i=0; i<visualizedCountries.size(); i++) {
    line(0, 0, circumplexRadius*cos(theta), circumplexRadius*sin(theta));
    line(0, 0, circumplexRadius*cos(theta+delta), circumplexRadius*sin(theta+delta));
    theta += delta;
  }
  
  popStyle();
  
  // draw black circle behind time controller to cover lines used for slice borders
  fill(background_color);
  noStroke();
  ellipse(0, 0, controllerRadius*2, controllerRadius*2);
}


void drawRightBorders() {
  Category category       = categoryList.get(currentCircumplex);
  float    delta          = TWO_PI/visualizedCountries.size(); 
  float    theta          = 0.0; 
  float    rightThickness = (circumplexRadius-controllerRadius)/category.rights.size();
  float    adjustedRadius = controllerRadius; 

  pushStyle();
  noFill();
  strokeWeight(5);
  stroke(4);
  
  for (int i=0; i<category.rights.size(); i++) {
    ellipse(0, 0, adjustedRadius*2, adjustedRadius*2);
    adjustedRadius += rightThickness;
  }
  
  for (int i=0; i<visualizedCountries.size(); i++) {
    line(0, 0, circumplexRadius*cos(theta), circumplexRadius*sin(theta));
    line(0, 0, circumplexRadius*cos(theta+delta), circumplexRadius*sin(theta+delta));
    theta += delta;
  }
  
  popStyle();
  
  // draw black circle behind time controller to cover lines used for slice borders
  fill(background_color);
  noStroke();
  ellipse(0, 0, controllerRadius*2, controllerRadius*2);
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
  int startTime = millis();
  
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
  
//  println("Parse Categories - Elapsed Time: " + (millis()-startTime)/1000);
}


void parseRights(String csv) {
  int startTime = millis();

  // reads CSV header column and returns only the Right strings
  String[] rows    = loadStrings(csv);
  String[] columns = split(rows[0].replaceAll("\"", ""), ',');
  int countryColumnIndex       = 0;
  int yearColumnIndex          = 1;
  int endYearColumnIndex       = 2;
  int visualizeColumnIndex     = 3;
  int adoptedRightsColumnIndex = 4;
  int rightColumnIndex         = 5;
  
  // used to find optimal time range
  int earliestStartYear = 2012;
  int latestEndYear   = 2012;

  // get all column headers that follow the column "Human Dignity"
  for (int i=rightColumnIndex; i<columns.length; i++) {
    rightsColumns.add(columns[i]);
  }

  // parse rights.csv and use rightsColumn array to filter results
  for (int i=1; i<rows.length; i++) {
    String[] row                = split(rows[i], ',');
    boolean  visualize          = (row[visualizeColumnIndex].equals("yes")) ? true : false;
    int      numOfAdoptedRights = int(row[adoptedRightsColumnIndex]);
    int      currentYear        = int(row[yearColumnIndex]);
    int      endYear            = int(row[endYearColumnIndex]);
           
    String   countryName      = row[countryColumnIndex]; // get string in column titled "country"
    Country  countryObject = countryMap.get(countryName);

    // first time this country was read in table
    if (countryObject == null) {  
      String[] yearsOfExistence = { row[yearColumnIndex], row[endYearColumnIndex] };
      countryObject           = new Country(countryName, yearsOfExistence, visualize);
      countryMap.put(countryName, countryObject);
      allCountries.add(countryObject);
      if (visualize) {
        if (currentYear < earliestStartYear) earliestStartYear = currentYear; 
        if (endYear < latestEndYear)         latestEndYear     = endYear;
        visualizedCountries.add(countryObject);
      }
    }
      
    // find all rights available for this country on this year
    Year year      = new Year(currentYear);

    if(numOfAdoptedRights > 0) { // skip years that have no rights
      for (int j=0, rightIterator=rightColumnIndex; j<rightsColumns.size(); j++, rightIterator++) {

        String right             = rightsColumns.get(j);
        String rightAvailability = row[rightIterator];

        if (rightAvailability.equals("1. yes") || rightAvailability.equals("2. full")) {
          year.addRight(right);
          year.addCateogry(findCategoryForRight(right));
        }     
      }
      
      countryObject.addYear(year);
    }            
  }
  
  yearRange[0] = earliestStartYear;
  yearRange[1] = latestEndYear;
  
//  println("Parse Rights - Elapsed Time: " + (millis()-startTime)/1000);
}


void parseSnippets(String csv) {
  int startTime = millis();
  
  String[] rows           = loadStrings(csv);

  for (int i=1; i<rows.length; i++) {
    String constitution   = split(rows[i], '|')[3];
    String right          = split(rows[i], '|')[1];
    String snippetText    = split(rows[i], '|')[4];
    String countryName    = split(constitution, '_')[0];
    
    Country countryObject = countryMap.get(countryName);
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
/*        GENERIC INPUT FUNCTIONS            */
/*********************************************/
void cursorDown() {
  float disX = width/2  - cursorX;
  float disY = height/2 - cursorY;

  // check if circumplex should be rotated
  if (sqrt(sq(disX) + sq(disY)) > controllerRadius && sqrt(sq(disX) + sq(disY)) < circumplexRadius) {
    // get the angle from the center to the mouse position
    mouseStartAngle = atan2(cursorY - height/2, cursorX - width/2); // atan2 returns angle between PI and -PI    
    mouseStartAngle = mouseStartAngle > 0 ? mouseStartAngle : (TWO_PI + mouseStartAngle); // map atan2 to radians between 0 and TWO_PI  
  }

  // highlight right ring when clicked wedge is selected via mouse press
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

  timecontroller.timelineTickClicked(width/2, height/2);
}


void cursorDragged() {
  // check if circumplex should be rotated
  float disX = width/2  - cursorX;
  float disY = height/2 - cursorY;

  if (sqrt(sq(disX) + sq(disY)) > controllerRadius && sqrt(sq(disX) + sq(disY)) < circumplexRadius) {

    // get the angle from the center to the mouse position
    float mouseEndAngle = atan2(cursorY - height/2, cursorX - width/2); // atan2 returns angle between PI and -PI    
    mouseEndAngle       = mouseEndAngle > 0 ? mouseEndAngle : (TWO_PI + mouseEndAngle); // map atan2 to radians between 0 and TWO_PI
    float angleOffset   = mouseEndAngle - mouseStartAngle;
    if(abs(angleOffset) > 0.006) dragMode = true;

    circumplexRotationAngle += angleOffset;
    circumplexRotationAngle = (circumplexRotationAngle > TWO_PI) ? 0 : circumplexRotationAngle; // constrain circumplexRotationAngle below TWO_PI
    mouseStartAngle         = mouseEndAngle;
  }  
}


void cursorUp() {
  timecontroller.playButtonClicked(width/2, height/2);
  timecontroller.ffButtonClicked(width/2, height/2);
  timecontroller.rewindButtonClicked(width/2, height/2);

  // if in "All Rights" circumplex, check for category selection via mouse click
  if (currentCircumplex == categoryList.size() && !dragMode) {

    float rightThickness    = (circumplexRadius-controllerRadius)/numberOfRights;
    float r                 = circumplexRadius;
    float x                 = width/2;
    float y                 = height/2;

    for (int i=categoryList.size()-1; i>=0; i--) {
      float categoryThickness = rightThickness*categoryList.get(i).rights.size();
      float disX = x - cursorX;
      float disY = y - cursorY;
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
/*       MOUSE/KEYBOARD INTERACTION          */
/*********************************************/

void mousePressed() { 
  cursorX      = mouseX;
  cursorY      = mouseY;
  cursorR      = min(width,height) * 0.02;
  
  cursorDown();
}

void mouseDragged() {
  cursorX = mouseX;
  cursorY = mouseY;
  cursorDragged();
}


void mouseReleased() {
  cursorX      = mouseX;
  cursorY      = mouseY;
  cursorUp();
}


/*********************************************/
/*         PDE/JAVASCRIPT FUNCTIONS          */
/*********************************************/

function setCanvasSize() {
  var browserWidth    = window.innerWidth;
  var browserHeight   = window.innerHeight;
  sketchWidth         = browserWidth * 0.665;
  sketchHeight        = browserHeight;
}


function generateButtonTreeLinks() {
  var listSize    = categoryList.size()+1;  
  var buttonTree  = document.getElementById('controls');
  var borderColor = "#ffffff";
  
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

  for (var i=0; i<6; i++) {
    var tr = document.createElement('TR');
    rootTableBody.appendChild(tr);
    var td = document.createElement('TD');
    if (i==2) { 
      td.style.borderBottom = "1px solid " + borderColor;
    }
    tr.appendChild(td);
  }
  buttonTree.appendChild(rootTable);  

  var childrenTable = document.createElement('TABLE');
  childrenTable.style.width = "35%";
  childrenTable.style.height = "100%";
  childrenTable.style.position = "absolute";
  childrenTable.style.top = "0%";
  childrenTable.style.left = "50%";
  childrenTable.style.border = "none";

  var childrenTableBody = document.createElement('TBODY');
  childrenTable.appendChild(childrenTableBody);

  for (var i=0; i<(listSize-1)*2; i++) {
    var tr = document.createElement('TR');
    childrenTableBody.appendChild(tr);
    var td = document.createElement('TD');
    if ((i&1) == 0) { 
      td.style.borderBottom = "1px solid " + borderColor;
    }
    tr.appendChild(td);
  }
  buttonTree.appendChild(childrenTable);
}


function generateButtonTree() {  
  var listSize   = categoryList.size()+1;  
  var buttonTree = document.getElementById('controls');

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

  for (var i=0; i<3; i++) {
    var tr = document.createElement('TR');
    rootTableBody.appendChild(tr);
    var td = document.createElement('TD');
    td.style.height = "33.33%";

    if (i == 1) {
      var rootButton = document.createElement('div');
      rootButton.appendChild(document.createTextNode("All Categories"));
      rootButton.setAttribute("id", "categoryButton" + (listSize-1));
      rootButton.setAttribute("class", "leaf");
      rootButton.setAttribute('onclick', 'changeCircumplex("'+(listSize-1)+'")');
      rootButton.style.width = "100%";
      rootButton.style.height = "100%";
      rootButton.style.fontSize = "1.7vw";
      rootButton.style.position = "relative";
      td.appendChild(rootButton);

      // calculate svg size (in pixels) based off of button dimensions
      var rootButtonHeight = (buttonTree.clientHeight)/3; // in px
      var rootButtonWidth  = ((buttonTree.clientWidth) * 0.4);
      var iconWidth  = min(rootButtonWidth*0.9, rootButtonHeight*0.5);
      var iconHeight = min(rootButtonWidth*0.9, rootButtonHeight*0.5);
      var iconRadius = iconWidth * 0.5;
      var scaler = iconRadius/listSize;

      // create circle svgs to represent categories and add them to rootButton
      for (var j=listSize-2; j>=0; j--) {
        // create svg to hold category icon
        var categorySVG = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        categorySVG.setAttribute("height", iconHeight);
        categorySVG.setAttribute("width", iconWidth);
        categorySVG.setAttribute("display", "block");
        categorySVG.style.position = "absolute";
        categorySVG.style.top = (rootButtonHeight*0.25)+(rootButtonHeight*0.75-iconHeight)/2 + "px";
        categorySVG.style.left = "0";

        // add circle elelment to svg
        var categoryCircle = document.createElementNS("http://www.w3.org/2000/svg", "circle");
        categoryCircle.setAttribute("cx", iconWidth/2);
        categoryCircle.setAttribute("cy", iconHeight/2);
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
  buttonTree.appendChild(rootTable);   

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
  for (var i=0; i<listSize-1; i++) {
    var tr = document.createElement('TR');
    childrenTableBody.appendChild(tr);
    var td = document.createElement('TD');
    td.style.height = 100/(listSize-1) + "%";

    var textHolder  = document.createElement('p');
    textHolder.appendChild(document.createTextNode(categoryList.get(i).name));
    textHolder.style.width = "33%";
    textHolder.style.margin = "0";

    var childButton = document.createElement('div');    
    childButton.appendChild(textHolder);
    childButton.setAttribute("id", "categoryButton" + (listSize-1));
    childButton.setAttribute("class", "leaf");
    childButton.setAttribute('onclick', 'changeCircumplex("'+i+'")');
    childButton.style.width = "100%";
    childButton.style.height = "50%";
    childButton.style.position = "relative";
    var childButtonHeight = ((buttonTree.clientHeight)/(listSize-1))*0.5; // in px
    var childButtonWidth  = ((buttonTree.clientWidth) * 0.35);
    childButton.style.lineHeight = childButtonHeight*0.5 + "px";

    // calculate svg size (in pixels) based off of button dimensions
    var iconWidth  = min(childButtonHeight * 0.97, childButtonWidth * 0.97);
    var iconHeight = min(childButtonHeight * 0.97, childButtonWidth * 0.97);
    var iconRadius = iconWidth*0.45;  

    // create svg to hold category icon
    var categorySVG = document.createElementNS("http://www.w3.org/2000/svg", "svg");
    categorySVG.setAttribute("height", iconHeight);
    categorySVG.setAttribute("width", iconWidth);
    categorySVG.setAttribute("display", "block");
    categorySVG.style.position = "absolute";
    categorySVG.style.top = "0";  
    categorySVG.style.right = "0";

    // add circle elelment to svg
    var categoryCircle = document.createElementNS("http://www.w3.org/2000/svg", "circle");
    categoryCircle.setAttribute("cx", iconWidth/2);
    categoryCircle.setAttribute("cy", iconHeight/2);
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
  buttonTree.appendChild(childrenTable);
}


function generateAlphabetList() {
  var lettersDiv = document.getElementById('letters');
  
  char prevLetter = '';
  char currLetter;
  
  for (int i=0; i<allCountries.size(); i++) {
    Country countryObject = allCountries.get(i);
    
    currLetter = countryObject.name.charAt(0);
    if(prevLetter != currLetter) {
       var letterButton  = document.createElement('a');
       letterButton.appendChild(document.createTextNode(str(currLetter)));
       letterButton.href = "#" + str(currLetter);
       lettersDiv.appendChild(letterButton);
       prevLetter = currLetter;
    }
  }
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
       letterElement.style.backgroundColor = "rgba(18,18,18,0.8)";
       letterElement.innerHTML = '<p id="' + str(currLetter) + '"> ' + str(currLetter) + '</p>';
       list.appendChild(letterElement);
       prevLetter = currLetter;
    }
    
    // Create the list item:
    var item     = document.createElement('li');
    
    // Create addition button
    var plusBG   = document.createElement('div');
    plusBG.id  = "plusBackground";
    item.appendChild(plusBG);    
    
    var plusLink = document.createElement('a');
    var plusSign = document.createTextNode('+');
    plusLink.id  = "plus";
    plusLink.appendChild(plusSign);
    plusLink.href = "javascript:addCountry('" + countryObject.name + "');";
    item.appendChild(plusLink);
    
    // Disable addition button if country is already in pie
    if(countryObject.visualize) {
      var plusBlocker = document.createElement('div');
      plusBlocker.id  = "plusBlocker";
      item.appendChild(plusBlocker);
    }
    
    // Create deletion button
    var minusBG   = document.createElement('div');
    minusBG.id  = "minusBackground";
    item.appendChild(minusBG);    
    
    var minusLink = document.createElement('a');
    var minusSign = document.createTextNode('-');
    minusLink.id  = "minus";
    minusLink.appendChild(minusSign);
    minusLink.href = "#";
    minusLink.href = "javascript:removeCountry('" + countryObject.name + "');";
    item.appendChild(minusLink);
    
    // Disable deletion button if country is NOT yet in pie
    if(!countryObject.visualize) {
      var minusBlocker = document.createElement('div');
      minusBlocker.id  = "minusBlocker";
      item.appendChild(minusBlocker);
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


void snippetRemoved(String oldCountry, String newCountry){
  // nothing to do if user is selecting different rights within the same country
  if(!oldCountry.equals(newCountry)) {
    Country lastSelected = countryMap.get(oldCountry);
    lastSelected.snippetCreated = false;
  }
}

void setCircumplexFromJS(int circumplexID) {
  // turn highlighted ring off when switching circumplexes 
  highlightRing            = false;
  highlightedRightIndex    = -1;
  highlightedCategoryIndex = -1;
  
  // delete existing snippet DIV 
  if(document.getElementsByClassName("snippet show").length > 0) {
    var existingSnippet            = document.getElementsByClassName("snippet show")[0];
    var existingSnippetCountryName = existingSnippet.id.split(':')[0];
    
    Country countryWithSnippet = countryMap.get(existingSnippetCountryName);
    countryWithSnippet.snippetCreated = false;
    
    document.body.removeChild(existingSnippet);
  }
  
  // change circumplex
  currentCircumplex = circumplexID;
}


void insertNewCountry(String country) {
  Country  countryObject = countryMap.get(country);
  
  if(!countryObject.visualize) {
     countryObject.recentlyAdded = true; 
     
     // enable overlay to prevent mulitple country addtitions before animation completes
     var countryListOverlay = document.getElementById('countryBoxOverlay');
     countryListOverlay.style.display = "block";
     
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
     
     // enable overlay to prevent mulitple country deletions before animation completes
     var countryListOverlay = document.getElementById('countryBoxOverlay');
     countryListOverlay.style.display = "block";
     
     // update year range after removing country 
//     if (countryObject.existence[0] < yearRange[0]) yearRange[0] = countryObject.existence[0] ; 
//     if (countryObject.existence[1] < yearRange[1]) yearRange[1] = countryObject.existence[1];
  }
  
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
