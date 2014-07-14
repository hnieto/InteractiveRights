// Code based off of:
// The Nature of Code
// <http://www.shiffman.net/teaching/nature>

//Last updated 3:00 7/9/14
//draggable bubbles and terminal velocities, throwEase
//NO PHYSICS

//Last updated 12:45 7/8/14
//The collide works better now. They aren't repulsive.
//But there is something weird with dividing the vy and vx upon collision
//so sometimes they just shoot out of the top because they collide
//and when they collide their speed doesn't dampen.

//Check out BouncyBubbles.pde in Documents/Processing/. Messed around a bit with that and it looks magnificent.

//TODO: add pin functionality, markers for year?, marker for US (flag), US amendment markers on time line, TUIO (eddy), change theme of time bar and stuff, category legend BUTTons from Eddy(adjust alpha), GG map(don't worry abou thtis yet)

float Gravity = 0.3;
float friction = 0.9;
float wallFriction = 0.4;
float terminalVY = 15;
float terminalVX = 3;

float throwEase = 2;//Higher the throwEase, the harder to throw

// A list we'll use to track fixed objects
ArrayList<Boundary> boundaries;
// A list for all of our rectangles
ArrayList<Bubble> bubbles;
//A list of the (index of) rights (bubbles) already created
String[] created;

Slider slide;
boolean slider_flag; //if slider is currently being dragged

PlayPause playpause;
PreviousButton previousbutton;
NextButton nextbutton;

int Year;
int PreviousYear;
int count;
int created_counter;
boolean play;

boolean fullscreen = false;
boolean lasso = true;
boolean procjs = true;

Bubble currentlyPressed;

//ADDED: to switch betwen inter-activities (pun intended)
//a certain mode number corresponds to how we are displaying info
//e.g., a mode for floating text boxes, a mode for basketball, etx
//(for now at least...)
int mode;
int NUM_OF_MODES = 2;

float  sketchWidth;
float  sketchHeight;

void setup() {
  // javascript function to set sketch size according to the width of the browser
  setCanvasSize();
  size(sketchWidth, sketchHeight);
  /*
  if(fullscreen) size(displayWidth, displayHeight);
  else if(lasso) size(1759, 1900);
  else{
    //rahul's comp.
    size(640,720);
    
    //agerome's comp.
    //size(1650, 1000);
  }
  */
  
  parse();
  Year = start_year;
  PreviousYear = Year;
  count = 0;
  created_counter = 0;
  slider_flag = false;
  play = false;

  //size(3840, 2160);
  smooth();
  
  //set to first mode
  mode = 1; 

  // Create ArrayLists	
  bubbles = new ArrayList<Bubble>();
  boundaries = new ArrayList<Boundary>();

  // Add a bunch of fixed boundaries
  float boundary_size = 10;
  boundaries.add(new Boundary(width/2,boundary_size/2,width,boundary_size,0));
  boundaries.add(new Boundary(width/2,height*7/8,width,boundary_size,0));
  boundaries.add(new Boundary(width-boundary_size/2,height/2,boundary_size,height,0));
  boundaries.add(new Boundary(boundary_size/2,height/2,boundary_size,height,0));
  
  boundaries.add(new Boundary(width/2,height-boundary_size/2,width,boundary_size,0));
  
  slide = new Slider(width/2,height*15/16, height/30, height/30, width*5/6, height/60);
  moveSlider();
  
  playpause = new PlayPause(slide.x, slide.y + height/36, height/43.2, height/54);
  previousbutton = new PreviousButton(slide.x - height/36, slide.y + height/36, height/54, height/72);
  nextbutton = new NextButton(slide.x + height/36, slide.y + height/36, height/54, height/72);
  
  frameRate(60);
}

void draw() {
  background(0);
  
  //code to move through time
  if(play){
    //spring.destroy();
    count++;
    if(count == 10){
      if(Year == end_year){
        Year = start_year;
      }
      else{
        Year++;
      }
      count = 0;
      moveSlider();
    }
  }
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(height/72);
  text(Year, slide.x, slide.y-height/24);
  textSize(height/108);
  text(created_counter, slide.x, slide.y-height/18);

  // Display all the boundaries
  for (Boundary wall: boundaries) {
    wall.display();
  }

  // Display all the bubbles
  Bubble bubble;
  for(int i=0; i<bubbles.size(); i++){
    bubble = bubbles.get(i);
    if(bubble.right.count[Year-start_year].year_count > 0){
      bubble.collide();
      bubble.move();
      bubble.display();
    }
    else{
      bubbles.remove(bubble);
      created_counter--;
    }
  }
  PreviousYear = Year;
  
  if (mousePressed) {
    //display slider
    if ((mouseX < (slide.x + slide.bar_length/2)) && (mouseX > (slide.x - slide.bar_length/2))
    && slider_flag) {
      float x;
      /*if (mouseX > (slide.x + slide.bar_length/2))  x = slide.x + slide.bar_length/2;
      else if (mouseX < (slide.x - slide.bar_length/2))  x = slide.x - slide.bar_length/2;
      else*/ x = mouseX;
      slide.slideTo(x,slide.y);
      //update year according to slider's new position
      Year = start_year + floor((x - slide.x + slide.bar_length/2) * (end_year - start_year + 1) / slide.bar_length);
    }
  }
  slide.display();
  
  playpause.display();
  previousbutton.display();
  nextbutton.display();
  
  for(int i=0; i<(table[0].length-start); i++){
    
    if(rightarray[i].count[Year-start_year].year_count > 0){
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
  text(mode, width - height/43.2, height - height/43.2);
}


//NOT DRAW FUNCTIONS BELOW

void keyPressed() {
  //spring.destroy();
  
  //move through time
  if(keyCode==UP){    Year++;}
  if(Year>2012){   Year=1789;}
  if(keyCode==DOWN){  Year--;}
  if(Year<1789){   Year=2012;}
  
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
  if(/*(mouseX < (slide.x + slide.bar_length/2)) && (mouseX > (slide.x - slide.bar_length/2))
    &&*/ (mouseY < (slide.y + slide.h/2)) && (mouseY > (slide.y - slide.h/2))){
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
void moveSlider()
{
  slide.moveTo(map(Year, start_year, end_year, slide.x-slide.bar_length/2, slide.x+slide.bar_length/2), slide.y);
}

//javascript function for resizing sketch
function setCanvasSize(){

  var buttonDivHeight = document.getElementById('buttonContainer').clientHeight;
  var browserWidth = window.innerWidth;
  var browserHeight = window.innerHeight;
  sketchWidth = browserWidth;
  sketchHeight = browserHeight * 0.95 - buttonDivHeight;
  
  document.getElementById('visDiv').setAttribute("style","width:"+sketchWidth+"px");
}


