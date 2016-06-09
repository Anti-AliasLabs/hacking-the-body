/***************************************************

   Written by Becky Stewart
   June 2016

   Adapted from:
  Basic ESP8266 MQTT example in PubSub

 ****************************************************/
#include <ESP8266WiFi.h>
#include <PubSubClient.h>

#include "mpr121.h"
#include <Wire.h>


/************************* WiFi Access Point *********************************/
const char* ssid = "AWR-7200";
const char* password = "";
const char* mqtt_server = "192.168.1.3";


/****************************** Feeds ***************************************/
#define SENSOR_FEED     "/htb/sensor/tara/shoulder/"
#define ACTUATOR_FEED   "/htb/actuator/tara/shoulder/"


/*************************** Cap Sensing ************************************/
int irqpin = 2;  // Digital 2
boolean touchStates[12]; //to keep track of the previous touch states
int motorPin = 13;


/************************* Other Variables **************************/
WiFiClient espClient;
PubSubClient client(espClient);
long lastMsg = 0;
char msg[50];
int value = 0;


/*************************** Setup ************************************/

void setup() {
  Serial.begin(115200);
  pinMode(BUILTIN_LED, OUTPUT);     // Initialize the BUILTIN_LED pin as an outp

  // Connect to WiFi access point.
  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);

  // Set up MPR121
  pinMode(irqpin, INPUT);
  digitalWrite(irqpin, HIGH); //enable pullup resistor
  Wire.begin();

  mpr121_setup();

  // Set up motor
  pinMode(motorPin, OUTPUT);
  digitalWrite(motorPin, LOW);
}


/*************************** Loop ************************************/

uint32_t x = 0;

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  // initial testing
  long now = millis();
  if (now - lastMsg > 500) {
    lastMsg = now;
    ++value;
    //snprintf (msg, 75, "hello world #%ld", value);
    //Serial.print("Publish message: ");
    //Serial.println(msg);
    //client.publish(SENSOR_FEED, msg);
    readTouchInputs();
  }
}

/*************************** Set up wifi ************************************/
void setup_wifi() {

  delay(10);
  // We start by connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
  client.subscribe(ACTUATOR_FEED);
}

/*************************** Reconnect to wifi ************************************/
void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Attempt to connect
    if (client.connect("ESP8266Client")) {
      Serial.println("connected");
      // Once connected, publish an announcement...
      client.publish(SENSOR_FEED, "hello world");
      // ... and resubscribe
      client.subscribe(ACTUATOR_FEED);
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

/*************************** Callback for received messages ************************************/
void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();

  // Switch on the LED if an 1 was received as first character
  if ((char)payload[0] == '1') {
    digitalWrite(BUILTIN_LED, LOW);   // Turn the LED on (Note that LOW is the voltage level
    // but actually the LED is on; this is because
    // it is active low on the ESP-01)
  } else {
    digitalWrite(BUILTIN_LED, HIGH);  // Turn the LED off by making the voltage HIGH
  }

}

/*************************** Read Touch Interrupts ************************************/
void readTouchInputs() {
  if (!checkInterrupt()) {

    //read the touch state from the MPR121
    Wire.requestFrom(0x5A, 2);

    byte LSB = Wire.read();
    byte MSB = Wire.read();

    uint16_t touched = ((MSB << 8) | LSB); //16bits that make up the touch states

    int touchTriggered = 0;
    for (int i = 0; i < 12; i++) { // Check what electrodes were pressed
      if (touched & (1 << i)) {

        if (touchStates[i] == 0) {
          //pin i was just touched
          Serial.print("pin ");
          Serial.print(i);
          Serial.println(" was just touched");
          touchStates[i] = 1;

          // activate motor
          //triggerMotor();
          //Serial.println("motor triggered");
          if (client.connect("ESP8266Client")) {
            // Once connected, publish an announcement...
            char s[4];
            snprintf(s, 4,  "%d", i);
            client.publish(SENSOR_FEED, s);
            // ... and resubscribe
            //client.subscribe(ACTUATOR_FEED);
          } else {
            Serial.print("failed, rc=");
            Serial.print(client.state());
            //Serial.println(" try again in 5 seconds");
            // Wait 5 seconds before retrying
            //delay(5000);
          }
        }
      } else {
        if (touchStates[i] == 1) {
          Serial.print("pin ");
          Serial.print(i);
          Serial.println(" is no longer being touched");

          //pin i is no longer being touched
          touchStates[i] = 0;
        }
      }
    }
  }
}



