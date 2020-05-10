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

Mover m;
float speed = 3;

void setup() {
  size(1280, 640);
  m = new Mover();
}

void draw() {
  background(255);
  
  // Trobem el vector entre el mouse i l'objecte Mover
  PVector v = new PVector(mouseX - m.location.x, mouseY - m.location.y);
  
  // Normalitzem el vector trobat, el multipliquem per a poder augmentar/disminuir la velocitat i el posem com a velocitat de l'objecte m.
  m.velocity = v.normalize().mult(speed);
  
  // Actualitzem l'objecte Mover
  m.update();
  m.checkEdges();
  m.display();
}




/* --------- UNUSED ------------


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


-------------------------------- */
