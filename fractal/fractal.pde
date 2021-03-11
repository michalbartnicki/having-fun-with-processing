double xMin = -2.0;
double xMax = 1.4;
double yMin = -1.2;
double yMax = 1.2;
  
PImage currentBuffer;
PImage backBuffer;

void setup() { 
  size(800, 800);
  currentBuffer = createImage(width, height, ARGB);
  backBuffer = createImage(width, height, ARGB);
  
  recalculate();
}

void recalculate() {
  double unitX = (xMax - xMin)/width;
  double unitY = (yMax - yMin)/height;
  
  Imaginary Z0 = new Imaginary(0.0, 0.0);
  Imaginary C0 = new Imaginary(xMin, yMax);
  Imaginary C = C0;
  
  //Imaginary Z = sumImaginary(multiplyImaginary(Z0, Z0), C); 

  for (int y=0; y<currentBuffer.height; y++) {
    C = new Imaginary(C0.re, C.im);
    
    for (int x=0; x<currentBuffer.width; x++) {
      //float it = convergence(Z0, C) / (float)MaxIterations;
      int it = convergence(Z0, C);
      color c = generateColor(it);
      //int r = (int)round(255-it);
      //int g = (int)round(255-it);
      //int b = (int)round(255-it);
      //color c = color(r, g, b);  
      currentBuffer.set(x, y, c);
      
      C = new Imaginary(C.re + unitX, C.im);
    }
    
    C = new Imaginary(C.re, C.im - unitY);
  }
}

color generateColor(int it) {
  color[] colors = new color[6];
  colors[0] = color(156, 79, 150);
  colors[1] = color(255, 99, 85);
  colors[2] = color(251, 169, 73);
  colors[3] = color(250, 228, 66);
  colors[4] = color(139, 212, 72);
  colors[5] = color(42, 168, 242);
  
  if (it < 0.1 * MaxIterations) {
    it = it * 10;  
  }
  
  float i = (float)translate(it, 0, MaxIterations, 0, 5);
  color c1 = colors[(int)floor((float)i)];
  color c2 = colors[(int)ceil((float)i)]; 
  
  float w1 = i - floor(i) + 1;
  
  float r1 = red(c1);
  float g1 = green(c1);
  float b1 = blue(c1);
  float r2 = red(c2);
  float g2 = green(c2);
  float b2 = blue(c2);
  
  return color(
    (float)translate(f(it), 0, MaxIterations, r1, r2),
    (float)translate(f(it), 0, MaxIterations, g1, g2), 
    (float)translate(f(it), 0, MaxIterations, b1, b2)
  );  
}

float f(float x) {
  return 1/(x*x);
}

void draw() {
 image(currentBuffer, 0, 0); 
  
  //text("xy:" + mouseX + ", " + mouseY,mouseX,mouseY); 
  //text("ixy:" + fromScreenH(mouseX) + ", " + fromScreenV(mouseY),mouseX,mouseY+10); 
  
  Box box = boxCenterPoint(mouseX, mouseY, width/8, height/8);
  stroke(255, 0, 255);
  noFill();
  box.draw();
    
}

double fromScreenH(double value) {
  return translate(value, 0, width, xMin, xMax);  
}

double fromScreenV(double value) {
  return translate(value, 0, height, yMin, yMax);
}

double toScreenH(double value) {
  return translate(value, xMin, xMax, 0, width);
}

double toScreenV(double value) {
  return translate(value, yMin, yMax, 0, height);
}

double translate(double srcValue, double srcMin, double srcMax, double dstMin, double dstMax) {
  return ( (srcValue - srcMin) * (dstMax - dstMin) ) / (srcMax - srcMin) + dstMin;  
}

void mouseClicked() {
  double h = (xMax - xMin);
  double v = (yMax - yMin);
  
  xMin = fromScreenH(mouseX) - h/8;
  xMax = fromScreenH(mouseX) + h/8;
  
  yMin = fromScreenV(height - mouseY) - v/8;
  yMax = fromScreenV(height - mouseY) + v/8;
    
  recalculate();
}

int MaxIterations = 255;
int convergence(Imaginary Z, Imaginary C) {
  int i;
  Imaginary Zn;
  for (i=0; i<MaxIterations; i++) {
      Zn = sumImaginary(multiplyImaginary(Z, Z), C);
      if (absImaginary(Zn) >= 2) {
        break;
        //return 0;
      }
      Z = Zn;
  }
  
  return i;
}

class Imaginary {
  double re;
  double im;
  
  Imaginary(double re,  double im) {
    this.re = re;
    this.im = im;
  } 
}

Imaginary multiplyImaginary(Imaginary a, Imaginary b) {
  return new Imaginary(
    a.re * b.re - a.im * b.im,
    a.re * b.im + a.im * b.re
  );
}

Imaginary sumImaginary(Imaginary a, Imaginary b) {
  return new Imaginary(
    a.re + b.re,
    a.im + b.im
  );
}

double absImaginary(Imaginary a) {
 return sqrt((float)(a.re * a.re + a.im * a.im)); 
}

Box boxCenterPoint(double x, double y, double w, double h) {
  double w2 = w / 2;
  double h2 = h / 2;
  return new Box(x - w2, y - h2, w, h);
}

class Box {
  double x, y, w, h;
  
  Box(double x, double y, double w, double h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  void draw() {
     rect((float)x, (float)y, (float)w, (float)h); 
  }
}
