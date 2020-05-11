class Vegetation extends java.awt.Polygon{
 PVector location, size;
 float maxVegetation, recoveryRate, currentVegetation;
 boolean depleted = false;
 
 Vegetation() {
   float sizer = random (75, 250);
   size = new PVector(sizer, sizer);
   location = new PVector(random(width - size.x), random(height - size.y));
   maxVegetation = random(150, 255); 
   currentVegetation = maxVegetation/2;
   recoveryRate = 1;

 }
 // Feeders = amount of herbivors on it
 void update() {
   int feeders = checkFeeders();
   if (feeders == 0) {
     currentVegetation = constrain(currentVegetation + recoveryRate, 0, maxVegetation);
   } else {
    currentVegetation = constrain(currentVegetation - feeders/2, 0, maxVegetation); 
   }
 }
 void display() {
   if (!depleted) {
      stroke(0);
      fill(0, 200, 0, currentVegetation);
      ellipse(location.x, location.y, size.x, size.y);
      //text(currentVegetation, location.x, location.y);
   }
 }
 int checkFeeders() {
   int amount = 0;
   for (Herbivore h : herbivores) {
     if (!h.dead && dist(location.x, location.y, h.location.x, h.location.y) < size.x/2) {
       amount++;
       h.saturation = constrain(h.saturation + 1, 0, h.maxSaturation);
     }
   }
   //if (amount > 0)
     //println(amount);
   return amount;
 }
}

class Animal {
 PVector location;
 float speed;
 float saturation;
 int maxSaturation;
 float hungerRate;
 boolean dead;
 
 Animal() {
  location = new PVector(random(width), random(height));
  speed = random(1, 3);
  maxSaturation = (int)random(150, 255);
  saturation = maxSaturation / 2;
  hungerRate = random(0.25, 0.5);
 }
}



class Herbivore extends Animal{
  boolean leader;
  Vegetation nearest;
  
  Carnivore danger;
  Herbivore() {
   super(); 
   location = new PVector(random(width/4), random(height/4));
  }
  synchronized void update() {
    // Movement
    float x = 0, y = 0;
    PVector target = new PVector(0,0);


    if (leader) {
      /* --------- Leader Movement --------- */
      if (nearest != null && !nearest.depleted && dist(location.x, location.y, nearest.location.x, nearest.location.y) < 15) { 
        target = new PVector(random(3)-1, random(3)-1).normalize();
      } else if (nearest == null || nearest.depleted) { 
        findNearestVegetation();
        target = new PVector((nearest.location.x) - location.x, (nearest.location.y) - location.y).normalize();  
      }
      else {
       target = new PVector((nearest.location.x) - location.x, (nearest.location.y) - location.y).normalize();  
      }
    } else {
      /* --------- Follower Movement ------------- */
      float n = random(1);
      if (dist(_leader.location.x, _leader.location.y, location.x, location.y) > 30) {
      if (n < 0.55) {
       // Move towards leader 
       target = new PVector(_leader.location.x - location.x, _leader.location.y - location.y).normalize();
      }
      } else {
        target = new PVector(random(3)-1, random(3)-1).normalize();
      }
    }
    
    // Check if leader dead
    if (_leader.dead) {
      target = new PVector(random(3)-1, random(3)-1).normalize();
    }
    
    // Check if carnivore nearby
    if ((danger = carnivoreNearby()) != null) {
     target = stayAwayFromCarnivore(); 
    }
    
    target.mult(speed);
      x = target.x;
      y = target.y;
    location.x += x;
    location.y += y;
    
    // If their saturation is maxed out, try to reproduce
    if (saturation >= maxSaturation) {
      //println("Trying to reproduce");
     if (random(0,1) > 0.99) {
      Herbivore newh = new Herbivore();
      newh.location = new PVector(location.x + 5, location.y + 5);
      newbornBuffer.add(newh);
     }
    }
    
    // They're getting hungry
    saturation -= hungerRate;

   // Check if they're dead
   if (saturation <= 0) {
     dead = true;
     display();
     //herbivores.remove(this);
   }
  }
  void display() {
    if (!dead) {
     stroke(0);
     fill(0, 0, saturation);
     ellipse(location.x, location.y, 16, 16);
     //text(saturation, location.x, location.y);
    }
  }

