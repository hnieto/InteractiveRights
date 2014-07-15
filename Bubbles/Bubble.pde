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
    
    //Collision detection against boundaries 
    if (x + radius + 10 > width) {
      x = width - radius - 10;
      vx *= 0 - wallFriction; 
    }
    else if (x - radius - 10 < 0) {
      x = radius + 10;
      vx *= 0 - wallFriction;
    }
    if (y + radius + 5 > height*7/8) {
      y = height*7/8 - radius - 5;
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
    
    //set radius of bubble based on year
    radius = getRadius();
   
    
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
    rectMode(CENTER);
    //textAlign(CENTER);
    
    fill(255,255,255);
    float regFont = width/96;   //font size of 20 on lasso
    float boldFont = width/80;  //bolded font for title 
    stroke(255);
    textSize(boldFont);
    float txtWdith = textWidth(right.description);
    float wdith = height/4.32;//(500)
    
    //if desciption fits in one line
//    if(txtWdith <= 480 && textWidth(right.right_name+":") <= 480){
//      rect(mouseX+(txtWdith+20)/2, mouseY-40, txtWdith+20, 6*boldFont, 10);
//      fill(0,0,0);
//      text(right.right_name+":", mouseX+(txtWdith+20)/2, mouseY-60, 500, 2*boldFont);
//      textSize(regFont);
//      text(right.description, mouseX+(txtWdith+20)/2, mouseY-20, 500, 2*boldFont);
//      if(right.introduced != 0){
//        text("This right was first introduced in the US in "+right.introduced+".", mouseX+(txtWdith+20)/2, mouseY, 500, 2*boldFont);
//      }
//      else{
//        text("This right was never introduced in the US.", mouseX+(txtWdith+20)/2, mouseY, 500, 2*boldFont);
//      }
//      //Print "This right was guaranteed by 89 countries in the year 1890."
//    }else{
      rect(mouseX+250, mouseY, wdith, (ceil(txtWdith/wdith)-.9)*40 + 6*boldFont, 10);
      fill(0,0,0);
      if(procjs){
        text(right.right_name+":", mouseX, mouseY - 55 - (ceil(txtWdith/wdith)-.9)*15- (ceil(txtWdith/wdith)-.9)*40/2, wdith, (ceil(txtWdith/wdith)-.9)*height/54 + 6*boldFont);
        textSize(regFont);
        text(right.description, mouseX, mouseY - 25 - (ceil(txtWdith/wdith)-.9)*40/2, wdith, ceil(txtWdith/wdith)*6*boldFont);
        if(right.introduced != 0){
          text("This right was first introduced in the US in "+right.introduced+".", mouseX, mouseY - 25 + ceil(txtWdith/510)*height/72 - (ceil(txtWdith/wdith)-.9)*40/2, wdith, 6*boldFont);
        }
        else{
          text("This right was never introduced in the US.", mouseX, mouseY - 25 + ceil(txtWdith/510)*30 - (ceil(txtWdith/wdith)-.9)*40/2, wdith, 6*boldFont);
        }
      }else{
        text(right.right_name+":", mouseX+250, mouseY - 55 - (ceil(txtWdith/wdith)-.9)*15, wdith, (ceil(txtWdith/wdith)-.9)*height/54 + 6*boldFont);
        textSize(regFont);
        text(right.description, mouseX+250, mouseY - 25, wdith, ceil(txtWdith/wdith)*6*boldFont);
        if(right.introduced != 0){
          text("This right was first introduced in the US in "+right.introduced+".", mouseX+250, mouseY - 25 + ceil(txtWdith/510)*height/72, wdith, 6*boldFont);
        }
        else{
          text("This right was never introduced in the US.", mouseX+250, mouseY - 25 + ceil(txtWdith/510)*30, wdith, 6*boldFont);
        }
      }
      String plurality = " countries in ";
      if(right.count[Year-start_year].year_count == 1)  plurality = " country in ";
      if(procjs){
        text("This right was guaranteed in "+right.count[Year-start_year].year_count+plurality+Year+".", mouseX, mouseY + 5 + ceil(txtWdith/510)*30 - (ceil(txtWdith/wdith)-.9)*40/2, wdith, 6*boldFont);
      }else{
        text("This right was guaranteed in "+right.count[Year-start_year].year_count+plurality+Year+".", mouseX+250, mouseY + 5 + ceil(txtWdith/510)*30, wdith, 6*boldFont);
      }  
  //}
    
 } 
}
