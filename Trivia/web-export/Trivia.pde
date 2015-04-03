//TODO:
//  add "next" next to the arrows
//  remove the extra taps state between states
//  clean up code/divide up into methods
//  fix the line that prints the initial time
//  move hint to status bar? (hide yellow box at beginning)
//  restart button
//  timer bug


/* @pjs font='../data/RefrigeratorDeluxeLight.ttf, ../data/Digital.ttf, ../data/VladimirScript.ttf'; */

//Total time for a round of the game in seconds
static final int MAX_TIME =  120;
//Number of questions asked; the number of us amendments
static final int NUM_QUESTIONS = 27;

//Color for status bar -- brownish-red
color statusBarColor = color(40, 10, 10);

int startTime;
boolean timerOn = true;
boolean hintRequested = false;
int countdown;

// Arraylists for the questions and squares
ArrayList<Question> questionList;
ArrayList<Square> squareList;
ArrayList<Popup> popupList;

//question index
int count;

//variables to display the score and to say if its correct
String result = "";
int score;
int attempt;
int attempts[] = new int[3];

//Graphics section
//variable to set the size of the window
float sketchWidth; 
float sketchHeight;

// variable to store the size of the boundary in order to have space for the question and score
float margin;

//variables to draw the squares proportional to the window size
float squareWidth;
float squareHeight;
float gapHeight;
float gapWidth;
float posX;
float posY;

//Lower bound (y coordinate) for the status bar
float statusBarBound;

//Variables to cause the screen to wait for input
boolean waiting;          //waiting means that the vis is in the state between questions
boolean ready;            //ready means that the game is ready to start a new game
boolean safeToClearHistory; //shows when it is safe to clear the history -- can't do in reset because it shows immediately
int     arrowColorTimer;
int     selectedArrowColor;
color[] arrowColors = new color[2];

//Var to remember latest box clicked
Square mostRecent;

//Font stuff   
PFont defaultFont;
PFont digitalFont;
float fontSize;

void setup() {
  //javascript function to set sketch size according to the width of the browser
  setCanvasSize();
  size(sketchWidth, sketchHeight);
  background(255);
  noStroke();
  frameRate(30);
  countdown = MAX_TIME;
  //set to first question
  count = 0;
  score = 0;
  result="";

  margin            = sketchHeight/4;
  squareWidth       = sketchWidth * 7/72;
  squareHeight      = sketchHeight * 2/15;
  gapHeight         = sketchHeight * 7/60;
  gapWidth          = sketchWidth/80;
  posX              = gapWidth;
  posY              = margin;
  statusBarBound    = sketchHeight/10;

  //Set game to begin after user input
  waiting = false;
  ready = true;
  safeToClearHistory = false;
  arrowColors[0] = color(255, 0, 0);     // red
  arrowColors[1] = color(255, 255, 255); // white

  // Initialize the ArrayLists
  popupList = new ArrayList<Popup>();
  questionList = new ArrayList<Question>();
  squareList = new ArrayList<Square>(); 
  attempts = [0, 0, 0];

  // creating object from a text file -- creating object form a text file
  String[] data = loadStrings("../data/data.txt");

  // read line by line
  for (int i=0; i<data.length; i++) {
    String[] values = splitLine(data[i]);
    String question = values[0];
    String hint     = values[1];

    //Crop quotes out of question string
    question = question.substring(1, question.length()-1);

    //To add the questions, incorrect answers, and solutions into the arrayList
    questionList.add(new Question(question, values[1], values[2]));
  }

  //ADD SQUARES TO ARRAY LIST
  posX = gapWidth;
  posY = margin;
  for (int i =0; i<NUM_QUESTIONS; i++) {
    //Add the squares into the arrayList; Args = X,Y, width, height, and correct Answer
    squareList.add(new Square(posX, posY, squareWidth, squareHeight, i+1));  

    // updating posX and posY after every iteration
    posX  = posX + gapWidth + squareWidth;
    if (posX > sketchWidth-gapWidth) {
      posX  = gapWidth;
      posY  += squareHeight + gapHeight;
    }
  }

  //font stuff
  fontSize                   = sketchWidth/37.5;
  scriptFont                 = createFont("../data/VladimirScript.ttf");
  defaultFont                = createFont("../data/RefrigeratorDeluxeLight.ttf", fontSize);
  digitalFont                = createFont("../data/Digital.ttf", fontSize/**4*/);
  textAlign(CENTER);
  textFont(defaultFont);

  questionList = shuffle(questionList);
  background(0);

  generateDescription();

  // let javascript know that this vis is ready to draw
  visLoaded();

  noLoop(); // do not draw anything until vis is selected in html
}


