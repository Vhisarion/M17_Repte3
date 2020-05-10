class Mover {
 PVector location, velocity;
 Mover() {
  location = new PVector(random(width), random(height));
  velocity = new PVector(random(-2,2),random(-2,2));
 }
 void update() {
  location.add(velocity); 
 }
 void display() {
  stroke(0);
  fill(125);
  ellipse(location.x, location.y, 16, 16);
 }
 void checkEdges() {
  if (location.x > width) {
   location.x = 0; 
  } else if (location.x < 0) {
    location.x = width;
  }
  if (location.y > height) {
   location.y = 0; 
  } else if (location.y < 0) {
   location.y = height; 
  }
 }
}

class Faller extends Mover{
  PVector acceleration;
  Faller() {
    super();
    acceleration = new PVector(0, 0.5);
  }
  Faller(PVector acceleration) {
   super();
   this.acceleration = acceleration;
  }
  void update() {
   velocity.add(acceleration);
   location.add(velocity);
  }
  void display() {
    stroke(0);
    fill(200);
    ellipse(location.x, location.y, 16, 16);
  }
}

Faller f;

void setup() {
  size(1280, 640);
  f = new Faller(new PVector(random(-1,1),random(-1,1)));
}

void draw() {
  background(255);
  f.update();
  f.checkEdges();
  f.display();
}
