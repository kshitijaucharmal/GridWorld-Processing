import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Q_Learning2_grid extends PApplet {


// I want to warn you while using encouragement gates, they can give a boost, but only if agent discovers the endpoint
// game environment
Game env;

// paramters to tweak
//---------------------------------------------------------------
int Episodes = 3000; //total episodes to train 
int episode = 0; // start from episode
int rows = 15; // rows in the grid (grid is square)
boolean show_numbers = false; // show numbers in grid (turn this off for bigger_grids)
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

public void setup() {
   // dont change this (size of canvas)
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

public void draw() {
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
    if(encourage_mode) text("Mode : Encourage", width/2, 40);
    else text("Mode : Danger", width/2, 40);
  }
  env.render();
}

public void Q_algo() {
  if (random(1) < epsilon) {
    Action = argmax(Q[State]);
  } else {
    Action = PApplet.parseInt(random(4));
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

public int argmax(float[] arr) {
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

public void mousePressed() {
  if (!start) {
    if(!encourage_mode){
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < rows; j++) {
          if (mouseX >= i * env.size && mouseX <= (i+1) * env.size && mouseY >= j * env.size && mouseY <= (j+1) * env.size) {
            push();
            fill(255, 10, 10);
            rect(i * env.size, j * env.size, env.size, env.size);
            int s = exist_in_danger(i*rows+j);
            if(s < 0)
              env.danger_states.add(i*rows + j);
            else if(mouseButton == RIGHT)
              env.danger_states.remove(env.danger_states.get(s));
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
            fill(10, 10, 255);
            rect(i * env.size, j * env.size, env.size, env.size);
            int s = exist_in_encourage(i*rows+j);
            if(s < 0)
              env.encourage_states.add(i*rows + j);
            else if(mouseButton == RIGHT)
              env.encourage_states.remove(env.encourage_states.get(s));
            pop();
          }
        }
      }
    }
  }
}

public int exist_in_danger(int state){
  for(int i = 0; i < env.danger_states.size();i++){
    if(env.danger_states.get(i) == state){
      return i;
    }
  }
  return -1;
}

public int exist_in_encourage(int state){
  for(int i = 0; i < env.encourage_states.size();i++){
    if(env.encourage_states.get(i) == state){
      return i;
    }
  }
  return -1;
}

public void save_lists(){
  String[] ds = cvt_to_array(env.danger_states);
  saveStrings("danger_list.txt", ds);
}

public void load_lists(){
  env.danger_states = cvt_from_array(loadStrings("danger_list.txt"));
}

public String[] cvt_to_array(ArrayList<Integer> arr){
  String[] a = new String[arr.size()];
  for(int i = 0; i < arr.size(); i++){
    a[i] = str(arr.get(i));
  }
  return a;
}

public ArrayList<Integer> cvt_from_array(String[] arr){
  ArrayList<Integer> a = new ArrayList<Integer>();
  for(int i = 0; i < arr.length; i++){
    a.add(Integer.parseInt(String.valueOf(arr[i])));
  }
  return a;
}

public void keyPressed() {
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
  if (key == 'S'){
    save_lists();
    print("Saved");
  }
  if(key == 'L'){
    load_lists();
    print("Loaded");
  }
}
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
  
  public int reset(){
    state = 0;
    done = false;
    return state;
  }
  
  public void render(){
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
  
  public Step step(int action){
    move(action);
    reward = giveReward();
    return new Step(state, reward, done);
  }
  
  public float giveReward(){
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
  
  public void move(int dir){
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
class Step{
  int next_state;
  float reward;
  boolean done;
  
  Step(int ns, float r, boolean d){
    this.next_state = ns;
    this.reward = r;
    this.done = d;
  }
}
  public void settings() {  size(600, 600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Q_Learning2_grid" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
