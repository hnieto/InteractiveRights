class Cursor {
  int   id;
  float x, y, r;
  color c;

  Cursor (int id, float x, float y, float r) {
    this.id   = id;
    this.x    = x;
    this.y    = y;
    this.r    = r;
    c         = color(255, 75);
  }

  void draw() {
    pushStyle();
    noStroke();
    fill(c);
    ellipse(x, y, r*2, r*2);
    popStyle();
  }
}


