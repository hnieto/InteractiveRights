
import java.util.*;

//MAY HAVE TO INCORPORATE THESE VARIABLES OUT
boolean procjs = true;
boolean onlyUS = false;
Bubble currentlyPressed;    //selected bubble - Switch to arraylist for TUIO

//List to hold objects
ArrayList<Bubble> bubbles;
Bubble bub;
//A list of the (index of) rights (bubbles) already created
String[] created;

float MARGIN = 10.0;
int initialSize = 0;

//Physics
float Gravity = 0.01;//0.25;

float friction = 0.87;
float wallFriction = 0.4;
float groundFriction = 0.3;//0.7;
float terminalVY = 15;
float terminalVX = 3;
float throwEase = 0.4;//Higher the throwEase, the harder to throw

//Data variables
int Year;
int PreviousYear;
int count;
int created_counter;
boolean play;
int selected;
PImage USFlag;
PImage tinyUSFlag;
PImage helpIcon;

//Sketch dimersion variables
float  sketchWidth;
float  sketchHeight;

//Mobile option
boolean onMobile = false;//set in setCanvasSize()

//buttons and slider
PlayPause playpause;
PreviousButton previousbutton;
NextButton nextbutton;
Slider slide;
boolean slider_flag; //if slider is currently being dragged
int play_time = 10;//Number of frames before year changes

//ADDED: to switch betwen inter-activities (pun intended)
//a certain mode number corresponds to how we are displaying info
//e.g., a mode for floating text boxes, a mode for basketball, etx
//(for now at least...)
int mode;
int NUM_OF_MODES = 2;

//Font Stuff
PFont defaultFont, monoSpacedFont, monoSpacedBold, digitalFont;

//mouse/touch 
HashMap<Integer,Cursor>  cursors        = new HashMap<Integer,Cursor>();
float cursorX, cursorY;

void setup() {
    // javascript function to set sketch size according to the width of the browser
    setCanvasSize();
    size(sketchWidth, sketchHeight);
    smooth();
    float s = millis();
    parse();
    print("Elapsed time: "+(millis()-s));
    Year = start_year;
    PreviousYear = Year;
    count = 0;
    created_counter = 0;
    slider_flag = false;
    play = false;
    selected = 0; // 0 shows all rights
    
    USFlag = loadImage("../data/united_states_flag.png");
    tinyUSFlag = loadImage("../data/united_states_flag_tiny.png");
    helpIcon = loadImage("../web/help-icon.jpg");
    
    //set to first mode
    mode = 1;

      // font stuff
    fontSize                   = lerp(0,20, sketchWidth/(3840*0.49)); // 0.49 is percentage of canvas relative to browser window width
    defaultFont                = createFont("../data/RefrigeratorDeluxeLight.ttf", fontSize);
    monoSpacedFont             = createFont("../data/MonoSpaced.ttf", fontSize); 
    monoSpacedBold             = createFont("../data/MonoSpacedBold.ttf", fontSize);
    digitalFont                = createFont("../data/Digital.ttf", fontSize*4);
    textAlign(CENTER);
    textFont(defaultFont);
    
    // Create ArrayLists	
    bubbles = new ArrayList<Bubble>(initialSize);
    bubbles.add(new Bubble(width/2, height/2, rightarray[0], true));
    
    slide = new Slider(width/2,height*15/16, height/40, height/40, width*5/6, height/120);
    moveSlider();
    
    playpause = new PlayPause(slide.x, slide.y + height/27, height*tan(PI/3)/54, height/27);
    previousbutton = new PreviousButton(slide.x - height/18, slide.y + height/27, height/36, height/36);
    nextbutton = new NextButton(slide.x + height/18, slide.y + height/27, height/36, height/36);
    
    //  playpause = new PlayPause(slide.x, slide.y + height/36, height/43.2, height/54);
    //  previousbutton = new PreviousButton(slide.x - height/36, slide.y + height/36, height/54, height/72);
    //  nextbutton = new NextButton(slide.x + height/36, slide.y + height/36, height/54, height/72);
    
    // javascript function to create HTML buttons using the category titles as labels
//    generateButtonTreeLinks(categories.length+1, "#FFFFFF")
//    generateButtonTree();
    generateDescription();
    frameRate(60);
    
//    while(Year <= end_year){
//        Bubble bubble;
//        for(int i=initialSize; i<bubbles.size(); i++){
//            bubble = bubbles.get(i);
//            if(((bubble.right.count[Year-start_year].year_count > 0)
//              &&(bubble.right.count[Year-start_year].US_flag || !onlyUS)
//              && bubble.right.category != 0)
//              || bubble.help){
//                bubble.radius = bubble.getRadius();
//            }else{
//                bubbles.remove(bubble);
//            }
//        }
//        for(int i=0; i<(table[0].length-start); i++){
//            if((rightarray[i].count[Year-start_year].year_count > 0)
//               &&(rightarray[i].count[Year-start_year].US_flag || !onlyUS)
//               && rightarray[i].category != 0){
//                int flag = 0;
//                for (int j=initialSize; j<bubbles.size(); j++){
//                    bub = bubbles.get(j);
//                    if(bub.right.right_name.equals(rightarray[i].right_name)){
//                        flag = 1;
//                    }
//                }
//                if(flag == 1)  continue;
//                
//                //This section is for bubble generation/spawning
//                float rx = (rightarray[i].category)*width/(categories.length+1) + random(width/(categories.length+1));
//                float ry = height/12+height/43.2;
//                Bubble newbub = new Bubble(rx, ry, rightarray[i], false);
//                bubbles.add(newbub);
//                created_counter++;
//            }
//        }
//        Year++;
//    }
//    Year = start_year;
    
    // let javascript know that this vis is ready to draw
    visLoaded();
    
    
   
    //noLoop();
}

