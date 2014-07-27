// Code based off of:
// The Nature of Code
// <http://www.shiffman.net/teaching/nature>

//Physics fixed, cleaned up code. A lot. Also fixed bug regarding bubbles resting on bottom. Only need to clean up draw loop.

/*
TODO: *US amendment markers on time line, TUIO (eddy), fix garbage collection(the drastic framerate drop at around 1950)
*category legend BUTTons from Eddy(adjust alpha), GG map(don't worry about this yet)
*/

/*
NOTE OF THE DAY FOR RJ:
Should we chagne onlyUS to a mode eventually, or just keep using mode for debugging? 
Also: large presentation thingy this morning. got almost nothing done.
Also-also: can we do much with garabe collection? We can really only suggest when it runs... Unless you had something else in mind
THE BIG ONE: added a flag called onlyUS which, if true, makes only the US rights appear on screen. We thought NCC might like that more since they love hiding data to make USA look good. Use key 'u' to toggle onlyUS during runtime.
*/

//MAY HAVE TO INCORPORATE THESE VARIABLES OUT
boolean procjs = true;
boolean onlyUS = false;
Bubble currentlyPressed;    //selected bubble - Switch to arraylist for TUIO

//LISTS To hold walls and objects
ArrayList<Boundary> boundaries;
ArrayList<Bubble> bubbles;
//A list of the (index of) rights (bubbles) already created
String[] created;

//Physics
float Gravity = 0.25;
float friction = 0.9;
float wallFriction = 0.4;
float groundFriction = 0.7;
float terminalVY = 15;
float terminalVX = 3;
float throwEase = 2;//Higher the throwEase, the harder to throw

//Data variables
int Year;
int PreviousYear;
int count;
int created_counter;
boolean play;
int selected;
PImage USFlag;

//Sketch dimersion variables
float  sketchWidth;
float  sketchHeight;

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

void setup() {
    // javascript function to set sketch size according to the width of the browser
    setCanvasSize();
    size(sketchWidth, sketchHeight);
    smooth();
    
    parse();
    Year = start_year;
    PreviousYear = Year;
    count = 0;
    created_counter = 0;
    slider_flag = false;
    play = false;
    selected = 0; // 0 shows all rights
    
    USFlag = loadImage("../data/united_states_flag.png");
    tinyUSFlag = loadImage("../data/united_states_flag_tiny.png");
    
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
    bubbles = new ArrayList<Bubble>();
    boundaries = new ArrayList<Boundary>();
    
    // Add a bunch of fixed boundaries
    float boundary_size = 10;
    //  boundaries.add(new Boundary(width/2,boundary_size/2,width,boundary_size,0));
    //  boundaries.add(new Boundary(width/2,height*7/8,width,boundary_size,0));
    //  boundaries.add(new Boundary(width-boundary_size/2,height/2,boundary_size,height,0));
    //  boundaries.add(new Boundary(boundary_size/2,height/2,boundary_size,height,0));
    //  boundaries.add(new Boundary(width/2,height-boundary_size/2,width,boundary_size,0));
    
    slide = new Slider(width/2,height*15/16, height/40, height/40, width*5/6, height/120);
    moveSlider();
    
    playpause = new PlayPause(slide.x, slide.y + height/27, height*tan(PI/3)/54, height/27);
    previousbutton = new PreviousButton(slide.x - height/18, slide.y + height/27, height/36, height/36);
    nextbutton = new NextButton(slide.x + height/18, slide.y + height/27, height/36, height/36);
    
    //  playpause = new PlayPause(slide.x, slide.y + height/36, height/43.2, height/54);
    //  previousbutton = new PreviousButton(slide.x - height/36, slide.y + height/36, height/54, height/72);
    //  nextbutton = new NextButton(slide.x + height/36, slide.y + height/36, height/54, height/72);
    
    // javascript function to create HTML buttons using the category titles as labels
    generateButtonTreeLinks(categories.length+1, "#FFFFFF")
    generateButtonTree(categories.length+1);
    
    frameRate(60);
    noLoop();
}

