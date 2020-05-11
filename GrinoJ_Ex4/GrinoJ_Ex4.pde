/******************************************************
**                    VEGETATION                     **
******************************************************/

class Vegetation {
  // Lloc i mida de la zona
 PVector location, size;
 // Variables per trackear l'estat de la zona
 float maxVegetation, recoveryRate, currentVegetation;
 // Flag per saber quan s'ha acabat la vegetació i s'ha d'eliminar la zona
 boolean depleted = false;
 
 /**** Constructor ******/
 Vegetation() {
   // Mateixa mida en x i y per a tenir un cercle
   float sizer = random (75, 250);
   size = new PVector(sizer, sizer);
   // Posició aleatoria, però que sempre quedi dins dels marges de la pantalla
   location = new PVector(constrain(random(width - size.x), 0 + size.x, width - size.x), constrain(random(height - size.y), 0 + size.y, height-size.y));
   // Vegetació màxima aleatoria dins d'un rang, sempre comença amb la meitat de vegetació màxima
   maxVegetation = random(150, 255); 
   currentVegetation = maxVegetation/2;
   recoveryRate = 1;

 }
 
 /****** update() ******/
 // Calcula la quantitat de harbívors que té a sobre i en consumeix una vegetacií igual.
 // Si no té herbivors a sobre, recupera vegetació.
 void update() {
   int feeders = checkFeeders();
   if (feeders == 0) {
     currentVegetation = constrain(currentVegetation + recoveryRate, 0, maxVegetation);
   } else {
    currentVegetation = constrain(currentVegetation - feeders/2, 0, maxVegetation); 
   }
 }
 
 /******* display() *********/
 void display() {
   // Si no queda vegetació, no es renderitza
   if (!depleted) {
      stroke(0);
      fill(0, 200, 0, currentVegetation);
      ellipse(location.x, location.y, size.x, size.y);
      //text(currentVegetation, location.x, location.y);
   }
 }
 
 /****** checkFeeders() ********/
 // Calcula i retorna el nombre d'herbivors vius sobre la zona de vegetació
 // Tembé alimenta als herbívors que detecta
 int checkFeeders() {
   int amount = 0;
   for (Herbivore h : herbivores) {
     if (!h.dead && dist(location.x, location.y, h.location.x, h.location.y) < size.x/2) {
       amount++;
       h.saturation = constrain(h.saturation + 1, 0, h.maxSaturation);
     }
   }
   return amount;
 }
}

/******************************************************
**                    ANIMAL                         **
******************************************************/
// Classe pare de Herbivore i Carnivore. Defineix els atributs base per representar l'animal i pel seu funcionament core.
class Animal {
 PVector location;
 // La velocitat és un factor que es multiplica al vector unitari que determina la direcció
 float speed;
 float saturation;
 int maxSaturation;
 float hungerRate;
 boolean dead;
 
 // Inicialització default dels animals. A cada fill s'hi fan petites variacions als atributs que interessen
 Animal() {
  location = new PVector(random(width), random(height));
  speed = random(1, 3);
  maxSaturation = (int)random(150, 255);
  saturation = maxSaturation / 2;
  hungerRate = random(0.25, 0.5);
 }
}


/******************************************************
**                    HERBIVORE                      **
******************************************************/
class Herbivore extends Animal{
  // Determina si és el líder
  boolean leader;
  // Determina la zona de vegetació a la que es dirigeix el líder.
  Vegetation nearest;
  // Indica si hi ha un carnívor a prop, i quin.
  Carnivore danger;
  
  /****** Constructor *******/
  Herbivore() {
   super(); 
   // Els instancio tots a la mateixa zona, ja que es mouen en ramat
   location = new PVector(random(width/4), random(height/4));
  }
  