void draw() {
    drawBackground();
  
    if(onMobile){
        Year = end_year;
    }
    else{
        //code to move through time
        if(play){
            count++;
            if(count == play_time){
                if(Year == end_year){
                    Year = start_year;
                }else{
                    Year++;
                }
                count = 0;
                moveSlider();
            }
        }
    }

    // Display all the bubbles
    Bubble bubble;
    for(int i=initialSize; i<bubbles.size(); i++){
        bubble = bubbles.get(i);
        if(((bubble.right.count[Year-start_year].year_count > 0)
          &&(bubble.right.count[Year-start_year].US_flag || !onlyUS)
          && bubble.right.category != 0)
          || bubble.help){
            bubble.collide();
            bubble.move();
            bubble.display();
        }else{
            bubble.destroy();
            if(bubble.destroying){
                bubble.display();
            }
        }
    }
    PreviousYear = Year;

//    if (mousePressed) {
//        //display slider
//        if (/*(mouseX < (slide.x + slide.bar_length/2)) && (mouseX > (slide.x - slide.bar_length/2))
//                &&*/ slider_flag) {
//            float x;
//            if (mouseX > (slide.x + slide.bar_length/2))  x = slide.x + slide.bar_length/2;
//            else if (mouseX < (slide.x - slide.bar_length/2))  x = slide.x - slide.bar_length/2;
//            else x = mouseX;
//            slide.slideTo(x,slide.y);
//            //update year according to slider's new position
//            Year = start_year + floor((x - slide.x + slide.bar_length/2) * (end_year - start_year + 1) / slide.bar_length);
//            if(Year>end_year) Year = end_year;
//        }
//    }
    slide.display(onMobile);
    
    if(!onMobile){
        playpause.display();
        previousbutton.display();
        nextbutton.display();
    }
  
    for(int i=0; i<(table[0].length-start); i++){
        if((rightarray[i].count[Year-start_year].year_count > 0)
           &&(rightarray[i].count[Year-start_year].US_flag || !onlyUS)
           && rightarray[i].category != 0){
            int flag = 0;
            for (int j=initialSize; j<bubbles.size(); j++){
                bub = bubbles.get(j);
                if(bub.right.right_name.equals(rightarray[i].right_name)){
                    flag = 1;
                }
            }
            if(flag == 1)  continue;
            
            //This section is for bubble generation/spawning
            float rx = (rightarray[i].category)*width/(categories.length+1) + random(width/(categories.length+1));
            float ry = height/12+height/43.2;
            Bubble newbub = new Bubble(rx, ry, rightarray[i], false);
            bubbles.add(newbub);
            created_counter++;
        }
    }
    
    drawMargin();
  
    if(!procjs)  println(frameRate);
    fill(0,0,0);
    textAlign(CENTER, TOP);
    text(mode, width - height/43.2, height - height/43.2);
    for (int i=initialSize; i<bubbles.size(); i++){
        bub = bubbles.get(i);
        if(bub.hasSpring && !bub.help){
            bub.showText();
        }
    }
//    for (int i=initialSize; i<bubbles.size(); i++){
//        bub = bubbles.get(i);
//        if(bub.hasSpring && mousePressed){
//            bub.moveByTouch(mouseX, mouseY);
//            break;
//        }
//    }
//    if(mousePressed){
//        //display text if pressing bubble and in first mode (1)
//        if(currentlyPressed != null){
//            currentlyPressed.showText();
//        }
//    }

    if(frameCount == 1){
        launchTutorial();
    }

}

