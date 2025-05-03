import oscP5.*;
import netP5.*;

OscP5 osc = new OscP5(this, 9999);
NetAddress meineAdresse = new NetAddress("127.0.0.1", 9999);

OscMessage rotMessage = new OscMessage("rotate");
OscMessage gameOverMessage = new OscMessage("gameover");
OscMessage removeLineMessage = new OscMessage("removeline");
OscMessage placeMessage = new OscMessage("place");
OscMessage moveMessage = new OscMessage("move");

Shape shape, rsInterface;
Background bg;
Grid grid;

boolean isPaused = false;
boolean gameOver = false;
int gameState = 1;
Table highscore;
String name ="";

//Variablen für Spiraleffekt
float angle = 0;
float radius = 50;

//blinkender Highscore
boolean isBlinking = false;
int blinkSpeed = 30; // Geschwindigkeit des Blinkens
int blinkCounter = 0; // Zähler für das Blinken



void setup() {
  //pixelDensity(displayDensity());
  //smooth();
  size(720, 600);

  shape = new Shape();
  shape.isActive = true;
  bg = new Background();
  grid = new Grid();
  rsInterface = new Shape(); //Interface mit Buttons/Score/Points auf der rechte Seite

  textFont(createFont("PIXY", 30));
  textAlign(LEFT);

  highscore = loadTable("./highscore.csv", "header");
  highscore.setColumnType("Punkte", Table.INT);
}

void draw() {


  switch(gameState) {
  case 1: //Main-Game
    bg.display();
    drawShape();
    grid.display();
    break;
  case 2: //Gameover-Fenster mit Score Anzeige
    loadPixels();
    filter(BLUR, 1); //Blur Effekt für Gameoverwindow
    updatePixels();
    gameOverWindow();
    break;
  case 3:
    drawHighscore();
    break;
  }
}


void drawShape() {
  shape.display(); //Erzeugung der zufälligen Objekte
  rsInterface.showInterface(); //Interface auf der rechten Seite
  if (shape.checkBackground(bg)) { //Objekte werden nur zu den bestimmten Koordinaten/Bedingungen erzeugt
    shape.moveDown(bg.score);
  } else {
    shape.isActive = false;
  }

  if (!shape.isActive) {
    bg.writeShape(shape); //"Speicherung" der Objekte welche schon platziert wurden
    shape = rsInterface;
    shape.isActive = true;
    rsInterface = new Shape(); //"Next" Anzeige im Interface
  }
}

void keyPressed() {
  if (keyCode == RIGHT) {
    shape.moveShape("RIGHT");
  }
  if (keyCode == LEFT) {
    shape.moveShape("LEFT");
  }
  if (keyCode == DOWN) {
    shape.moveShape("DOWN");
  }

  if (key == 'p' || key == 'P') {
    if (isPaused) {
      loop();
    } else {    //Pausieren
      noLoop();
    }
    isPaused = !isPaused;
  }



  if (gameState == 2) {
    if ((keyCode == ENTER || keyCode == RETURN) && name.length() > 0) {
      saveNewHighscore(name, bg.points);
      name = "";
      gameState = 3;
    }
    if (keyCode == BACKSPACE && name.length() > 0) {
      name = name.substring(0, name.length()-1);
    }
    if (name.length() < 10) {
      if (key >= 'a' && key <= 'z' || key >= 'A' && key <= 'Z' || key >= '0' && key <= '9') {
        name+=key;
      }
    }
  }
}


void keyReleased() {
  if (gameOver == false) {
    if (keyCode == UP) {
      shape.rotate();
      shape.rotate();
      osc.send(rotMessage, meineAdresse);

      //Bedingungen damit die Rotation innerhalb des Fensters passiert
      if (shape.checkLeftRight("LEFT") == false) {
        shape.moveShape("RIGHT");
      }

      if (shape.checkLeftRight("RIGHT") == false) {
        shape.moveShape("LEFT");
      }

      if (shape.checkSide("DOWN") == false) {
        shape.moveShape("DOWN");
      }
    }
    shape.rotCount++;
  }
}

boolean isMouseOver(int x, int y, int w, int h) {

  if (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y+h) {
    return true;
  }
  return false;
}

boolean imRechteck(int px, int py, int rx, int ry, int rw, int rh) {
  return (px > rx && px < rx + rw && py > ry && py < ry + rh);
}


void mousePressed() {
  //START BUTTON
  if (gameState == 0) {
    if (imRechteck(mouseX, mouseY, width/2-60, height/2-25, 120, 50)) {
      gameState = 1;
    }
  }


  //QUIT-BUTTON INTERFACE
  if (isMouseOver(width/2+60, 470, 245, 45) == true) {
    exit();
  }

  //QUIT-BUTTON DRAWHIGHSCORE
  if (isMouseOver(width/2, 550, 245, 100) == true) {
    exit();
  }


  if (gameOver == false) {
    //PAUSE-BUTTON
    if (isMouseOver(width/2 + 60, 400, 245, 45) == true) {
      if (isPaused) {
        noLoop();
      } else {
        loop();
      }
    }
    isPaused = !isPaused;
  }
}


void drawHighscore() {
  background(0);

  // Blinkeffekt für den "HIGHSCORE"-Text
  if (isBlinking) {
    fill(255, 0, 0); // Rote Textfarbe während des Blinkens
  } else {
    fill(255); // Normale Textfarbe
  }
  text("HIGHSCORE", width/2, 60);

  blinkCounter++;
  if (blinkCounter >= blinkSpeed) {
    isBlinking = !isBlinking; // Ändert den Zustand des Blinkens
    blinkCounter = 0;
  }

  //Spiraleffekt beim DrawHighscore
  for (int i = 0; i < 100; i++) {
    float x = width/2 + cos(angle) * radius;
    float y = height/2 + sin(angle) * radius;
    ellipse(x, y, 10, 10);
    angle += 0.1;
    radius += 0.1;
  }

  //Spielerleistungen. geordnet nach Score
  for (int i = 0; i < highscore.getRowCount(); i++) {
    String name = highscore.getRow(i).getString("Name");
    int score = highscore.getRow(i).getInt("Punkte");

    text(name+": "+score, width/2, 120+(i*40));

    //QUIT-BUTTON
    fill(0);
    stroke(255, 0, 0);
    rect(width/2, 550, 100, 45, 15);
    fill(255);
    text("QUIT", width/2, 555);
  }
}

void saveNewHighscore(String name, int score) {
  TableRow row = highscore.addRow();
  row.setString("Name", name);
  row.setInt("Punkte", score);

  highscore.sortReverse("Punkte");

  while (highscore.getRowCount() > 10) {
    highscore.removeRow(highscore.getRowCount()-1);
  }

  saveTable(highscore, "./highscore.csv");
}
