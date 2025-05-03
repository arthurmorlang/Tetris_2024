
public class Background {

  private int[][][] colors; //3D-Array damit die Objekte mit den jeweiligen Farben am Boden gespeichert bzw. endgültig platziert werden
  //[Breite][Höhe][Farbe -> rgb]
  private int r, g, b;
  private int w;
  private int theX, theY;
  private int score;
  private int points;



  public Background() {
    colors = new int[12][20][3];
    w = width / 24;
  }

  public void display() {   //Formen werden angezeigt für jede X/Y Koordinate mithilfe RGB
    for (int i = 0; i < 12; i++) {
      for (int k = 0; k < 20; k++) {
        r = colors[i][k][0];
        g = colors[i][k][1];
        b = colors[i][k][2];

        fill(r, g, b);
        rect(i*w, k*w, w, w);
      }
    }
    for (int i = 0; i < 20; i++) {
      if (checkLine(i)) {
        removeLine(i);
      }
    }
  }

  //Prüft ob eine Zeile komplett ist
  public boolean checkLine(int row) {
    for (int i = 0; i < 12; i++) {
      if (colors[i][row][0] == 0 && colors[i][row][1] == 0 && colors[i][row][2] == 0) {
        return false;
      }
    }

    return true;
  }

  //Entfernt eine komplette Zeile
  public void removeLine(int row) {
    for (int i = 0; i < 12; i++) {
      colors[i][row][0]= 0;
      colors[i][row][1]= 0;
      colors[i][row][2]= 0;
    }
    osc.send(removeLineMessage, meineAdresse);

    dropLinesAbove(row);
  }

  //rückt die Zeilen pro kompletter Zeile nach unten
  public void dropLinesAbove(int row) {
    score++;
    points += 100;
    for (int r = row; r >= 1; r--) {
      for (int j = 0; j < 12; j++) {
        colors[j][r][0] = colors[j][r-1][0];
        colors[j][r][1] = colors[j][r-1][1];
        colors[j][r][2] = colors[j][r-1][2];
      }
    }
  }

  public void writeShape(Shape s) {
    //XY-Koordinate von jedem Block/Form bekommen, Kopie von theShape um die Formen zu platzieren
    for (int i = 0; i < 4; i++) {
      theX = s.theShape[i][0];
      theY = s.theShape[i][1];
      //neue Farben werden den gegebenen XY-Koordinaten gegeben
      colors[theX][theY][0] = s.r;
      colors[theX][theY][1] = s.g;
      colors[theX][theY][2] = s.b;

      if (s.theShape[i][1] == 0 || s.theShape[i][1] == 1  ) { //Gameover Bedingung
        osc.send(gameOverMessage, meineAdresse);
        gameOver = true;
        gameState=2;
        //println(gameState);
      }
    }
    points += 10; //+10 Punkte falls eine Form platziert wurde
  }
}


public void gameOverWindow() {

  if (gameOver == true) {
    fill(255);
    rectMode(CENTER);
    rect(width/2, height/2, 390, 300, 15);

    fill(255, 0, 0);
    textSize(32);
    textAlign(CENTER);
    text("Game Over", width / 2, height / 2 - 100);

    textSize(25);
    textAlign(CENTER);
    //LINE-SCORE
    fill(0);
    fill(255, 0, 0);
    text("LINES:  " +  bg.score, width/2 - 100, height/2);

    //POINTS-COUNTER
    fill(0);
    fill(255, 0, 0);
    text("POINTS: " +  bg.points, width/2 + 75, height/2);

    //Eingabe für Name
    textAlign(CENTER);
    textSize(25);
    text("Name:", width/2 -100, height/2+80);
    text(name, width/2 +30, height/2 +80);
    if (frameCount%60 < 30) {
      stroke(255);
      rect(width/2 + textWidth(name), height/2+82, 20, 2);
    }
  }
}
