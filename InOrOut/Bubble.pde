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
  colorArray[4] = #D43266;
  colorArray[5] = #76A0D5;
  colorArray[6] = #FEDC1C;
  colorArray[7] = #113C5D;


class Bubble {

    int holder;
    
    float x, y;
    float radius;
    boolean answer;
    
    float offsetX;
    float offsetY;
    
    String rightName;
    String rightDesc;
    
    float vx;
    float vy;
    
    float vx1, vx2;
    float vy1, vy2;
    
    float terminalVx;
    float terminalVy;
    
    boolean hasSpring;//if bubble is being held
    
    boolean destroying;
    
    float flagSize;
    // Constructor
    Bubble(float x, float y, boolean answer) {
        this.x = x;
        this.y = y;
        this.answer = answer;
        
        vx = random(1, 1.5);
        vy = random(1,2);//random initial velocity
        
        vx1 = 0;
        vx2 = 0;
        vy1 = 0;
        vy2 = 0;
        
        this.terminalVx = terminalVX;
        this.terminalVy = terminalVY;
        
        this.radius = getRadius();
        
        destroying = false;
        
        flagSize = 400;
        
        holder = 999;
        
//        int index = (int)random(1, 27);
//        
//        if(answer){
//          txt = "Amendment "+index+":\n"+amendments[index];
//        }
//        else{
//          int index2 = (int)random(1, 27);
//          while(index2 == index)  index2 = (int)random(1, 27);//makes sure index2 != index so answer is false
//          txt = "Amendment "+index+":\n"+amendments[index2];
//        }
        int index = (int) random(19, 136);
        String available = table[selected][index];
        
        if(available.equals("1.yes") || available.equals("2.full")){
          answer = true;
        }else answer = false;
//        if(answer){
//          while(available.equals("1.yes") || available.equals("2.full")){
//              index = (int) random(19, 136);
//              available = table[selected][index];
//          }
//        }
//        else{
//          alert(available.equals("1.yes"));
//          while(available.equals("1.yes") || available.equals("2.full")){
//              index = (int) random(19, 136);
//              available = table[selected][index];
//          }
//        }
        rightName = table[0][index];
        rightDesc = table[1][index];
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
                    
                    if(this.hasSpring){
                      bub.terminalVx = 100;
                      bub.terminalVy = 100;
                    }
                    //        if(vx < 1 && vx > -1)  vx = 0;   
                    //        if(vy < 1 && vy > -1)  vy = 0;   
                }
            }
        }   
    }
    
    void moveByTouch(float touchX, float touchY){
        terminalVx = 100;
        terminalVy = 100;
    
        vx = (touchX - offsetX - x)/throwEase;
        vy = (touchY - offsetY - y)/throwEase;
        x = touchX - offsetX;
        y = touchY - offsetY;
    }
    void move(){
        vy2 = vy1;
        vx2 = vx1;
        vy1 = vy;
        vx1 = vx;
        if(!hasSpring){
            if(this.terminalVx > terminalVX){
                if(vx < terminalVx && vx > 0 - terminalVx){
                    //terminalVx = terminalVX;
                }
            }
            if(this.terminalVy > terminalVY){
                if(vy < terminalVy && vy > 0 - terminalVy){
                    //terminalVy = terminalVY;
                }
            }
            
//            if(y < height/16){
//                vy += Gravity;
//            }
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
        if (!hasSpring && (y + radius + BOUNDRY_SIZE > height*10/12)) {//BOTTOM
            y = (height*10/12 - radius) - BOUNDRY_SIZE;
            vy *= 0 - groundFriction; 
        } 
        else if (hasSpring && (y + radius + BOUNDRY_SIZE > height)) {//MOST BOTTOM
            y = (height - radius) - BOUNDRY_SIZE;
            vy *= 0 - groundFriction; 
        } 
        if (y - radius - BOUNDRY_SIZE - height/10 < 0) {//TOP
            y = radius + BOUNDRY_SIZE + height/10;
            vy *= 0 - wallFriction;
        }
        
        if(vy2<0 && vy1>0 && vy<0){ vy = 0; print("HEY");}
        if(vy2>0 && vy1<0 && vy>0){ vy = 0; print("HEY");}
        if(vx2<0 && vx1>0 && vx<0){ vx = 0; print("YOU");}
        if(vx2>0 && vx1<0 && vx>0){ vx = 0; print("YOU");}
        //print("I DONT LIKE YOUR BOYFRIEND");
    }
    
    // This function calculates radius size
    float getRadius(){
      return height/12;
    }
    
    void display() {
        pushMatrix();
        pushStyle();
        
        //set drawing modes
        //    colorMode(RGB, 100);
        ellipseMode(PConstants.CENTER);
        rectMode(CENTER);
        if (procjs) textAlign(CENTER);
        else        textAlign(CENTER, BOTTOM);
        
        stroke(255); //white circumference
        
        strokeWeight(BOUNDRY_SIZE);
        
        int alpha = 255;
        if(hasSpring)
          alpha = 185;
//        if(answer)  fill(100, 200, 255, alpha);
//        else        fill(255, 200, 100, alpha);

        fill(100, 100, 100, alpha);
                
        translate(x, y);
        
        //draw bubble
        ellipse(0, 0, (radius)*2, (radius)*2);
        
        //font
        fill(0,0,0);
        float fontSize = radius/4;
        textSize(fontSize); //text always fits in bubble
        if(textWidth(rightName) > radius*1.8){
          text(rightName, 0 - 0.9*radius, (0-radius/2), radius*1.8, 2*fontSize);
          fontSize = radius/6;
          textSize(fontSize); //text always fits in bubble
          if(answer) text(rightDesc + ".", 0 - 0.9*radius, 0.1*radius, radius*1.8, 6*fontSize);
          else text(rightDesc, 0 - 0.9*radius, 0.1*radius, radius*1.8, 6*fontSize);
        }
        else{
          text(rightName, 0 - 0.9*radius, (0-radius/3), radius*1.8, 2*fontSize);
          fontSize = radius/6;
          textSize(fontSize); //text always fits in bubble
          if(answer) text(rightDesc + ".", 0 - 0.9*radius, 0, radius*1.8, 6*fontSize);
          else text(rightDesc, 0 - 0.9*radius, 0, radius*1.8, 6*fontSize);
        }
        
        
        //debugging text: displays x and y velocities
//            text(vx+"",  0, (0-radius/3)+10, radius*1.8, 4*fontSize);
//            text(vy+"",  0, (0-radius/3)+25, radius*1.8, 4*fontSize);
        
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
}