/*************************** Set up MPR121 ************************************/
void mpr121_setup(void) {

  set_register(0x5A, ELE_CFG, 0x00);

  // Section A - Controls filtering when data is > baseline.
  set_register(0x5A, MHD_R, 0x01);
  set_register(0x5A, NHD_R, 0x01);
  set_register(0x5A, NCL_R, 0x00);
  set_register(0x5A, FDL_R, 0x00);

  // Section B - Controls filtering when data is < baseline.
  set_register(0x5A, MHD_F, 0x01);
  set_register(0x5A, NHD_F, 0x01);
  set_register(0x5A, NCL_F, 0xFF);
  set_register(0x5A, FDL_F, 0x02);

  // Section C - Sets touch and release thresholds for each electrode
  set_register(0x5A, ELE0_T, TOU_THRESH);
  set_register(0x5A, ELE0_R, REL_THRESH);

  set_register(0x5A, ELE1_T, TOU_THRESH);
  set_register(0x5A, ELE1_R, REL_THRESH);

  set_register(0x5A, ELE2_T, TOU_THRESH);
  set_register(0x5A, ELE2_R, REL_THRESH);

  set_register(0x5A, ELE3_T, TOU_THRESH);
  set_register(0x5A, ELE3_R, REL_THRESH);

  set_register(0x5A, ELE4_T, TOU_THRESH);
  set_register(0x5A, ELE4_R, REL_THRESH);

  set_register(0x5A, ELE5_T, TOU_THRESH);
  set_register(0x5A, ELE5_R, REL_THRESH);

  set_register(0x5A, ELE6_T, TOU_THRESH);
  set_register(0x5A, ELE6_R, REL_THRESH);

  set_register(0x5A, ELE7_T, TOU_THRESH);
  set_register(0x5A, ELE7_R, REL_THRESH);

  set_register(0x5A, ELE8_T, TOU_THRESH);
  set_register(0x5A, ELE8_R, REL_THRESH);

  set_register(0x5A, ELE9_T, TOU_THRESH);
  set_register(0x5A, ELE9_R, REL_THRESH);

  set_register(0x5A, ELE10_T, TOU_THRESH);
  set_register(0x5A, ELE10_R, REL_THRESH);

  set_register(0x5A, ELE11_T, TOU_THRESH);
  set_register(0x5A, ELE11_R, REL_THRESH);

  // Section D
  // Set the Filter Configuration
  // Set ESI2
  set_register(0x5A, FIL_CFG, 0x04);

  // Section E
  // Electrode Configuration
  // Set ELE_CFG to 0x00 to return to standby mode
  set_register(0x5A, ELE_CFG, 0x0C);  // Enables all 12 Electrodes


  // Section F
  // Enable Auto Config and auto Reconfig
  /*set_register(0x5A, ATO_CFG0, 0x0B);
    set_register(0x5A, ATO_CFGU, 0xC9);  // USL = (Vdd-0.7)/vdd*256 = 0xC9 @3.3V   set_register(0x5A, ATO_CFGL, 0x82);  // LSL = 0.65*USL = 0x82 @3.3V
    set_register(0x5A, ATO_CFGT, 0xB5);*/  // Target = 0.9*USL = 0xB5 @3.3V

  set_register(0x5A, ELE_CFG, 0x0C);

}

/*************************** Check interrupt on MPR121 ************************************/
boolean checkInterrupt(void) {
  return digitalRead(irqpin);
}


/*************************** Set register on MPR121 ************************************/
void set_register(int address, unsigned char r, unsigned char v) {
  Wire.beginTransmission(address);
  Wire.write(r);
  Wire.write(v);
  Wire.endTransmission();
}

/*************************** Trigger Motor ************************************/
void triggerMotor() {
  digitalWrite(motorPin, HIGH);
  Serial.println("motor on");
  delay(300);
  digitalWrite(motorPin, LOW);
}
