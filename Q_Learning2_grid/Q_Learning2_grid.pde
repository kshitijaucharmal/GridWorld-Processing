
Game env;
int Episodes = 10000;
int episode = 0;

float epsilon = 0.6f;
float alpha = 0.6f;
float gamma = 0.9f;

int Action;
int State;
boolean Done;
float Rew;

float[][] Q;
int cycles = 1000;
int treps = 1;

void setup(){
  size(600, 600);
  frameRate(120);
  
  env = new Game(30);
  
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
  for(int i = 0; i < cycles; i++){
    Q_algo();
  }
  
  env.render();
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

//void keyPressed(){
//  if(key == 'w'){
//    println(env.step(1).done);
//  }
//  if(key == 'a'){
//    println(env.step(2).done);
//  }
//  if(key == 's'){
//    println(env.step(0).done);
//  }
//  if(key == 'd'){
//    println(env.step(3).done);
//  }
//}
