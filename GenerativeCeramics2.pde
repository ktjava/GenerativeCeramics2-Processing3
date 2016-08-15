import oscP5.*;
import netP5.*;
import ddf.minim.*;

PFont font_en;

OscP5 osc;
NetAddress netAddr;

Minim minim;
AudioInput in;
float volumeIn, wheel_value=0.5;

float rotX, rotY, rotZ;
float lerp_count=0, time_count=0;

float uMin = -PI;
float uMax = PI;
int uCount = 10;
float vMin = -PI;
float vMax = PI;
int vCount = 10;

float key_vibration = 0.0;

boolean click_lect_visible = false;
int offsetX = 0, offsetY = 0, clickX=0, clickY=0, dragX=width/2, dragY=height, x = 0, y = 0, line_count=101, circle_count=101, circle_count_d=101, rect_count=0, rect_count_realtime=0, beat_count_realtime=0;
float rotationX = -0.5, rotationY = 0, targetRotationX = 0, targetRotationY = 0, clickRotationX, clickRotationY, scale = 200, bpm = -0.00901999, beat_count=0, shells_rate=1;

float[][] shells_property_array = {{-5200, 10, 100}, {-5200, 0.05, 100}, {-5200, 0.01, 100}, {-5200, 0.1, 100}, {-5200, 0.4, 100}, {-5200, 0.9, 100}, {-5200, 1, 100}, {-5200, 5, 100}, {-5200, 3, 100}, {-5200, 2, 100}};
PVector[][] points, points0, points1;

PVector Sphere(float u, float v) {
  v /= 2;
  v += HALF_PI;
  float x = 2 * sin(v) * sin(u);
  float y = 2 * cos(v);
  float z = 2 * sin(v) * cos(u);
  return new PVector(x, y, z);
}

PVector Tube(float u, float v, float r) {
  float x = r*sin(u);
  float y = v;
  float z = r*cos(u);
  return new PVector(x, y, z);
}

PVector SteinbachScrew(float u, float v) {
  float x = u * cos(v);
  float y = u * sin(v);
  float z = v * cos(u);
  return new PVector(x, y, z);
}

PVector Paraboloid(float u, float v) {
  float x = sqrt(v) * sin(u);
  float y = v;
  float z = sqrt(v) * cos(u);
  return new PVector(x, y, z);
}

void setup() {
  //fullScreen(P3D);
  size(1920, 1080, P3D);
  frameRate(60);
  blendMode(ADD);
  font_en = loadFont("TW-Kai-Plus-98_1-96.vlw");
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, 512);
  netAddr = new NetAddress("127.0.0.1", 57120);
  osc = new OscP5(this, 7000);
  osc.send(new OscMessage("/noteon"), netAddr);
}

