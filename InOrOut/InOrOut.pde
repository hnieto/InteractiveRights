// Code based off of:
// The Nature of Code
// <http://www.shiffman.net/teaching/nature>

//Physics fixed, cleaned up code. A lot. Also fixed bug regarding bubbles resting on bottom. Only need to clean up draw loop.

//MAY HAVE TO INCORPORATE THESE VARIABLES OUT
boolean procjs = true;
boolean onlyUS = false;
Bubble currentlyPressed;    //selected bubble - Switch to arraylist for TUIO

//LISTS To hold walls and objects
ArrayList<Bubble> bubbles;
ArrayList<Popup> popups;
ArrayList<Bubble> levelProgress;

Panel panel;
//A list of the (index of) rights (bubbles) already created
String[] created;

//List of amendments parsed from .txt
String[] amendments;

float MARGIN = 10.0;

color colorIn = #64C8FF;
color colorOut = #FFC864;

//Physics
float Gravity = 0.00;//0.01;
float friction = 0.9;
float wallFriction = 0.4;
float groundFriction = 0.3;//0.7;
float terminalVY = 15;
float terminalVX = 3;
float throwEase = 0.4;//Higher the throwEase, the harder to throw

float bottomMargin = height*10/12;

//Data variables
int Year;
int PreviousYear;
int count;
int created_counter;
boolean play;
int selected;
PImage USFlag;

int level;
int score = 0;
int pointInc = 1;//get more points on a winning streak
int totalTime = 180;
int time;
boolean timerOn;
int startTime = 0;

boolean waitflag = false;//true when screen has just been touched
boolean waitflag2 = false;
boolean restartflag = false;

//Sketch dimersion variables
float  sketchWidth;
float  sketchHeight;


int play_time = 10;//Number of frames before year changes

//ADDED: to switch betwen inter-activities (pun intended)
//a certain mode number corresponds to how we are displaying info
//e.g., a mode for floating text boxes, a mode for basketball, etx
//(for now at least...)
int mode;
int NUM_OF_MODES = 2;

//Font Stuff
PFont defaultFont, monoSpacedFont, monoSpacedBold, digitalFont;

//mouse/touch 
HashMap<Integer,Cursor>  cursors        = new HashMap<Integer,Cursor>();
float cursorX, cursorY;

//-------PARSE-------
String[] lines;
String[][] table;

//index:[19,136)

String[] splitLine(String line){
    int substringcount = 0;
    ArrayList<String> stringlist = new ArrayList<String>();
    for(int i=0; i<line.length()-1; i++){
    //    if((line.charAt(i) == ',') && (line.charAt(i+1) != ' ')){
        if((line.substring(i, i+1).equals(",")) && !(line.substring(i+1, i+2).equals(" "))){
            stringlist.add(line.substring(substringcount, i));
            substringcount = i+1;
        }
    }
    String[] strings = new String[stringlist.size()];
    strings = stringlist.toArray(strings);
    return strings;
}

void parse() {
    table = new String[18957][];
    lines = loadStrings("../data/rights2012.csv");
    for(int i=0; i<lines.length; i++){
        table[i] = splitLine(lines[i]);
    }
    for(int i=0; i<table[1].length; i++){
        table[1][i] = table[1][i].replace("\"", "");
    }
}
//--------------------end of parse

void setup() {
    // javascript function to set sketch size according to the width of the browser
    setCanvasSize();
    size(sketchWidth, sketchHeight);
    smooth();
    count = 0;
    created_counter = 0;
    play = false;
    
    level = 0;
    score = 0;
    time = totalTime;
    
    //amendments = loadStrings("../data/true_statements.txt");
    parse();
    selected = -1; // display generic message at startup before country is selected
    
    //set to first mode
    mode = 1;

      // font stuff
    fontSize                   = lerp(0,20, sketchWidth/(3840*0.49)); // 0.49 is percentage of canvas relative to browser window width
    defaultFont                = createFont("../data/RefrigeratorDeluxeLight.ttf", fontSize);
    monoSpacedFont             = createFont("../data/MonoSpaced.ttf", fontSize); 
    monoSpacedBold             = createFont("../data/MonoSpacedBold.ttf", fontSize);
    digitalFont                = createFont("../data/Digital.ttf", fontSize);
    textAlign(CENTER);
    textFont(defaultFont);
    
    panel = new Panel(height*10/12);
    
    // Create ArrayLists	
    bubbles = new ArrayList<Bubble>();
    popups = new ArrayList<Popup>();
    int margin = 10;
//      float rx = random(margin,width-margin);
//      float ry = 110;
//      Bubble bub = new Bubble(rx, ry);
//      bubbles.add(bub);
    frameRate(60);
    
    generateAlphabetList();
    generateCountryList();
    generateDescription();
    
    // let javascript know that this vis is ready to draw
    visLoaded();
    
    noLoop();
}

