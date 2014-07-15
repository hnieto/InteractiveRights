class Square {

  float   x, y;   
  float   w, h;  
  int     value     = 0;
  boolean clicked;
  String  answer    = "";
  boolean tm;

  Square(float x, float y, float w, float h, String answer) {
    this.x       = x;
    this.y       = y;
    this.w       = w;
    this.h       = h;
    this.clicked = false; 
    this.answer  = answer;
  }

  boolean selected(float mx, float my) {
    return (mx >= x && mx <= x+w && my >= y && my <= y+h); // to know if the square was selected
  }

  void display() {

    if (clicked) fill(100);
    else fill(255, 0, 255, 128);

    rect(x, y, w, h); 

    if (y > 200 && newCuestionX) { // condition to display the square along the y axis
      y -=3; //variable that states how fast are the squares going to move along the y axis
    } else {
      if(!timerOn) {
        startTime = millis();
        timerOn = true;
        
      }
      newCuestionX= false;
    }

    if (x < 1100 && newCuestionY) { //when newCuestionY is true, the questions will be moved to the right along the x-axis
      x+=6;
    } else {
      if (newCuestionY) {
        count++;
        reset();
      }
      newCuestionY= false;
    }
  }
}//class Square