void drawBackground(){
    background(0);
    lights();
    pushStyle();
    for(int i = 0; i < categories.length+1; i++){
        fill(colorArray[i]);
        strokeWeight(height/100);
        stroke(0);
        rectMode(CORNER);
        float rectHeight = height/24;
        if(i == selected)  rectHeight = height/18;
        rect((i)*width/(categories.length+1), 0, width/(categories.length+1), rectHeight);
        
        textAlign(CENTER);
        textSize(height/48);
        fill(255);
        if(i == 0){
            text("All Categories", (i)*width/(categories.length+1), (height/24 - (textAscent() + textDescent()))/2,
                                    width/(categories.length+1), rectHeight*2);
        }
        else
            text(categories[i-1], (i)*width/(categories.length+1), (height/24 - (textAscent() + textDescent()))/2,
                                    width/(categories.length+1), rectHeight*2);
    }
    popStyle();
}

//NOT DRAW FUNCTIONS BELOW
void keyPressed() {
  
    //move through time
    if(keyCode==UP){
        Year++;
    }
    if(Year>2012){
        Year=1789;
    }
    if(keyCode==DOWN){
        Year--;
    }
    if(Year<1789){
        Year=2012;
    }
    
    //mode select
    if(keyCode == RIGHT){
        mode = (mode+1)%NUM_OF_MODES;
    }else if(keyCode == LEFT){
        mode--;
        if(mode < 0){
            mode = NUM_OF_MODES - 1;
        }
    }
    
    //play/pause
    if(key==' ')  play = play ? false : true;
    else play = false;
    moveSlider();
    
    if(key=='u')  onlyUS = onlyUS ? false : true;
    if(key=='m')  mode = (mode==1)? 0:1;
}

//void mousePressed() {
//    //to dragble b
//    for (int i=initialSize; i<bubbles.size(); i++){
//        bub = bubbles.get(i);
//        if(bub.contains(mouseX, mouseY)){
//            bub.hasSpring = true;
//            if(mode == 1){
//                bub.showText();
//            }
//            currentlyPressed = bub;
//            break;
//        }
//    }
//    
//    if(mouseY < height/24){
//        for(int i = 0; i < categories.length+1; i++){
//            if(i*width/(categories.length+1) <= mouseX && mouseX < (i+1)*width/(categories.length+1)){
//                selected = selected == i ? 0 : i;
//            }
//        }
//    }
//    
//    if (playpause.contains(mouseX, mouseY)){
//        play = play ? false : true;
//    }
//    if (previousbutton.contains(mouseX, mouseY)){
//        play = false;
//        Year--;
//        if(Year<1789)  Year=2012;
//        moveSlider();
//    }
//    if (nextbutton.contains(mouseX, mouseY)){
//        play = false;
//        Year++;
//        if(Year>2012)  Year=1789;
//        moveSlider();
//    }
//    
//    //to drag slider
//    if((mouseX < (slide.x + slide.bar_length/2)) && (mouseX > (slide.x - slide.bar_length/2))
//            && (mouseY < (slide.y + slide.h/2)) && (mouseY > (slide.y - slide.h/2))){
//        slider_flag = true;
//        play = false;
//    }
//  
//    //to click important years
//    float offset = height/40;
//    for(int i=0; i<importantyears.length; i++){
//        float dx = map(importantyears[i], start_year, end_year, slide.x-slide.bar_length/2, slide.x+slide.bar_length/2) - mouseX;
//        float dy = slide.y - offset - mouseY;
//        float distance = sqrt(dx*dx + dy*dy);
//        if(distance <= abs(offset/2)){
//          Year = importantyears[i];
//          moveSlider();
//        }
//        offset *= 0-1;
//    }
//}
//
//void mouseReleased(){
//  for (int i=initialSize; i<bubbles.size(); i++){
//        bub = bubbles.get(i);
//        if(bub.hasSpring){
//            bub.hasSpring = false;
//        }
//    }
//    currentlyPressed = null;
//    slider_flag = false;
//}

//Moves slider to current year
void moveSlider(){
    slide.moveTo(map(Year, start_year, end_year, slide.x-slide.bar_length/2, slide.x+slide.bar_length/2), slide.y);
}