//-------------------------DRAW----------------------------------

void draw() {
    background(0);
    lights();
    
    panel.display();

    // Display all the bubbles
    Bubble bubble;
    for(int i=0; i<bubbles.size(); i++){
        bubble = bubbles.get(i);
        bubble.collide();
        bubble.move();
        bubble.display();
    }
    PreviousYear = Year;
    
    fill(0,0,0);
    textAlign(CENTER, TOP);
    text(mode, width - height/43.2, height - height/43.2);

    for (int i=0; i<popups.size (); i++) {
        Popup popp = popups.get(i);
        popp.adjust();
        if (popp.alpha <= 0) {
          popups.remove(popp);
        } else {
          popp.display();
        }
    }
    
    
//top panel
    pushStyle();
    textAlign(CENTER);
    fill(40, 10, 10);
    rect(0,0, sketchWidth, height/10);
    stroke(255,0,0);
    line(0,height/10,sketchWidth,height/10);
    stroke(0);
    
    textFont(digitalFont);
    fill(255, 0, 0);
    textSize(sketchWidth/37.5);

    String currScore = "Score: " + score;
    text(currScore, sketchWidth*0.15, height/21);
    if (timerOn) {
      if (millis()-startTime > 1000) {
        time -= 1;
  
        if (time <= 0) {
          timerOn = false;
        }
        startTime = millis();
      }
    }
    String timeStr;
    if(time%60 < 10){
        timeStr = "Time: " + (int)(time/60) + ":0" + time%60;
    }else{
        timeStr = "Time: " + (int)(time/60) + ":" + time%60;
    }
    text(timeStr, sketchWidth*0.9, sketchHeight/21);
    
    popStyle();
    
    if(time <= 0){
      pushStyle();
        fill(255);
        pushStyle();
          fill(255, 0, 0);
          textFont(digitalFont);
          textSize(width/35);
          text("ROUND OVER", sketchWidth/2, height/21);
        popStyle();
        textSize(height/40);
        text("TAP ANYWHERE TO RESTART",width/2, height/2);
      popStyle();
      endGame();
      return;
    }
    
    if(restartflag){
      endGame();
      return;
    }
    
    if(bubbles.size() == 0){
      nextLevel();
      return;
    }
    
    printQuestion();
}

//---------------------------------------------------------end of draw

void printQuestion(){
  pushStyle();
      fill(255);
      textAlign(CENTER);
      textSize(width/37.5);
      text("Which rights existed in "+table[selected][2]+" Constitution in 2012?", sketchWidth/4, height/42, sketchWidth/2, height/10);
    popStyle();
}

void nextLevel(){
  timerOn = false;
  pushStyle();
  fill(255);
  textSize(height/40);
  if(level == 0){
  }
  else{
    text("TAP ANYWHERE TO CONTINUE",width/2, height/2);
    waitflag2 = true;
    printQuestion();
  }
  popStyle();
  
  if(level == 0){
    document.getElementById('addCountryButton').style.visibility = 'visible';
    document.getElementById('letters').style.visibility          = 'visible';
    document.getElementById('addCountryBox').style.visibility    = 'visible';
  }
  
  if(!waitflag) return;
  waitflag = false;
  
  document.getElementById('addCountryButton').style.visibility = 'hidden';
  document.getElementById('letters').style.visibility          = 'hidden';
  document.getElementById('addCountryBox').style.visibility    = 'hidden';
  
  level++;
  for(int i=0; i<(5 + 2*(level-1)); i++){
      //This section is for bubble generation/spawning
      int margin = 10;
      float rx = random(margin,width-margin);
      float ry = height/11.9 + height/10;
      int a = (int)random(2);
//      jsAlert(a);
      Bubble bub = new Bubble(rx, ry, a!=0);
      bubbles.add(bub);
//      jsAlert("b");
      created_counter++;
  }
  timerOn = true;
}

void endGame(){
//  for(int i=0; i<bubbles.size(); i++){
//    bubble = bubbles.get(i);
//    bubbles.remove(bubble);
//  }
  bubbles.clear();
  waitflag2 = true;
  if(!waitflag && !restartflag) return;
  waitflag = false;
  waitflag2 = false;
  restartflag = false;
  level = 0;
  score = 0;
  time = totalTime;
  pointInc = 1;
  clearGameHistory();
}
  
  
void killBubble(Bubble bub, float x, float y){
  
  String rightAnswer;
  String yourAnswer;
  
  if(bub.x < width/2){//if bub is in the truezone
    if(bub.answer == true){//if this is right
      popups.add(new Popup(x, y, "+"+pointInc, true));
      score += pointInc;
      
      rightAnswer = "In";
      yourAnswer  = "In";
      pointInc++;
    }
    else{//wrong
      popups.add(new Popup(x, y, "WRONG", false));
      
      rightAnswer = "Out";
      yourAnswer  = "In";
      pointInc = 1;
    }
  }
  else{//if bub is in the falsezone
    if(bub.answer == false){//if this is right
      popups.add(new Popup(x, y, "+"+pointInc, true));
      score += pointInc;
      
      rightAnswer = "Out";
      yourAnswer  = "Out";
      pointInc++;
    }
    else{//wrong
      popups.add(new Popup(x, y, "WRONG", false));
      
      rightAnswer = "In";
      yourAnswer  = "Out";
      pointInc = 1;
    }
  }
  
  recordGameHistory(bub.rightName, bub.rightDesc, yourAnswer, rightAnswer, hex(colorIn, 6), hex(colorOut, 6));
  bubbles.remove(bub);
} 