void draw() {
  background(0);

  //display boxes
  for (Square box : squareList) {    
    //display each square
    box.display();
  }
  
  //check if the previoud game just ended -- need to clear history
  if(safeToClearHistory){
    clearGameHistory();
    safeToClearHistory = false;
  }
  
  //display statusBar
  fill(statusBarColor);
  rect(0, 0, sketchWidth, statusBarBound);
  stroke(255, 0, 0);
  line(0, statusBarBound, sketchWidth, statusBarBound);
  stroke(0);
  //reset fill
  fill(255);

  //state before round starts
  if (!ready) {
    //show that we are waiting for user input
    textSize(sketchWidth/37.5);
//    String restart = "TAP ANYWHERE TO START";
//    text(restart, (sketchWidth-textWidth(restart))/2 + textWidth(restart)/2, sketchHeight*7/16);
    
    // display starting score
    textFont(digitalFont);
    fill(255, 0, 0);
    String currScore = "Score: " + score;
    text(currScore, sketchWidth*0.15, sketchHeight/21);
    
    // display starting time
    int startTime = (int) MAX_TIME;
    String sTime;
    if (startTime%60 < 10) {
      sTime = "Time: " + (int)(startTime/60) + ":0" + startTime%60;
    } else {
      sTime = "Time: " + (int)(startTime/60) + ":" + startTime%60;
    }
    text(sTime, sketchWidth*0.9, sketchHeight/21);
    
  } else if (count >= NUM_QUESTIONS) {  //Check if round finished
    
    for(int i=0; i < popupList.size(); i++){
        Popup pop = popupList.get(i);
        pop.adjust();
        if(pop.alpha <= 0){
            popupList.remove(pop);
            i--;
        }else{
            pop.display();
        }
    }

    timerOn = false;
    textFont(digitalFont);
    fill(255, 0, 0);
    String completionText = "ROUND OVER";
    textSize(sketchWidth/37.5);
    text(completionText, (sketchWidth-textWidth(completionText))/2 + textWidth(completionText)/2, sketchHeight/21);

    fill(255);
    textFont(defaultFont);
    int intElapsedTime = (int)(MAX_TIME - countdown);
    String stats;
    if (intElapsedTime%60 < 10) {
      stats = "Final Score: " + score + "\nElapsed Time: " + (int)(intElapsedTime/60) + ":0" + intElapsedTime%60;
    } else {
      stats = "Final Score: " + score + "\nElapsed Time: " + (int)(intElapsedTime/60) + ":" + intElapsedTime%60;
    }
    text(stats, (sketchWidth-textWidth(stats))/2 + textWidth(stats)/2, sketchHeight/6);

//    String restart = "TAP ANYWHERE TO RESTART";
//    text(restart, (sketchWidth-textWidth(restart))/2 + textWidth(restart)/2, sketchHeight*7/16);
    document.getElementById("overlay").style.display = "none";
    
  } else {
    //keep going -- may be in waiting mode (tap to continue)

    //Display question -- when a new question is introduced, it grows until full size.
    float fullTextSize = sketchWidth/37.5;
    textSize(fullTextSize * (((float)questionList.get(count).size)/FULL_SIZE));
    if (questionList.get(count).size < FULL_SIZE) {
      questionList.get(count).size++;
    }

    //Display question
    text(questionList.get(count).question, (sketchWidth-textWidth(questionList.get(count).question))/2
      + textWidth(questionList.get(count).question)/2, sketchHeight/6);
      
    //Display popups
    for(int i=0; i < popupList.size(); i++){
        Popup pop = popupList.get(i);
        pop.adjust();
        if(pop.alpha <= 0){
            popupList.remove(pop);
            i--;
        }else{
            pop.display();
        }
    }  
      
    //Display Hint
    pushStyle();
    noFill();
    stroke(204, 204, 0);
    rect(sketchWidth*0.52 + textWidth(questionList.get(count).question)/2, sketchHeight*.13, sketchWidth*0.05, sketchHeight*0.045, 5, 5, 5, 5);
    fill(204, 204, 0);
    if(hintRequested){
      text(questionList.get(count).hint, sketchWidth*0.545 + textWidth(questionList.get(count).question)/2, sketchHeight/6);
    }else{
      text("Hint", sketchWidth*0.545 + textWidth(questionList.get(count).question)/2, sketchHeight/6);
    }
    popStyle();

    //Reset size to normal
    textSize(fullTextSize);

    //To display if the selected answer is correct
    if (!result.substring(0, 5).equals("Wrong") && !result.equals("")) {
      text(result, sketchWidth *.5, sketchHeight/5); 
      waiting = true;
    } else if (!result.equals("")) {
      //diplay at box location
      text(result, mostRecent.x + mostRecent.w/2, mostRecent.y + mostRecent.h + textAscent() + textDescent());
    }

    //Show the arrows and overlay if current question has been answered
    if (waiting) {
      // enable HTML overlay to block the touches on the boxes
      document.getElementById("overlay").style.display = "block";
      
      // show hint if not already shown
      hintRequested = true;
      drawArrows();
    }

    //To display score
    textFont(digitalFont);
    fill(255, 0, 0);
    String currScore = "Score: " + score;
    text(currScore, sketchWidth*0.15, sketchHeight/21);

    if (timerOn) {
      if (millis()-startTime > 1000) {
        countdown -= 1;

        if (countdown <= 0) {
          timerOn = false;
          count = NUM_QUESTIONS;
        }
        startTime = millis();
      }
    }
    int intTime = (int) countdown;
    String time;
    if (intTime%60 < 10) {
      time = "Time: " + (int)(intTime/60) + ":0" + intTime%60;
    } else {
      time = "Time: " + (int)(intTime/60) + ":" + intTime%60;
    }
    text(time, sketchWidth*0.9, sketchHeight/21);

    //reset fonts
    textFont(defaultFont);
    fill(255);
  }
}

