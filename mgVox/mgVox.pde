// Applet entry point.
// Interesting algorithmic stuff happens in cubes file.
// The Marching Cubes reference tables are in cubeTables.

PShape mainModel;
Arcball arcball;
PShader myShader;

void setup() {
//  size(1024, 768, P3D);
  size(1920, 1080, P3D);

  frameRate(30);
  arcball = new Arcball(width/2, height/2, 600);   
  setupGrid();

  myShader = loadShader("frag.glsl", "vert.glsl");
  perf();
}

void perf() {
  PShape[] arr= new PShape[20];
  //warmup
  for (int i=0; i<100; ++i) 
    arr[i%20]=createModel();
  
  long start= System.currentTimeMillis();
  for (int i=0; i<100; ++i) 
    arr[i%20]=createModel();
  long end= System.currentTimeMillis();
  float total= (end-start)/100.0;
  println("time(ms): "+ total );
  exit();
}
void draw() {
  background(0);
  shader( myShader );
  
  translate(width/2, height/2, 200);
  arcball.run();
  directionalLight(255,255,255, 1,0,0);

  shape(createModel());
}

void mousePressed() {
  arcball.mousePressed();
}

void mouseDragged() {
  arcball.mouseDragged();
}
