class TimeController {
    
  float   containerRadius;
  int     numberOfYears;
  int[]   years;
  int     year;
          
  boolean play,          rewind,        fastforward, timelineActive;
  float   savedTime,     passedTime,    timeToWait;
  float   rectW,         rectH;
  float   buttonW,       buttonH;
  float   timelineX,     timelineY,     timelineW,   timelineH;
  float   tickX,         tickY,         tickW,       tickH;
  float   arrowHeadX,    arrowHeadY,    arrowHeadW,  arrowHeadH;
  float   playButtonX,   playButtonY,   playButtonW, playButtonH;
  float   pauseButtonX,  pauseButtonY;
  float   rewindButtonX, rewindButtonY;
  float   ffButtonX,     ffButtonY;
  float   padding;
  
   
  TimeController(float containerRadius, int[] years){
      
    this.containerRadius = containerRadius*.8;
    this.years           = years;
    this.numberOfYears   = years[1]-years[0];
    this.year            = years[1] - (int)((years[1]-years[0])/2); // start in the middle of the time range when all the action is happening.
    this.play            = false;
    this.fastforward     = false;
    this.rewind          = false;
    this.timeToWait      = 300; // in milliseconds
  } 
  
  
  void init(){
      
    rectW         = (containerRadius*cos(PI/4))*2;
    rectH         = (containerRadius*sin(PI/4))*2;  
    
    // timeline
    timelineW     = rectW*1.3;
    timelineH     = rectH/32;
    timelineX     = 0;
    timelineY     = -timelineH*2;
    
    // timeline tick marker
    tickX         = timelineX;
    tickY         = timelineY;
    tickW         = timelineW/16;
    tickH         = timelineW/12;
    
    // generic button geometry
    padding       = rectW/12;
    buttonW       = (rectW-padding*5)/3;
    buttonH       = rectH/4;
    
    // rewind
    rewindButtonX = -buttonW-padding*2;
    rewindButtonY = rectH/2-buttonH/2-padding;
    
    // play
    playButtonX   = 0;
    playButtonY   = rectH/2-buttonH/2-padding;
    playButtonW   = (buttonW*cos(PI/4))*2;
    playButtonH   = (buttonW*sin(PI/4))*2;
    
    // pause
    pauseButtonX  = playButtonX;
    
    // fast forward
    ffButtonX     = buttonW+padding*2;
    ffButtonY     = rectH/2-buttonH/2-padding;
    
    // arrowheads (for rotation symbol)
    arrowHeadX   = 0;
    arrowHeadY   = 0;
    arrowHeadW    = (buttonW*cos(PI/4))*2;
    arrowHeadH    = (buttonW*sin(PI/4))*2;
  }
  
  
  void draw(){
      
    pushStyle();
    pushMatrix();
    strokeWeight(1);
    
    // Seperate controller from vis with ellipse
    fill(40, 10, 10);
    stroke(255, 0, 0, 150);
    ellipse(0, 0, containerRadius*2, containerRadius*2); 
    
    if(rotateVis) {
      
      // arrow tails
      noFill();
      stroke(255, 0, 0, 150);
      strokeWeight(2);
      arc(0, 0, containerRadius*1.6, containerRadius*1.6, QUARTER_PI, HALF_PI+QUARTER_PI);
      arc(0, 0, containerRadius*1.6, containerRadius*1.6, PI+QUARTER_PI, PI+HALF_PI+QUARTER_PI);
      
      // arrow heads style
      stroke(255, 100, 100);
      fill(255, 0, 0);
      scale(0.6);
      
      // arrow head #1
      pushMatrix();
      translate(containerRadius*1.29*cos(HALF_PI+QUARTER_PI), containerRadius*1.29*sin(HALF_PI+QUARTER_PI));
      triangle(arrowHeadX - (arrowHeadW * 0.3), arrowHeadY - (arrowHeadH * 0.5), arrowHeadX + (arrowHeadW * 0.5), arrowHeadY, arrowHeadX - (arrowHeadW * 0.3), arrowHeadY + (arrowHeadH * 0.5));
      popMatrix();
      
      // arrow head #2
      pushMatrix();
      translate(containerRadius*1.29*cos(PI+HALF_PI+QUARTER_PI), containerRadius*1.29*sin(PI+HALF_PI+QUARTER_PI));
      rotate(QUARTER_PI);
      triangle(arrowHeadX - (arrowHeadW * 0.3), arrowHeadY - (arrowHeadH * 0.5), arrowHeadX + (arrowHeadW * 0.5), arrowHeadY, arrowHeadX - (arrowHeadW * 0.3), arrowHeadY + (arrowHeadH * 0.5));
      popMatrix();

      // reset styles
      noFill();
      strokeWeight(1);
      noLoop();
    } 
    
    else {
      // rect to hold controls
      rectMode(CENTER);    
      noFill();
      
      if(onMobile) {
        // year
        textAlign(CENTER);
        fill(255, 0, 0); 
        textFont(digitalFont);
        text(str(year), 0, 0);
        textSize(fontSize*0.7);
        noFill();        
      }
      
      else {
        // year
        textAlign(CENTER);
        fill(255, 0, 0); 
        textFont(digitalFont);
        text(str(year), 0, -containerRadius*0.4);
        noFill();
        
        // timeline
        fill(255, 0, 0, 150);
        rect(timelineX, timelineY, timelineW, timelineH, 5);
        noFill();
        
        // timeline marker
        fill(255, 0, 0);
        ellipse(tickX, tickY, tickW*2, tickH*2);
        noFill();
        
        // timeline ticks
        line(-timelineW/2, tickY+tickH/2, -timelineW/2, tickY-tickH/2);
        line(-timelineW/4, tickY+tickH/2, -timelineW/4, tickY-tickH/2);
        line(timelineW/2,  tickY+tickH/2,  timelineW/2, tickY-tickH/2);
        line(timelineW/4,  tickY+tickH/2,  timelineW/4, tickY-tickH/2);
        
        // timeline years
        pushStyle();
        textSize(fontSize*0.7);
        text(years[0],                                  -timelineW/2, tickY-tickH*0.7);
        text((years[0] + (int)((years[1]-years[0])/4)), -timelineW/4, tickY+tickH*0.9);
        text(years[1],                                   timelineW/2, tickY-tickH*0.7);
        text((years[1] - (int)((years[1]-years[0])/4)),  timelineW/4, tickY+tickH*0.9);
        popStyle();
        
        // rewind
        stroke(255, 100, 100);
        fill(255, 0, 0);
        rect(rewindButtonX + buttonW / 32 + (padding * 0.5), rewindButtonY, buttonW / 6, (buttonH * 0.7));
        triangle(rewindButtonX, rewindButtonY-buttonH*0.35, rewindButtonX-buttonW/2, rewindButtonY, rewindButtonX, rewindButtonY+buttonH*0.35);
        textSize(fontSize*0.9);
        fill(255, 0, 0, 100);
        text("-1 year", rewindButtonX, rewindButtonY + (buttonH * 0.7));
        noFill();
        
        // play/pause
        stroke(255, 100, 100);
        fill(255, 0, 0);
        if(!play) {
          triangle(playButtonX - (playButtonW * 0.3), playButtonY - (playButtonH * 0.5), playButtonX + (playButtonW * 0.5), playButtonY, playButtonX - (playButtonW * 0.3), playButtonY + (playButtonH * 0.5));
          fill(255, 0, 0, 100);
          text("Play", playButtonX, playButtonY + (playButtonH * 0.8));
        }
        else {
          rect(pauseButtonX - playButtonW / 32 - padding / 2, playButtonY, playButtonW / 4, playButtonH);
          rect(pauseButtonX + playButtonW / 32 + padding / 2, playButtonY, playButtonW / 4, playButtonH);
          fill(255, 0, 0, 100);
          text("Pause", playButtonX, playButtonY + (playButtonH * 0.8));
        }
        noFill();
        
        // fast forward
        stroke(255, 100, 100);
        fill(255, 0, 0);
        rect(ffButtonX - buttonW / 32 - (padding * 0.5), ffButtonY, buttonW / 6, (buttonH * 0.7));
        triangle(ffButtonX, ffButtonY - (buttonH * 0.35), ffButtonX + buttonW / 2, ffButtonY, ffButtonX, ffButtonY + buttonH * 0.35);
        fill(255, 0, 0, 100);
        text("+ 1 year", ffButtonX, ffButtonY + (buttonH * 0.7));
        noFill();         
      }
     
    }
    
    popMatrix();
    popStyle();
  }
  
