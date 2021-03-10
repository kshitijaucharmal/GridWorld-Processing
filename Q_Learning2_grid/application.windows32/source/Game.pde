class Game{
  int rows, cols;
  int size;
  int offset;
  ArrayList<Integer> danger_states = new ArrayList<Integer>();
  ArrayList<Integer> encourage_states = new ArrayList<Integer>();
  
  int state;
  float reward = 0f;
  boolean done = false;
  
  Game(int r){
    this.rows = r;
    this.cols = r;
    size = width/rows;
    offset = size/2;
    
    state = 0;
  }
  
  int reset(){
    state = 0;
    done = false;
    return state;
  }
  
  void render(){
    push();
    fill(255);
    textSize(15);
    textAlign(CENTER, CENTER);
    for(int i = 0; i < rows; i++){
      for(int j = 0; j < cols; j++){
        if(show_numbers)
          text(i*cols + j, i*size + offset, j * size + offset);
        if(i * cols + j == state){
          push();
          fill(0, 0, 255);
          circle(i * size + offset, j * size + offset, size/2);
          pop();
        }
        if(i * cols + j == (rows * rows) - 1){
          push();
          fill(0, 255, 0, 100);
          rect(i * size, j * size, size, size);
          pop();
        }
        
        for(int k = 0; k < danger_states.size(); k++){
          if(i * cols + j == danger_states.get(k)){
            push();
            fill(255, 0, 0, 100);
            rect(i * size, j * size, size, size);
            pop();
          }
        }
        for(int k = 0; k < encourage_states.size(); k++){
          if(i * cols + j == encourage_states.get(k)){
            push();
            fill(0, 0, 255, 100);
            rect(i * size, j * size, size, size);
            pop();
          }
        }
      }
    }
    stroke(255);
    for(int i = 0; i < rows; i++){
      line(0, i * size, width, i * size);
    }
    for(int i = 0; i < cols; i++){
      line(i * size, 0, i * size, height);
    }
    pop();
  }
  
  Step step(int action){
    move(action);
    reward = giveReward();
    return new Step(state, reward, done);
  }
  
  float giveReward(){
    float r = -1;
    if(state == (rows * rows) - 1){
      r = 100;
      done = true;
    }
    for(int i = 0;i < danger_states.size(); i++){
      if(state == danger_states.get(i)){
        r = -10f;
        done = true;
      }
    }
    for(int i = 0;i < encourage_states.size(); i++){
      if(state == encourage_states.get(i)){
        r = 0f;
      }
    }
    return r;
  }
  
  void move(int dir){
    switch(dir){
      case 0: // Down
        if(state % rows == rows-1){
          return;
        }
        state += 1;
        break;
      case 1: // Up
        if(state % rows == 0){
          return;
        }
        state -= 1;
        break;
      case 2: // Left
        if(state < rows){
          return;
        }
        state -= rows;
        break;
      case 3: // Right
        if(state >= (rows * rows) - rows){
          return;
        }
        state += rows;
        break;
    }
  }
}
