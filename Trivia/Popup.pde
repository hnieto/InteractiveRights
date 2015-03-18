class Popup{
  float x;
  float y;
  String txt;
  float alpha;
  boolean correct;
  Popup(float X, float Y, String Txt, boolean Correct){
    x = X;
    y = Y;
    txt = Txt;
    alpha = 255;
    correct = Correct;
  }
  void adjust(){
    y -= width/1920;
    alpha -= 5;
  }
  void display(){
    pushStyle();
    stroke(1);
    textSize(height/20);
    if(correct)    fill(0, 255, 0, alpha);
    else           fill(255, 0, 0, alpha);
    text(txt, x, y); 
    popStyle();
  }
}
