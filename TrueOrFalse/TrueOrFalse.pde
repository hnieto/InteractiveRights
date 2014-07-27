ArrayList    <Ball> balls;//creates the array list balls
ArrayList    <Ball> amendments;


String       [] data;


//setting the window speceifications and boundaries
//lasso specs (for 2 rows and 1 column): width=1920, height=2160 
float        sketchWidth;//sets the width of the window
float        sketchHeight;//sets the height of the window
float        heightuPB;//the height of the height of the window and the upper bottom boundary
float        uPB;//sets the upper platform boundary 
float        infoBoundary;//sets the boundary for the score and time on the top of the boundary


//setting the ball's specifications
int          numBall=5;//number of balls to appear
int          numBallLimit=numBall;//max number of balls to appear
int          maxspeed=3;//maximum speed of ball 
int          minspeed=1;//minimun speed of the ball
int          j= 0;//identification number for each ball

float        radius;//sets the radius of the ball
float        diameter;//sets the diameter of the ball
float        secondsPerBall=1*1000;//delay time per ball to respawn
float        spring = 0.05;//spring effect of the ball

int          xRespawn;//sets where the ball will respawn on the x axis
int          yRespawn;//sets where the ball will respawn on the y axis



//setting the font specifications for teh text in the circle as well as the score and timer
float        fontSize;
float        fontColor=255;
float        lineSpacing;
/* @pjs font='../data/RefrigeratorDeluxeLight.ttf */



//time variables
int          startTime, startTime2;
int          currentTime;
int          remainingTime= 180;
int          timeInc = 0;
int          timeDec = 0;
int          timerSeconds;
int          timerMinutes;
String       zero;


//score
int          score=0;
int          pointsInc=3;
int          correctBall;
int          incorrectBall;


//color of ball
color       ballColor= color(0, 0, 255);

//color of ball when selected
color        selectedBallColor= color(111, 126, 216);

//color of platforms true and false
int          trueColorR=50;
int          trueColorG=127;
int          trueColorB=133;

int          falseColorR=170;
int          falseColorG=71;
int          falseColorB=67;

//platform and ball transperancy and color
int          platformTrans=180;
int          noTrans=255;
int          trueTrans;
int          falseTrans;



//the color of the info board
color        infoBoardColor=color(118, 0, 0);


//variables for levels
int          gameLevel=1;
boolean      timePause;
int          remainingBall=numBall;
int          levelDelay=3*1000;


void setup() {
  // javascript function to set sketch size according to the width of the browser
  setCanvasSize();
  size(sketchWidth, sketchHeight);

  // initialize variables who's value is based off sketchHeight
  heightuPB=sketchHeight/6;
  uPB=sketchHeight-heightuPB;
  radius = heightuPB*.47;
  diameter= 2*radius;
  fontSize=radius*.15;
  lineSpacing=fontSize;
  infoBoundary=height/20;
  yRespawn=radius+infoBoundary;


  background(0);
  smooth();


  //initializing start times for the respawn delay and the timer
  startTime = millis();//used for the respawning of the balls
  startTime2 = millis();//used for the counter
  timerMinutes=int(remainingTime/60);
  timerSeconds=remainingTime-(timerMinutes*60);

  //text settings
  PFont defaultFont = createFont("../data/RefrigeratorDeluxeLight.ttf", fontSize);
  textAlign(CENTER);//centers text
  textFont(defaultFont);


  //Initializing the ArrayLists
  balls = new ArrayList<Ball>();//setting balls, as a new empty array list
  //Creating an object from a text file
  amendments = new ArrayList<Ball>();//setting amendments, as a new empty array list
  data = loadStrings("../data/true_statements.txt");

  //initiallizing values
  correctBall=0;
  incorrectBall=0;

  //initializing the counter for the max number of balls to appear
  numBallLimit=0;



  //initialling the transparency of the platforms true and false
  trueTrans=platformTrans;
  falseTrans=platformTrans;


  noLoop(); // do not draw anything until vis is selected in html
}





