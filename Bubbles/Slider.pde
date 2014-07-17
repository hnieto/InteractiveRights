// Code based off of:
// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2012
// Box2DProcessing example

// A slider

class Slider {

  float w;
  float h;
  float bar_length;
  float x;
  float y;
  float bar_height;
  float thumbX, thumbY;
  
  boolean sliding;
  float slidingX, initialX;
  float slidingV;
  
  // Constructor
  Slider(float x_, float y_, float w_, float h_, float L_, float H_) {
    x = x_; //coordinates of center
    y = y_;
    w = w_; //width of thumb
    h = h_; //height of thumb
    bar_length = L_; //length of bar
    bar_height = H_; //height of bar
    sliding = false;
  }
  
  void moveTo(float x, float y){
    thumbX = x;
    thumbY = y;
  }
  
  void slideTo(float x, float y){
    slidingX = this.thumbX;
    initialX = this.thumbX;
    thumbX = x;
    thumbY = y;
    slidingV = 0;
    sliding = true;
  }

  // Drawing the box
  void display() {
    
    textAlign(CENTER, CENTER);
    rectMode(PConstants.CENTER);
    pushMatrix();
    
    strokeWeight(0); 
    
    fill(40, 10, 10);
    stroke(255, 0, 0, 0);//150);
    rect(width/2, height*15/16, width, height/8);
       
    fill(255, 0, 0, 150);
    rect(x, y, bar_length, bar_height, bar_height/2);
    
    fill(255, 0, 0);
    if(sliding){
      ellipse(slidingX, y, w, h);
      slidingV += ((thumbX + initialX)/2 - slidingX)/1;
      slidingX += slidingV;
      if(slidingX == thumbX)  sliding = false;
    }
    else{ 
      ellipse(thumbX, thumbY, w, h);
    }
    
    popMatrix();
    
    textAlign(CENTER, CENTER);
    textSize(height/72);
    text(Year, slide.x, slide.y-height/24);
//    textSize(height/108);
//    text(created_counter, slide.x, slide.y-height/18);
    
    int numberOfIndents = 7;
    textSize(height/108);
    for(int i = start_year; i <= end_year; i += floor((end_year-start_year+1)/numberOfIndents)){
      //if((i-start_year+1)>((end_year-start_year)*(numberOfIndents-1)/numberOfIndents))  i = 2012;
      text(i, map(i, start_year, end_year, x-bar_length/2, x+bar_length/2), y-height/43.2);
    }
    text(2012, map(2012, start_year, end_year, x-bar_length/2, x+bar_length/2), y-height/43.2);
  }
}