void drawArrows(){
  pushStyle();
  // toggle arrow color between white and red
  if (millis() - arrowColorTimer > 500) {
    selectedArrowColor++;
    arrowColorTimer = millis();
  }
  
  // draw arrow at top and bottom for ADA compliancy
  fill(arrowColors[selectedArrowColor % arrowColors.length]);
  triangle((width - statusBarBound*0.75), (statusBarBound*1.25), 
           (width - statusBarBound*0.75), (statusBarBound*2.00), 
           (width - statusBarBound*0.10), (statusBarBound*1.625));
  rect(width - statusBarBound*0.95, statusBarBound*1.425, width*0.01, height*0.04);
  //bottom arrow
  triangle((width - statusBarBound*0.75), (height - statusBarBound*0.25), 
           (width - statusBarBound*0.75), (height - statusBarBound*1.00), 
           (width - statusBarBound*0.10), (height - statusBarBound*0.625));
  rect(width - statusBarBound*0.95, height - statusBarBound*0.425, width*0.01, 0-height*0.04);
  
  popStyle(); 
}

boolean nextSelected(float mx, float my) {
  boolean topArrow = ((width - statusBarBound) <= mx && mx <= width &&  statusBarBound <= my && my <= (2.25*statusBarBound));
  boolean botArrow = ((width - statusBarBound) <= mx && mx <= width &&  height - (1.25*statusBarBound) <= my && my <= height);
  return topArrow || botArrow;
}

