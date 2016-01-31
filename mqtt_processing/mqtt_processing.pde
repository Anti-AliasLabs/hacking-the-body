import mqtt.*;

MQTTClient myClient;

String broker   = "tcp://localhost:1883";
String publishTopic    = "/feeds/touch";
String subscribeTopic    = "/feeds/motor";

PFont font;
PShape figure1, figure2;

int shoulderX = 50;
int shoulderY = 50;
int hipX = 300;
int hipY = 50;
int squareSize = 200;

boolean shoulderTouched = false;
boolean hipTouched = false;

int shoulderTime = 0;
int hipTime = 0;

void setup()
{
  // setup window and font
  size(850, 700);
  noStroke();
  font = createFont("Avenir-Book-48.vlw", 32);
  textFont(font);
  
  // load image
  figure1 = loadShape("dancer1.svg");
  figure2 = loadShape("dancer2.svg");
  
  // create client
  myClient = new MQTTClient(this);

  // connect to broker
  myClient.connect(broker, "processing");

  // subscribe to feeds
  myClient.subscribe("/example");
}

void draw() {
  background(#BEEE62);
  
  // left dancer
  fill(#3C6E71);
  rect(0, 120, width*.45, 400);
  shape(figure1, 30, 65, figure1.width*1.25, figure1.height*1.25);
  
    // right dancer
  fill(#70AE6E);
  rect(width*.55, 120, width*.45, 400);
  shape(figure2, width-figure2.width-65, 65, figure2.width*1.25, figure2.height*1.25);

  // if shoulder touched
  /*if (shoulderTouched) {
    // white square
    fill(255);
  } else {
    // else purple square
    fill(101, 65, 188);
  }
  rect(shoulderX, shoulderY, squareSize, squareSize);
  fill(20);
  text("shoulder", 80, 150);*/

  // if hip touched 
  /*if ( hipTouched) {
    // white square
    fill(255);
  } else {
    // yellow square
    fill(240, 178, 85);
  }
  rect(hipX, hipY, squareSize, squareSize);
  fill(50);
  text("hip", 370, 150);*/

  updateTouchedFlags();
  
  
  // bottom banner
  fill(#483C46);
   rect(width*0.25, height-100, width*0.75, 50); 
   fill(#BEEE62);
   text("hacking the body", width*0.25+10, height-64);
}

void keyPressed() {
  if (key=='z')
    myClient.publish("/feeds/shoulder/motor", "buzz");

  if (key=='x'){
    myClient.publish("/feeds/hip/motor", "buzz");
    println("hip");
  }
}

void messageReceived(String topic, byte[] payload) {
  println("new message: " + topic + " - " + new String(payload));

  // shoulder touched
  if (topic.equals("/feeds/shoulder/touch")) {
    shoulderTouched = true;
    shoulderTime = millis();
    
    // trigger the hip
    myClient.publish("/feeds/hip/motor", "from the shoulder");
    println("shoulder triggered hip");
  }

  // hip touched
  if (topic.equals("/feeds/hip/touch")) {
    hipTouched = true;
    hipTime = millis();
    
    // trigger the shoulder
    myClient.publish("/feeds/shoulder/motor", "from hip");
    println("hip triggered shoulder");
  }
}

void updateTouchedFlags() {
  if (shoulderTouched && (millis()-shoulderTime) > 500) {
    shoulderTouched = false;
  }
  if (hipTouched && (millis()-hipTime) > 500) {
    hipTouched = false;
  }
}

void mouseClicked() {
  // if clicked on shoulder square
  if (mouseX > shoulderX &&
    mouseX < shoulderX+squareSize &&
    mouseY > shoulderY &&
    mouseY < shoulderY+squareSize) {
    // publish motor message for shoulder
    println("shoulder");
    myClient.publish("/feeds/shoulder/motor", "buzz");
  }

  // if clicked on hip square
  if (mouseX > hipX &&
    mouseX < hipX+squareSize &&
    mouseY > hipY &&
    mouseY < hipY+squareSize) {
    // publish motor message for hip
    println("hip");
    myClient.publish("/feeds/hip/motor", "world");
  }
}