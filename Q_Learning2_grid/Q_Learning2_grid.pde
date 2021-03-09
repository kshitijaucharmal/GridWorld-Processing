
// I want to warn you while using encouragement gates, they can give a boost, but only if agent discovers the endpoint
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
int cycles = 1000; // This is the speed of the training dont raise too high if on a low end pc
int treps = 1; // training episode start
boolean speedup = false; // press p to speed up (see keyPressed function)
boolean start = false; // start and pause with space (pause to edit danger_states)
boolean encourage_mode = false;

void setup() {
  size(600, 600); // dont change this (size of canvas)
  if (speedup)
    frameRate(120); // frame rate
  else
    frameRate(10);

  env = new Game(rows);

  Q = new float[env.rows * env.cols][4];
  for (int i = 0; i < Q.length; i++) {
    for (int j = 0; j < Q[0].length; j++) {
      Q[i][j] = 0.0f;
    }
  }

  State = env.reset();
  Done = false;
  Rew = 0;
}

void draw() {
  background(51);
  if (start) {
    if (!heuristic) {
      for (int i = 0; i < cycles; i++) {
        Q_algo();
      }
    }

    if (speedup)frameRate(120);
    else frameRate(10);

    //env.render();
    textSize(20);
    textAlign(CENTER, CENTER);
    text("Episode : " + episode, width/2, height/2);
  } else {
    textSize(32);
    textAlign(CENTER, CENTER);
    text("Press Space to start", width/2, height/2);
  }
  env.render();
}

void Q_algo() {
  if (random(1) < epsilon) {
    Action = argmax(Q[State]);
  } else {
    Action = int(random(4));
  }

  Step p = env.step(Action);
  Q[State][Action] += alpha * (p.reward + gamma * max(Q[p.next_state]) - Q[State][Action]);
  State = p.next_state;
  Rew += p.reward;

  if (p.done) {
    episode ++;
    State = env.reset();
    Done = false;
    Rew = 0;
    if (episode >= Episodes) {
      epsilon = 1;
      cycles = 1;
      frameRate(10);
      println("Testing Episode : " + treps);
      treps++;
    } else
      println("Episode : " + episode);
  }
}

int argmax(float[] arr) {
  float max = -100000;
  int arg = -1;
  for (int i = 0; i < arr.length; i++) {
    if (arr[i] > max) {
      max = arr[i];
      arg = i;
    }
  }
  return arg;
}

void mouseClicked() {
  if (!start) {
    if(!encourage_mode){
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < rows; j++) {
          if (mouseX >= i * env.size && mouseX <= (i+1) * env.size && mouseY >= j * env.size && mouseY <= (j+1) * env.size) {
            push();
            fill(255, 10, 10);
            rect(i * env.size, j * env.size, env.size, env.size);
            if(!exist_in_danger(i*rows+j))
              env.danger_states.add(i*rows + j);
            pop();
          }
        }
      }
    }
    else{
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < rows; j++) {
          if (mouseX >= i * env.size && mouseX <= (i+1) * env.size && mouseY >= j * env.size && mouseY <= (j+1) * env.size) {
            push();
            fill(255, 10, 10);
            rect(i * env.size, j * env.size, env.size, env.size);
            if(!exist_in_encourage(i*rows+j))
              env.encourage_states.add(i*rows + j);
            pop();
          }
        }
      }
    }
  }
}

boolean exist_in_danger(int state){
  for(int i = 0; i < env.danger_states.size();i++){
    if(env.danger_states.get(i) == state){
      return true;
    }
  }
  return false;
}

boolean exist_in_encourage(int state){
  for(int i = 0; i < env.encourage_states.size();i++){
    if(env.encourage_states.get(i) == state){
      return true;
    }
  }
  return false;
}

void keyPressed() {
  if (heuristic) {
    if (key == 'w') {
      if (env.step(1).done) env.reset();
    }
    if (key == 'a') {
      if (env.step(2).done) env.reset();
    }
    if (key == 's') {
      if (env.step(0).done) env.reset();
    }
    if (key == 'd') {
      if (env.step(3).done) env.reset();
    }
  }
  if (key == 'p') {
    speedup = !speedup;
  }
  if (key == ' ') {
    start = !start;
  }
  if (key == 'e') {
    encourage_mode = !encourage_mode;
  }
}