boolean hintSelected(float mx, float my) {
  if(count < NUM_QUESTIONS){
    return ((sketchWidth*0.52 + textWidth(questionList.get(count).question)/2) <= mx && mx <= (sketchWidth*0.57 + textWidth(questionList.get(count).question)/2) && sketchHeight*.13 <= my && my <= sketchHeight*.175);
  }else{
    return false;
  }
}

//formerly mousePressed
void cursorDown(float x, float y) {

  cursorX    = x;
  cursorY    = y;

  //check if done
  if (!ready) {
    ready = true;  
    timerOn = true;
    
  //Check if click hint  
  } else if(hintSelected(cursorX, cursorY)){
    hintRequested = true;
  }else if (waiting && nextSelected(cursorX, cursorY)) {
    //click to continue after question
    count++;
    //continue
    result="";
    waiting = false;
    hintRequested = false;

    // disable HTML overlay
    document.getElementById("overlay").style.display = "none";
  } else {
    //Clicked a box -- do necessary scorekeeping
    for (Square box : squareList) {
      //scan to see which square was clicked, and mark it
      if (box.selected(cursorX, cursorY)) {
        mostRecent = box;
        box.clicked = true;
        attempts[questionList.get(count).attempts] = box.answerNumber;
        questionList.get(count).attempts++;

        // check if the answers of every square in the arrayList is equal to the correctAnswer on the questionList arrayList
        //SELECTED CORRECT BOX
        if (box.answerNumber == questionList.get(count).answer) {

          box.inactiveCorrect = true;
          box.setColor();
          result ="Correct (Amendment " + questionList.get(count).answer + ")";
          recordGameHistory(questionList.get(count).question, attempts[0], attempts[1], attempts[2], questionList.get(count).answer, "right");

          int points = MAX_POINT_VALUE - questionList.get(count).attempts + 1;
          //Slightly less points if you use a hint
          if(hintRequested && points > 0){
            points--;
          }
          popupList.add(new Popup(box.x + box.w/2, box.y, "+"+points, true));

          score += points;
          box.pointsReceived = points;

          //hold question and answer on the screen until click
          waiting = true;
          
          resetAnswers();
        } else {
          // to automatically answer after 3 attempts
          //Activate Incorrect Action (wiggle)
          box.wiggling = true;
          if (questionList.get(count).attempts > 2) {
            int ans = questionList.get(count).answer;
            Square correctBox = squareList.get(ans - 1);
            correctBox.inactiveWrong = true;
            correctBox.setColor();
            result = "The correct answer was Amendment " + ans;

            recordGameHistory(questionList.get(count).question, attempts[0], attempts[1], attempts[2], ans, "wrong"); 
            popupList.add(new Popup(correctBox.x + correctBox.w/2, correctBox.y, "WRONG", false));

            //hold question and answer on the screen until click
            waiting = true;
            
//            //check to avoid the arrows on the last question
//            if(count + 1 >= NUM_QUESTIONS){
//              count++;
//              //continue
//              result="";
//              waiting = false;
//              hintRequested = false;
//            }
//            
            resetAnswers();
          } else {
            result ="Wrong";
            box.incorrect = true;
            box.setColor();
          }
        }
      }
    }
  }
  if (count >= NUM_QUESTIONS) {
      timerOn = false;
      reset();
  } 
}

//Reset is called to start an entirely new round of the game
void reset() {
  //pause on end screen to show results -- resumes on touch
  launchTutorial();
  
  for (Square box : squareList) {
    box.resetFlags();
    result = "";
    questionList = shuffle(questionList);
  }
  for (Question q : questionList) {
    q.reset();
  }
  countdown = MAX_TIME;
  count = 0;
  score = 0;
  //make screen wait for user
  ready = false;
  hintRequested = false;
  waiting = false;
  safeToClearHistory = true;
}

