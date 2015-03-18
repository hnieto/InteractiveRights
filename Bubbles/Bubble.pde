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
  colorArray[5] = #54A88D;
  colorArray[6] = #76A0D5;
  colorArray[7] = #113C5D;


class Bubble {

    int holder;
    
    float x, y;
    float radius;
    float bubbleColorInt;
    String rightName;
    public Right right;
    
    float vx;
    float vy;
    
    float vx1, vx2;
    float vy1, vy2;
    
    float terminalVx;
    float terminalVy;
    
    float GravityX;
    float GravityY;
    float gravitateToX;
    float gravitateToY;
    
    float textOffsetX;
    float textOffsetY;
    
    boolean hasSpring;
    
    boolean destroying;//determines shrinking animation when a bubble is being destroyed
    boolean collideFlag;//determines whether bubble collides with other bubbles
    boolean gravitating;
    
    boolean help;
    
    float flagSize;
    
    // Constructor
    Bubble(float x, float y, Right right, boolean help) {
        this.x = x;
        this.y = y;
        this.right = right;
        this.help = help;
        bubbleColorInt = random(1, 360);
        vx = 0;
        vy = random(2,2);//random initial velocity
        
        vx1 = 0;
        vx2 = 0;
        vy1 = 0;
        vy2 = 0;
        
        this.terminalVx = terminalVX;
        this.terminalVy = terminalVY;
        
        GravityX = 0;
        GravityY = 0;
        gravitateToX = width/2;//((2*right.category + 1)/2)*width/(categories.length+1);
        gravitateToY = height/2;
        
        textOffsetX = 0;
        textOffsetY = 0;
        
        this.rightName = right.right_name;
        this.radius = getRadius();
        
        destroying = false;
        collideFlag = true;
        gravitating = false;
        
        flagSize = 400;
        
        holder = 999;
    }
    
    void destroy(){
        destroying = true;
    }
    