void drawMargin(){
  pushStyle();
  pushMatrix();
  strokeWeight(MARGIN);
  stroke(#323232);
  line(0, height*7/8 - MARGIN/2, width, height*7/8 - MARGIN/2);
  popMatrix();
  popStyle();
}


void cursorDown(float x, float y, int id){
    cursorX    = x;
    cursorY    = y;
    
    //to drag bubbles
    for (int i=initialSize; i<bubbles.size(); i++){
        bub = bubbles.get(i);
        if(bub.contains(cursorX, cursorY) && !(bub.hasSpring)){
            if(bub.help){
              launchTutorial();
              return;
            }
            bub.hasSpring = true;
            bub.holder = id;
        }
    }
    
    //check the selected boxes
    if(cursorY < height/24){
        for(int i = 0; i < categories.length+1; i++){
            if(i*width/(categories.length+1) <= cursorX && cursorX < (i+1)*width/(categories.length+1)){
                selected = selected == i ? 0 : i;
                for(Bubble bub : bubbles){
                  bub.gravitating = true;
                }
            }
        }
    }
        
    //click controls
    if (playpause.contains(cursorX, cursorY)){
        play = play ? false : true;
    }
    if (previousbutton.contains(cursorX, cursorY)){
        play = false;
        Year--;
        if(Year<1789)  Year=2012;
        moveSlider();
    }
    if (nextbutton.contains(cursorX, cursorY)){
        play = false;
        Year++;
        if(Year>2012)  Year=1789;
        moveSlider();
    }

    //to drag slider
    if((cursorX < (slide.x + slide.bar_length/2)) && (cursorX > (slide.x - slide.bar_length/2))
            && (cursorY < (slide.y + slide.h)) && (cursorY > (slide.y - slide.h))){
        slider_flag = true;
        slide.holder = id;
        play = false;
    }
  
    //to click important years
    float offset = height/40;
    for(int i=0; i<importantyears.length; i++){
        float dx = map(importantyears[i], start_year, end_year, slide.x-slide.bar_length/2, slide.x+slide.bar_length/2) - cursorX;
        float dy = slide.y - offset - cursorY;
        float distance = sqrt(dx*dx + dy*dy);
        if(distance <= abs(offset/2)){
          Year = importantyears[i];
          play = false;
          moveSlider();
        }
        offset *= 0-1;
    }
}

void cursorMove(float x, float y, int id){
    cursorX    = x;
    cursorY    = y;
    
    if (slider_flag && (slide.holder == id)) {
        float x;
        if (cursorX > (slide.x + slide.bar_length/2))  x = slide.x + slide.bar_length/2;
        else if (cursorX < (slide.x - slide.bar_length/2))  x = slide.x - slide.bar_length/2;
        else x = cursorX;
        slide.slideTo(x,slide.y);
        //update year according to slider's new position
        Year = start_year + floor((x - slide.x + slide.bar_length/2) * (end_year - start_year + 1) / slide.bar_length);
        if(Year>end_year) Year = end_year;
    }
    for (int i=initialSize; i<bubbles.size(); i++){
        bub = bubbles.get(i);
        if(bub.hasSpring && bub.holder == id){
            bub.moveByTouch(cursorX, cursorY);
            break;
        }
    }
}

void cursorUp(float x, float y, int id){
    for (int i=initialSize; i<bubbles.size(); i++){
        bub = bubbles.get(i);
        if(bub.hasSpring && bub.holder == id){
            bub.hasSpring = false;
            bub.holder = 999;
        }
    }
    currentlyPressed = null;
//    if(slider.holder == id){
        slider_flag = false;
//        slider.holder = 999;
//    }
}


//*********************************************/
//*          MULTI-TOUCH SUPPORT              */
//*********************************************/
//void touchStart(TouchEvent touchEvent) {
//    touchEvent.preventDefault();
//    for (int k = 0; k < touchEvent.touches.length; k++) {
//        float touchX = touchEvent.touches[k].offsetX;
//        float touchY = touchEvent.touches[k].offsetY;
//        //to drag bubbles
//
//        for (int i=initialSize; i<bubbles.size(); i++){
//            bub = bubbles.get(i);
//            if(bub.contains(touchX, touchY) && !(bub.hasSpring)){
//                bub.hasSpring = true;
//                bub.holder = (Integer)touchEvent.touches[k].identifier;
//            }
//        }
//        
//        //check the selescted boxes
//        if(touchY < height/24){
//            for(int i = 0; i < categories.length+1; i++){
//                if(i*width/(categories.length+1) <= touchX && touchX < (i+1)*width/(categories.length+1)){
//                    selected = selected == i ? 0 : i;
//                }
//            }
//        }
//        
//    //click controls
//    if (playpause.contains(touchX, touchY)){
//        play = play ? false : true;
//    }
//    if (previousbutton.contains(touchX, touchY)){
//        play = false;
//        Year--;
//        if(Year<1789)  Year=2012;
//        moveSlider();
//    }
//    if (nextbutton.contains(touchX, touchY)){
//        play = false;
//        Year++;
//        if(Year>2012)  Year=1789;
//        moveSlider();
//    }
//
//    //to drag slider
//    if((touchX < (slide.x + slide.bar_length/2)) && (touchX > (slide.x - slide.bar_length/2))
//            && (touchY < (slide.y + slide.h)) && (touchY > (slide.y - slide.h))){
//        slider_flag = true;
//        slide.holder = (Integer)touchEvent.touches[k].identifier;
//        play = false;
//    }
//  
//    //to click important years
//    float offset = height/40;
//    for(int i=0; i<importantyears.length; i++){
//        float dx = map(importantyears[i], start_year, end_year, slide.x-slide.bar_length/2, slide.x+slide.bar_length/2) - touchX;
//        float dy = slide.y - offset - touchY;
//        float distance = sqrt(dx*dx + dy*dy);
//        if(distance <= abs(offset/2)){
//          Year = importantyears[i];
//          play = false;
//          moveSlider();
//        }
//        offset *= 0-1;
//    }
//  }
//}
//
//void touchMove(TouchEvent touchEvent){
//  for (int i = 0; i < touchEvent.changedTouches.length; i++) {
//    float touchX = touchEvent.changedTouches[i].offsetX;
//    float touchY = touchEvent.changedTouches[i].offsetY;
//    if (slider_flag && (slide.holder == (Integer)touchEvent.changedTouches[i].identifier)) {
//        float x;
//        if (touchX > (slide.x + slide.bar_length/2))  x = slide.x + slide.bar_length/2;
//        else if (touchX < (slide.x - slide.bar_length/2))  x = slide.x - slide.bar_length/2;
//        else x = touchX;
//        slide.slideTo(x,slide.y);
//        //update year according to slider's new position
//        Year = start_year + floor((x - slide.x + slide.bar_length/2) * (end_year - start_year + 1) / slide.bar_length);
//        if(Year>end_year) Year = end_year;
//    }
//    for (int i=initialSize; i<bubbles.size(); i++){
//        bub = bubbles.get(i);
//        if(bub.hasSpring && bub.holder == (Integer)touchEvent.changedTouches[i].identifier){
//            bub.moveByTouch(touchX, touchY);
//            break;
//        }
//    }
//  }
//}
//
//void touchEnd(TouchEvent touchEvent){ 
//  for (int i = 0; i < touchEvent.changedTouches.length; i++){
//        for (int i=initialSize; i<bubbles.size(); i++){
//        bub = bubbles.get(i);
//        if(bub.hasSpring && bub.holder == (Integer)touchEvent.changedTouches[i].identifier){
//            bub.hasSpring = false;
//        }
//    }
//    currentlyPressed = null;
////    if(slider.holder == (Integer)touchEvent.changedTouches[i].identifier){
//        slider_flag = false;
////    }
//  }
//}

/*********************************************/
/* PDE/JAVASCRIPT COMMUNICATION */
/*********************************************/

/* @pjs font='../data/RefrigeratorDeluxeLight.ttf, ../data/MonoSpaced.ttf, ../data/MonoSpacedBold.ttf, ../data/Digital.ttf'; */

/*********************************************/
/*       PDE/JAVASCRIPT COMMUNICATION        */
/*********************************************/

//javascript function for resizing sketch
function setCanvasSize() {
  var browserWidth    = window.innerWidth;
  var browserHeight   = window.innerHeight;
  if(screen.width*screen.height < 8294400) onMobile = true;
  sketchWidth         = browserWidth * 0.856;
  sketchHeight        = browserHeight;
}

function generateDescription() {
  String[] descriptionText = loadStrings("../web/description.html");
  String   joinedText      = join(descriptionText, " ");
  
  var descriptionDiv = document.getElementById('description'); 
  descriptionDiv.innerHTML = joinedText;
}

void visLoaded() {
    readyToDraw();
} 

