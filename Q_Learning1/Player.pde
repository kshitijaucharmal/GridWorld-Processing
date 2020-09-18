class Player{
  PVector pos;
  PVector vel;
  int size = gridSize/2;
  int state;
  boolean dead = false;
  
  Player(int x, int y){
    pos = new PVector(x * gridSize + gridSize/2, y * gridSize + gridSize/2);
    vel = new PVector();
  }
  
  void show(){
    push();
    fill(0, 0, 255);
    circle(pos.x, pos.y, size);
    pop();
  }
  
  void update(int dir){
    vel = new PVector(0, 0);
    if(dir == 0 && pos.y > gridSize) vel.y = -1;
    if(dir == 1 && pos.y < height - gridSize) vel.y = 1;
    if(dir == 2 && pos.x > gridSize) vel.x = -1;
    if(dir == 3 && pos.x < width - gridSize) vel.x = 1;
    vel = vel.mult(gridSize);
    pos.add(vel);
    state = grid.giveState((int)pos.x, (int)pos.y);
  }
  
  int readState(){
    return state;
  }
}  
  
