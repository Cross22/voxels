
PShape mainModel;
Arcball arcball;
PShader myShader;

void setup() {
  size(1024, 768, P3D);

  frameRate(30);
  arcball = new Arcball(width/2, height/2, 600);   
  setupGrid();

  myShader = loadShader("frag.glsl", "vert.glsl");
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