//This is called to reset the status of the squares clicked for each question in a round
void resetAnswers() {
  attempts = [0, 0, 0];
  for (Square box : squareList) {
    box.incorrect = false;
    box.setColor();
  }
  hintRequested = false;
}

//This parses a file by comma, or by quotes if a statement has commas in it   
String[] splitLine(String line) {
  int substringcount = 0;
  ArrayList<String> stringlist = new ArrayList<String>();
  for (int i=0; i<line.length (); i++) {
    if ((line.substring(i, i+1).equals(",")) && !(line.substring(i+1, i+2).equals(" "))) {
      stringlist.add(line.substring(substringcount, i));
      substringcount = i+1;
    } else if (i == line.length()-1) {
      stringlist.add(line.substring(substringcount, line.length()));
    }
  }
  String[] strings = new String[stringlist.size()];
  strings = stringlist.toArray(strings);
  return strings;
}

//Shuffles the question order for every round
ArrayList<Question> shuffle(ArrayList<Question> list) {
  //generate a new random seed - need to call javascript to do so (doesn't work in processing)
  randomSeed(getRand());
  //generate 3 random numbers, multiply by a large prime, divide by a also large prime
  int times = (int)Math.floor(((random(1, 11)*random(1, 5)*random(1, 13) * 3457)/547));
  //Remove a random element from list 'x' times, and place at the backs
  while (times > 0) {
    list.add(list.remove((int)getRandRange(list.size())));
    times--;
  }
  return list;
}

//*
//*********************************************/
//*       PDE/JAVASCRIPT COMMUNICATION        */
//*********************************************/

function setCanvasSize() {

  var browserWidth    = window.innerWidth;
  var browserHeight   = window.innerHeight;
  sketchWidth         = browserWidth * 0.615;
  sketchHeight        = browserHeight;
}

function generateDescription() {
  String[] descriptionText = loadStrings("../web/description.html");
  String   joinedText      = join(descriptionText, " ");

  var descriptionDiv       = document.getElementById('description');
  descriptionDiv.innerHTML = joinedText;
}

function getRand() {
  return Math.random()*50192;
}

function getRandRange(x) {
  var value = Math.floor(x*Math.random());
  //small chance to return x -- in this case, I never want it to equal the actual list size,
  //so I have to account for when Math.random returns 1.0000...
  if (value == x) {
    return (value-1);
  }
  return value;
}

void visLoaded() {
  readyToDraw();
} 

boolean isArrowVisible() {
  if(waiting) return true;
  else return false; 
}

class Popup{
  float x;
  float y;
  String txt;
  float alpha;
  boolean correct;
  Popup(float X, float Y, String Txt, boolean Correct){
    x = X;
    y = Y;
    txt = Txt;
    alpha = 255;
    correct = Correct;
  }
  void adjust(){
    y -= width/1920;
    alpha -= 5;
  }
  void display(){
    pushStyle();
    stroke(1);
    textSize(height/20);
    if(correct)    fill(0, 255, 0, alpha);
    else           fill(255, 0, 0, alpha);
    text(txt, x, y); 
    popStyle();
  }
}
static final int MAX_POINT_VALUE = 3;
static final int MAX_GUESSES = 3;
static final int FULL_SIZE = 10;

class Question {
    String question;
    int answer;
    int hint;
    int attempts;
    int points;
    int size = 0;
    
    Question(String question, String hint, String answer) {
        this.question = question;
        this.answer = int(answer);
        this.hint   = int(hint);
        attempts = 0;
        size = 0;
        points = MAX_POINT_VALUE;
    }
    
    void reset(){
        attempts = 0;
        size = 0;
    }
}
class Square {
  //Wiggle const
  static final float WIGGLE = 2.0;
  
  //Some basic color constants used:
  static final color RED = color(255,0,0,51);
  static final color GREEN = color(0,255,0,51);
  static final color PURPLE = color(255, 0, 255, 128);
  static final color PARCHMENT = color(60, 60, 40);
  static final color GREY = color(128, 128, 128);

