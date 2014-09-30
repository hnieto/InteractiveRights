class TimeController {
    
  float   containerRadius;
  int     numberOfYears;
  int[]   years;
  int     year;
          
  boolean play, rewind, fastforward, timelineActive;
  float   rectW,         rectH;
  float   buttonW,       buttonH;
  float   timelineX,     timelineY,   timelineW, timelineH;
  float   tickX,         tickY,       tickR;
  float   playButtonX,   playButtonY, playButtonW, playButtonH;
  float   pauseButtonX,  pauseButtonY;
  float   rewindButtonX, rewindButtonY;
  float   ffButtonX,     ffButtonY;
  float   padding;
  
   
  TimeController(float containerRadius, int[] years){
      
    this.containerRadius = containerRadius*.6;
    this.years           = years;
    this.numberOfYears   = years[1]-years[0];
    this.year            = years[0];
    this.play            = false;
    this.fastforward     = false;
    this.rewind          = false;
  } 
  
  
  void init(){
      
    rectW         = (containerRadius*cos(PI/4))*2;
    rectH         = (containerRadius*sin(PI/4))*2;  
    
    // timeline
    timelineW     = rectW;
    timelineH     = rectH/32;
    timelineX     = 0;
    timelineY     = -timelineH;
    
    // timeline tick marker
    tickX         = timelineX-timelineW/2;
    tickY         = timelineY;
    tickR         = timelineW/10;
    
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
//    pauseButtonY  = pauseButtonY;
    
    // fast forward
    ffButtonX     = buttonW+padding*2;
    ffButtonY     = rectH/2-buttonH/2-padding;
  }
  
  
  void draw(){
      
    pushStyle();
    pushMatrix();
    
    // Seperate controller from vis with ellipse
    fill(40, 10, 10);
    stroke(255, 0, 0, 150);
    ellipse(0, 0, containerRadius*2, containerRadius*2); 
       
    // rect to hold controls
    rectMode(CENTER);    
    noFill();
    
    // year
    textAlign(CENTER);
    fill(255, 0, 0); 
    textFont(digitalFont);
    text(str(year), 0, -containerRadius/3);
    noFill();
    
    // timeline
    fill(255, 0, 0, 150);
    rect(timelineX, timelineY, timelineW, timelineH, 5);
    noFill();
    
    // timeline marker
    fill(255, 0, 0);
    ellipse(tickX, tickY, tickR*2, tickR*2);
    noFill();
    
    // rewind
    stroke(255, 100, 100);
    fill(255, 0, 0);
    rect(rewindButtonX + buttonW / 32 + (padding * 0.5), rewindButtonY, buttonW / 6, (buttonH * 0.7));
    triangle(rewindButtonX, rewindButtonY-buttonH*0.35, rewindButtonX-buttonW/2, rewindButtonY, rewindButtonX, rewindButtonY+buttonH*0.35);
    textSize(fontSize*0.7);
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
    
    popMatrix();
    popStyle();
  }
  
  
  void update() {
      
    if(play){
      if(frameCount%1 == 0){
        year++;
        if(year > years[1]) { year = years[0]; }
        tickX = map(year, years[0], years[1], timelineX-timelineW/2, timelineW/2);
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
      else     { play = true;  }
      
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

    if(mouseDist < tickR){
      timelineActive = true;
      play           = false;
      rewind         = false; 
      fastforward    = false;
    }    
  }
}
