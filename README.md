# M17_Repte3

### Exercici 1

La classe mover crea un objecte que es mourà a la velocitat *velocity* cada cop que es cridi el mètode **update()**.

Té dos atributs de tipus PVector que determinen la seva posició i velocitat.

Té un constructor sense paràmetres que inicialitza *location* i *velocity*  a uns valors predeterminats.

Té un mètode **update()** que modifica la posició afegint-hi el vector velocitat.

Té un mètode **display()** que pinta una el·lipse representant l'objecte Mover amb un radi de 16px en la posició actual de l'objecte.

Té un mètode **checkEdged()** que detecte si l'objecte s'ha sortit dels marges de la pantalla, i si ho ha fet fa que aparegui a l'altre banda de la pantalla.

### Exercici 2

La classe que hereda de Mover i hi afegeix acceleració vertical és la següent:

```java
class Faller extends Mover{
  PVector acceleration;
  Faller() {
    super();
    acceleration = new PVector(0, 0.5);
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
```

També he considerat oportú canviar-li el color per a poder diferenciar els objectes Mover dels Faller

### Exercici 3

He afegit un constructor amb paràmetre PVector acceleration per a isntanciar objectes Faller amb una acceleració personalitzada. 
```java
Faller(PVector acceleration) {
   super();
   this.acceleration = acceleration;
  }
```

I l'he instanciat amb la següent línia
```java
  f = new Faller(new PVector(random(-1,1),random(-1,1)));
```

Amb això és suficient, ja que el constructor de Mover ja implementa la velocitat aleatòria.

Simplement cal actualitzar l'objecte en el mètode **draw()**:
```java
void draw() {
  background(255);
  f.update();
  f.checkEdges();
  f.display();
}
```

### Exercici 4

La part clau de l'exercici és trobar el vector entre el mouse i l'objecte i tractar-lo per a poder-lo aplicar a l'objecte coma  a velocity.
```java
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
```

### Exercici 5

He refactoritzat el codi de l'exercici anterior i posat el càlcul del vector velocitat cap al ratolí dins del mètode **update()** de Mover.

Per a instanciar els 60 objectes Mover, faig un bucle que es repetirà 60 vegades i els guardo en un array de Movers inicialitzat anteriorment.
Així, per a actualitzar-los, només he de recórrer l'array i actualitzar cada element.

```java
void setup() {
  size(1280, 640);
  for (int i = 0; i < 60; i++) {
    movers[i] = new Mover();
  }
  
}

void draw() {
  background(255);
  
  // Actualitzem els objectes Mover
  for (Mover m : movers) {
    m.update();
    m.checkEdges();
    m.display();
  }
}
```

### Exercici 6

He creat un projecte completament nou.

#### Funcionament General
Representa un ecosistema abstracte, on existeixen dos tipus d'elements: Zones de Vegetació i Animals.
Hi ha dos tipus d'animals, herbívors i carnívors.

Els animals herbívors es mengen les zones de vegetació, mentre que els carnívors es mengen als herbívors.
Els animals herbívors s'escapen si s'els acosta un carnívor.
Els animals carnívors lluiten entre sí quan s'acosten massa. Guanya el més gran.


##### Zones de Vegetació
Estan representades per cercles verds. Regeneren vegetació amb el temps, però desapareixen si s'esgoten completament i n'apareix una de nova. Com més intens és el verd, més vegetació conté.

##### Animals Herbívors
Estàn representats per petits cercles blaus.
El seu tret més distintiu és el moviment, ja que al principi de la simulació es designa un d'ells com a líder.

El líder és el que decideix cap a on anirà tota la manada, i els que no són líders intenten seguir-lo i quedar-se al voltant seu.
Si el líder mor, la manada es desbanda i segueixen un moviment aleatori fins que moren.

Si estàn massa temps sense menjar, moren.

La gana que tenen està representada amb la intensitat del color. Com més apagat, més gana tenen.

##### Animals Carnívors
Estàn representats per cercles blaus lleugerament diferents en radi.

El seu moviment es caracteritza per definir objectius i moure's en la seva direcció. Quan han arribat a l'objectiu(presa), la devoren i es queden en moviment aleatori fins que tornen a tenir gana.
Tenen un factor de mandra que influeix en el temps que tarden a tornar a perseguir una presa.

Si s'acosten entre si, lluiten, i el més gran guanya.

Si estàn massa temps sense menjar, moren.

La gana que tenen està representada amb la intensitat del color. Com més apagat, més gana tenen.