void draw() {
    background(0);
  
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

    // Display all the boundaries
    for (Boundary wall: boundaries) {
        wall.display();
    }

    // Display all the bubbles
    Bubble bubble;
    for(int i=0; i<bubbles.size(); i++){
        bubble = bubbles.get(i);
        if((bubble.right.count[Year-start_year].year_count > 0)
          &&(bubble.right.count[Year-start_year].US_flag || !onlyUS)){
            bubble.collide();
            bubble.move();
            bubble.display();
        }else{
            bubble.destroy();
            if(bubble.destroying){
                bubble.display();
            }
            //else{
            //bubbles.remove(bubble);
            //created_counter--;
            //}
        }
    }
    PreviousYear = Year;

    if (mousePressed) {
        //display slider
        if (/*(mouseX < (slide.x + slide.bar_length/2)) && (mouseX > (slide.x - slide.bar_length/2))
                &&*/ slider_flag) {
            float x;
            if (mouseX > (slide.x + slide.bar_length/2))  x = slide.x + slide.bar_length/2;
            else if (mouseX < (slide.x - slide.bar_length/2))  x = slide.x - slide.bar_length/2;
            else x = mouseX;
            slide.slideTo(x,slide.y);
            //update year according to slider's new position
            Year = start_year + floor((x - slide.x + slide.bar_length/2) * (end_year - start_year + 1) / slide.bar_length);
            if(Year>end_year) Year = end_year;
        }
    }
    slide.display();
      
    playpause.display();
    previousbutton.display();
    nextbutton.display();
  
    for(int i=0; i<(table[0].length-start); i++){
        if((rightarray[i].count[Year-start_year].year_count > 0)
           &&(rightarray[i].count[Year-start_year].US_flag || !onlyUS)){
            int flag = 0;
            for(Bubble bub: bubbles){
                if(bub.right.right_name.equals(rightarray[i].right_name)){
                    flag = 1;
                }
            }
            if(flag == 1)  continue;
            
            //This section is for bubble generation/spawning
            int margin = 10;
            float rx = random(margin,width-margin);
            float ry = random(margin+10, margin+height/43.2);
            Bubble bub = new Bubble(rx, ry, rightarray[i]);
            bubbles.add(bub);
            created_counter++;
        }
    }
  
    if(mousePressed){
        //display text if pressing bubble and in first mode (1)
        if(currentlyPressed != null && mode == 1){
            currentlyPressed.showText();
        }
    }
  
    if(!procjs)  println(frameRate);
    fill(0,0,0);
    textAlign(CENTER, TOP);
    text(mode, width - height/43.2, height - height/43.2);
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
}

void mousePressed() {
    //to drag bubbles
    for (Bubble bub: bubbles) {
        if(bub.contains(mouseX, mouseY)){
            bub.hasSpring = true;
            if(mode == 1){
                bub.showText();
            }
            currentlyPressed = bub;
            break;
        }
    }
    
    //to drag slider
    if((mouseX < (slide.x + slide.bar_length/2)) && (mouseX > (slide.x - slide.bar_length/2))
            && (mouseY < (slide.y + slide.h/2)) && (mouseY > (slide.y - slide.h/2))){
        slider_flag = true;
        play = false;
    }
    
    if (playpause.contains(mouseX, mouseY)){
        play = play ? false : true;
    }
    if (previousbutton.contains(mouseX, mouseY)){
        play = false;
        Year--;
        if(Year<1789)  Year=2012;
        moveSlider();
    }
    if (nextbutton.contains(mouseX, mouseY)){
        play = false;
        Year++;
        if(Year>2012)  Year=1789;
        moveSlider();
    }
  
    //to click important years
    float offset = height/40;
    for(int i=0; i<importantyears.length; i++){
        float dx = map(importantyears[i], start_year, end_year, slide.x-slide.bar_length/2, slide.x+slide.bar_length/2) - mouseX;
        float dy = slide.y - offset - mouseY;
        float distance = sqrt(dx*dx + dy*dy);
        if(distance <= abs(offset/2)){
          Year = importantyears[i];
          moveSlider();
        }
        offset *= 0-1;
    }
}

void mouseReleased(){ 
    for(Bubble bub: bubbles){
        if(bub.hasSpring){
            bub.hasSpring = false;
        }
    }
    currentlyPressed = null;
    slider_flag = false;
}

//Moves slider to current year
void moveSlider(){
    slide.moveTo(map(Year, start_year, end_year, slide.x-slide.bar_length/2, slide.x+slide.bar_length/2), slide.y);
}


