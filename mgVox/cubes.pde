float ISOLEVEL= 50;      // threshold value for finding the iso surface //<>//
float dLevel = 0.004;    // delta increase, animates ISOLEVEL
final int CELL_WIDTH = 6;
final int GRID_COUNT = 100; // how many cells per axis
final float[] gridValueArr= new float[GRID_COUNT*GRID_COUNT*GRID_COUNT];

// temp vertices to be added
PVector[] vertList= new PVector[12];

void setupGrid() {
  for (int v=0; v<12; ++v) vertList[v]= new PVector();
  
  noiseSeed(0);
  for (int k=0; k<GRID_COUNT; ++k) {
    for (int j=0; j<GRID_COUNT; ++j) {
      for (int i=0; i<GRID_COUNT; ++i) {    
        setVal(i,j,k, density(i*CELL_WIDTH, j*CELL_WIDTH, k*CELL_WIDTH));
      }
    }
  }
}


// get/set density value at given grid point
float getVal(int i, int j, int k) {
  return gridValueArr[ i+ GRID_COUNT*j + GRID_COUNT*GRID_COUNT*k ];
}

void setVal(int i, int j, int k, float newVal) {
  gridValueArr[ i+ GRID_COUNT*j + GRID_COUNT*GRID_COUNT*k ]= newVal;
}


// base density function
float density(int i, int j, int k) {
  final float PRESCALE= 0.01 / CELL_WIDTH;
  float n= noise((float)i*PRESCALE, (float)j*PRESCALE, (float)k*PRESCALE)* 50*2; // set output to 0..100 range
  return n;

  // sphere
  //  PVector distSq= PVector.sub( new PVector(i,j,k), new PVector(50,50,50));
  //  return distSq.magSq();

  //  return k; // plane
}

// vertex positions p1,p2 and their associated values
// returns linearly interpolated point of zero-crossing
void VertexInterp(PVector p1, PVector p2, float valp1, float valp2, float isolevel, PVector outVec)
{
  if (abs(isolevel-valp1) < 0.00001) {
    outVec.set(p1) ;
    return;
  }
  if (abs(isolevel-valp2) < 0.00001) {
    outVec.set(p2) ;
    return;
  }    
  if (abs(valp1-valp2) < 0.00001) {
    outVec.set(p1) ;
    return;
  }

  // linear interpolation for intersection point
  float t = (isolevel - valp1) / (valp2 - valp1);
  float x = p1.x + t * (p2.x - p1.x);
  float y = p1.y + t * (p2.y - p1.y);
  float z = p1.z + t * (p2.z - p1.z);
  outVec.set(x,y,z) ;
}

float ValueForCellVertex(int i, int j, int k, int numVertex) {
  switch (numVertex) {
  case 0: 
    return getVal(i+0,j+0,k+0);
  case 1: 
    return getVal(i+1,j+0,k+0);
  case 2: 
    return getVal(i+1,j+1,k+0); 
  case 3: 
    return getVal(i+0,j+1,k+0);

  case 4: 
    return getVal(i+0,j+0,k+1);
  case 5: 
    return getVal(i+1,j+0,k+1);
  case 6: 
    return getVal(i+1,j+1,k+1); 
  default: 
    return getVal(i+0,j+1,k+1);
  }
}

PVector PosForCellVertex(int i, int j, int k, int numVertex) {
  switch (numVertex) {
  case 0: 
    return PVector.mult(new PVector(i+0, j+0, k+0), CELL_WIDTH);
  case 1: 
    return PVector.mult(new PVector(i+1, j+0, k+0), CELL_WIDTH);
  case 2: 
    return PVector.mult(new PVector(i+1, j+1, k+0), CELL_WIDTH);
  case 3: 
    return PVector.mult(new PVector(i+0, j+1, k+0), CELL_WIDTH);

  case 4: 
    return PVector.mult(new PVector(i+0, j+0, k+1), CELL_WIDTH);
  case 5: 
    return PVector.mult(new PVector(i+1, j+0, k+1), CELL_WIDTH);
  case 6: 
    return PVector.mult(new PVector(i+1, j+1, k+1), CELL_WIDTH);
  default: 
    return PVector.mult(new PVector(i+0, j+1, k+1), CELL_WIDTH);
  }
}