    void collide() {
        if(!collideFlag)  return;
        Bubble bub;
        for (int i=initialSize; i<bubbles.size(); i++){
            bub = bubbles.get(i);
            if(bub != this && bub.collideFlag){
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
    
    void moveByTouch(float touchX, float touchY){
        terminalVx = 100;
        terminalVy = 100;
    
        vx = (touchX - x)/throwEase;
        vy = (touchY - y)/throwEase;
        x = touchX;
        y = touchY;
    }
    void move(){
        vy2 = vy1;
        vx2 = vx1;
        vy1 = vy;
        vx1 = vx;
        if(!hasSpring){
          
            if(y > height/4){
                terminalVx = 100;
                terminalVy = 100;
            }
            
//            if(y < height/16){
//                vy += Gravity;
//            }
            
            if(selected != 0 && !help){
                if(selected != right.category){
                    gravitateToX = x > width/2? width : 0;
                    gravitateToY = y > height/2? height : 0;
                }
                else{
                    gravitateToX = width/2;//((2*right.category + 1)/2)*width/(categories.length+1);
                    gravitateToY = height/2;
                }
                    
                if(gravitating)  collideFlag = false;
                else             collideFlag = true;
                GravityX = (gravitateToX - x)/(throwEase*200);
                GravityY = (gravitateToY - y)/(throwEase*200);
                float limit;
                if(selected != right.category)  limit = map(Year, start_year, end_year, 75, 1100);
                else                            limit = map(Year, start_year, end_year, 75, 500);
//                float distance = sqrt((gravitateToX - x)*(gravitateToX - x) + (gravitateToY - y)*(gravitateToY - y));
//                if(distance < limit){
//                  vx += GravityX;
//                  vy += GravityY;
//                }else{
//                  vx /= 1.1;
//                  vy /= 1.1;
//                }
                if(gravitateToX - x > limit || gravitateToX - x < -limit){
                    vx += GravityX;
                }
                else{
                    vx /= 1.1;
                }
                if(gravitateToY - y > limit || gravitateToY - y < -limit){
                    vy += GravityY;
                }
                else{
                    vy /= 1.1;
                }
                
                if((gravitateToY - y > limit || gravitateToY - y < -limit) || (gravitateToX - x > limit || gravitateToX - x < -limit)){
                }
                else{
                    collideFlag = true;
                    gravitating = false;
                }
            }
            else{
                vy += Gravity;
                collideFlag = true;
                gravitating = false;
            }
            
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
        
        float rectHeight = height/24;
        
        if(selected*width/(categories.length+1) <= this.x && this.x < (selected+1)*width/(categories.length+1)){
            rectHeight = height/18;
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
        if (y + radius + BOUNDRY_SIZE > (height*7/8 - MARGIN)) {//BOTTOM
            y = (height*7/8 - radius) - MARGIN - BOUNDRY_SIZE;
            vy *= 0 - groundFriction; 
        } 
        else if (y - radius - BOUNDRY_SIZE - (rectHeight - height/200) < 0) {//TOP --- height/12 is margin, but Pjs doesn't like calling margin here
            y = radius + BOUNDRY_SIZE + (rectHeight - height/200);            //rectHeight varies based on what is selected
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
      if(help)  return height/25;
      else{
          //return ((right.count[Year-start_year].year_count + 100) * height / 4400);
          int count = countrycount[Year - start_year];
//          console.log(count);
          float n = (right.count[Year-start_year].year_count / count);
          return n*(height/10 - height/50) + (height/50);
      }
      
      
//      float r;
//      if(onlyUS){
//        r = ((right.count[Year-start_year].year_count + 100) * height / 3000);
//      }
//      else{
//        if(mode==1)  r = map((right.count[Year-start_year].year_count / countrycount[Year-start_year]), 0, 1, height/50, height/10);
//        else         r = ((right.count[Year-start_year].year_count + 100) * height / 4400);
////        r = ((right.count[Year-start_year].year_count + 190) * height / 5600);
//      }
//      return r;
    }
    
    void display() {
        if(help){
            pushMatrix();
            pushStyle();
            translate(x, y);
            imageMode(CENTER);
            image(helpIcon, 0, 0, radius*2, radius*2);
            popStyle();
            popMatrix();
            return;
        }
            
            
            
        pushMatrix();
        pushStyle();
        
        if(destroying){
            //if bubble's count has now become zero
            if(radius >= 1){
              if(PreviousYear - Year > 5)  radius = 0;
              else              radius /= 2;
            }else{
                destroying = false;//bubble will now be removed from arraylist
                bubbles.remove(this);
                created_counter--;
            }
        }
        else{
            //set radius of bubble based on year
            if(Year != PreviousYear){
                if(right.count[Year-start_year].year_count != right.count[PreviousYear-start_year].year_count){
                    radius = getRadius();
                }
            }
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
        if(right.category > 7)
          fill(colorArray[0], alpha);
        else
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
        
        textOffsetX = 0;
        textOffsetY = 0;
        //Making text appear inside the screen at all times
        if(x + radius + textOffsetX + wdith > width) {
            textOffsetX = width - wdith - x - radius;
        }
        if(y - hieght + textOffsetY < 0) {
             textOffsetY = 0 - y + hieght;
        } 
        
        pushMatrix();
        translate(x + radius + textOffsetX, y - hieght + textOffsetY);
        
        rect(0, 0, wdith, hieght, 10);
        fill(0,0,0);
        
        text(right.right_name+":", 0, txtHieght/8, wdith, txtHieght*2);
        textSize(regFont);
        text(right.description, wdith/32, txtHieght*5/4, wdith*15/16, ceil(txtWdith/wdith)*txtHieght*2);
        //this next line is the second to last line
//        if(right.USintroduced != 0){
//            text("This right was first introduced in the US in "+right.USintroduced+".", 0, hieght - txtHieght*9/4, wdith, (hieght-(3*txtHieght))*2);
//        }else{
//            text("This right was never introduced in the US.",0,hieght - txtHieght*9/4, wdith, (hieght-(3*txtHieght)+10)*2);
//        }
        text("This right was first introduced in "+right.introduce+" in "+right.introduced+".", 0, hieght - txtHieght*9/4, wdith, (hieght-(3*txtHieght))*2);
        
        String plurality = " countries in ";
        if(right.count[Year-start_year].year_count == 1)  plurality = " country in ";
        //This should always be the last line in the box
        text("This right was guaranteed in "+right.count[Year-start_year].year_count+"/"+countrycount[Year-start_year]+plurality+Year+".", 0, hieght - txtHieght*9/8, wdith, txtHieght*2);      
         
        popMatrix();
    } 
}