/*********************************************/
/* PDE/JAVASCRIPT COMMUNICATION */
/*********************************************/

/* @pjs font='../data/RefrigeratorDeluxeLight.ttf, ../data/MonoSpaced.ttf, ../data/MonoSpacedBold.ttf, ../data/Digital.ttf'; */

/*********************************************/
/*       PDE/JAVASCRIPT COMMUNICATION        */
/*********************************************/
function generateButtonTreeLinks(listSize, borderColor){
  var buttonIframe = window.parent.document.getElementById('controlsDiv2');
  var buttonDiv = buttonIframe.contentWindow.document.getElementById('buttonDiv');
  var rootTable = document.createElement('TABLE');
  rootTable.style.width = "40%";
  var childTableCellHeight = 100/((listSize-1)*2); // as percentage
  rootTable.style.height = 100 - childTableCellHeight*2 + "%"; 
  rootTable.style.position = "absolute";
  rootTable.style.top = childTableCellHeight + "%"; 
  rootTable.style.left = "10%";
  rootTable.style.borderRight = "1px solid " + borderColor;
  
  var rootTableBody = document.createElement('TBODY');
  rootTable.appendChild(rootTableBody); 
  
  for (var i=0; i<6; i++){
     var tr = document.createElement('TR');
     rootTableBody.appendChild(tr);
     var td = document.createElement('TD');
     if(i==2) { td.style.borderBottom = "1px solid " + borderColor; }
     tr.appendChild(td);
  }
  buttonDiv.appendChild(rootTable);  
  
  var childrenTable = document.createElement('TABLE');
  childrenTable.style.width = "35%";
  childrenTable.style.height = "100%";
  childrenTable.style.position = "absolute";
  childrenTable.style.top = "0%";
  childrenTable.style.left = "50%";
  childrenTable.style.border = "none";
  
  var childrenTableBody = document.createElement('TBODY');
  childrenTable.appendChild(childrenTableBody);
    
  for (var i=0; i<(listSize-1)*2; i++){
     var tr = document.createElement('TR');
     childrenTableBody.appendChild(tr);
     var td = document.createElement('TD');
     if((i&1) == 0) { td.style.borderBottom = "1px solid " + borderColor; }
     tr.appendChild(td);
  }
  buttonDiv.appendChild(childrenTable);    
}

