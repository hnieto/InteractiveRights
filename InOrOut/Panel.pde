class Panel{
  float y;
  
  Panel(float y){
    this.y = y;
  }
  
  void display(){
    pushMatrix();
    pushStyle();
    
    rectMode(CENTER);
    
    int alpha = 80;
    for(Bubble bub: bubbles){
        if(trueContainsBubble(bub)){
            alpha = 155;
        }
    }
    fill((colorIn), alpha);
    rect(width/4, y + (height-y)/2, width/2, (height-y));
    
    alpha = 80;
    for(Bubble bub: bubbles){
        if(falseContainsBubble(bub)){
            alpha = 195;
        }
    }
    fill((colorOut), alpha);
    rect(width*3/4, y + (height-y)/2, width/2, (height-y));
    
    pushStyle();
    fill(255);
    textAlign(CENTER);
    textFont(defaultFont);
    textSize(height/15);
    String str = "IN";
    text(str, 0, y + (height-y)/4 - height/50, width/2, (height-y)/2);
    str = "OUT";
    text(str, width/2, y + (height-y)/4 - height/50, width/2, (height-y)/2);
    textSize(width/37.5);
    if(selected < 0) str = "(In Country's Constitution in 2012)";
    else str = "(In "+table[selected][2]+" Constitution in 2012)";
    text(str, 0, y + (height-y)*3/4 - height/50, width/2, (height-y)/2);
    if(selected < 0) str = "(Not in Country's Constitution in 2012)";
    else str = "(Not in "+table[selected][2]+" Constitution in 2012)";
    text(str, width/2, y + (height-y)*3/4 - height/50, width/2, (height-y)/2);
    popStyle();

     popStyle();
     popMatrix();
  }
  
  boolean trueContainsBubble(Bubble bub){
    if(bub.y + bub.radius > y && bub.x < width/2){
      return true;
    }
    return false;
  }
  
  boolean falseContainsBubble(Bubble bub){
    if(bub.y + bub.radius > y && bub.x > width/2){
      return true;
    }
    return false;
  }
}