  void findNearestVegetation() {
    float minDistance = 10000;
    for (Vegetation v : vegetations) {
      float thisDistance = dist(location.x, location.y, v.location.x, v.location.y);
      minDistance += thisDistance;
      minDistance -= thisDistance;
      if ( !v.depleted && minDistance > (dist(location.x, location.y, v.location.x, v.location.y))) {
        nearest = v;
        minDistance = dist(location.x, location.y, v.location.x, v.location.y);
      }
    }
    
  }
  
  Carnivore carnivoreNearby() {
   for (Carnivore c : carnivores) {
    if (dist(location.x, location.y, c.location.x, c.location.y) < 30)
      return c;
   }
   return null;
  }
  
  PVector stayAwayFromCarnivore() {
    return new PVector(location.x - danger.location.x, location.y - danger.location.y).normalize();
  }
}




class Carnivore extends Animal {
  float strength;
  int laziness; // This will determine at what hunger level they will start looking for food
  Herbivore prey;
  Carnivore enemy;
  
  // To not create and destroy variables every frame
  PVector direction;
  Carnivore() {
    super();
    laziness = (int)random(maxSaturation*0.25, maxSaturation*0.75);
    speed *= 1.5;
    strength = random(16, 24);
  }
  
  void update() {
    if (!dead) {
      // If hungry, find an objective to eat
      if (prey == null && laziness > saturation) {
       findPrey(); 
      }
      
      // If has a prey, hunt it. Else move randomly
      if (enemy != null || (enemy = hasNearbyCarnivore()) != null) {
        huntPrey(enemy);
      } else if (prey == null) {
       direction = moveRandomly(); 
      } else {
       direction = huntPrey(prey); 
      }
      
      direction = direction.mult(speed);
      //println("Taking direction: " + direction);
      location.x += direction.x;
      location.y += direction.y;
      
      // Check prey eat
      if (prey != null && dist(location.x, location.y, prey.location.x, prey.location.y) < 5) {
        deadHerbivores.add(prey);
        prey.dead = true;
        saturation += 175;
        prey = null;
      }
      
      // Check enemy fight
      if (enemy != null && dist(location.x, location.y, enemy.location.x, enemy.location.y) < strength) {
        if (strength > enemy.strength) {
         enemy.dead = true;
         deadCarnivores.add(enemy);
         saturation += 150;
        } else {
          dead = true;
          deadCarnivores.add(this);
        }
        enemy = null;
      }
      
      // Check if dead of hunger
      if (saturation <= 0) {
        deadCarnivores.add(this);
        dead = true;
    } else {
         saturation -= hungerRate; 
    }
    }
    
  }
  
  void display() {
    if (!dead) {
     stroke(0);
     fill(saturation, 0, 0);
     ellipse(location.x, location.y, strength, strength);
     //text(saturation, location.x, location.y);
     if (prey != null) {
       stroke(255,0,0);
     line(location.x, location.y, prey.location.x, prey.location.y);
     }
    }
  }
  
  
  void findPrey() {
    if (!allHerbivoresDead()) 
      prey = herbivores.get((int)random(herbivores.size()));
  }
  
  PVector moveRandomly() {
    return new PVector((int)random(3)-1, (int)random(3)-1).normalize();
  }
  
  PVector huntPrey(Animal prey) {
    return new PVector(prey.location.x - location.x, prey.location.y - location.y).normalize();
  }
  
  Carnivore hasNearbyCarnivore() {
    for(Carnivore c : carnivores) {
      if (c != this && dist(location.x, location.y, c.location.x, c.location.y) < 30) 
        return c;
    }
    return null;
  }
  
}




ArrayList<Vegetation> vegetations = new ArrayList<Vegetation>();
ArrayList<Herbivore> herbivores = new ArrayList<Herbivore>();
ArrayList<Herbivore> newbornBuffer = new ArrayList<Herbivore>();
Herbivore _leader;
ArrayList<Carnivore> carnivores = new ArrayList<Carnivore>();
ArrayList<Herbivore> deadHerbivores = new ArrayList<Herbivore>();
ArrayList<Carnivore> deadCarnivores = new ArrayList<Carnivore>();