void addTriangles(int i, int j, int k, PShape model) {
  // ijk is first corner index, thus
  // PRE: for all i,j,k : 0 <= i,j,k <= GRID_COUNT-2 !

  // First find vertex/cube configuration
  int cubeindex=0;
  if (getVal(i+0,j+0,k+0) < ISOLEVEL) cubeindex |= 1;
  if (getVal(i+1,j+0,k+0) < ISOLEVEL) cubeindex |= 2;
  if (getVal(i+1,j+1,k+0) < ISOLEVEL) cubeindex |= 4;  
  if (getVal(i+0,j+1,k+0) < ISOLEVEL) cubeindex |= 8;

  if (getVal(i+0,j+0,k+1) < ISOLEVEL) cubeindex |= 16;
  if (getVal(i+1,j+0,k+1) < ISOLEVEL) cubeindex |= 32;
  if (getVal(i+1,j+1,k+1) < ISOLEVEL) cubeindex |= 64;  
  if (getVal(i+0,j+1,k+1) < ISOLEVEL) cubeindex |= 128;

  // intersected edge index for given configuration
  final int edgeIndex = EDGE_TABLE[cubeindex]; 

  if (edgeIndex==0)
    return; // cell is completely empty or completely filled

  // Find the vertices where the surface intersects the cube. Calculate intersection point along each edge
  if (0!=(edgeIndex & 1))
      VertexInterp( PosForCellVertex(i, j, k, 0), PosForCellVertex(i, j, k, 1), ValueForCellVertex(i, j, k, 0), ValueForCellVertex(i, j, k, 1), ISOLEVEL, vertList[0]);
  if (0!=(edgeIndex & 2))
      VertexInterp(PosForCellVertex(i, j, k, 1), PosForCellVertex(i, j, k, 2), ValueForCellVertex(i, j, k, 1), ValueForCellVertex(i, j, k, 2), ISOLEVEL, vertList[1]);
  if (0!=(edgeIndex & 4))
      VertexInterp(PosForCellVertex(i, j, k, 2), PosForCellVertex(i, j, k, 3), ValueForCellVertex(i, j, k, 2), ValueForCellVertex(i, j, k, 3), ISOLEVEL, vertList[2]);
  if (0!=(edgeIndex & 8))
      VertexInterp(PosForCellVertex(i, j, k, 3), PosForCellVertex(i, j, k, 0), ValueForCellVertex(i, j, k, 3), ValueForCellVertex(i, j, k, 0), ISOLEVEL, vertList[3]);
  if (0!=(edgeIndex & 16))
      VertexInterp(PosForCellVertex(i, j, k, 4), PosForCellVertex(i, j, k, 5), ValueForCellVertex(i, j, k, 4), ValueForCellVertex(i, j, k, 5), ISOLEVEL, vertList[4]);
  if (0!=(edgeIndex & 32))
      VertexInterp(PosForCellVertex(i, j, k, 5), PosForCellVertex(i, j, k, 6), ValueForCellVertex(i, j, k, 5), ValueForCellVertex(i, j, k, 6), ISOLEVEL, vertList[5]);
  if (0!=(edgeIndex & 64))
      VertexInterp(PosForCellVertex(i, j, k, 6), PosForCellVertex(i, j, k, 7), ValueForCellVertex(i, j, k, 6), ValueForCellVertex(i, j, k, 7), ISOLEVEL, vertList[6]);
  if (0!=(edgeIndex & 128))
      VertexInterp(PosForCellVertex(i, j, k, 7), PosForCellVertex(i, j, k, 4), ValueForCellVertex(i, j, k, 7), ValueForCellVertex(i, j, k, 4), ISOLEVEL, vertList[7]);
  if (0!=(edgeIndex & 256))
      VertexInterp(PosForCellVertex(i, j, k, 0), PosForCellVertex(i, j, k, 4), ValueForCellVertex(i, j, k, 0), ValueForCellVertex(i, j, k, 4), ISOLEVEL, vertList[8]);
  if (0!=(edgeIndex & 512))
      VertexInterp(PosForCellVertex(i, j, k, 1), PosForCellVertex(i, j, k, 5), ValueForCellVertex(i, j, k, 1), ValueForCellVertex(i, j, k, 5), ISOLEVEL, vertList[9]);
  if (0!=(edgeIndex & 1024))
      VertexInterp(PosForCellVertex(i, j, k, 2), PosForCellVertex(i, j, k, 6), ValueForCellVertex(i, j, k, 2), ValueForCellVertex(i, j, k, 6), ISOLEVEL, vertList[10]);
  if (0!=(edgeIndex & 2048))
      VertexInterp(PosForCellVertex(i, j, k, 3), PosForCellVertex(i, j, k, 7), ValueForCellVertex(i, j, k, 3), ValueForCellVertex(i, j, k, 7), ISOLEVEL, vertList[11]);

  // Check in table how many tris we need to create. TRI_TABLE is an array of arrays that is "-1" terminated //<>//
  for (i=0; TRI_TABLE[cubeindex][i] != -1; i+=3) {
    //    println("i : " + i); 
    //    println("cube : " + cubeindex);
    //    println("TRI_TABLE[cubeindex][i  ] : " + TRI_TABLE[cubeindex][i  ]); 
    final int i0 = TRI_TABLE[cubeindex][i  ];
    final int i1 = TRI_TABLE[cubeindex][i+1];
    final int i2 = TRI_TABLE[cubeindex][i+2];

    final PVector v0 = vertList[ i0 ];
    final PVector v1 = vertList[ i1 ];
    final PVector v2 = vertList[ i2 ];
    
    // append new triangle to model
    model.vertex( v0.x, v0.y, v0.z, 0,0 );
    model.vertex( v1.x, v1.y, v1.z, 0,0 );
    model.vertex( v2.x, v2.y, v2.z, 0,0 );
  }
}

void animateLevel(float dt) {
//  // animate iso level
  ISOLEVEL += dt*dLevel;
  if (ISOLEVEL>60 || ISOLEVEL <40 ) {
    dLevel *= -1;
    ISOLEVEL += dt*dLevel;
  }
}

float prevTime=0;

PShape createModel() {
  float currTime = millis();
  animateLevel( currTime-prevTime );
  prevTime= currTime;
  
  PShape model = createShape();
  model.beginShape(TRIANGLES); 
  model.rotate(PI/2, 1, 0, 0); // xy plane at bottom, z going up
  model.translate(-GRID_COUNT*CELL_WIDTH*0.5, -GRID_COUNT*CELL_WIDTH*0.5, -GRID_COUNT*CELL_WIDTH*0.5); // centered
  model.fill(0, 255, 0);   
  model.noStroke();

//  model.vertex(100, 100, 0);
//  model.vertex(200, 100, 0);
//  model.vertex(100, 200, 0); 

  for (int k=0; k<=GRID_COUNT-2; ++k) {
    for (int j=0; j<=GRID_COUNT-2; ++j) {
      for (int i=0; i<=GRID_COUNT-2; ++i) {
        addTriangles(i, j, k, model);
      }
    }
  }


  model.endShape();    
  return model;
}
