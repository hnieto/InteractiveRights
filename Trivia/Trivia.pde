
int wait = 5*1000;
int startTime;
boolean timerOn = false;
int timeLimit = 10;
int timer = 10;


ArrayList<Question> pregC; // declare arrayList of type Question
ArrayList<Square> squareC; //declare arrayList of type Square
int count = 0;
boolean newCuestionX = true;
boolean newCuestionY = false;
String anuncio = " ";
int score = 0;
float sketchWidth, sketchHeight;


void setup()
{
  // javascript function to set sketch size according to the width of the browser
  setCanvasSize();
  size(sketchWidth,sketchHeight);
  
  background(255);
  noStroke();

  // Initialize the ArrayLists
  pregC = new ArrayList<Question>();
  squareC = new ArrayList<Square>(); 

  // creating object from a text file -- creating object form a text file
  String[] data = loadStrings("../data/data.txt");

  // read line by line
  for (int i=0; i<data.length; i++)
  {
    String[] values = split(data[i], ",");
    String question = values[0];
    String solution = values[1];

    String[] incorrectAnswers = new String[10];

    // create wrong answers

    for (int j=0; j<incorrectAnswers.length; j++) {

      incorrectAnswers[j] = "Amendment " + str((int)random(1, 28));

      // if(incorrectAnswers[j] == incorrectAnswers[j++])
      //{
      //incorrectAnswers[j] = "Amendment " + str((int)random(1,28));
      //}
    }
    int n = ((int)random(1, 6));
    incorrectAnswers[n] = solution; 

    pregC.add((new Question(question, incorrectAnswers[0], incorrectAnswers[1], incorrectAnswers[2], incorrectAnswers[3], incorrectAnswers[4], incorrectAnswers[5], incorrectAnswers[6], incorrectAnswers[7], incorrectAnswers[8], incorrectAnswers[9], solution)));
  }

  reset();
  background(0);
  
  noLoop(); // do not draw anything until vis is selected in html
}

//--------------------------------------------------

void reset() {

  newCuestionX=true; // this will make the squares move to the top
  newCuestionY=false; // variable to move the squares move to the right whenever it is set to true
  anuncio="";
  squareC.clear();
  String res=""; // variable to store each incorrectaAnswer in the constructor

  for (int i=0; i<10; i++) {
    
    switch (i) {
    //set each incorrect answer to the res variable in each case 0, 1, 2, 3, 4, 5, 6, 7
    case 0: res=pregC.get(count).r1; break; 
    case 1: res=pregC.get(count).r2; break;
    case 2: res=pregC.get(count).r3; break;
    case 3: res=pregC.get(count).r4; break;
    case 4: res=pregC.get(count).r5; break;
    case 5: res=pregC.get(count).r6; break;
    case 6: res=pregC.get(count).r7; break;
    case 7: res=pregC.get(count).r8; break;
    case 8: res=pregC.get(count).r9; break;
    case 9: res=pregC.get(count).r10;break;
    }

   // Adding the squares into the squareC arrayList
    if (i<5){ /// if there are at least 5 answers-- 5 squares 
      squareC.add(new Square(10+(i*110),400,100,80,res)); //add the squares into the arrayList scuareC- put the squares into the position
    } else {
      squareC.add(new Square(squareC.get(i-5).x,500,100, 80, res)); ///else add the squares at the position below of the first ones 
    }
   
    fill(0, 0, 255, 128); //set the color for the squares
    rect( squareC.get(i).x, squareC.get(i).y, 40, 40); ///draw each rectangle with the assigned answer and position as stated above 
    
}
}

//--------------------------------------------------
void mousePressed() {
  for (int i=0; i< 10; i++) {
     // check if every square in arrayList is selected then set clicked to true
    if (squareC.get(i).selected(mouseX, mouseY)) {
        squareC.get(i).clicked = true; 
       
       // check if the answers of every square in the arrayList is equal to the correctAnswer on the pregC arrayList
      if(squareC.get(i).answer == pregC.get(count).rCorrect) {  
        anuncio="Correct!!!";
        newCuestionY= true;    //set the newCuestionY to true whenever the answer in the squareC arraylist is equal to the correct answer in the pregC arrayList
        score += 5;
      } else {
        anuncio="Wrong!!!";
        //score -=2;
      }
    }
  }
}

//-------------------------------------------

void draw() {
  
  //background(0);  
   
 //if (millis()-time >= wait)
//{ 
  background(0);
   
  for (int i=0; i<10; i++)
  {    
    //display each square
    squareC.get(i).display(); 
    textSize(10);
    fill(255);
    text(squareC.get(i).answer, squareC.get(i).x+5, squareC.get(i).y+40); // text to appear
    
 // }
  
  textSize(16);
  fill(255);
  text(pregC.get(count).question, 10, 130); //display question
  text(anuncio,100, 450); //displays if its correct
  int Score = score;
  text("Score:" + Score, 480, 30); 
  
  if(timerOn){
    if(millis()-startTime > 1000) {
      timer -= 1;
      
      if(timer < 0) {
        newCuestionY = true; 
        timerOn = false;
        timer = timeLimit;
      }
      
      startTime = millis();
    }
  }
  text("Time:" + timer, 20, 30); 
}
   
}
//put the timer and subtract 5 seconds everytime they get wrong an answer
/////--------------------------------------------------

/*********************************************/
/*       PDE/JAVASCRIPT COMMUNICATION        */
/*********************************************/

function setCanvasSize(){

  var browserWidth    = window.innerWidth;
  var browserHeight   = window.innerHeight;
  sketchWidth         = browserWidth;
  sketchHeight        = browserHeight * 0.95;

}