  void drawEmpty(){
      
    pushStyle();
    pushMatrix();
    strokeWeight(1);
    
    // Seperate controller from vis with ellipse
    fill(40, 10, 10);
    stroke(255, 0, 0, 150);
    ellipse(0, 0, containerRadius*2, containerRadius*2); 
    
    // Brief notice to user
    textAlign(CENTER);
    fill(255, 0, 0); 
    textFont(digitalFont);
    textSize(fontSize*2);
    text("Please Select\nCountry", 0, 0);
    noFill();
    
    popMatrix();
    popStyle();
  }
  
  
  void update() {
      
    if(play){
      passedTime = millis() - savedTime;
      if(passedTime > timeToWait){ 
        year++;
        if(year > years[1]) { year = years[0]; }
        tickX = map(year, years[0], years[1], timelineX-timelineW/2, timelineW/2);
        savedTime = millis();
      }  
    }
    
    if(fastforward){
      year++;
      if(year > years[1]) { year = years[0]; }
      fastforward = false;
      tickX       = map(year, years[0], years[1], timelineX-timelineW/2, timelineW/2);
    }
    
    if(rewind){
      year--;
      if(year < years[0]) { year = years[1]; }
      rewind = false;
      tickX  = map(year, years[0], years[1], timelineX-timelineW/2, timelineW/2);
    }
    
    if(timelineActive){
      tickX = cursorX-width/2;
      if(tickX < timelineX-timelineW/2) { tickX = timelineX-timelineW/2; }
      if(tickX > timelineW/2)           { tickX = timelineW/2;           }
      year  = (int)map(tickX, timelineX-timelineW/2, timelineW/2, years[0], years[1]);
    }
  }
    
  
  void playButtonClicked(float xOffset, float yOffset){
      
    float disX = playButtonX + xOffset - cursorX;
    float disY = playButtonY + yOffset - cursorY;
    
    if (sqrt(sq(disX) + sq(disY)) < buttonW) {
        
      if(play) { play = false; }
      else     { play = true;  savedTime = millis();}
      
      rewind         = false;
      fastforward    = false;
      timelineActive = false;
    }
  }
  
  
  void ffButtonClicked(float xOffset, float yOffset){
      
    if(cursorX >= ffButtonX+xOffset-buttonW/2 && cursorX <= ffButtonX+xOffset+buttonW/2 && 
       cursorY >= ffButtonY+yOffset-buttonH/2 && cursorY <= ffButtonY+yOffset+buttonH/2){
        
      fastforward    = true; 
      play           = false;
      rewind         = false;
      timelineActive = false;
    }
  }
  
  
  void rewindButtonClicked(float xOffset, float yOffset){
      
    if(cursorX >= rewindButtonX+xOffset-buttonW/2 && cursorX <= rewindButtonX+xOffset+buttonW/2 && 
       cursorY >= rewindButtonY+yOffset-buttonH/2 && cursorY <= rewindButtonY+yOffset+buttonH/2){
        
      rewind         = true; 
      play           = false;
      fastforward    = false;
      timelineActive = false;
    }
  }
  
  
  void timelineTickClicked(float xOffset, float yOffset){
      
    float mouseDist = dist(tickX+xOffset, tickY+yOffset, cursorX, cursorY);

    if(mouseDist < tickH){
      timelineActive = true;
      play           = false;
      rewind         = false; 
      fastforward    = false;
    }    
  }
}
