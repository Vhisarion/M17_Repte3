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