void setup() {
  size(1280, 640);
  // Initialize Vegetations
  for (int i = 0; i < 3; i++) {
    Vegetation v = new Vegetation(); 
    v.addPoint((int)v.location.x, (int)v.location.y);
    v.addPoint((int)(v.location.x + v.size.x), (int)v.location.y);
    v.addPoint((int)v.location.x, (int)(v.location.y + v.size.y));
    v.addPoint((int)(v.location.x + v.size.x), (int)(v.location.y + v.size.y));
    vegetations.add(v);
  }
  // Initialize Herbivores
  for (int i = 0; i < 10; i++) {
    herbivores.add(new Herbivore()); 
  }
  // Set leader herbivore
  _leader = herbivores.get((int)random(herbivores.size()));
  _leader.leader = true;
  
  // Initialize Carnivores
  for (int i = 0; i < 4; i++) {
    carnivores.add(new Carnivore()); 
  }
  
}

void draw() {
  background(228,255,133);
  if (allHerbivoresDead()) {
    exit();
   }
  
  removeDeadAnimals();
  removeDepletedVegetation();
  removeDeadCarnivores();
  addNewborns();
  
  
  // Update Vegetations
  for (Vegetation v : vegetations) {
   v.update(); 
  }
  // Update Herbivores
  for (Herbivore h : herbivores) {
   h.update(); 
  }
  // Update Carnivores
  for (Carnivore c : carnivores) {
   c.update(); 
  }


// Display Vegetations
  for (Vegetation v : vegetations) {
   v.display(); 
  }
  
  // Display Herbivores
  for (Herbivore h : herbivores) {
   h.display(); 
  }
   if (allHerbivoresDead()) {
     background(255);
    text("All herbivores are dead!", width/2, height/2);
    delay(5000);
    exit();
   }
  // Display Carnivores
  for (Carnivore c : carnivores) {
   c.display(); 
  }
  
  stroke(0,0,255);
  line(_leader.location.x, _leader.location.y, _leader.nearest.location.x, _leader.nearest.location.y); //<>//
  //text(dist(_leader.location.x, _leader.location.y, _leader.nearest.location.x, _leader.nearest.location.y), width/2, height/2);
  
  if (allHerbivoresDead()) {
      background(255);
    text("All herbivores are dead!", width/2, height/2);
   } 

}

void removeDeadAnimals() {
  
 for (Herbivore h : herbivores) {
   if (h.dead)
     deadHerbivores.add(h);
 }
 for (Herbivore h : deadHerbivores) {
  herbivores.remove(h);
  for (Carnivore c : carnivores) {
   if (c.prey == h)
     c.prey = null;
  }
 }
 
 deadHerbivores.clear();
}

void removeDepletedVegetation() {
  ArrayList<Vegetation> deadVegetations = new ArrayList<Vegetation>();
 for (Vegetation v : vegetations) {
   if (v.currentVegetation <= 0) {
     v.depleted = true;
     deadVegetations.add(v);
   }
 }
 for (Vegetation oldv : deadVegetations) {
  vegetations.remove(oldv);
  Vegetation v = new Vegetation();
  v.addPoint((int)v.location.x, (int)v.location.y);
  v.addPoint((int)(v.location.x + v.size.x), (int)v.location.y);
  v.addPoint((int)v.location.x, (int)(v.location.y + v.size.y));
  v.addPoint((int)(v.location.x + v.size.x), (int)(v.location.y + v.size.y));
  
  vegetations.add(v);
 }
}

void removeDeadCarnivores() {
  
 for (Carnivore c : carnivores) {
   if (c.dead)
     deadCarnivores.add(c);
 }
 for (Carnivore c : deadCarnivores) {
  carnivores.remove(c);   
 }
 
 deadCarnivores.clear();
}

void addNewborns() {
 for (Herbivore h : newbornBuffer) {
   herbivores.add(h);
 }
 newbornBuffer.clear();
 
 }
 
 
 boolean allHerbivoresDead() {
   return herbivores.size() <= 0;
 }
