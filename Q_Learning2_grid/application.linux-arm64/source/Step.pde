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
