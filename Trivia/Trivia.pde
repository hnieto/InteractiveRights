/*
TODO:
    DONE FOR NOW
*/
 
/* @pjs font='../data/RefrigeratorDeluxeLight.ttf, ../data/Digital.ttf'; */
 
static final int MAX_TIME = 240;
static final int NUM_QUESTIONS = 27;

//Color for status bar
color statusBarColor = color(40,10,10);

int wait = 5*1000;
int startTime;
boolean timerOn = false;
int countdown;

// Arraylists for the questions and squares
ArrayList<Question> questionList;
ArrayList<Square> squareList;

//question index
int count;

//variables to display the score and to say if its correct
String result = "";
int score;
int attempt;

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

//Lower bound for the status bar
float statusBarBound;

//Variables to cause the screen to wait for input
boolean waiting;
boolean ready;

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
//    size(1600, 900);    //FOR DEBUG
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
    ready = false;
  
    // Initialize the ArrayLists
    questionList = new ArrayList<Question>();
    squareList = new ArrayList<Square>(); 
  
    // creating object from a text file -- creating object form a text file
    String[] data = loadStrings("../data/data.txt");
  
    // read line by line
    for (int i=0; i<data.length; i++) {
        String[] values = splitLine(data[i]);
        String question = values[0];
    
        //Crop quotes out of question string
        question = question.substring(1, question.length()-1);
    
        //To add the questions, incorrect answers, and solutions into the arrayList
        questionList.add(new Question(question, values[1]));
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
    defaultFont                = createFont("../data/RefrigeratorDeluxeLight.ttf", fontSize);
    digitalFont                = createFont("../data/Digital.ttf", fontSize/**4*/);
    textAlign(CENTER);
    textFont(defaultFont);
    
    questionList = shuffle(questionList);
    background(0);

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
  //display statusBar
  fill(statusBarColor);
  rect(0,0, sketchWidth, statusBarBound);
  stroke(255,0,0);
  line(0,statusBarBound,sketchWidth,statusBarBound);
  stroke(0);
  //reset fill
  fill(255);
    
  if(!ready){
    //show that we are waiting for user input
    textSize(sketchWidth/37.5);
    String restart = "TAP ANYWHERE TO START";
    text(restart, (sketchWidth-textWidth(restart))/2 + textWidth(restart)/2, sketchHeight*7/16);
    
  }else if(count >= NUM_QUESTIONS){  //Check if round finished
    //round complete -- show points received
    for (Square box : squareList) {    
      //display each square
      box.showPoints(); 
    }
    
    timerOn = false;
    textFont(digitalFont);
    fill(255,0,0);
    String completionText = "ROUND OVER";
    textSize(sketchWidth/37.5);
    text(completionText, (sketchWidth-textWidth(completionText))/2 + textWidth(completionText)/2, sketchHeight/21);
    
    fill(255);
    textFont(defaultFont);
    int intElapsedTime = (int)(MAX_TIME - countdown);
    String stats;
    if(intElapsedTime%60 < 10){
        stats = "Final Score: " + score + "\nElapsed Time: " + (int)(intElapsedTime/60) + ":0" + intElapsedTime%60;
    }else{
        stats = "Final Score: " + score + "\nElapsed Time: " + (int)(intElapsedTime/60) + ":" + intElapsedTime%60;
    }
    text(stats, (sketchWidth-textWidth(stats))/2 + textWidth(stats)/2, sketchHeight/6);
    
    String restart = "TAP ANYWHERE TO RESTART";
    text(restart, (sketchWidth-textWidth(restart))/2 + textWidth(restart)/2, sketchHeight*7/16);
    
  }else{
    //keep going -- may be in waiting mode (tap to continue)
    
    //Display question -- when a new question is introduced, it grows until full size.
    float fullTextSize = sketchWidth/37.5;
    textSize(fullTextSize * (((float)questionList.get(count).size)/FULL_SIZE));
    if(questionList.get(count).size < FULL_SIZE){
        questionList.get(count).size++;
    }
   
   //Display question
    text(questionList.get(count).question, (sketchWidth-textWidth(questionList.get(count).question))/2
            + textWidth(questionList.get(count).question)/2, sketchHeight/6);
    
    //Reset size to normal
    textSize(fullTextSize);
    
    //To display if the selected answer is correct
    if(!result.substring(0,5).equals("Wrong") && !result.equals("")){
        text(result, sketchWidth *.5, sketchHeight/5); 
        waiting = true;
    }else if(!result.equals("")){
        //diplay at box location
        text(result, mostRecent.x + mostRecent.w/2, mostRecent.y + mostRecent.h + textAscent() + textDescent());
    }
    
    if(waiting){
        text("TAP TO CONTINUE", sketchWidth/2, sketchHeight*7/16);
    }
    
    //To display score
    textFont(digitalFont);
    fill(255, 0, 0);
    String currScore = "Score: " + score;
    text(currScore, sketchWidth*0.1, sketchHeight/21);
  
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
    if(intTime%60 < 10){
        time = "Time: " + (int)(intTime/60) + ":0" + intTime%60;
    }else{
        time = "Time: " + (int)(intTime/60) + ":" + intTime%60;
    }
    text(time, sketchWidth*0.9, sketchHeight/21);
    
    //reset fonts
    textFont(defaultFont);
    fill(255);
  }
}


