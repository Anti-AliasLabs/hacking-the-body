import mqtt.*;
import controlP5.*;
import java.util.*;

MQTTClient myClient;
ControlP5 cp5;
RadioButton tickle1, tickle2, hipLeft1, hipLeft2, hipRight1, hipRight2;

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

  //------------radio buttons-----------------
  cp5 = new ControlP5(this);
  // tickle1
  tickle1 = cp5.addRadioButton("tickle1")
    .setPosition(100, 150)
    .setSize(20, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(5)
    .setSpacingColumn(50)
    .addItem("hip", 1)
    .addItem("shoulder", 2)
    ;

  for (Toggle t : tickle1.getItems()) {
    t.getCaptionLabel().setColorBackground(color(255, 80));
    t.getCaptionLabel().getStyle().moveMargin(-7, 0, 0, -3);
    t.getCaptionLabel().getStyle().movePadding(7, 0, 0, 3);
    t.getCaptionLabel().getStyle().backgroundWidth = 45;
    t.getCaptionLabel().getStyle().backgroundHeight = 13;
  }

  // tickle2
  tickle2 = cp5.addRadioButton("tickle2")
    .setPosition(600, 150)
    .setSize(20, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(5)
    .setSpacingColumn(50)
    .addItem("hip ", 1)
    .addItem("shoulder ", 2)
    ;

  for (Toggle t : tickle2.getItems()) {
    t.getCaptionLabel().setColorBackground(color(255, 80));
    t.getCaptionLabel().getStyle().moveMargin(-7, 0, 0, -3);
    t.getCaptionLabel().getStyle().movePadding(7, 0, 0, 3);
    t.getCaptionLabel().getStyle().backgroundWidth = 45;
    t.getCaptionLabel().getStyle().backgroundHeight = 13;
  }

  // hipLeft1
  hipLeft1 = cp5.addRadioButton("hipLeft1")
    .setPosition(160, 260)
    .setSize(20, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(5)
    .setSpacingColumn(50)
    .addItem("hip  ", 1)
    .addItem("shoulder  ", 2)
    ;

  for (Toggle t : hipLeft1.getItems()) {
    t.getCaptionLabel().setColorBackground(color(255, 80));
    t.getCaptionLabel().getStyle().moveMargin(-7, 0, 0, -3);
    t.getCaptionLabel().getStyle().movePadding(7, 0, 0, 3);
    t.getCaptionLabel().getStyle().backgroundWidth = 45;
    t.getCaptionLabel().getStyle().backgroundHeight = 13;
  }

  // hipLeft2
  hipLeft2 = cp5.addRadioButton("hipLeft2")
    .setPosition(680, 290)
    .setSize(20, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(5)
    .setSpacingColumn(50)
    .addItem("hip   ", 1)
    .addItem("shoulder   ", 2)
    ;

  for (Toggle t : hipLeft2.getItems()) {
    t.getCaptionLabel().setColorBackground(color(255, 80));
    t.getCaptionLabel().getStyle().moveMargin(-7, 0, 0, -3);
    t.getCaptionLabel().getStyle().movePadding(7, 0, 0, 3);
    t.getCaptionLabel().getStyle().backgroundWidth = 45;
    t.getCaptionLabel().getStyle().backgroundHeight = 13;
  }

  // hipRight1
  hipRight1 = cp5.addRadioButton("hipRight1")
    .setPosition(30, 290)
    .setSize(20, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(5)
    .setSpacingColumn(50)
    .addItem("hip    ", 1)
    .addItem("shoulder    ", 2)
    ;

  for (Toggle t : hipRight1.getItems()) {
    t.getCaptionLabel().setColorBackground(color(255, 80));
    t.getCaptionLabel().getStyle().moveMargin(-7, 0, 0, -3);
    t.getCaptionLabel().getStyle().movePadding(7, 0, 0, 3);
    t.getCaptionLabel().getStyle().backgroundWidth = 45;
    t.getCaptionLabel().getStyle().backgroundHeight = 13;
  }

  // hipRight2
  hipRight2 = cp5.addRadioButton("hipRight2")
    .setPosition(540, 260)
    .setSize(20, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(5)
    .setSpacingColumn(50)
    .addItem("hip     ", 1)
    .addItem("shoulder     ", 2)
    ;

  for (Toggle t : hipRight2.getItems()) {
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
  text("1", width*0.45-30, 510);

  // right dancer
  fill(#70AE6E);
  rect(width*.55, 120, width*.45, 400);
  shape(figure2, width-figure2.width-135, 65, figure2.width*1.25, figure2.height*1.25);
  fill(#BEEE62);
  text("2", width*0.55+10, 510);

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
  //if (theEvent.isFrom(tickle1)) {
  print("got an event from "+theEvent.getName()+": " + (int)theEvent.getValue() + " ");
  switch ((int)theEvent.getValue()) {
  case 1:
    println("hip");
    break;
  case 2:
    println("shoulder");
    break;
  }
  //}
}

//--------------------------------------------------------
// messageReceived
//--------------------------------------------------------
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
  if (key=='z')
    myClient.publish("/feeds/shoulder/motor", "buzz");

  if (key=='x') {
    myClient.publish("/feeds/hip/motor", "buzz");
    println("hip");
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