import mqtt.*;
import controlP5.*;
import java.util.*;


MQTTClient myClient;
ControlP5 cp5;
RadioButton scene;
Chimes myChimes;

import ddf.minim.*;
Minim minim;

// variables for MQTT
String broker   = "tcp://localhost:1883";
String publishTopic    = "/feeds/touch";
String subscribeTopic    = "/feeds/motor";

// GUI variables
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

//--------------------------------------------------------
// setup
//--------------------------------------------------------
void setup()
{
  //------------window, fonts, and images-----------------
  size(850, 700);
  noStroke();
  font = createFont("Avenir-Book-48.vlw", 32);
  textFont(font);

  // load image
  figure1 = loadShape("dancer1.svg");
  figure2 = loadShape("dancer2.svg");

  //------------audio playback-----------------
  minim = new Minim(this);
  myChimes = new Chimes(minim);

  //------------radio buttons-----------------
  cp5 = new ControlP5(this);
  // scene
  scene = cp5.addRadioButton("scene")
    .setPosition(300, 50)
    .setSize(20, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(50))
    .setItemsPerRow(5)
    .setSpacingColumn(50)
    .addItem("scene 1", 1)
    .addItem("scene 2", 2)
    .addItem("scene 3", 3)
    ;

  for (Toggle t : scene.getItems()) {
    t.getCaptionLabel().setColorBackground(color(255, 80));
    t.getCaptionLabel().getStyle().moveMargin(-7, 0, 0, -3);
    t.getCaptionLabel().getStyle().movePadding(7, 0, 0, 3);
    t.getCaptionLabel().getStyle().backgroundWidth = 45;
    t.getCaptionLabel().getStyle().backgroundHeight = 13;
  }


  //------------MQTT-----------------
  // create client
  myClient = new MQTTClient(this);

  // connect to broker
  myClient.connect(broker, "processing");

  // subscribe to feeds
  myClient.subscribe("/example");
}

//--------------------------------------------------------
// draw
//--------------------------------------------------------
void draw() {
  background(#BEEE62);

  // left dancer
  fill(#3C6E71);
  rect(0, 120, width*.45, 400);
  shape(figure1, 100, 65, figure1.width*1.25, figure1.height*1.25);
  fill(#BEEE62);
  text("Tara", width*0.45-80, 510);

  text("Q", width*0.17, 150); //tickle trigger

  text("z", width*0.3, 170); // chime triggers
  text("x", width*0.31, 200);
  text("c", width*0.32, 230);
  text("v", width*0.33, 260);
  text("b", width*0.34, 290);
  text("n", width*0.35, 320);
  text("m", width*0.36, 350);

  // right dancer
  fill(#70AE6E);
  rect(width*.55, 120, width*.45, 400);
  shape(figure2, width-figure2.width-135, 65, figure2.width*1.25, figure2.height*1.25);
  fill(#BEEE62);
  text("Phoebe", width*0.55+10, 510);
  text("P", width*0.80, 150); // tickle trigger

  text("l", width*0.69, 170); // chime triggers
  text("k", width*0.67, 200); 
  text("j", width*0.65, 230); 
  text("h", width*0.63, 260); 
  text("g", width*0.61, 290); 


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

//--------------------------------------------------------
// controlEvent
//--------------------------------------------------------
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(scene)) {
    println("got an event from "+theEvent.getName()+": " + (int)theEvent.getValue() + " ");
    switch ((int)theEvent.getValue()) {
    case 1:
      myChimes.setScene(1);
      break;
    case 2:
      myChimes.setScene(2);
      break;
    case 3:
      myChimes.setScene(3);
      break;
    }
  }
}

//--------------------------------------------------------
// messageReceived
//--------------------------------------------------------
void messageReceived(String topic, byte[] payload) {
  println("new message: " + topic + " - " + new String(payload));

  // phoebe shoulder touched
  if (topic.equals("/htb/sensor/phoebe/shoulder/")) {
    println("phoebe shoulder sensor triggered");
    shoulderTouched = true;
    shoulderTime = millis();
    myChimes.playChime(1);

    // trigger the hip
    myClient.publish("/htb/actuator/tara/shoulder", "from the shoulder");
    println("tara shoulder actuator triggered hip");
  }

  // tara shoulder touched
  if (topic.equals("/htb/sensor/tara/shoulder/")) {
    hipTouched = true;
    hipTime = millis();
    println("tara shoulder sensor triggered");
    myChimes.playChime(11);

    // trigger the shoulder
    myClient.publish("/htb/actuator/phoebe/shoulder/", "from hip");
    println("phoebe shoulder actuator triggered");
  }
}

//--------------------------------------------------------
// updateTouchedFlags
//--------------------------------------------------------
void updateTouchedFlags() {
  if (shoulderTouched && (millis()-shoulderTime) > 500) {
    shoulderTouched = false;
  }
  if (hipTouched && (millis()-hipTime) > 500) {
    hipTouched = false;
  }
}

//--------------------------------------------------------
// keyPressed
//--------------------------------------------------------
void keyPressed() {
  switch (key) {
  case 'Q':
    myClient.publish("/htb/actuator/tara/shoulder/", "tickle");
    break;

  case 'P':
    myClient.publish("/htb/actuator/phoebe/shoulder/", "tickle");
    break;

    // dancer 1
  case 'z':
    myChimes.playChime(0);
    break;
  case 'x':
    myChimes.playChime(1);
    break;
  case 'c':
    myChimes.playChime(2);
    break;
  case 'v':
    myChimes.playChime(3);
    break;
  case 'b':
    myChimes.playChime(4);
    break;
  case 'n':
    myChimes.playChime(5);
    break;
  case 'm':
    myChimes.playChime(6);
    break;

    // dancer 2 
  case 'l':
    myChimes.playChime(7);
    break;
  case 'k':
    myChimes.playChime(8);
    break;
  case 'j':
    myChimes.playChime(9);
    break;
  case 'h':
    myChimes.playChime(10);
    break;
  case 'g':
    myChimes.playChime(11);
    break;
  }
}

//--------------------------------------------------------
// mouseClicked
//--------------------------------------------------------
void mouseClicked() {
  /* // if clicked on shoulder square
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
   }*/
}