  // coordinate of the square
  float   x, y;   
  float   w, h; 
  int     answerNumber;
  int     pointsReceived;

  boolean inactiveCorrect;
  boolean inactiveWrong;
  boolean incorrect;
  boolean clicked;

  boolean wiggling;
  float wiggle;

  //variable to store the color of the square
  color c;
//CLEAN UP?  
  //Lets the box turn green for a short time before going grey
//  int greenFade;
//  int redFade;

  Square(float x, float y, float w, float h, int answerNumber) {
    this.x       = x;
    this.y       = y;
    this.w       = w;
    this.h       = h;
    c            = PARCHMENT;
    this.answerNumber  = answerNumber;
    pointsReceived = 0;
    
    clicked = false;
    //inactive = guessed right, can't select anymore
    inactiveCorrect = false;
    inactiveWrong = false;
    //incorrect = guessed wrong, reset for each new question
    incorrect = false;

//CLEAN UP?
    //greenFade = 0;
    //redFade = 0;

    wiggling = false;
    wiggle = WIGGLE;
  }

  //To detect if the square was clicked
  boolean selected(float mx, float my) {
    return !(inactiveCorrect || inactiveWrong || incorrect) && (mx >= x && mx <= x+w && my >= y && my <= y+h);
  }

  //method to display the squares
  void display() {    
    pushStyle();
    pushMatrix();
    if (wiggling) {//introduce wiggle effect
      translate(x+wiggle, y);
    } else {//normal translate
      translate(x, y);
    }
    rectMode(CORNER);
    
    /*
    CLEAN UP?
    //set color to the rect
    if (inactiveCorrect) {
      if (greenFade < 20) {
        greenFade++;
      }
    } else if (inactiveWrong) {
      if (redFade < 20) {
        redFade++;
      }
    }
    */
    
    setColor();
    fill(c);
    //draw the rectangle
    stroke(255);
    strokeWeight(2);
    rect(0, 0, w, h, 5, 5, 5, 5);
    
    //display text
    textAlign(CENTER);
    if(inactiveCorrect || inactiveWrong || incorrect){
      fill(255);
    }else{
      fill(0);
    }
    textFont(scriptFont);
    textSize(h/6);
    text("Amendment", w/2, h/4);
    textSize(h/2);
    text(answerNumber, w/2, h*0.8);
    
    popMatrix();
    popStyle();
    updateWiggle();
  }

  //this will show how many points you recieved from the questions (doesn't show anything if 0
  void showPoints(){
    pushStyle();
    pushMatrix();
    translate(x, y);
    
    if(pointsReceived > 0){
      fill(255);
      textSize(h/9);
      String points = "Points: " + pointsReceived;
      text(points, w/2, 0-(h/9));
    }
    
    popMatrix();
    popStyle();
  }

  //sets the color of the square based on the flags
  void setColor() {
    if (inactiveCorrect) {
      //fade to pale green
      //c = color(greenFade, 255, greenFade);
      c = GREEN;
    } else if (inactiveWrong) {
      //fades to pale red
      //c = color(255, redFade, redFade);
      c = RED;
    } else if (incorrect) {
      c = GREY;
    } else {//can still be clicked
      c = PARCHMENT;
    }
  }

  void resetFlags() {
    //reset state of boxes so that they can be clicked again
    pointsReceived = 0;
    clicked = false;
    inactiveCorrect = false;
    inactiveWrong = false;
    incorrect = false;

//CLEAN UP
//    greenFade = 0;
//    redFade = 0;

    wiggling = false;
    wiggle = WIGGLE;

    setColor();
  }

  void updateWiggle() {
    if (wiggling) {
      if (Math.abs(wiggle) > 0.01) {
        wiggle *= -0.95;
      } else {
        wiggle = 0;
        wiggling = false;
      }
    } else {
      //reset wiggle
      wiggle = WIGGLE;
    }
  }
}


