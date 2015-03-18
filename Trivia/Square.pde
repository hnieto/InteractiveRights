class Square {
  //Wiggle const
  static final float WIGGLE = 2.0;

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
  //Lets the box turn green for a short time before going grey
  int greenFade;
  int redFade;

  Square(float x, float y, float w, float h, int answerNumber) {
    this.x       = x;
    this.y       = y;
    this.w       = w;
    this.h       = h;
    c            = color(255, 0, 255, 128);
    this.answerNumber  = answerNumber;
    pointsReceived = 0;
    
    clicked = false;
    //inactive = guessed right, can't select anymore
    inactiveCorrect = false;
    inactiveWrong = false;
    //incorrect = guessed wrong, reset for each new question
    incorrect = false;

    greenFade = 0;
    redFade = 0;

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
    //gray [color(128, 128, 128)]
    if (inactiveCorrect) {
      //fade to pale green
      c = color(greenFade, 255, greenFade);
    } else if (inactiveWrong) {
      //fades to pale red
      c = color(255, redFade, redFade);
    } else if (incorrect) {
      //red
      c = color(128, 128, 128)//color(255, 0, 0); CHECK WITH THIS?
    } else {//can still be clicked
      //purple
      //c = color(255, 0, 255, 128);
      //parchment color
      //c = #B7A159;#F8ECC2;
      c = color(60, 60, 40);
    }
  }

  void resetFlags() {
    //reset state of boxes so that they can be clicked again
    pointsReceived = 0;
    clicked = false;
    inactiveCorrect = false;
    inactiveWrong = false;
    incorrect = false;

    greenFade = 0;
    redFade = 0;

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