void mousePressed() {
  //check if done
  if(!ready){
    ready = true;  
    timerOn = true;
  }else if(waiting){
    //click to continue after question
    count++;
    //continue
    result="";
    waiting = false;
  }else if(count >= NUM_QUESTIONS){
    reset();
  }else{
    for (Square box : squareList) {
      //scan to see which square was clicked, and mark it
      if (box.selected(mouseX, mouseY)) {
        mostRecent = box;
        box.clicked = true;
        questionList.get(count).attempts++;
  
        // check if the answers of every square in the arrayList is equal to the correctAnswer on the questionList arrayList
        if (box.answerNumber == questionList.get(count).answer) {
          
          box.inactiveCorrect = true;
          box.setColor();
          result ="Correct (Amendment " + questionList.get(count).answer + ")";
  
//This should work, but it doesn't?
          int points = MAX_POINT_VALUE - questionList.get(count).attempts + 1;
          score += points;
          box.pointsReceived = points;
          
          //hold question and answer on the screen until click
          waiting = true;
          
          resetAnswers();
        }else{
          // to automatically answer after 3 attempts
          //Activate Incorrect Action (wiggle)
          box.wiggling = true;
          if (questionList.get(count).attempts > 2) {
            //ADD THIS!
            //squareList.get(questionList.get(count).answer - 1).highlight = true;
            squareList.get(questionList.get(count).answer - 1).inactiveWrong = true;
            squareList.get(questionList.get(count).answer - 1).setColor();
            result ="The correct answer was Amendment " + questionList.get(count).answer;
            
            
            //hold question and answer on the screen until click
            waiting = true;
            
            resetAnswers();
          }else{
            result ="Wrong";
            box.incorrect = true;
            box.setColor();
          }
        }
      }
    }
  }
}

void reset() {
    for(Square box : squareList){
        box.resetFlags();
        result = "";
        questionList = shuffle(questionList);
    }
    for (Question q : questionList){
        q.reset();
    }
    countdown = MAX_TIME;
    count = 0;
    score = 0;
    //make screen wait for user
    ready = false;
}


void resetAnswers(){
    for(Square box : squareList){
        box.incorrect = false;
        box.setColor();
    }
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

/*
/*********************************************/
/*       PDE/JAVASCRIPT COMMUNICATION        */
/*********************************************/

function setCanvasSize() {

  var browserWidth    = window.innerWidth;
  var browserHeight   = window.innerHeight;
  sketchWidth         = browserWidth;
  sketchHeight        = browserHeight * 1;
}

function getRand() {
 return Math.random()*50192; 
}

function getRandRange(x){
  var value = Math.floor(x*Math.random());
  //small chance to return x -- in this case, I never want it to equal the actual list size,
  //so I have to account for when Math.random returns 1.0000...
  if(value == x){
    return (value-1);
  }
  return value;
}

void visLoaded() {
    readyToDraw();
} 

