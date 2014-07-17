// This code was based off of:
// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2011
// Box2DProcessing example

class Bubble {

  float x, y;
  float radius;
  float bubbleColorInt;
  String rightName;
  public Right right;
  
  float vx;
  float vy;
  
  float terminalVx;
  float terminalVy;
  
  boolean hasSpring;
  
  boolean destroying;

  // Constructor
  Bubble(float x, float y, Right right) {
    this.x = x;
    this.y = y;
    this.right = right;
    bubbleColorInt = random(1, 360);
    vx = 0;
    vy = random(1,2);//random initial velocity
    
    this.terminalVx = terminalVX;
    this.terminalVy = terminalVY;
    
    this.rightName = right.right_name;
    this.radius = getRadius();
    
    destroying = false;
  }
  
  void destroy(){
    destroying = true;
  }
  
  void collide() {
    for (Bubble bub: bubbles) {
        if(bub != this){
          float dx = bub.x - x;
          float dy = bub.y - y;
          float distance = sqrt(dx*dx + dy*dy);
          float minDist = bub.radius + radius;
          if (distance < minDist) { 
              
            float angle = atan2(dy, dx);
            float targetX = x + cos(angle) * minDist;
            float targetY = y + sin(angle) * minDist;
            float ax = (targetX - bub.x);
            float ay = (targetY - bub.y);
            vx -= ax;
            vy -= ay;
            bub.vx += ax;
            bub.vy += ay;
            vx *= friction;
            vy *= friction;
            bub.vx *= friction;
            bub.vy *= friction;
//            if(vx < 1 && vx > -1)  vx = 0;   
//            if(vy < 1 && vy > -1)  vy = 0;   
        }
      }
    }   
  }
  
  void move(){
    
    if(hasSpring){
      terminalVx = 100;
      terminalVy = 100;
      
      vx = (mouseX - x)/throwEase;
      vy = (mouseY - y)/throwEase;
      x = mouseX;
      y = mouseY;
    }

    else{
      
      if(this.terminalVx > terminalVX){
        if(vx < terminalVx && vx > 0 - terminalVx){
        terminalVx = terminalVx;
        }
      }
      if(this.terminalVy > terminalVY){
        if(vy < terminalVy && vy > 0 - terminalVy){
        terminalVy = terminalVy;
        }
      }
      
      vy += Gravity;
      if(vy > terminalVy){
        vy = terminalVy;
      }
      if(vy < 0 - terminalVy){
        vy = 0 - terminalVy;
      }
      
      if(vx > terminalVx){
        vx = terminalVx;
      }
      if(vx < 0 - terminalVx){
        vx = 0 - terminalVx;
      }
      
      x += vx;
      y += vy;
    }
    
    float boundary_size = 0;
    
    //Collision detection against boundaries 
    if (x + radius + boundary_size > width) {
      x = width - radius - boundary_size;
      vx *= 0 - wallFriction; 
    }
    else if (x - radius - boundary_size < 0) {
      x = radius + boundary_size;
      vx *= 0 - wallFriction;
    }
    if (y + radius > height*7/8) {
      y = height*7/8 - radius;
      vy *= 0 - friction; 
    } 
    else if (y - radius < 0) {
      y = radius;
      vy *= 0 - wallFriction;
    }
    
  }
  
  // This function calculates radius size
  float getRadius(){
    return ((right.count[Year-start_year].year_count + 100) * height / 4400); 
  }