  /******** update() *******/
  void update() {
    // Variables per a simplificar codi de moviment. És la direcció del moviment.
    PVector target = new PVector(0,0);

    if (leader) {
      /* --------------------------- Leader Movement -------------------------------- */
      
      // Si està sobre una zona de vegetació, moviment aleatori
      if (nearest != null && !nearest.depleted && dist(location.x, location.y, nearest.location.x, nearest.location.y) < 15) { 
        target = new PVector(random(3)-1, random(3)-1).normalize();
      } 
      
        // Si no té cap zona target o la que tenia s'ha acabat, en busca una de nova i s'hi dirigeix
        else if (nearest == null || nearest.depleted) { 
        findNearestVegetation();
        target = new PVector((nearest.location.x) - location.x, (nearest.location.y) - location.y).normalize();  
      }
      
      // Si no, es segueix dirigint a la zona nearest
      else {
       target = new PVector((nearest.location.x) - location.x, (nearest.location.y) - location.y).normalize();  
      }
    } else {
      
      
      /* --------------------------- Follower Movement ------------------------------ */
      // Determinem un nombre random que decidirà si segueix el líder o fa una passa aleatoria (Sempre i quan estigui a més de 30px d'ell
      float n = random(1);
      if (dist(_leader.location.x, _leader.location.y, location.x, location.y) > 30 && n < 0.55) {
        // Moviment cap a líder
       target = new PVector(_leader.location.x - location.x, _leader.location.y - location.y).normalize();
      } else {
        // Passa aleatòria
        target = new PVector(random(3)-1, random(3)-1).normalize();
      }
    }
    
    // Comproba si el líder està mort. Si està mort, tots els herbívors fan moviment aleatori.
    if (_leader.dead) {
      target = new PVector(random(3)-1, random(3)-1).normalize();
    }
    
    // Comprova si hi ha un carnívor a prop, i si n'hi ha se n'escapa
    if ((danger = carnivoreNearby()) != null) {
     target = stayAwayFromCarnivore(); 
    }
    
    // Aplica la velocitat a la direcció i es mou. Sempre dins dels marges de la pantalla
    target.mult(speed);
    location.x = constrain(location.x + target.x, 0, width);
    location.y = constrain(location.y + target.y, 0, height);
    
    
    // Si té la saturació al màxim, intenta reproduir-se. Si es reprodueix, s'instancia molt a prop seu
    if (saturation >= maxSaturation && random(0,1) > 0.99) {
      Herbivore newh = new Herbivore();
      newh.location = new PVector(location.x + 5, location.y + 5);
      newbornBuffer.add(newh);
    }
    
    // Aplica la gana a la saturacio
    saturation -= hungerRate;

   // Comprova si s'ha mort de gana
   if (saturation <= 0) {
     dead = true;
   }
  }
  
  /********* display ***********/
  // Renderitza l'herbívor a la pantalla si no està mort
  void display() {
    if (!dead) {
     stroke(0);
     fill(0, 0, saturation);
     ellipse(location.x, location.y, 16, 16);
    }
  }

/********* findNearestVegetation() *************/
// Busca la zona de vegetació més propera a ell
  void findNearestVegetation() {
    float minDistance = 10000;
    for (Vegetation v : vegetations) {
      if ( !v.depleted && minDistance > (dist(location.x, location.y, v.location.x, v.location.y))) {
        nearest = v;
        minDistance = dist(location.x, location.y, v.location.x, v.location.y);
      }
    }
    
  }
  
 /************* carnivoreNearby() ****************/
 // Busca si hi ha un carnívor a prop i retorna el carnívor, si n'hi ha. Si no n'hi ha cap a prop, retorna null;
  Carnivore carnivoreNearby() {
   for (Carnivore c : carnivores) {
    if (dist(location.x, location.y, c.location.x, c.location.y) < 30)
      return c;
   }
   return null;
  }
  
  /************* stayAwayFromCarnivore() ****************/
  // Retorna la direcció contrària al carnívor.
  PVector stayAwayFromCarnivore() {
    return new PVector(location.x - danger.location.x, location.y - danger.location.y).normalize();
  }
}



/******************************************************
**                    CARNIVORE                      **
******************************************************/
class Carnivore extends Animal {
  float strength; // Determina qui guanyarà la lluita amb un altre depredador i la seva mida
  int laziness; // Determina amb quanta gana buscarà una presa
  
  // Objectius a caçar.
  Herbivore prey;
  Carnivore enemy;
  
  // Per no crear i destruir objectes a cada fram
  PVector direction;
  
  /***** Constructor *****/
  // Inicialitza els atributs d'animal i els seus propis. Augmenta un 50% la velocitat.
  Carnivore() {
    super();
    laziness = (int)random(maxSaturation*0.25, maxSaturation*0.75);
    speed *= 1.5;
    strength = random(16, 24);
  }
  
  /***** update() *****/
  void update() {
    // Si no està mort, fa l'update
    if (!dead) {
      
      
      // Si té gana i ha sobrepassat el llindar de laziness, busca una presa
      if (prey == null && laziness > saturation) {
       findPrey(); 
      }
      
      // Si té una presa(tant herbivora com carnivora), la presegueix. Si no, es mou aleatoriament
      if (enemy != null || (enemy = hasNearbyCarnivore()) != null) {
        huntPrey(enemy);
      } else if (prey == null) {
       direction = moveRandomly(); 
      } else {
       direction = huntPrey(prey); 
      }
      
      // Aplica la velocitat a la direcció i mou al carnívor
      direction = direction.mult(speed);
      location.x = constrain(location.x + direction.x, 0, width);
      location.y = constrain(location.y + direction.y, 0, height);
      
      // Comprova si s'ha menjat la presa herbívora
      if (prey != null && dist(location.x, location.y, prey.location.x, prey.location.y) < 5) {
        deadHerbivores.add(prey);
        prey.dead = true;
        saturation += 175;
        prey = null;
      }
      
      // Comprova si ha lluitat i si l'ha guanyat o perdut
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
      
      // Comproba si s'ha mort de gana
      if (saturation <= 0) {
        deadCarnivores.add(this);
        dead = true;
    } else {
         saturation -= hungerRate; 
    }
    }
    
  }
  
