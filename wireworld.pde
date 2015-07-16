int boardSize = 50;
int cellSize = 12, sliderHeight = 25;
int CELL_EMPTY = 0, CELL_ELCHEAD = 1, CELL_ELCTAIL = 2, CELL_CNDCTR = 3;
int[][][] cellState = new int[2][boardSize][boardSize];
int cellStateIdx = 0;
color[] cellColour = new color[]{#000000, #4466FF, #FF3333, #FFFF00};

int maxInterval = 1000, lastUpdate = -maxInterval - 1345786;
float intervalRate = 0.5;
boolean paused = false;
boolean editMode = true;
boolean headDrawn = false;
int headX, headY;

void keyPressed() {
  if (keyCode == 32) paused = !paused;
  else if (keyCode == 10) editMode = !editMode;
  else if (keyCode == 66) {    // B
    for (i = 0; i < boardSize; ++i)
      for (j = 0; j < boardSize; ++j) cellState[cellStateIdx][i][j] = CELL_EMPTY;
  } else if (keyCode == 67) {  // C
    for (i = 0; i < boardSize; ++i)
      for (j = 0; j < boardSize; ++j) cellState[cellStateIdx][i][j] = CELL_CNDCTR;
  } else if (keyCode == 70) {  // F
    for (i = 0; i < boardSize; ++i)
      for (j = 0; j < boardSize; ++j)
        if (cellState[cellStateIdx][i][j] == CELL_ELCHEAD
          || cellState[cellStateIdx][i][j] == CELL_ELCTAIL)
        {
          cellState[cellStateIdx][i][j] = CELL_CNDCTR;
        }
  }
}

void setup() {
  size(boardSize * cellSize, boardSize * cellSize + sliderHeight);
  textSize(sliderHeight);
}

int i, j, curTime;
void draw() {
  // Draw the cells
  strokeWeight(1);
  stroke(48);
  for (i = 0; i < boardSize; ++i)
    for (j = 0; j < boardSize; ++j) {
      fill(cellColour[cellState[cellStateIdx][i][j]]);
      rect(i * cellSize, j * cellSize, cellSize, cellSize);
    }

  // Draw the slider
  noStroke();
  fill(128);
  rect(0, boardSize * cellSize, boardSize * cellSize, sliderHeight);
  fill(232);
  rect(0, boardSize * cellSize, boardSize * cellSize * intervalRate, sliderHeight);
  fill(0);
  text(paused ? "PAUSED" : "SPEED", 0, boardSize * cellSize + sliderHeight);
  fill(255);
  text(editMode ? "Edit Mode" : "Run Mode", 0, sliderHeight);

  // Check for updates
  curTime = millis();
  if (!mousePressed && !paused && curTime - lastUpdate > maxInterval * (1 - intervalRate)) {
    lastUpdate = curTime;
    update();
  }

  if (mousePressed) {
    if (mouseY >= boardSize * cellSize - 1) {
      // Update the slider
      intervalRate = mouseX / (float)(boardSize * cellSize);
    } else {
      i = (int)(mouseX / cellSize);
      j = (int)(mouseY / cellSize);
      // Rare exceptions
      if (i < 0) i = 0; else if (i >= boardSize) i = boardSize - 1;
      if (j < 0) j = 0; else if (j >= boardSize) j = boardSize - 1;
      if (editMode) {
        cellState[cellStateIdx][i][j] = (mouseButton == LEFT) ? CELL_CNDCTR : CELL_EMPTY;
      } else {
        if (headDrawn && (i != headX || j != headY)) {
          cellState[cellStateIdx][i][j] = (mouseButton == LEFT) ? CELL_ELCTAIL : CELL_CNDCTR;
        } else {
          headDrawn = true;
          headX = i; headY = j;
          cellState[cellStateIdx][i][j] = (mouseButton == LEFT) ? CELL_ELCHEAD : CELL_CNDCTR;
        }
      }
    }
  } else {
    headDrawn = false;
  }
}

int nextStateIdx, k, t, ii, jj;
int[][] neighbour = new int[][] {
  {-1, -1}, {-1, 0}, {-1, +1},
  { 0, -1},          { 0, +1},
  {+1, -1}, {+1, 0}, {+1, +1}
};
void update() {
  nextStateIdx = 1 - cellStateIdx;
  for (i = 0; i < boardSize; ++i)
    for (j = 0; j < boardSize; ++j) switch (cellState[cellStateIdx][i][j]) {
      case 0: // CELL_EMPTY
        cellState[nextStateIdx][i][j] = CELL_EMPTY; break;
      case 1: // CELL_ELCHEAD
        cellState[nextStateIdx][i][j] = CELL_ELCTAIL; break;
      case 2: // CELL_ELCTAIL
        cellState[nextStateIdx][i][j] = CELL_CNDCTR; break;
      case 3: // CELL_CNDCTR
        t = 0;
        for (k = 0; k < 8; ++k) {
          ii = i + neighbour[k][0];
          jj = j + neighbour[k][1];
          if (ii >= 0 && ii < boardSize && jj >= 0 && jj < boardSize
            && cellState[cellStateIdx][ii][jj] == CELL_ELCHEAD) ++t;
        }
        cellState[nextStateIdx][i][j] = (t == 1 || t == 2) ? CELL_ELCHEAD : CELL_CNDCTR;
        break;
    }
  cellStateIdx = nextStateIdx;
}

