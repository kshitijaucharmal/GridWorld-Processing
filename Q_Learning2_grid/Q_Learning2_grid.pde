
// game environment
Game env;

// paramters to tweak
//---------------------------------------------------------------
int Episodes = 1000; //total episodes to train 
int episode = 0; // start from episode
int rows = 10; // rows in the grid (grid is square)
boolean show_numbers = true; // show numbers in grid (turn this off for bigger_grids)
boolean heuristic = false; // want to play/test yourself??

// q-learning hyperparamters
float epsilon = 0.6f;
float alpha = 0.6f;
float gamma = 0.9f;

// Q learning variables
int Action;
int State;
boolean Done;
float Rew;

// THE Q Table
float[][] Q;
int cycles = 1; // This is the speed of the training dont raise too high if on a low end pc
int treps = 1; // training episode start
boolean speedup = false;
boolean start = false;

void setup(){
  size(600, 600); // dont change this (size of canvas)
  if(speedup)
    frameRate(120); // frame rate
  else
    frameRate(10);
  
  env = new Game(rows);
  
  Q = new float[env.rows * env.cols][4];
  for(int i = 0; i < Q.length; i++){
    for(int j = 0; j < Q[0].length; j++){
      Q[i][j] = 0.0f;
    }
  }
  
  State = env.reset();
  Done = false;
  Rew = 0;
}

void draw(){
  background(51);
  if(start){
    if(!heuristic){
      for(int i = 0; i < cycles; i++){
        Q_algo();
      }
    }
    
    if(speedup)frameRate(120);
    else frameRate(10);
    
    env.render();
  }
  else{
    textSize(32);
    textAlign(CENTER, CENTER);
    text("Press Space to start", width/2, height/2);
  }
}

void Q_algo(){
  if(random(1) < epsilon){
    Action = argmax(Q[State]);
  }
  else{
    Action = int(random(4));
  }
  
  Step p = env.step(Action);
  Q[State][Action] += alpha * (p.reward + gamma * max(Q[p.next_state]) - Q[State][Action]);
  State = p.next_state;
  Rew += p.reward;
  
  if(p.done){
    episode ++;
    State = env.reset();
    Done = false;
    Rew = 0;
    if(episode >= Episodes){
      epsilon = 1;
      cycles = 1;
      frameRate(10);
      println("Testing Episode : " + treps);
      treps++;
    }
    else
      println("Episode : " + episode);
  }
}

int argmax(float[] arr){
  float max = -100000;
  int arg = -1;
  for(int i = 0; i < arr.length; i++){
    if(arr[i] > max){
      max = arr[i];
      arg = i;
    }
  }
  return arg;
}

void keyPressed(){
  if(heuristic){
    if(key == 'w'){
      if(env.step(1).done) env.reset();
    }
    if(key == 'a'){
      if(env.step(2).done) env.reset();
    }
    if(key == 's'){
      if(env.step(0).done) env.reset();
    }
    if(key == 'd'){
      if(env.step(3).done) env.reset();
    }
  }
  if(key == 'p'){
    speedup = !speedup;
  }
  if(key == ' '){
    start = !start;
  }
}
