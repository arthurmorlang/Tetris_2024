class Shape {
  //2D-Array für 7 Tetris Formen, jedes Array bildet eine Form im Koordinatensystem
  //jedes 2D-Array hat 4 "Blöcke" mit 2 X und 2 Y-Koordinaten

  private int[][] square = {{0, 0}, {1, 0}, {0, 1}, {1, 1}}; //Square
  private int[][] ln = {{0, 0}, {1, 0}, {2, 0}, {3, 0}}; //Line
  private int[][] tri = {{0, 0}, {1, 0}, {1, 1}, {2, 1}}; //Triangle
  private int[][] leftL = {{0, 0}, {0, 1}, {1, 0}, {2, 0}}; //LeftL
  private int[][] rightL = {{0, 0}, {1, 0}, {2, 0}, {2, 1}}; //RightL
  private int[][] theS = {{0, 0}, {1, 0}, {1, 1}, {2, 1}}; //Z Form
  private int[][] otherS = {{0, 1}, {1, 1}, {1, 0}, {2, 0}}; //otherZ Form

  private int[][] theShape, originalShape; //theShape ist die durch Zufall gebildete Form, originalShape = Kopie von TheShape für Rotation
  private int r, g, b, choice; //Variablen zur Auswahl der Formen/Farbe
  private boolean isActive;
  private float w; // Variable damit die Formen die gleiche Größe wie Grid haben
  private int counter;
  private int rotCount; //Counter für Rotation
  private int theX, theY;
  color bColor = color(51);
  color sColor = color(144, 180, 144);

  public Shape() { //Konstruktor Shape
    w = width/24;
    choice = (int)random(7); //Zufällige Wahl der 7 Formen/Farben
    switch(choice) {
    case 0:
      theShape = square;
      r = 155;
      break;
    case 1:
      theShape = ln;
      g = 155;
      break;
    case 2:
      theShape = tri;
      b = 155;
      break;
    case 3:
      theShape = leftL;
      r = 155;
      g = 155;
      break;
    case 4:
      theShape = rightL;
      g = 155;
      b = 155;
      break;
    case 5:
      theShape = theS;
      r = 155;
      b = 155;
      break;
    case 6:
      theShape = otherS;
      r = 155;
      g = 60;
      b = 200;
      break;
    }
    counter = 1;
    originalShape = theShape;
    rotCount = 0;
  }

  public void display() { // die neuen zufälligen Formen anzeigen
    fill(r, g, b);

    for (int i = 0; i < 4; i++) {
      rect(theShape[i][0]*w, theShape[i][1]*w, w, w); //theShape[i][0] = X-Koordinaten,   theShape[i][1] = Y-Koordinaten
    }
  }

  public void moveDown(int speed) {
    if (speed == 0) {
      if (counter % 35 == 0) {
        moveShape("DOWN");
      }
    } else if (speed < 3) {
      if (counter % 35 == 0) {
        moveShape("DOWN");
      }
    } else if (speed < 6) {
      if (counter % 20 == 0) {
        moveShape("DOWN");
      }
    } else {
      if (counter % 15 == 0) {
        moveShape("DOWN");
      }
    }
    counter++;
  }



  public void moveShape(String direction) {
    if (gameOver == false) {
      if (checkSide(direction)) {
        if (direction == "RIGHT") {
          osc.send(moveMessage, meineAdresse);

          for (int i = 0; i < 4; i++) {
            theShape[i][0]++;    //nach rechts bewegen (X-Koordinaten++)
          }
        } else if (direction == "LEFT") {
          osc.send(moveMessage, meineAdresse);

          for (int i = 0; i < 4; i++) {
            theShape[i][0]--;   //nach links bewegen (X-Koordinaten--)
          }
        } else if (direction == "DOWN") {

          for (int i = 0; i < 4; i++) {
            theShape[i][1]++;  //nach unten bewegen (Y-Koordinaten++)
          }
        }
      }
    }
  }


  public boolean checkSide(String direction) { //Bildet die "Grenzen" bis wann man die Objekte bewegen darf
    switch(direction) {
    case "RIGHT":
      for (int i = 0; i < 4; i++) {
        if (theShape[i][0] > 10) {
          return false;
        }
      }
      break;
    case "LEFT":
      for (int i = 0; i < 4; i++) {
        if (theShape[i][0] < 1) {
          return false;
        }
      }
      break;
    case "DOWN":
      for (int i = 0; i < 4; i++) {
        if (theShape[i][1] > 18) {
          isActive = false;
          return false;
        }
      }
      break;
    }
    return true;
  }


  public boolean checkLeftRight(String direction) { //gibt boolean zurück wann eine Form rotiert werden darf
    switch(direction) {
    case "RIGHT":
      for (int i = 0; i < 4; i++) {
        if (theShape[i][0] > 11) {
          return false;
        }
      }
      break;
    case "LEFT":
      for (int i = 0; i < 4; i++) {
        if (theShape[i][0] < 0) {
          return false;
        }
      }
      break;
    }

    if (theShape == leftL) {
      switch(direction) {
      case "RIGHT":
        for (int i = 0; i < 4; i++) {
          if (theShape[i][0] > 10) {
            return false;
          }
        }
        break;
      case "LEFT":
        for (int i = 0; i < 4; i++) {
          if (theShape[i][0] < 4) {
            return false;
          }
        }
        break;
      }
    }

    if (theShape == ln) {
      switch(direction) {
      case "RIGHT":
        for (int i = 0; i < 4; i++) {
          if (theShape[i][0] > 8) {
            return false;
          }
        }
        break;
      case "LEFT":
        for (int i = 0; i < 4; i++) {
          if (theShape[i][0] < 5) {
            return false;
          }
        }
        break;
      }
    }

    return true;
  }


  //ROTATION-OBJEKTE
  public void rotate() {
    //90Grad Rotation: (x,y) -> (y, -x)
    //180Grad Rotation: (x,y) -> (-x,-y)
    //270Grad Rotation: (x,y) -> (-y,x)
    //360 Rotation: (x,y) -> (x,y)

    //theShape[1][0] ist der Punkt der Rotation der Punkt, daher erfolgt die Rotation aller Objekte am gleichem Punkt


    if (theShape != square) {
      int[][] rotated = new int[4][2]; //gleiche Dimension wie theShape

      if (rotCount % 4 == 0) {
        for (int i = 0; i < 4; i++) {
          rotated[i][0] = originalShape[i][1] - theShape[1][0];
          rotated[i][1] = -originalShape[i][0] - theShape[1][1];
        }
      } else if (rotCount % 4 == 1) {
        for (int i = 0; i < 4; i++) {
          rotated[i][0] = -originalShape[i][0] - theShape[1][0];
          rotated[i][1] = -originalShape[i][1] - theShape[1][1];
        }
      } else if (rotCount % 4 == 2) {
        for (int i = 0; i < 4; i++) {
          rotated[i][0] = -originalShape[i][1] - theShape[1][0];
          rotated[i][1] = originalShape[i][0] - theShape[1][1];
        }
      } else if (rotCount % 4 == 3) {
        for (int i = 0; i < 4; i++) {
          rotated[i][0] = originalShape[i][0] - theShape[1][0];
          rotated[i][1] = originalShape[i][1] - theShape[1][1];
        }
      }
      theShape = rotated; //360 Grad Rotation
    }
  }



  //PRÜFUNG OB SCHON EIN OBJEKT UNTER DEM NEU ERZEUGTEN PLATZIERT WURDE
  //Ermöglicht das "Stapeln" von Formen
  public boolean checkBackground(Background b) {
    for (int i = 0; i < 4; i++) {
      theX = theShape[i][0];
      theY = theShape[i][1];
      if (theX >= 0 && theX < 12 && theY >= 0 && theY < 19) {

        for (int s = 0; s < 3; s++) {
          if (b.colors[theX][theY+1][s] != 0) {
            osc.send(placeMessage, meineAdresse);

            return false;
          }
        }
      }
    }
    return true;
  }


  //INTERFACE AUF RECHTEN SEITE DES FENSTERS
  //BEEINHALTET SCORE,POINTS,TIMER,BUTTONS
  public void showInterface() {
    fill(bColor);
    rect(width/2, 0, width/2, height);
    fill(0);
    stroke(sColor);

    rect(width/2 + 60, 60, 245, 85);
    stroke(0);
    fill(255);
    text("NEXT", width/2 + 60, 40);
    fill(r, g, b);
    for (int i = 0; i < 4; i++) {
      rect(theShape[i][0]*w + width/2 +130, theShape[i][1]*w +72, w, w);
    }

    //LINE-SCORE
    fill(0);
    stroke(sColor);
    rect(width/2 +60, 180, 245, 45);
    fill(255);
    text("LINES:  " +  bg.score, width/2 + 80, 210);

    //POINTS-COUNTER
    fill(0);
    stroke(sColor);
    rect(width/2+60, 250, 245, 45);
    fill(255);
    text("POINTS: " +  bg.points, width/2 + 80, 280);


    buttons();
  }

  public void buttons() {
    if (gameOver == false) {

      //PAUSE-BUTTON
      fill(0);
      stroke(81);
      rect(width/2 + 60, 400, 245, 45, 15);
      fill(255);
      text("PAUSE", width/2+140, 430);


      //QUIT-BUTTON
      fill(0);
      stroke(81);
      rect(width/2 + 60, 470, 245, 45, 15);
      fill(255);
      text("QUIT", width/2+155, 500);
    }
  }
}