void draw() {

  background(map(mouseX, 0, width, 0, 2), 2, 0.1);

  volumeIn = map(in.left.level(), 0, 0.5, 0, 10);

  //Material Settings
  colorMode(RGB, 255);
  lightFalloff(2.0, 0.01, 100.0);
  lightSpecular(255, 255, 255);
  directionalLight(255, 240, 240, 1, 1, -1);
  pointLight(255, 0, 0, mouseX, mouseY, 0);
  ambient(0, 255, 0);
  emissive(255, 0, 0);
  shininess(255);
  specular(255, 255, 255);

  //Display Shells
  for (int shells_id=0; shells_id<5; ++shells_id) {

    //3D Object
    pushMatrix();

    //translate Settings
    translate(width*0.4, height*0.5, shells_property_array[shells_id][0]);
    rotateX(-0.5);
    rotateY(rotationX/(wheel_value*shells_id));
    rotationX += 0.01;
    scale(scale);
    for (int shell_count=0; shell_count<shells_property_array[shells_id][2]; ++shell_count) {
      //UV - XYZ Coordinates Transformation (Sphere & Tube)
      float u, v;
      points0 = new PVector[vCount+1][uCount+1];
      for (int iv = 0; iv <= vCount; iv++) {
        for (int iu = 0; iu <= uCount; iu++) {
          u = map(iu, 0, uCount, uMin, uMax);
          v = map(iv, 0, vCount, vMin, vMax);
          points0[iv][iu] = Sphere(u, v);
        }
      }
      points1 = new PVector[vCount+1][uCount+1];
      for (int iv = 0; iv <= vCount; iv++) {
        for (int iu = 0; iu <= uCount; iu++) {
          u = map(iu, 0, uCount, uMin, uMax);
          v = map(iv, 0, vCount, vMin, vMax);
          points1[iv][iu] = Tube(u, v, shells_property_array[shells_id][1]*shells_rate*shell_count);
        }
      }
      for (int iv = 0; iv <= vCount; iv++) {
        for (int iu = 0; iu <= uCount; iu++) {
          u = map(iu, 0, uCount, uMin, uMax);
          v = map(iv, 0, vCount, vMin, vMax);
          points0[iv][iu].lerp(points1[iv][iu], 0.5*map(dragY, height, 0, 0, 0.001)*sin(lerp_count)+0.4);
        }
      }
      for (int iv = 0; iv <= vCount; iv++) {
        for (int iu = 0; iu <= uCount; iu++) {
          u = map(iu, 0, uCount, uMin, uMax);
          v = map(iv, 0, vCount, vMin, vMax);
          points1[iv][iu] = SteinbachScrew(u, v);
        }
      }
      for (int iv = 0; iv <= vCount; iv++) {
        for (int iu = 0; iu <= uCount; iu++) {
          u = map(iu, 0, uCount, uMin, uMax);
          v = map(iv, 0, vCount, vMin, vMax);
          points0[iv][iu].lerp(points1[iv][iu], 0.6*map(dragY, height, 0, 0, 0.001)*sin(lerp_count)+0.4);
        }
      }
      if(shell_count<=0){
      for (int iv = 0; iv <= vCount; iv++) {
        for (int iu = 0; iu <= uCount; iu++) {
          u = map(iu, 0, uCount, uMin, uMax);
          v = map(iv, 0, vCount, vMin, vMax);
          points1[iv][iu] = Tube(u, v, 0.5);
        }
      }
      for (int iv = 0; iv <= vCount; iv++) {
        for (int iu = 0; iu <= uCount; iu++) {
          u = map(iu, 0, uCount, uMin, uMax);
          v = map(iv, 0, vCount, vMin, vMax);
          points0[iv][iu].lerp(points1[iv][iu], 0.6*map(dragY, height, 0, 0, 10)+0.4);
        }
      }
      }
      lerp_count += shells_id*bpm*TWO_PI/360;
      if (lerp_count>=TWO_PI) {
        lerp_count=0;
      }
      points = points0;

      //Displey Meshes
      noStroke();
      int iuMax = uCount-1, ivMax = vCount-1;
      for (int iv = 0; iv <= ivMax; iv++) {
        for (int iu = 0; iu <= iuMax; iu++) {
          float r1 = (bpm + volumeIn + 0.1 * key_vibration) * random(-1, 1);
          float r2 = (bpm + volumeIn + 0.1 * key_vibration) * random(-1, 1);
          float r3 = (bpm + volumeIn + 0.1 * key_vibration) * random(-1, 1);
          colorMode(HSB, 2);
          fill(map(mouseX, 0, width, 0, 2), 2, 2, 0.2);
          beginShape(TRIANGLES);
          vertex(points[iv][iu].x+r1, points[iv][iu].y+r2, points[iv][iu].z+r3);
          vertex(points[iv+1][iu+1].x+r1, points[iv+1][iu+1].y+r2, points[iv+1][iu+1].z+r3);
          vertex(points[iv+1][iu].x+r1, points[iv+1][iu].y+r2, points[iv+1][iu].z+r3);
          endShape();
          beginShape(TRIANGLES);
          vertex(points[iv+1][iu+1].x+r1, points[iv+1][iu+1].y+r2, points[iv+1][iu+1].z+r3);
          vertex(points[iv][iu].x+r1, points[iv][iu].y+r2, points[iv][iu].z+r3);
          vertex(points[iv][iu+1].x+r1, points[iv][iu+1].y+r2, points[iv][iu+1].z+r3);
          endShape();
        }
      }
    }
    popMatrix();
  }

  //Display Shells
  for (int shells_id=0; shells_id<4; ++shells_id) {

    //3D Object
    pushMatrix();

    //translate Settings
    translate(width*0.4, height*0.5, shells_property_array[shells_id][0]);
    rotateX(-0.5);
    rotateY(rotationX/wheel_value);
    rotationX += 0.01;
    scale(scale);
    for (int shell_count=0; shell_count<shells_property_array[shells_id][2]; ++shell_count) {
      //UV - XYZ Coordinates Transformation (Sphere & Tube)
      float u, v;
      points0 = new PVector[vCount+1][uCount+1];
      for (int iv = 0; iv <= vCount; iv++) {
        for (int iu = 0; iu <= uCount; iu++) {
          u = map(iu, 0, uCount, uMin, uMax);
          v = map(iv, 0, vCount, vMin, vMax);
          points0[iv][iu] = Sphere(u, v);
        }
      }
      points1 = new PVector[vCount+1][uCount+1];
      for (int iv = 0; iv <= vCount; iv++) {
        for (int iu = 0; iu <= uCount; iu++) {
          u = map(iu, 0, uCount, uMin, uMax);
          v = map(iv, 0, vCount, vMin, vMax);
          points1[iv][iu] = Tube(u, v, shells_property_array[shells_id][1]*shells_rate*shell_count);
        }
      }
      for (int iv = 0; iv <= vCount; iv++) {
        for (int iu = 0; iu <= uCount; iu++) {
          u = map(iu, 0, uCount, uMin, uMax);
          v = map(iv, 0, vCount, vMin, vMax);
          points0[iv][iu].lerp(points1[iv][iu], 0.5*map(dragY, height, 0, 0, 3)*sin(lerp_count)+0.4);
        }
      }
      for (int iv = 0; iv <= vCount; iv++) {
        for (int iu = 0; iu <= uCount; iu++) {
          u = map(iu, 0, uCount, uMin, uMax);
          v = map(iv, 0, vCount, vMin, vMax);
          points1[iv][iu] = SteinbachScrew(u, v);
        }
      }
      for (int iv = 0; iv <= vCount; iv++) {
        for (int iu = 0; iu <= uCount; iu++) {
          u = map(iu, 0, uCount, uMin, uMax);
          v = map(iv, 0, vCount, vMin, vMax);
          points0[iv][iu].lerp(points1[iv][iu], 0.6*map(dragY, height, 0, 0, 3)*sin(lerp_count)+0.4);
        }
      }
      lerp_count += 0.0000901*bpm*TWO_PI/360;
      if (lerp_count>=TWO_PI) {
        lerp_count=0;
      }
      points = points0;

      //Displey Meshes
      noStroke();
      int iuMax = uCount-1, ivMax = vCount-1;
      for (int iv = 0; iv <= ivMax; iv++) {
        for (int iu = 0; iu <= iuMax; iu++) {
          float r1 = (bpm + volumeIn + 0.1 * key_vibration) * random(-1, 1);
          float r2 = (bpm + volumeIn + 0.1 * key_vibration) * random(-1, 1);
          float r3 = (bpm + volumeIn + 0.1 * key_vibration) * random(-1, 1);
          colorMode(HSB, 2);
          fill(map(mouseX, 0, width, 0, 2), 2, 2, 0.2);
          beginShape(TRIANGLES);
          vertex(points[iv][iu].x+r1, points[iv][iu].y+r2, points[iv][iu].z+r3);
          vertex(points[iv+1][iu+1].x+r1, points[iv+1][iu+1].y+r2, points[iv+1][iu+1].z+r3);
          vertex(points[iv+1][iu].x+r1, points[iv+1][iu].y+r2, points[iv+1][iu].z+r3);
          endShape();
          beginShape(TRIANGLES);
          vertex(points[iv+1][iu+1].x+r1, points[iv+1][iu+1].y+r2, points[iv+1][iu+1].z+r3);
          vertex(points[iv][iu].x+r1, points[iv][iu].y+r2, points[iv][iu].z+r3);
          vertex(points[iv][iu+1].x+r1, points[iv][iu+1].y+r2, points[iv][iu+1].z+r3);
          endShape();
        }
      }
    }
    popMatrix();
  }

  fill(map(bpm, -1, 1, 0, 2), 2, 2, 1);

  //2D Text
  pushMatrix();
  float r1 = volumeIn * bpm * random(-1, 1);
  float r2 = volumeIn * bpm * random(-1, 1);
  colorMode(HSB, 2);
  textSize(96);
  textFont(font_en);
  text("GenerativeCeramics", 1200+map(mouseX, 0, width, 0, 200)+100*r1, 540+100*r2);
  textSize(60);
  text("GenerativeCeramics", 1200+map(mouseX, 0, width, 0, 100)+100*r1, 540+100*r2);
  textSize(48);
  text("GenerativeCeramics", 1200+map(mouseX, 0, width, 0, 50)+100*r1, 540+100*r2);
  fill(map(bpm, -1, 1, 0, 2), 2, 2, 1);
  popMatrix();

  pushMatrix();
  if (keyPressed == false && line_count<=100) {
    stroke(map(bpm, -1, 1, 0, 2), 2, line_count*2/15);
    line(0, y - line_count, width, y - line_count);
    line(0, y + line_count, width, y + line_count);
    line(x - line_count, 0, x - line_count, height);
    line(x + line_count, 0, x + line_count, height);
    rectMode(CENTER);
    rect(x, y, 300+20*bpm*circle_count, 300+20*bpm*circle_count);
    ++line_count;
  }
  if (mousePressed == false && circle_count<=100) {
    stroke(map(bpm, -1, 1, 0, 2), 2, line_count*2/15);
    fill(map(bpm, -1, 1, 0, 2), 2, 2, 1);
    line(0, clickY - circle_count, width, clickY - circle_count);
    line(0, clickY + circle_count, width, clickY + circle_count);
    line(clickX - circle_count, 0, clickX - circle_count, height);
    line(clickX + circle_count, 0, clickX + circle_count, height);
    ellipseMode(CENTER);
    ellipse(clickX, clickY, 300+20*bpm*circle_count, 300+20*bpm*circle_count);
    ++circle_count;
  }
  if (mousePressed == false && circle_count_d<=100) {
    stroke(map(bpm, -1, 1, 0, 2), 2, line_count*2/15);
    fill(map(bpm, -1, 1, 0, 2), 2, 2, 1);
    line(0, dragY - circle_count_d, width, dragY - circle_count_d);
    line(0, dragY + circle_count_d, width, dragY + circle_count_d);
    line(dragX - circle_count_d, 0, dragX - circle_count_d, height);
    line(dragX + circle_count_d, 0, dragX + circle_count_d, height);
    ellipseMode(CENTER);
    ellipse(dragX, dragY, 300+20*bpm*circle_count, 300+20*bpm*circle_count);
    ++circle_count_d;
  }
  popMatrix();

  stroke(map(bpm, -1, 1, 0, 2), 2, 2);

  rectMode(CORNER);
  rect(rect_count_realtime*width/4+100, 3.5*height/4, 300, 30);
  if (beat_count_realtime>=60) {
    beat_count_realtime=0;
    ++rect_count_realtime;
    if (rect_count_realtime>=4) {
      rect_count_realtime=0;
    }
  }
  ++beat_count_realtime;

  //Mouse Interaction
  if (keyPressed) {
    x = width/2;
    y = height/2;
    stroke(map(bpm, -1, 1, 0, 2), 2, 2);
    line(0, y, width, y);
    line(x, 0, x, height);
    rectMode(CENTER);
    rect(x, y, 300+20*bpm*circle_count, 300+20*bpm*circle_count);
    key_vibration = 1;
    shells_rate = 0;
    line_count = 0;
  }
  if (mousePressed) {
    dragX = mouseX; 
    dragY = mouseY;
    stroke(map(bpm, -1, 1, 0, 2), 2, 2);
    line(0, mouseY, width, mouseY);
    line(mouseX, 0, mouseX, height);
    line(clickX, clickY, mouseX, mouseY);
    ellipseMode(CENTER);
    ellipse(mouseX, mouseY, 300, 300);
    stroke(map(bpm, -1, 1, 0, 2), 2, 2);
    fill(map(bpm, -1, 1, 0, 2), 2, 2, 1);
    line(0, clickY - circle_count, width, clickY - circle_count);
    line(0, clickY + circle_count, width, clickY + circle_count);
    line(clickX - circle_count, 0, clickX - circle_count, height);
    line(clickX + circle_count, 0, clickX + circle_count, height);
    ellipseMode(CENTER);
    ellipse(clickX, clickY, 300+20*bpm*circle_count, 300+20*bpm*circle_count);
    circle_count = 0;
    OscMessage msg = new OscMessage("/amp");
    msg.add(map(dragY, height, 0, 0, 3));
    osc.send(msg, netAddr);
  }
  if (shells_rate<=10) {
    shells_rate+=0.01;
  }

  time_count += 0.001;
}

void keyReleased() {
  OscMessage msg = new OscMessage("/chord_start");
  msg.add(key);
  osc.send(msg, netAddr);
}

void mousePressed() {
  clickX = mouseX;
  clickY = mouseY;
  clickRotationX = rotationX;
  clickRotationY = rotationY;
  circle_count = 0;
}

void mouseReleased() {
  dragX = mouseX;
  dragY = mouseY;
  circle_count_d = 0;
}

void mouseWheel(MouseEvent event) {
  wheel_value += 0.01*event.getCount();
}

void stop() {
  in.close();
  minim.stop();
}