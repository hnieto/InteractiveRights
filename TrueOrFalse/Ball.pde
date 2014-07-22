
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

    //A push and pop matrix is used to make sure that only the ball text is centered and not in the corner
    pushMatrix();
    rectMode(CENTER);//centers the position of the text
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
    popMatrix();
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
    if (this.y <= yRespawn) {
      this.ySpeed = abs(this.ySpeed);
    }

    //check if ball is on bottom margin, 
    if (this.y >= (uPB*.99)-this.h/2) {
      this.ySpeed = -abs(this.ySpeed);
    }

    //check if out of bounds
    if (this.x < this.w/2) { 
      this.x = this.w/2;
    }
    if (this.y < yRespawn) { 
      this.y = yRespawn;
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

    for (int i = 1; i < balls.size (); i++) {

      //compute distance
      float dx = balls.get(i).x- this.x;
      float dy = balls.get(i).y - this.y;
      float distance = sqrt(dx*dx + dy*dy);

      float minDist = balls.get(i).w/2 + this.w/2;

      if (distance < minDist) { 
        float angle = atan2(dy, dx);
        float targetX = this.x + cos(angle) * minDist;
        float targetY = this.y + sin(angle) * minDist;
        float ax = (targetX - balls.get(i).x);
        float ay = (targetY - balls.get(i).y);
        this.xSpeed -= ax;
        this.ySpeed -= ay;
        balls.get(i).xSpeed += ax;
        balls.get(i).ySpeed += ay;
      }
    }
  }

  //mousepressed,mouserelease, and drag
  boolean selected = false;//selected is false


    boolean mouseOver(int mx, int my) {
    return ((x - mx)*(x - mx) + (y - my)*(y - my)) <= radius*radius;
  }

  //function if mousePressed is true
  void mousePressed() {
    selected = true;//selected is true
  }

  //function if mouseReleased is false
  void mouseReleased() {
    selected = false;//selected is false
    this.c = ballColor;//the transparency of the ball will revert when released
  }


  void selectedBall() {//function move
    if (selected) {//if selected is true
      //modifies the velocity according to how much the ball is moved 
      this.xSpeed=(mouseX-this.x)/2;
      this.ySpeed=(mouseY-this.y)/2;

      this.x = mouseX;//the current ball's x position will be altered to the mouses'
      this.y = mouseY;//the current ball's y position will be altered to the mouse's location
      this.c = selectedBallColor;//the transparency of the ball will change when clicked

      //detects if any part of the ball is in either the true or false platform, and will remove the transparency.
      if (y+radius > uPB && selected==true) {
        if (x>0 && x<width/2) {
          trueTrans=255; 
          falseTrans=255/2;
        } else if (x>width/2 && x<width) {
          falseTrans=255; 
          trueTrans=255/2;
        }
      } else {
        trueTrans=255/2;
        falseTrans=255/2;
      } 
      if (y+radius > uPB && selected == false) {
        trueTrans=255/2;
        falseTrans=255/2;
      }

      //Prevent the ball from leaving the screen from all directions when dragged 
      if (mouseX >= width-this.w/2) {//right
        this.x = width-this.w/2;
      }
      if (mouseY >= height-this.h/2) {//bottom
        this.y = height-this.h/2;
      }
      if (mouseX <= this.w/2) {//left
        this.x = this.w/2;
      }
      if (mouseY <= yRespawn) {//top
        this.y = yRespawn;
      }
    }
  }


  //returns true if the ball is on the platform and the mouse has been released.
  boolean belowBoundary() {
    //if any part of the ball is in the  platform and is dragged and released
    if (this.y+radius > uPB && selected == false) return true;
    else return false;
  }

  //used to determine if the ball is dragged to the correct location
  boolean correctLocationTrue() {
    //    println(newRight);
    //    println(originalRight);
    if ((newRight.equals(originalRight))) {
      //      println("new right == original right correct");
      if (this.y> uPB) {
        //        println("this.y > uPB");
        if (selected == false) {
          //          println("not selected");
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
      if (this.y> uPB) {
        //        println("this.y > uPB");
        if (selected == false) {
          //          println("not selected");
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
      if (this.y> uPB) {
        //        println("this.y > uPB");
        if (selected == false) {
          //          println("not selected");
          if (this.x> width/2) {
            //            println("x > width/2");
            return true;
          } else return false;
        } else return false;
      } else return false;
    } else return false;
  }

  //    if ((newRight !=  (originalRight))
  //    if this.y> uPB && selected == false && this.x< width/2) return true;
  //    else return false;

  boolean wrongLocationFalse() {
    if ((!newRight.equals(originalRight))) {
      //      println("new right != original right wrong");
      if (this.y> uPB) {
        //        println("this.y > uPB");
        if (selected == false) {
          //          println("not selected");
          if (this.x< width/2) {
            //            println("x < width/2");
            return true;
          } else return false;
        } else return false;
      } else return false;
    } else return false;

    //    if ((newRight == originalRight)&& this.y> uPB && selected == false && this.x> width/2) return true;
    //    else return false;
  }



  //  void removeBall() {
  //    for (int i =balls.size() >=0 ; i--) {
  //      if (this.y> height-height/7 && selected == false) {
  //        balls.get(i);
  //          balls.remove(i);
  //      }
  // 
  //
}

