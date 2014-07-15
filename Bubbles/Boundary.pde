//This code was borrowed from:
// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2012
// Box2DProcessing example

// A fixed boundary class (now incorporates angle)

class Boundary {

  // A boundary is a simple rectangle with x,y,width,and height
  float x;
  float y;
  float w;
  float h;

 Boundary(float x_,float y_, float w_, float h_, float a) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;
 }
  
  boolean contains(float x, float y) {
    boolean inside = false;
    if((x < this.x + this.w/2) && (x > this.x - this.w/2) && (y < this.y + this.h/2) && ( y > this.y - this.h/2)){
      inside = true;
    }
    return inside;
  }

  // Draw the boundary, it doesn't move so we don't have to ask the Body for location
  void display() {
    fill(255);
    stroke(0);
    strokeWeight(0);
    rectMode(CENTER);
    pushMatrix();
    translate(x,y);
    rect(0,0,w,h);
    popMatrix();
  }

}


