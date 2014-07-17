
class Ball {

  // Properties, all of these are global variables that can be used throughout the class
  float x;//x-origin position
  float y;//y-origin position
  float w;//width of circle
  float h;//length of circle
  color c;//color
  float xSpeed = 5;
  float ySpeed = 5;
  int id;
  //  ArrayList<Ball> others;
  Timed_bouncing_ball_trialFour parent;
  String[] inputRight;
  String newRight;
  String newRightText;
  String originalRight;
  String randomizer;

  // Constructor
  //  Ball(int x, int y, int w, int h, color c, float sx, float sy, int id, ArrayList<Ball> others) {
  Ball(float x, float y, float w, float h, color c, float xSpeed, float ySpeed, int id, Timed_bouncing_ball_trialFour parent, String[] inputRight) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.c = c;
    this.id=id;
    this.xSpeed = xSpeed;
    this.ySpeed = ySpeed;
    //    this.others= others;
    this.parent = parent;
    this.inputRight = inputRight;
  }

  // Methods

  //Inputing random description and amendment numbers
  void init () {
    // randomly select n number of rights
    for (int i=0; i<numBall; i++) {
      int randomIndex = int(random(0, this.inputRight.length));//ramdomonly choosing a number from 0 to the amound of lines on the text file to select a specific line.
      originalRight= this.inputRight[randomIndex];
      String[] randomRight = split(originalRight, ":");//makes an array that will split the data of the text file into two lines, a random line of text will be selected.
      String randomRightAmendment = randomRight[0];//the random right's amendment number which is the first part of the element
      String randomRightDescription = randomRight[1];// the random right's description which is the second part of the element
      String randomizer= randomRightAmendment;
      int randomAmendmentNum = int(random(1, 28));

      //fixing the ramondomiztion of the statement's description and amendment number
      int b = int(random(0, 2));
      if (b == 0) {
        randomizer="Amendment " + str(randomAmendmentNum);
      }

      newRight =randomizer + ":" +  randomRightDescription;//this will be used to check if the altered and original are the same

      newRightText= randomizer + ":\n"+ "\n" +  randomRightDescription;//new right is what will be written in the ball
      //    amendments.add(new Amendments(newRight));
    }
  }


  //draws the ball and applys the text
  void drawBall() {
    fill(this.c);
    ellipse( this.x, this.y, this.w, this.h);
    textSize(fontSize);
    fill(fontColor);
    //    text(this.x      + " " + this.y, this.x - radius, this.y - 0.5*radius);
    //    text(this.xSpeed + " " + this.ySpeed, this.x - radius, this.y + 0.5*radius );
    textLeading(lineSpacing);

    //fill(255, 0, 0);
    //rect(this.x, this.y, radius*1.5, radius*1.5);
    text(newRightText, this.x-radius*0.75, this.y-radius/2, radius*1.5, radius*1.5);
  }

  void updatePosition() {


    //move ball
//these if statemenets check if the ball is near a margin all all sides, and will bounce of of them
    //check if ball is on left margin
    if (this.x <= this.w/2) {
      this.xSpeed = abs(this.xSpeed);
    }

    //check if ball is on right margin
    if (this.x >= width-this.w/2) {
      this.xSpeed = -abs(this.xSpeed);
    }

    //check if ball is on top margin
    if (this.y <= this.h/2) {
      this.ySpeed = abs(this.ySpeed);
    }

    //check if ball is on bottom margin, the margin is reduced to allow the illusion that the ball can go past the image, hinting that the user may drag the ball there
    if (this.y >= (uBB)-this.h/3) {
      this.ySpeed = -abs(this.ySpeed);
    }

    //check if out of bounds
    if (this.x < this.w/2) { 
      this.x = this.w/2;
    }
    if (this.y < this.h/2) { 
      this.y = this.h/2;
    }
    
    //limit speed
    if (this.xSpeed> maxspeed && this.xSpeed>0 ) {
      this.xSpeed=maxspeed;
    }

    if (this.xSpeed< -maxspeed && this.xSpeed<0 ) {
      this.xSpeed=-maxspeed;
    }

    if (this.ySpeed> maxspeed && this.ySpeed>0 ) {
      this.ySpeed=maxspeed;
    }

    if (this.ySpeed< -maxspeed && this.ySpeed<0 ) {
      this.ySpeed=-maxspeed;
    }




    //move ball
    this.x += this.xSpeed;
    this.y += this.ySpeed;



    //    if ((this.x > width-this.w/2)
    //      || (this.x < this.w/2)) {
    //      this.xSpeed = -this.xSpeed;
    //    }

    //    if ((this.y > (height-height/7)-this.h/2)
    //      || (this.y < this.h/2)) {
    //      this.ySpeed = -this.ySpeed;
    //    }
  }

  void collide() {

    for (int i = 1; i < balls.size(); i++) {

      //compute distance
      float dx = balls.get(i).x- this.x;
      float dy = balls.get(i).y - this.y;
      float distance = sqrt(dx*dx + dy*dy);

      float minDist = balls.get(i).w/2 + this.w/2;

      if (distance < minDist) { 
        float angle = atan2(dy, dx);
        float targetX = this.x + cos(angle) * minDist;
        float targetY = this.y + sin(angle) * minDist;
        float ax = (targetX - balls.get(i).x) * spring;
        float ay = (targetY - balls.get(i).y) * spring;
        this.xSpeed -= ax;
        this.ySpeed -= ay;
        balls.get(i).xSpeed += ax;
        balls.get(i).ySpeed += ay;
      }
    }
  }

  //mousepressed,mouserelease, and drag
  boolean moving = false;//moving is false


    boolean mouseOver(int mx, int my) {
    return ((x - mx)*(x - mx) + (y - my)*(y - my)) <= radius*radius;
  }

  //function if mousePressed is true
  void mousePressed() {
    moving = true;//moving is true
  }

  //function if mouseReleased is false
  void mouseReleased() {
    moving = false;//moving is false
  }


  void move() {//function move
    if (moving) {//if moving is true
      this.x = mouseX;//the current ball's x position will be altered to the mouses'
      this.y = mouseY;

      //Prevent the ball from leaving the screen from all directions when dragged except the bottom margin
      if (mouseX >= width-this.w/2) {//right
        this.x = width-this.w/2;
      }
//      if (mouseY >= height-this.h/2) {//bottom
//        this.y = height-this.h/2;
//      }
      if (mouseX <= this.w/2) {//left
        this.x = this.w/2;
      }
      if (mouseY <= this.h/2) {//top
        this.y = this.h/2;
      }
    }
  }

  //returns true if the ball is on the platform a 7th of the screen of height and the mouse has been released.
  boolean belowBoundary() {
    //if the ball is in the left side of the bottom boundary and is dragged and released
    if (this.y> uBB && moving == false) return true;
    else return false;
  }
  //used to determine if the ball is dragged to the correct location
  boolean correctLocationTrue() {
    //    println(newRight);
    //    println(originalRight);
    if ((newRight.equals(originalRight))) {
      //      println("new right == original right correct");
      if (this.y> uBB) {
        //        println("this.y > uBB");
        if (moving == false) {
          //          println("not moving");
          if (this.x< width/2) {
            //            println("x < width/2");
            return true;
          } else return false;
        } else return false;
      } else return false;
    } else return false;
  }

  boolean correctLocationFalse() {
    //    println();
    //    println(newRight);
    //    println(originalRight);
    if ((!newRight.equals(originalRight))) {
      //      println("new right != original right correct");
      if (this.y> uBB) {
        //        println("this.y > uBB");
        if (moving == false) {
          //          println("not moving");
          if (this.x> width/2) {
            //            println("x > width/2");
            return true;
          } else return false;
        } else return false;
      } else return false;
    } else return false;
  }


  //used to determine if the ball is dragged to the wrong location
  boolean wrongLocationTrue() {
    if ((newRight.equals(originalRight))) {
      //      println("new right = original right  wrong");
      if (this.y> uBB) {
        //        println("this.y > uBB");
        if (moving == false) {
          //          println("not moving");
          if (this.x> width/2) {
            //            println("x > width/2");
            return true;
          } else return false;
        } else return false;
      } else return false;
    } else return false;
  }

  //    if ((newRight !=  (originalRight))
  //    if this.y> uBB && moving == false && this.x< width/2) return true;
  //    else return false;

  boolean wrongLocationFalse() {
    if ((!newRight.equals(originalRight))) {
      //      println("new right != original right wrong");
      if (this.y> uBB) {
        //        println("this.y > uBB");
        if (moving == false) {
          //          println("not moving");
          if (this.x< width/2) {
            //            println("x < width/2");
            return true;
          } else return false;
        } else return false;
      } else return false;
    } else return false;

    //    if ((newRight == originalRight)&& this.y> uBB && moving == false && this.x> width/2) return true;
    //    else return false;
  }



  //  void removeBall() {
  //    for (int i =balls.size() >=0 ; i--) {
  //      if (this.y> height-height/7 && moving == false) {
  //        balls.get(i);
  //          balls.remove(i);
  //      }
  // 
  //
}

