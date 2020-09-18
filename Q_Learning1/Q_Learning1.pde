
int rows, cols;
int gridSize = 60;
int p;
Grid grid;
Player player;
boolean heuristic = false;
int dir;
boolean train = false;

// for q learning
int states, actions;
float[][] Q;
float[][] R;
int currentState;
int nextState;
int action;
int episode = 0;
int max_episodes = 500;
float reward;
float max_reward = 100f;

//hyperparameters
float alpha = 0.6f;
float gamma = 0.9f;
float epsilon = 0.6f;

void setup() {
  size(600, 600);
  p = width/gridSize;
  println(p);
  rows = width/gridSize;
  cols = height/gridSize;
  grid = new Grid();
  player = new Player(0, 0);

  // For Q Learning
  states = rows * cols;
  actions = 4;
  Q = new float[states][actions];
  R = new float[rows][cols];

  for (int i = 0; i < states; i++) {
    for (int j = 0; j < actions; j++)Q[i][j] = 0.0f;
  }
  initializeRewards();

  if (!train) {
    frameRate(10);
    Q = loadFromFile();
    printa(Q);
    max_episodes = 10;
  }
  else{
    frameRate(120);
  }
}

void initializeRewards(){
  for(int i = 0; i < rows; i++){
    for(int j = 0; j < cols; j++){
      R[i][j] = -0.01;
      for(int k = 0; k < grid.danger.length; k++){
        if(i * cols + j == grid.danger[k]){
          R[i][j] = -max_reward;
        }
      }
      if(i * cols + j == rows * cols - 1){
        R[i][j] = max_reward;
      }
    }
  }
}

void showEp() {
  push();
  textAlign(CENTER);
  textSize(40);
  fill(0, 130);
  text("Episode : " + episode, width/2, height/2);
  pop();
}

void printa(float[][] array) {
  for (int i = 0; i < array.length; i++) {
    for (int j = 0; j < array[0].length; j++)print(array[i][j] + ", ");
    println();
  }
  println("\n\n");
}

void saveToFile(float[][] array) {
  String[] l = new String[array.length * array[0].length + grid.danger.length];
  for (int i = 0; i < array.length; i++) {
    for (int j = 0; j < array[0].length; j++) {
      l[i * array[0].length + j] = Float.toString(array[i][j]);
    }
  }
  for(int i = 0; i < grid.danger.length; i++){
    l[array.length * array[0].length + i] = Integer.toString(grid.danger[i]);
  }
  saveStrings("file.txt", l);
}

void draw() {
  background(255);
  showEp();
  grid.show();
  if (train) {
    if (!heuristic) {
      // Q Learning Algorithm
      currentState = player.state;
      if (random(1) < epsilon) action = int(random(0, 4));
      else action = argmax(Q[currentState]);
      //take action
      reward = giveReward(currentState);
      player.update(action);
      //store reward
      //observe next state
      nextState = player.state;
      //end game if reach the end
      if (nextState == rows * cols - 1) {
        reset();
      }
      Q[currentState][action] += alpha * (reward + gamma * max(Q[nextState]) - Q[currentState][action]);
      currentState = nextState;
    } else {
    }
  } else {
    currentState = player.state;
    action = argmax(Q[currentState]);
    player.update(action);
    nextState = player.state;
    if (nextState == rows * cols - 1) reset();
    currentState = nextState;
  }

  if (episode >= max_episodes) {
    print("DONE");
    saveToFile(Q);
    print("Saved");
    exit();
  }

  player.show();
}

float giveReward(int state){
  for(int i = 0; i < rows; i++){
    for(int j = 0; j < cols; j++){
      if(i * cols + j == state){
        return R[i][j];
      }
    }
  }
  return -10;
}

float[][] loadFromFile() {
  float[][] table = new float[states][actions];
  String[] l = loadStrings("file.txt");
  for (int i = 0; i < states; i++) {
    for (int j = 0; j < actions; j++) {
      table[i][j] = Float.valueOf(l[i * actions + j]).floatValue();
    }
  }
  for(int i = 0; i < l.length - states * actions; i++){
    grid.danger[i] = Integer.valueOf(l[states * actions + i]).intValue();
  }
  initializeRewards();
  return table;
}

void reset() {
  episode++;
  player = new Player(0, 0);
  println("Episode : " + episode);
}

int argmax(float[] array) {
  float max = array[0];
  int am = 0;
  for (int i = 0; i < array.length; i++) {
    if (array[i] > max) {
      max = array[i];
      am = i;
    }
  }
  return am;
}

void keyPressed() {
  if (key == 'f') saveToFile(Q);
  if (key == 't') {
    train = false;
    loadFromFile();
    frameRate(5);
  }
  if (heuristic) {
    if (key == 'd') {
      dir = 3;
    }
    if (key == 'a') {
      dir = 2;
    }
    if (key == 'w') {
      dir = 0;
    }
    if (key == 's') {
      dir = 1;
    }
    player.update(dir);
  }
}
