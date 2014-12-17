
PShape mainModel;
Arcball arcball;

void setup() {
  size(1024, 768, P3D);

  arcball = new Arcball(width/2, height/2, 600);   
  setupGrid();
  frameRate(30);
  //  mainModel= createModel();
}

void draw() {
  background(0);

  //  ambient(180);   
  lights();

  translate(width/2, height/2, 200);
  arcball.run();

  shape(createModel());
}

void mousePressed() {
  arcball.mousePressed();
}

void mouseDragged() {
  arcball.mouseDragged();
}

