
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
float limit;
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
float seconds;
int created_counter;
boolean play;
int selected;
int selectedSize;
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
    seconds = millis();
    parse();
    print("Elapsed time: "+(millis()-seconds));
    seconds = millis();
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
    
    // javascript function to create HTML text on right
    generateDescription();
    frameRate(60);
    
    // let javascript know that this vis is ready to draw
    visLoaded();
   
    //noLoop();
//    play = true;
}

void draw() {
    drawBackground();
    //code to move through time
    if(play){
        if((millis() - seconds) > 300){
            if(Year == end_year){
                Year = start_year;
            }else{
                Year++;
            }
            seconds = millis();
            count++;
            moveSlider();
        }
    }
//    console.log(count);
//    if(count == 0)  Year = 1860;
//    if(count == 5)  Year = 1940;
//    if(count == 10)  Year = 2008;
//    if(count == 15)  {
//        play = false;
//        count++;
////        visLoaded();
//    }
    
    

    // Display all the non-selected bubbles
    Bubble bubble;
    for(int i=initialSize; i<bubbles.size(); i++){
        bubble = bubbles.get(i);
        if(bubble.right.category == selected || selected == 0)  continue;
        if(((bubble.right.count[Year-start_year].year_count > 0)
          &&(bubble.right.count[Year-start_year].US_flag || !onlyUS)
          && bubble.right.category != 0)
          || bubble.help){
            bubble.collide();
            if(bubble.hasSpring){
                bubble.vx = 0;
                bubble.vy = 0;
                bubble.move();
            }
            else
                bubble.move();
            bubble.display();
        }else{
            bubble.destroy();
            if(bubble.destroying){
                bubble.display();
            }
        }
    }
    //Display all the selected bubbles
    for(int i=initialSize; i<bubbles.size(); i++){
        bubble = bubbles.get(i);
        if(!(bubble.right.category == selected || selected == 0))  continue;
        if(((bubble.right.count[Year-start_year].year_count > 0)
          &&(bubble.right.count[Year-start_year].US_flag || !onlyUS)
          && bubble.right.category != 0)
          || bubble.help){
            bubble.collide();
            if(bubble.hasSpring){
                bubble.vx = 0;
                bubble.vy = 0;
            }
            else
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
    
    slide.display();
      
    playpause.display();
    previousbutton.display();
    nextbutton.display();
  
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
    selectedSize = 0;
    for (int i=initialSize; i<bubbles.size(); i++){
        bub = bubbles.get(i);
        if(bub.help)  continue;
        
        if(bub.right.category == selected){
            selectedSize++;
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
    
    fill(0, 0);
    stroke(#FF0000);
    strokeWeight(1);
    rectMode(CENTER);
//    rect(width/2, height/2, 2*limit, 2*limit);
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
            text("All Categories", (i)*width/(categories.length+1), (height/24 - (textAscent() + textDescent()))/2, width/(categories.length+1), rectHeight*2);
            if(i == selected){
                pushStyle();
                textSize(height/64);
                text(created_counter, (i)*width/(categories.length+1), (height/18 + (textAscent() + textDescent()))/2, width/(categories.length+1), rectHeight*2);
                popStyle();
            }
        }
        else{
            text(categories[i-1], (i)*width/(categories.length+1), (height/24 - (textAscent() + textDescent()))/2, width/(categories.length+1), rectHeight*2);
            if(i == selected){
                pushStyle();
                textSize(height/64);
                text(selectedSize, (i)*width/(categories.length+1), (height/18 + (textAscent() + textDescent()))/2, width/(categories.length+1), rectHeight*2);
                popStyle();
            }
        }
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

//called in cursorDown(), k is the index of the category tab clicked
void setSelected(int k){
    selected = selected == k ? 0 : k;
    
    selectedSize = 0;
    
    for (int i=initialSize; i<bubbles.size(); i++){
        bub = bubbles.get(i);
        if(bub.help)  continue;
        bub.gravitating = true;
        if(bub.holder == 998){
            bub.holder = 999;
            bub.hasSpring = false;
        }
        
        if(bub.right.category == selected){
            selectedSize++;
        }
    }
}

void cursorDown(float x, float y, int id){
    cursorX    = x;
    cursorY    = y;
    
    //to drag bubbles
    for (int i=initialSize; i<bubbles.size(); i++){
        bub = bubbles.get(i);
        if(bub.textContains(cursorX, cursorY) && bub.hasSpring){
//            String[] countryList = new String[bub.right.count[Year-start_year].year_count];
//            for(int j = 0; j < bub.right.count[Year-start_year].year_count; j++)
//                countryList[j] = bub.right.introduce10[j];
            
            parent.changeCircleOfRights(bub.right.count[Year-start_year].countries.toArray(), bub.right.category - 1, Year, bub.rightName);
        }
        //for second click
        if(bub.contains(cursorX, cursorY) && bub.hasSpring && bub.holder != 998){
            bub.holder = 998;//pinned
        }
        else if(bub.contains(cursorX, cursorY) && (!(bub.hasSpring) || bub.holder == 998)){
            if(bub.help){
              launchTutorial();
              return;
            }
            bub.setSpring();
            bub.holder = id;
            bub.offsetX = cursorX - bub.x;
            bub.offsetY = cursorY - bub.y;
        }
    }
    
    //check the selected boxes
    if(cursorY < height/18){
        for(int i = 0; i < categories.length+1; i++){
            if(i*width/(categories.length+1) <= cursorX && cursorX < (i+1)*width/(categories.length+1)){
                setSelected(i);
            }
        }
    }
        
    //click controls
    if (playpause.contains(cursorX, cursorY)){
        play = play ? false : true;
        return;
    }
    if (previousbutton.contains(cursorX, cursorY)){
        play = false;
        Year--;
        if(Year<1789)  Year=2012;
        moveSlider();
        return;
    }
    if (nextbutton.contains(cursorX, cursorY)){
        play = false;
        Year++;
        if(Year>2012)  Year=1789;
        moveSlider();
        return;
    }

    //to drag slider
    if((cursorX < (slide.x + slide.bar_length/2)) && (cursorX > (slide.x - slide.bar_length/2))
            && (cursorY < (slide.y + slide.h)) && (cursorY > (slide.y - slide.h))){
        slider_flag = true;
        slide.holder = id;
        play = false;
    }
  
    //to click important years
    float offset = - height/40;
    for(int i=0; i<importantyears.length; i++){
        float dx = map(importantyears[i], start_year, end_year, slide.x-slide.bar_length/2, slide.x+slide.bar_length/2) - cursorX;
        float dy = slide.y - offset - cursorY;
        float distance = sqrt(dx*dx + dy*dy);
        if(distance <= abs(offset/2)){
          Year = importantyears[i];
          play = false;
          moveSlider();
        }
        offset *= -1;
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
            if(bub.moveByTouch(cursorX, cursorY)){
                break;
            }
        }
    }
}

void cursorUp(float x, float y, int id){
    for (int i=initialSize; i<bubbles.size(); i++){
        bub = bubbles.get(i);
        if(bub.hasSpring && (bub.holder == id)){
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

/*********************************************/
/* PDE/JAVASCRIPT COMMUNICATION */
/*********************************************/

/* @pjs font='../data/RefrigeratorDeluxeLight.ttf, ../data/MonoSpaced.ttf, ../data/MonoSpacedBold.ttf, ../data/Digital.ttf'; */

//javascript function for resizing sketch
function setCanvasSize() {
  var browserWidth    = window.innerWidth;
  var browserHeight   = window.innerHeight;
  if(screen.width*screen.height < 8000000/*8294400*/) onMobile = true;
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
