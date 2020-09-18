class Grid{
  int[][] blocks;
  int[] danger = new int[p];
  
  Grid(){
    blocks = new int[rows][cols];
    for(int i = 0; i < rows; i++){
      for(int j = 0; j < cols; j++){
        blocks[i][j] = i * cols + j;
      }
    }
    for(int i = 0; i < danger.length; i++){
      danger[i] = int(random(rows * cols - 1));
    }
  }
  
  void show(){
    //grid lines
    for(int i = 0; i < rows; i++) line(0, i * gridSize, width, i * gridSize);
    for(int i = 0; i < cols; i++) line(i * gridSize, 0, i * gridSize, height);
    
    // show numbers(states)
    for(int i = 0; i < rows; i++){
      for(int j = 0; j < cols; j++){
        if(i == rows - 1 && j == cols - 1)fill(0, 255, 0);
        else fill(0, 100);
        for(int k = 0; k < danger.length; k++){
          if(i * cols + j == danger[k]) fill(255, 0, 0);
        }
        textAlign(CENTER);
        textSize(10);
        text(blocks[i][j], i * gridSize + gridSize/2, j * gridSize + gridSize/2);
      }
    }
  }
  
  int giveState(int x, int y){
    x = (x - gridSize/2)/gridSize;
    y = (y - gridSize/2)/gridSize;
    for(int i = 0; i < rows; i++){
      for(int j = 0; j < cols; j++){
        if(i == x && j == y){
          return i * cols + j;
        }
      }
    }
    return -1;
  }
}