void draw() {
  background(0);


  //draw bottom platforms true and false and the info board, a push and pop Matrix is used to make sure the platforms can be drawn from the corner instead of the center
  pushMatrix();
  rectMode(CORNER);


  fill(infoBoardColor);
  rect(0, 0, width, infoBoundary);

  //true platform
  fill(150);
  rect(0, uPB, width, heightuPB);
  fill(trueColorR, trueColorG, trueColorB, trueTrans);
  rect(0, uPB, width/2, heightuPB);
  //false platform
  fill(falseColorR, falseColorG, falseColorB, falseTrans);
  rect(width/2, uPB, width/2, heightuPB);
  popMatrix();



  // inserting text for the platforms true and false
  fill(255);
  textSize(fontSize*8);
  String trueQuote = "TRUE";
  String falseQuote= "FALSE";
  text(trueQuote, width/4, height-height/17);
  text(falseQuote, width-width/4, height-height/17);

  //if there is still balls on the screen then the level hasn't been completed and will continue running the time
  //  if (remainingBall != 0) {
  //    timerPause == false;
  //  }



  currentTime = millis();
  //Setting the timer to decrease only when a second has passed to allow modifications later on such as when points are increased
  if (timePause == false) {

    if (currentTime-startTime2 > 1000) {//if one second passes
      remainingTime -= 1;
      timerSeconds -= 1;

      //setting the digital timer parameters
      if (timerSeconds == -1 && timerMinutes != 0) { //if the seconds = 0 and there is still minutes, the seconds are resetted to 59 and a minute is reduced
        timerSeconds = 59;
        timerMinutes -= 1;
      }

      if (timerSeconds<=0 && timerMinutes == 0) {//if both seconds and minutes are at zero, then they'll remain in zero
        timerSeconds=0;
        timerMinutes=0;
      }

      //prevents time from going lower than zero
      if (remainingTime <=0) {
        remainingTime=0;
      }
      startTime2 = currentTime;
    }
  }

  //("frame " + frameCount);
  //  int respawnDelay = int(secondsPerBall * 60);//respawn delay in seconds; int is used to obtain framecount values; i.e. fractions of a seconds
  //  //Code for delayed drawing of balls

  //if statement that will create a ball after a certain time.
  if ((currentTime-startTime > secondsPerBall) && balls.size()<numBall && numBallLimit != numBall ) {//runs if the time is greater than secondsPerBall, the size of the arraylist balls is smaller than the number of balls and if the limit (numBallLimit)  hasn't reached the number of balls 
    xRespawn= int(random(radius, width-radius));//this sets a random number for the x-axis origin of the circle greater than the radius, but less than the width-radius to avoid having

    //creates a random coloor
    //    int randomColorR=int(random(0, 256));
    //    int randomColorG=int(random(0, 256));
    //    int randomColorB=int(random(0, 256));

    //the ball will be given a random speed rate 
    int xsrandom = int(random(minspeed, maxspeed));//x- speed random 
    int ysrandom = int(random(minspeed, maxspeed));//y- speed random

    // the sign positive or negative will be given to have the ball go either left or right by a chance of 50%
    int b = int(random(0, 2));
    if (b == 0) {
      xsrandom = int (-1.0 * xsrandom);
      ysrandom = int (-1.0 * ysrandom);
    }

    //  balls.add(new Ball(xRespawn, radius, diameter, diameter, color(randomColor, randomColor, randomColor), xsrandom, ysrandom, j , balls));//adds a new ball with the specified parameters
    //create a ball
    Ball newBall = new Ball(xRespawn, yRespawn, diameter, diameter, ballColor, xsrandom, ysrandom, j, this, data);
    newBall.init();
    balls.add(newBall);//adds a new ball with the specified parameters
    j++;
    numBallLimit++;//increases the count of balls to make sure new balls are created when the number of balls (numBall) isn't surpassed
    //    frameCount=0;//resets the framecount to 0
    startTime = currentTime; // reset timer, next time if loop gets executed,
  }



  for (int i= 0; i<balls.size (); i++) {//runs for the entire size of the Arraylist:balls
    Ball b = (Ball) balls.get(i);//sets the variable b, data type Ball to obtain all of the information of each element.

    b.drawBall();
    b.updatePosition();
    b.selectedBall();
    //checks the function belowBoundary to see if the ball has been dragged and released below the boundary
    if (b.belowBoundary()) {
      remainingBall--;
      //println(remainingBall);
      //increase time and points if the true ball is put on the left side and if the false ball is put on the right side
      if (b.correctLocationTrue()) {
        score += pointsInc;
        remainingTime += timeInc;
        correctBall++;
      }

      if (b.correctLocationFalse()) {
        score +=pointsInc;
        remainingTime += timeInc;
        correctBall++;
      }
      //decreases time  if the true ball is put on the right side and if the false ball is put on the left side
      if (b.wrongLocationTrue()) {
        remainingTime -= timeDec;
        incorrectBall++;
      }

      if (b.wrongLocationFalse()) {
        remainingTime -= timeDec;
        incorrectBall++;
      }
      //prevents negative points
      if (score<0) {
        score=0;
      }
      //removes ball one dragged below the boundary and reverts the true and false transparacy platforms back to normal
      trueTrans=platformTrans;
      ;

      falseTrans=platformTrans;
      ;


      //removes ball one dragged below the boundary
      balls.remove(i);
    }
    b.collide();
  }

  //  //draw images true and false
  //  image(imgTrue, 0, uPB, width/2, heightuPB);
  //  image(imgFalse, width/2, uPB, width/2, heightuPB);





  //Display the remaining time and the score
  fill(255);
  textSize(fontSize*3);
  textMode(RIGHT);  

  //makes sure that there is at least three digits in the clock
  if (timerSeconds < 10) {
    zero = "0";
  } else {
    zero = "";
  }
  String timeQuote = "TIME  " + timerMinutes + " : " + zero + timerSeconds;
  String scoreQuote= "SCORE : "+ score;
  String levelQuote= "LEVEL : " + gameLevel;
  text(timeQuote, width-width/8, height/25);
  text(scoreQuote, width/9, height/25);
  text(levelQuote, width/2, height/25);


  // Remove the balls and indicate that the game is over, when the timer runs out, and the final score of the user as well as how many they got write and wrong
  if (remainingTime==0) {

    //remove all of the balls so the user can't increase points once the timer runs out
    for (int i= 0; i<balls.size (); i++) {//runs for the entire size of the Arraylist:balls
      Ball b = (Ball) balls.get(i);
      balls.remove(i);
    }


    //inserting all of the text that will show the user's final score
    pushMatrix();
    textSize(fontSize*5);
    textAlign(CENTER);
    rectMode(CENTER);
    String gameOver= "GAME OVER" + "\n" + "Final Score : " + score + "\n" + "Correct : " + correctBall + "\n" + "Incorrect : " + incorrectBall + "\n" + "Touch the screen to play again" ; 
    float scalar= 1.25;
    float textHeight= (textAscent() + textDescent())*scalar;// height of the text 
    textLeading(lineSpacing*5);
    float z= textWidth(gameOver)*1.5;
    text(gameOver, width*.17, height*.25, z, textHeight*5 );
    popMatrix();
  }

  //  println(numBall);//remains the same; set amount of balls
  //  println(numBallLimit);// counts up untill it equals numBall
  // println(remainingBall);// counts how many balls are in the screen


  //  //informs the user of the next level and increase the difficulty  
  if (remainingBall == 0) {
    gameLevel++;//increases level

    //pauses the screen for a set delay to allow the user to know of the next level
    levelDelayTimer=millis();//starts a new timer for the level delay
    println(levelDelayTimer);
    if (levelDelayTimer-(levelDelay+startTime2) <= 0) {
      timerPause = true;
    } else {
      //once the delay ends the new level is set with faster speed, increased number of balls
      timerPause = false;
      numBall +=5;//increases the number of balls by 5 each level
      maxspeed +=.2;//increases speed each level
      numBallLimit=0;//reset the limit of balls in the screen
      remainingBall=numBall;//the amount of remaining balls is also resetted to escape this loop
    }

    pushMatrix();
    textSize(fontSize*5);
    textAlign(CENTER);
    rectMode(CENTER);
    float scalar= 1.25;
    float textHeight= (textAscent() + textDescent())*scalar;// height of the text 
    String nextLevel = "Level: " + gameLevel + "\n" + "Start";
    float z = textWidth(nextLevel)*1.5;
    text(nextLevel, width*.43, height*.38, z, textHeight*2);
    popMatrix();
  }
}


//run mousePressed on all of the balls
void mousePressed() {

  for (int i= 0; i<balls.size (); i++) {
    Ball b = (Ball) balls.get(i);
    if (b.mouseOver(mouseX, mouseY)) {
      b.mousePressed();
    }
  }
}


//run mouseReleased for all of the balls
void mouseReleased() {
  for (int i= 0; i<balls.size (); i++) {
    Ball b = (Ball) balls.get(i);
    b.mouseReleased();
  }
}

/*********************************************/
/*       PDE/JAVASCRIPT COMMUNICATION        */
/*********************************************/
function setCanvasSize() {

  var browserWidth    = window.innerWidth;
  var browserHeight   = window.innerHeight;
  sketchWidth         = browserWidth;
  sketchHeight        = browserHeight * .99;
}