//*********************************************/
//*          MULTI-TOUCH SUPPORT              */
//*********************************************/

void cursorDown(float x, float y, int id){
  cursorX    = x;
  cursorY    = y;

  //to drag bubbles
  for (Bubble bub: bubbles) {
      if(bub.contains(cursorX, cursorY) && !(bub.hasSpring)){
          bub.hasSpring = true;
          bub.holder    = id;
          bub.offsetX = cursorX - bub.x;
          bub.offsetY = cursorY - bub.y;
      }
  }
    
  if(waitflag2 && bubbles.size() == 0){
    waitflag = true;//used in nextLevel()
  }
}

void cursorMove(float x, float y, int id){
  cursorX    = x;
  cursorY    = y;

  for (Bubble bub: bubbles) {
      if(bub.hasSpring && bub.holder == id){
          bub.moveByTouch(cursorX, cursorY);
          break;
      }
  }
}

void cursorUp(float x, float y, int id){
  cursorX    = x;
  cursorY    = y;

  Bubble bub;
  for(int j=0; j<bubbles.size(); j++){
      bub = bubbles.get(j);
      if(bub.hasSpring && bub.holder == id){
          bub.hasSpring = false;
          bub.holder = 999;
          if(bub.y + bub.radius > panel.y){
              killBubble(bub, bub.x, bub.y);
          }
      }
  }
  currentlyPressed = null;
}

/*//////////////////////////////////////////////////////////////////////////////////////////*/

void setSelectedFromJS(int newID){
  selected = newID;
  waitflag = true;
}
void setRestartFromJS(){
  restartflag = true;
}


/*********************************************/
/*        PDE/JAVASCRIPT COMMUNICATION       */
/*********************************************/

/* @pjs font='../data/RefrigeratorDeluxeLight.ttf, ../data/MonoSpaced.ttf, ../data/MonoSpacedBold.ttf, ../data/Digital.ttf'; */


//javascript function for resizing sketch
function setCanvasSize() {

  var browserWidth     = window.innerWidth;
  var browserHeight    = window.innerHeight;
  sketchWidth          = browserWidth * 0.615;
  sketchHeight         = browserHeight;
}


function generateAlphabetList() {
  var lettersDiv   = document.getElementById('letters');
  
  int  letterCount = 0;
  char prevLetter  = '';
  char currLetter;
 
  for (int i=2; i<195; i++) {
    String countryString = table[i][2];
    
    currLetter = countryString.charAt(0); 
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
  
  for (int i=2; i<195; i++) {
    String countryString = table[i][2];
    
    // insert letter indicator 
    currLetter = countryString.charAt(0);
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
//    var plusBG   = document.createElement('div');
//    plusBG.id  = "plusBackground";
//    item.appendChild(plusBG);    
    
//    var plusLink = document.createElement('a');
//    var plusSign = document.createTextNode('+');
//    plusLink.id  = "plus";
//    plusLink.appendChild(plusSign);
//    plusLink.href = "javascript:changeSelected('" + i + "');";
//    item.appendChild(plusLink);

    // country name
    var textElement = document.createElement('p');
    var text    = document.createTextNode(countryString);
    textElement.appendChild(text);
    item.appendChild(textElement);

    // add touch and mouse handlers
//    (function(value){
//      item.addEventListener("touchstart", function() {
//         changeSelected(value);
//      }, false);
//  
//      item.addEventListener("mousedown", function() {
//         changeSelected(value);
//      }, false);
//    })(i);   

    (function(value){
      item.addEventListener("tap", function() {
         changeSelected(value);
      }, false);
    })(i);   
   
    // Add item to the list: 
    list.appendChild(item);
  }
}


function generateDescription() {
  String[] descriptionText = loadStrings("../web/description.html");
  String   joinedText      = join(descriptionText, " ");
 
  var descriptionDiv       = document.getElementById('description');
  descriptionDiv.innerHTML = joinedText; 
}

void visLoaded() {
    readyToDraw();
} 

function jsAlert(value) {
  alert(value); 
}

