// This code was based off of:
// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2011
// Box2DProcessing example

float BOUNDRY_SIZE = 1;

color[] colorArray = new color[7];
  colorArray[0] = #8BA7A7;
  colorArray[1] = #80304A;
  colorArray[2] = #00A871;
  colorArray[3] = #0065A0;
  colorArray[4] = #FF0000;
  colorArray[5] = #00FF00;
  colorArray[6] = #0000FF;


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
    
    float flagSize;
    
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
        
        flagSize = 400;
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
                //        if(vx < 1 && vx > -1)  vx = 0;   
                //        if(vy < 1 && vy > -1)  vy = 0;   
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
        
        //float boundary_size = 0;
        
        //Collision detection against boundaries 
        if (x + radius + BOUNDRY_SIZE > width) {//RIGHT
            x = width - radius - BOUNDRY_SIZE;
            vx *= 0 - wallFriction; 
        }
        else if (x - radius - BOUNDRY_SIZE < 0) {//LEFT
            x = radius + BOUNDRY_SIZE;
            vx *= 0 - wallFriction;
        }
        if (y + radius > height*7/8) {//BOTTOM
            y = height*7/8 - radius;
            vy *= 0 - groundFriction; 
        } 
        else if (y - radius - BOUNDRY_SIZE < 0) {//TOP
            y = radius + BOUNDRY_SIZE;
            vy *= 0 - wallFriction;
        }
    }
    
    // This function calculates radius size
    float getRadius(){
      float r;
      if(onlyUS){
        r = ((right.count[Year-start_year].year_count + 100) * height / 3000);
      }
      else{
        r = ((right.count[Year-start_year].year_count + 100) * height / 4400);
      }
      return r;
    }
    
    void display() {
        pushMatrix();
        pushStyle();
        
        if(destroying){
            //if bubble's count has now become zero
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
        
        strokeWeight(BOUNDRY_SIZE);
        
        int alpha = 35;
        if(selected == 0 || selected == right.category){
          alpha = 255;
        }
        
        fill(colorArray[right.category], alpha);
                
        translate(x, y);
        
        //draw bubble
        ellipse(0, 0, (radius)*2, (radius)*2);
        
        //font
        fill(0,0,0);
        float fontSize = radius/3.5;
        textSize(fontSize); //text always fits in bubble
        if(procjs)    text(rightName, 0 - 0.9*radius, (0-radius/3), radius*1.8, 4*fontSize);
        else          text(rightName, 0, (0-radius/3), radius*1.8, 4*fontSize);
//        text(str(right.count[Year-start_year].year_count), 0, radius/5);
        
        imageMode(CENTER, TOP);
        //print USflag not number!!!!!!!!!!!!!!!!!!!
        if(right.count[Year-start_year].US_flag){
          if(onlyUS){
            flagSize = 20;
          }
          else{
            if(flagSize>20){
              flagSize /= 1.2;
              image(USFlag, 0, radius/2.5, flagSize, flagSize);
            }
            else{
              flagSize = 20;
              image(tinyUSFlag, 0, radius/2.5, flagSize, flagSize);
            }
          }
        }
        else  flagSize = 400;
        
        //debugging text: displays x and y velocities
        //    text(vx+"",  0, (0-radius/3)+10, radius*1.8, 4*fontSize);
        //    text(vy+"",  0, (0-radius/3)+25, radius*1.8, 4*fontSize);
        
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
        float wdith = width/5.2;
        float txtWdith = textWidth(right.description);
        float txtHieght = textAscent() + textDescent();
        float hieght = (ceil(txtWdith/wdith) + 3)*txtHieght*5/4; //this is based on the number of lines to write: description is variable length, but there are always 3 more lines
        
        pushMatrix();
        translate(x+radius, y - hieght);
        
        rect(0, 0, wdith, hieght, 10);
        fill(0,0,0);
        
        text(right.right_name+":", 0, txtHieght/8, wdith, txtHieght*2);
        textSize(regFont);
        text(right.description, wdith/32, txtHieght*5/4, wdith*15/16, ceil(txtWdith/wdith)*txtHieght*2);
        //this next line is the second to last line
        if(right.introduced != 0){
            text("This right was first introduced in the US in "+right.introduced+".", 0, hieght - txtHieght*9/4, wdith, (hieght-(3*txtHieght))*2);
        }else{
            text("This right was never introduced in the US.",0,hieght - txtHieght*9/4, wdith, (hieght-(3*txtHieght)+10)*2);
        }
        
        String plurality = " countries in ";
        if(right.count[Year-start_year].year_count == 1)  plurality = " country in ";
        //This should always be the last line in the box
        text("This right was guaranteed in "+right.count[Year-start_year].year_count+plurality+Year+".", 0, hieght - txtHieght*9/8, wdith, txtHieght*2);      
         
        popMatrix();
    } 
}