function generateButtonTree(listSize){      
  var buttonIframe = window.parent.document.getElementById('controlsDiv2');
  var buttonDiv = buttonIframe.contentWindow.document.getElementById('buttonDiv');
  
  // center root button within left div using table
  var rootTable = document.createElement('TABLE');
  rootTable.style.width = "35%";
  rootTable.style.height = "100%";
  rootTable.style.position = "absolute";
  rootTable.style.top = "0%";
  rootTable.style.left = "5%";
  rootTable.style.border = "none";
  
  var rootTableBody = document.createElement('TBODY');
  rootTable.appendChild(rootTableBody); 
  
  for (var i=0; i<3; i++){
     var tr = document.createElement('TR');
     rootTableBody.appendChild(tr);
     var td = document.createElement('TD');
     td.style.height = "33.33%";
     
     if(i == 1) {
       var rootButton = document.createElement('div');
       rootButton.appendChild(document.createTextNode("All Categories"));
       rootButton.setAttribute("id", "categoryButton" + (listSize-1));
       rootButton.setAttribute("class", "button");
       rootButton.setAttribute('onclick', 'window.parent.document.getElementById("visDiv2").contentWindow.changeSelected("'+0+'")');
       rootButton.style.width = "100%";
       rootButton.style.height = "100%";
       rootButton.style.position = "relative";
       td.appendChild(rootButton);
       
       // create circle svgs to represent categories and add them to rootButton
       for(var j=0; j<listSize-1; j++){
         // calculate svg size (in pixels) based off of button dimensions
         var rootButtonHeight = (buttonIframe.clientHeight)/3; // in px
         var rootButtonWidth  = ((buttonIframe.clientWidth) * 0.35);
         var iconWidth  = (rootButtonHeight * 0.75 * 0.33);
         var iconHeight = (rootButtonHeight * 0.75 * 0.33);
         var iconRadius = iconWidth * 0.4;
              
         // create svg to hold category icon
         var categorySVG = document.createElementNS("http://www.w3.org/2000/svg", "svg");
         categorySVG.setAttribute("height", iconHeight);
         categorySVG.setAttribute("width", iconWidth);
         categorySVG.setAttribute("display", "block");
         categorySVG.style.position = "absolute";
         categorySVG.style.top = rootButtonHeight*0.25 + iconHeight*j;
         categorySVG.style.left = (rootButtonWidth-iconWidth)/2 + "px";
         
         // add circle elelment to svg
         var categoryCircle = document.createElementNS("http://www.w3.org/2000/svg", "circle");
         categoryCircle.setAttribute("cx",iconWidth/2);
         categoryCircle.setAttribute("cy",iconHeight/2);
         categoryCircle.setAttribute("r", iconRadius);
         categoryCircle.setAttribute("stroke", "#000000");
         categoryCircle.setAttribute("stroke-width", "1");
         categoryCircle.setAttribute("fill", "#" + hex(colorArray[j+1], 6));
         categorySVG.appendChild(categoryCircle);
    
         // add icon to button
         rootButton.appendChild(categorySVG);
       }
     }
     tr.appendChild(td);
  }
  buttonDiv.appendChild(rootTable);   
  
  // create table to hold category buttons
  var childrenTable = document.createElement('TABLE');
  childrenTable.style.width = "35%";
  childrenTable.style.height = "100%";
  childrenTable.style.position = "absolute";
  childrenTable.style.top = "0%";
  childrenTable.style.left = "60%";
  childrenTable.style.border = "none";
  
  var childrenTableBody = document.createElement('TBODY');
  childrenTable.appendChild(childrenTableBody);
    
  // generate a button for each category in the csv file
  for (var i=0; i<listSize-1; i++){
     var tr = document.createElement('TR');
     childrenTableBody.appendChild(tr);
     var td = document.createElement('TD');
     td.style.height = 100/(listSize-1) + "%";
     
     var childButton = document.createElement('div');
     childButton.appendChild(document.createTextNode(categories[i]));
     childButton.setAttribute("id", "categoryButton" + (listSize-1));
     childButton.setAttribute("class", "button");
     childButton.setAttribute('onclick', 'window.parent.document.getElementById("visDiv2").contentWindow.changeSelected("'+(i+1)+'")');
     childButton.style.width = "100%";
     childButton.style.height = "50%";
     childButton.style.position = "relative";
     
     // calculate svg size (in pixels) based off of button dimensions
     var childButtonHeight = ((buttonIframe.clientHeight)/(listSize-1))*0.5; // in px
     var childButtonWidth  = ((buttonIframe.clientWidth) * 0.35);
     var iconWidth  = Math.min(childButtonHeight * 0.5, childButtonWidth * 0.5);
     var iconHeight = Math.min(childButtonHeight * 0.5, childButtonWidth * 0.5);
     var iconRadius = iconWidth * 0.4;
          
     // create svg to hold category icon
     var categorySVG = document.createElementNS("http://www.w3.org/2000/svg", "svg");
     categorySVG.setAttribute("height", iconHeight);
     categorySVG.setAttribute("width", iconWidth);
     categorySVG.setAttribute("display", "block");
     categorySVG.style.position = "absolute";
     categorySVG.style.top = "50%";
     categorySVG.style.left = (childButtonWidth-iconWidth)/2 + "px";
     
     // add circle elelment to svg
     var categoryCircle = document.createElementNS("http://www.w3.org/2000/svg", "circle");
     categoryCircle.setAttribute("cx",iconWidth/2);
     categoryCircle.setAttribute("cy",iconHeight/2);
     categoryCircle.setAttribute("r", iconRadius);
     categoryCircle.setAttribute("stroke", "#000000");
     categoryCircle.setAttribute("stroke-width", "1");
     categoryCircle.setAttribute("fill", "#" + hex(colorArray[i+1], 6));
     categorySVG.appendChild(categoryCircle);

     // add icon to button
     childButton.appendChild(categorySVG);
     td.appendChild(childButton);
     tr.appendChild(td);
  }
  buttonDiv.appendChild(childrenTable);    
}

//javascript function for resizing sketch
function setCanvasSize(){

    var browserWidth = window.innerWidth;
    var browserHeight = window.innerHeight;
    sketchWidth = browserWidth;
    sketchHeight = browserHeight * .98;
}

void setSelectedFromJS(int i){
    selected = i;
}
