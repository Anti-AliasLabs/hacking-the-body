import mqtt.*;

MQTTClient myClient;

String broker   = "tcp://localhost:1883";
String publishTopic    = "/feeds/touch";
String subscribeTopic    = "/feeds/motor";

void setup()
{
  // create client
  myClient = new MQTTClient(this);

  // connect to broker
  myClient.connect(broker, "processing");

  // subscribe to feeds
  myClient.subscribe("/example");
}

void draw() {
}

void messageReceived(String topic, byte[] payload) {
  println("new message: " + topic + " - " + new String(payload));
}

void keyPressed() {
  myClient.publish("/hello", "world");
}