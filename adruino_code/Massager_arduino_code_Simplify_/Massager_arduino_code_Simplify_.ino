#include <SoftwareSerial.h>
#include <ArduinoJson.h>


SoftwareSerial mySerial(8, 9); // RX, TX
const int motor1pin1 = 3;
const int motor1pin2 = 4;
const int pwm = 5;
bool isPause =  false;
StaticJsonDocument<500> doc;

void setup() {

  HardwareSerial test = Serial;
  test.begin(9600);
  Serial.println ("BT is ready" );

  mySerial.begin(9600);
  //mySerial.println("Please select massaging mode?");

  pinMode(motor1pin1, OUTPUT);
  pinMode(motor1pin2, OUTPUT);
  pinMode(pwm, OUTPUT);

}

void loop() {


  digitalWrite(motor1pin1, LOW);              // motor stopped
  digitalWrite(motor1pin2, LOW);
  analogWrite(pwm, 0);
  delay (1000);
  mySerial.println ("{\"status\":\"WAITING\",\"remainingTime\":0}");
  Serial.println ("{\"status\":\"WAITING\",\"remainingTime\":0}");
  //Serial
  if (Serial.available() > 0) {
    String data = Serial.readStringUntil('#');
    ProcessData(data, false);
  }
  //bluetooth
  if (mySerial.available() > 0) {
    String data = mySerial.readStringUntil('#');
    ProcessData(data, true);
  }

}

void ProcessData(String data, bool isBluetooth) {
  //Serial.println (data);
  DecodeJson(data);

  for (int i = 0; i < doc.size(); i++) {
    // Serial.println ("***");
    //Serial.println (doc[i]["s"].as<String>());
    //char* motorSpeed = doc[i]["s"];
    int duration = doc[i]["d"];
    int motorSpeed = doc[i]["s"];

    MassagerRun(motorSpeed, duration, isBluetooth);
    Serial.println ("exit");
  }
}


void MassagerRun(int pwm_Value, int duration, bool isBluetooth) {

  int totalTime = duration * 60;

  digitalWrite(motor1pin1, HIGH);          // motor started, change to HIGH
  digitalWrite(motor1pin2, LOW);

  analogWrite(pwm, pwm_Value);
  char x;
  char y;

  while (totalTime >= 0) {
    if (isBluetooth) {
      mySerial.println ("{\"status\":\"RUNNING\",\"remainingTime\":" + String(totalTime) + "}");
    } else {
      Serial.println ("Massaging in progress");
      Serial.print ("remaining time ");
      Serial.print ( totalTime );
      Serial.println (" Seconds");
    }

    totalTime--;
    delay (1000);
    if (isBluetooth) {
      while (mySerial.available() >= 1) {
        String data =  mySerial.readString();
        DecodeJson(data);

        char* messageStatus = doc["status"];

        switch (toupper(messageStatus[0])) {
          case 'P':
            digitalWrite(motor1pin1, LOW);
            digitalWrite(motor1pin2, LOW);
            while (mySerial.available() < 1) {
              mySerial.println ("{\"status\":\"PAUSED\",\"remainingTime\":" + String(totalTime) + "}");
              delay(1000);
              if (mySerial.available() > 0) {

                String data =  mySerial.readString();

                DecodeJson(data);

                String status = doc["status"];

                if (status == "S") {
                  mySerial.println ("{\"status\":\"STOPPED\",\"remainingTime\":" + String(totalTime) + "}");
                  return;
                }
                else if (status == "R") {
                  digitalWrite(motor1pin1, HIGH);
                  digitalWrite(motor1pin2, LOW);
                  mySerial.println ("{\"status\":\"RESUME\",\"remainingTime\":" + String(totalTime) + "}");
                  break;
                }
              }
            }
            break;

          case 'S':
            mySerial.println ("{\"status\":\"STOPPED\",\"remainingTime\":" + String(totalTime) + "}");
            return;

          case 'T':
            mySerial.println ("{\"status\":\"TIMEOUT\",\"remainingTime\":" + String(totalTime) + "}");
            return;
        }
      }
    } else {
      while (Serial.available() >= 1) {
        String data = Serial.readString();
        DecodeJson(data);
        Serial.println(data);

        char* messageStatus = doc["status"];

        Serial.println(messageStatus);

        switch (toupper(messageStatus[0])) {
          case 'P':
            isPause = true;
            Serial.println ("massager paused");
            digitalWrite(motor1pin1, LOW);
            digitalWrite(motor1pin2, LOW);

            while (Serial.available() <= 1) {
              Serial.println("Press R to resume or press S to stop");
              delay(1000);
              if (Serial.available() > 0) {

                String data =  Serial.readString();

                DecodeJson(data);

                String status = doc["status"];

                if (status == "S") {
                  Serial.println ("Massager Stopped");
                  return;
                }
                else if (status == "R") {
                  digitalWrite(motor1pin1, HIGH);
                  digitalWrite(motor1pin2, LOW);
                  Serial.println ("Massager resumed");
                  break;
                }
              }
            }
            break;
          case 'S':
            Serial.println ("Massager Stopped");
            return;

          case 'T':
            Serial.println ("Massager Timed out");
            return;
        }
      }
    }

  }
  Serial.println ("This is the End");
}

void DecodeJson(String data) {
  DeserializationError error = deserializeJson(doc, data);

  if (error)
  {
    Serial.print(F("deserializeJson() failed: "));
    Serial.println(error.c_str());
    return;
  }

  Serial.println(error.c_str());
}


// T=time out
// P=Pause
// R=Resume
// s=Stop
