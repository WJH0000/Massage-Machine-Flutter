#include <SoftwareSerial.h>
#include <ArduinoJson.h>


SoftwareSerial mySerial(8, 9); // RX, TX
const int motor1pin1 = 3;
const int motor1pin2 = 4;
const int pwm = 5;
bool isPause =  false;
String processData = ""; 
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

// {
//   "s": "w",
//   "r": 0,
//   "c": 1,
//   "p":[{
//         'd': 10,
//         's': 100,
//       },
//       {
//         'd': 5,
//         's': 150,
//       },
//       {
//         'd': 5,
//         's': 120,
//       }]
// }

void loop() {
  digitalWrite(motor1pin1, LOW);              // motor stopped
  digitalWrite(motor1pin2, LOW);
  analogWrite(pwm, 0);
  delay (1000);
  mySerial.println ("{\"s\":\"W\",\"r\":0,\"c\": 0,\"p\": null}");
  Serial.println ("{\"s\":\"W\",\"r\":0,\"c\": 0,\"p\":null}");
  //Serial
  if (Serial.available() > 0) {
    processData = Serial.readStringUntil('#');
    ProcessData(processData, false);
  }
  //bluetooth
  if (mySerial.available() > 0) {
    processData = mySerial.readStringUntil('#');
    ProcessData(processData, true);
  }

}

void ProcessData(String data, bool isBluetooth) {
  //Serial.println (data);
  DecodeJson(data);

  for (int i = 0; i < doc.size() ; i++) {
    // Serial.println ("***");
    //Serial.println (doc[i]["s"].as<String>());
    //char* motorSpeed = doc[i]["s"];

    int duration = doc[i]["d"];
    int motorSpeed = doc[i]["s"];
    int currentStep = i;

    Serial.println ("duration= " + String(duration) + " speed= " + String(motorSpeed) + " current step= " + String(currentStep) );
    MassagerRun(motorSpeed, duration, currentStep, isBluetooth);
    Serial.println ("exit");
  }
  processData = "";
}


void MassagerRun(int pwm_Value, int duration, int currentStep, bool isBluetooth) {

  int totalTime = duration * 60;

  digitalWrite(motor1pin1, HIGH);          // motor started, change to HIGH
  digitalWrite(motor1pin2, LOW);

  analogWrite(pwm, pwm_Value);
  char x;
  char y;

  while (totalTime >= 0) {
    if (isBluetooth) {
      Serial.println (doc.as<String>());
      //show the running status
      mySerial.println ("{\"s\":\"R\",\"r\":" + String(totalTime) + ",\"c\":" + String(currentStep) + ",\"p\":" + processData + "}");
      Serial.println ("{\"s\":\"R\",\"r\":" + String(totalTime) + ",\"c\":" + String(currentStep) + ",\"p\":" + processData + "}");
    } else {
      Serial.println ("Massaging in progress");
      Serial.print ("remaining time ");
      Serial.print ( totalTime );
      Serial.println (" Seconds");
    }

    totalTime--;
    delay (1500);
    if (isBluetooth) {
      while (mySerial.available() >= 1) {
        String data =  mySerial.readString();
        DecodeJson(data);

        char* messageStatus = doc["s"];

        switch (toupper(messageStatus[0])) {
          case 'P':
            digitalWrite(motor1pin1, LOW);
            digitalWrite(motor1pin2, LOW);
            while (mySerial.available() < 1) {
              //Pause
              mySerial.println ("{\"s\":\"P\",\"r\":" + String(totalTime) + ",\"c\":" + String(currentStep) + ",\"p\":" + processData + "}");
              Serial.println ("{\"s\":\"P\",\"r\":" + String(totalTime) + ",\"c\":" + String(currentStep) + ",\"p\":" + processData + "}");
              delay(1500);
              if (mySerial.available() > 0) {

                String data =  mySerial.readString();

                DecodeJson(data);

                String status = doc["s"];

                if (status == "S") {
                  //Stop the process
                  mySerial.println ("{\"s\":\"ST\",\"r\":" + String(totalTime) + ",\"c\":" + String(currentStep) + ",\"p\":" + processData + "}");
                  Serial.println ("{\"s\":\"ST\",\"r\":" + String(totalTime) + ",\"c\":" + String(currentStep) + ",\"p\":" + processData + "}");
                  return;
                }
                else if (status == "R") {
                  digitalWrite(motor1pin1, HIGH);
                  digitalWrite(motor1pin2, LOW);
                  //Resume
                 // mySerial.println ("{\"s\":\"R\",\"r\":" + String(totalTime) + ",\"c\":" + String(currentStep) + ",\"p\":" + processData + "}");
                  break;
                }
              }
            }
            break;
          case 'S':
            //Stop the process
            mySerial.println ("{\"s\":\"ST\",\"r\":" + String(totalTime) + ",\"c\":" + String(currentStep) + ",\"p\":" + processData + "}");
            Serial.println ("{\"s\":\"ST\",\"r\":" + String(totalTime) + ",\"c\":" + String(currentStep) + ",\"p\":" + processData + "}");
            return;
          case 'T':
            //Timeout
            mySerial.println ("{\"s\":\"T\",\"r\":" + String(totalTime) + ",\"c\":" + String(currentStep) + ",\"p\":" + processData + "}");
            Serial.println ("{\"s\":\"T\",\"r\":" + String(totalTime) + ",\"c\":" + String(currentStep) + ",\"p\":" + processData + "}");
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