  void display() {
    pushMatrix();
    pushStyle();
    
    if(destroying){//if bubble's count has now become zero
      if(radius >= 0.5){
        radius /= 1.5;
      }else{
        destroying = false;//bubble will now be removed from arraylist
        bubbles.remove(this);
        created_counter--;
      }
    }
    else{
      //set radius of bubble based on year
      radius = getRadius();
    }
   
    
    //set drawing modes
//    colorMode(RGB, 100);
    ellipseMode(PConstants.CENTER);
    rectMode(CENTER);
    if (procjs) textAlign(CENTER);
    else        textAlign(CENTER, BOTTOM);
    
    stroke(255); //white circumference
    
    strokeWeight(1);
    
    int alpha = 35;
    
    if(right.category == 1){
      if(selected == 1 || selected == 0)  fill(0, 101, 160);
      else                                fill(0, 101, 160, alpha);
    }
    else if(right.category == 2){
      if(selected == 2 || selected == 0)  fill(0, 168, 113);
      else                                fill(0, 168, 113, alpha);
    }
    else if(right.category == 3){
      if(selected == 3 || selected == 0)  fill(128, 48, 74);
      else                                fill(128, 48, 74, alpha);
    }
    else if(right.category == 4){
      if(selected == 4 || selected == 0)  fill(255, 0, 0);
      else                                fill(255, 0, 0, alpha);
    }
    else if(right.category == 5){
      if(selected == 5 || selected == 0)  fill(0, 255, 0);
      else                                fill(0, 255, 0, alpha);
    }
    else if(right.category == 6){
      if(selected == 6 || selected == 0)  fill(0, 0, 255);
      else                                fill(0, 0, 255, alpha);
    }
    else{
      if(selected == 0)                   fill(0x8B, 0xA7, 0xA7);
      else                                fill(0x8B, 0xA7, 0xA7, alpha);
    }
    
    translate(x, y);
    
    //draw bubble
    ellipse(0, 0, (radius)*2, (radius)*2);
    
    //font
    fill(0,0,0);
    float fontSize = radius/6;
    textSize(fontSize); //text always fits in bubble
    if(procjs)    text(rightName, 0 - 0.9*radius, (0-radius/3), radius*1.8, 4*fontSize);
    else          text(rightName, 0, (0-radius/3), radius*1.8, 4*fontSize);
    text(str(right.count[Year-start_year].year_count), 0, radius/5);
    
    //debugging text: displays x and y velocities
//    text(vx+"",  0, (0-radius/3)+10, radius*1.8, 4*fontSize);
//    text(vy+"",  0, (0-radius/3)+25, radius*1.8, 4*fontSize);
//    
    popStyle();
    popMatrix();
  }
  
  boolean contains(float x, float y) {
    boolean inside = false;
    if(sqrt((x-this.x)*(x-this.x) + (y-this.y)*(y-this.y)) <= this.radius){
      inside = true;
    }
    return inside;
  }
 
 void showText(){
    rectMode(CORNER);    //this was LEFT before
    textAlign(CENTER, TOP);
    
    fill(255,255,255);
    float regFont = width/96;   //font size of 20 on lasso
    float boldFont = width/80;  //bolded font for title 
    stroke(255);
    textSize(boldFont);
    //misspelled on purpose, because cannot use Width and Height.
    float wdith = width/3.84;//(500)
    float txtWdith = textWidth(right.description);
    float txtHieght = textAscent() + textDescent();
    float hieght = (ceil(txtWdith/wdith) + 3)*txtHieght; //this is based on the number of lines to write: description is variable length, but there are always 3 more lines
    
    pushMatrix();
    translate(x+radius, y - hieght);
    
    rect(0, 0, wdith, hieght, 10);
    fill(0,0,0);
    
    text(right.right_name+":", 0, 0, wdith, txtHieght*2);
    textSize(regFont);
    text(right.description, 0, txtHieght, wdith, ceil(txtWdith/wdith)*txtHieght*2);
    //this next line is the second to last line
    if(right.introduced != 0){
        text("This right was first introduced in the US in "+right.introduced+".", 0, hieght - txtHieght*2, wdith, (hieght-(3*txtHieght))*2);
    }
    else{
        text("This right was never introduced in the US.",0,hieght - txtHieght*2, wdith, (hieght-(3*txtHieght)+10)*2);
    }

    String plurality = " countries in ";
    if(right.count[Year-start_year].year_count == 1)  plurality = " country in ";
    //This should always be the last line in the box
    text("This right was guaranteed in "+right.count[Year-start_year].year_count+plurality+Year+".", 0, hieght - txtHieght, wdith, txtHieght*2);      
 
    popMatrix();
 } 
}
