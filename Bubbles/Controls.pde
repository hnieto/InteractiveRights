// This code was based off of:
// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2012
// Box2DProcessing example

class PlayPause {

  float x;
  float y;
  float w;
  float h;

 PlayPause(float x_,float y_, float w_, float h_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
  }

  void display() {
    fill(255);
    strokeWeight(0);
    if(play){
      rectMode(CENTER);
      rect(x - w/4, y, (w/3), (h));
      rect(x + w/4, y, (w/3), (h));
    }
    else{
      triangle((x - w/2), (y - h/2),
                (x - w/2), (y + h/2),
                (x + w/2), (y));
    }
  } 
  
  boolean contains(float x, float y) {
    boolean inside = false;
    if((x < this.x + this.w/2) && (x > this.x - this.w/2) && (y < this.y + this.h/2) && ( y > this.y - this.h/2)){
      inside = true;
    }
    return inside;
  }

}


class NextButton {

  float x;
  float y;
  float w;
  float h;

 NextButton(float x_,float y_, float w_, float h_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
  }

  void display() {
    fill(255);
    strokeWeight(0);
    rectMode(CENTER);
    triangle((x - w/2), (y - h/2),
              (x - w/2), (y + h/2),
              (x + w/4), (y));
    rect(x + 3*w/8, y, w/4, h);
  } 
  
  boolean contains(float x, float y) {
    boolean inside = false;
    if((x < this.x + this.w/2) && (x > this.x - this.w/2) && (y < this.y + this.h/2) && ( y > this.y - this.h/2)){
      inside = true;
    }
    return inside;
  }

}

class PreviousButton {

  float x;
  float y;
  float w;
  float h;
  
 PreviousButton(float x_,float y_, float w_, float h_) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
  }

  void display() {
    fill(255);
    strokeWeight(0);
    rectMode(CENTER);
    triangle((x + w/2), (y - h/2),
              (x + w/2), (y + h/2),
              (x - w/4), (y));
    rect(x - 3*w/8, y, w/4, h);
  } 
  
  boolean contains(float x, float y) {
    boolean inside = false;
    if((x < this.x + this.w/2) && (x > this.x - this.w/2) && (y < this.y + this.h/2) && ( y > this.y - this.h/2)){
      inside = true;
    }
    return inside;
  }

}