  /***** display() *****/
  // Renderitza al carnívor. També fa una línia indicativa del carnívor cap a la presa.
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
  
  
  /***** findPrey() *****/
  // Busca una presa
  void findPrey() {
    if (!allHerbivoresDead()) // Per evitar indexoob
      prey = herbivores.get((int)random(herbivores.size()));
  }
  
  /***** moveRandomly() *****/
  // Genera un vector unitari aleatori de moviment en 360º al voltant del carnivor.
  PVector moveRandomly() {
    return new PVector((int)random(3)-1, (int)random(3)-1).normalize();
  }
  
  /***** huntPrey() *****/
  // Retorna un vector unitari en direcció a l'animal indicat
  PVector huntPrey(Animal prey) {
    return new PVector(prey.location.x - location.x, prey.location.y - location.y).normalize();
  }
  
  /***** hasNearbyCarnivore() *****/
  // Retorna a un carnívor proper. Si no en té cap a prop, retorna null
  Carnivore hasNearbyCarnivore() {
    for(Carnivore c : carnivores) {
      if (c != this && dist(location.x, location.y, c.location.x, c.location.y) < 30) 
        return c;
    }
    return null;
  }
  
}



// Variables globals
ArrayList<Vegetation> vegetations = new ArrayList<Vegetation>();
ArrayList<Herbivore> herbivores = new ArrayList<Herbivore>();
ArrayList<Herbivore> newbornBuffer = new ArrayList<Herbivore>();
Herbivore _leader;
ArrayList<Carnivore> carnivores = new ArrayList<Carnivore>();
ArrayList<Herbivore> deadHerbivores = new ArrayList<Herbivore>();
ArrayList<Carnivore> deadCarnivores = new ArrayList<Carnivore>();

// Flag de game over
boolean game_over;
int game_overCounter;




void setup() {
  // Mida de la pantalla
  size(1280, 640);
  
  // Framerate
  frameRate(60);
  
  // Initialize Vegetations
  for (int i = 0; i < 3; i++) {
    vegetations.add(new Vegetation());
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
  if (!game_over) {
    // Neteja la pantalla
    background(228,255,133);
    
    // Comprova si han mort tots els herbívors, i si és el cas tanca el programa.
    if (allHerbivoresDead()) {
      exit();
     }
    
    // Elimina del tot els animals morts i les vegetacions acabades.
    removeDeadAnimals();
    removeDepletedVegetation();
    removeDeadCarnivores();
    // Afegeix els fills dels herbívors a l'arraylist d'herbivors vius
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
    // Display Carnivores
    for (Carnivore c : carnivores) {
     c.display(); 
    }
    
    // Crea una línea entre el líder i la vegetacio a la que s'està dirigint
    if (!_leader.dead) {
    stroke(0,0,255);
    line(_leader.location.x, _leader.location.y, _leader.nearest.location.x, _leader.nearest.location.y); //<>//
    //text(dist(_leader.location.x, _leader.location.y, _leader.nearest.location.x, _leader.nearest.location.y), width/2, height/2);
    }
  } else {
   // Game over
   text("S'han mort tots els herbívors", width/2, height/2);
   game_overCounter++;
   if (game_overCounter >= 300)
     exit();
  }
}


// Elimina els herbívors morts de l'arraylist definitivament. Per evitar un error al eliminar un element de la collection que s'està iterant.
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

// Elimina definitivament les zones de vegetacio acabades i en crea de noves. Per evitar un error al eliminar un element de la collection que s'està iterant.
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
  vegetations.add(new Vegetation());
 }
}

// Elimina definitivament els carnívors morts. Per evitar un error al eliminar un element de la collection que s'està iterant.
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

// Instancia els nous herbívors
void addNewborns() {
 for (Herbivore h : newbornBuffer) {
   herbivores.add(h);
 }
 newbornBuffer.clear();
 
 }
 
 // Comprova si han mort tots els herbívors
 boolean allHerbivoresDead() {
   return herbivores.size() <= 0;
 }
