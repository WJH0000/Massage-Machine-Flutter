/*
    Video: https://www.youtube.com/watch?v=oCMOYS71NIU
    Based on Neil Kolban example for IDF: https://github.com/nkolban/esp32-snippets/blob/master/cpp_utils/tests/BLE%20Tests/SampleNotify.cpp
    Ported to Arduino ESP32 by Evandro Copercini

   Create a BLE server that, once we receive a connection, will send periodic notifications.
   The service advertises itself as: 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
   Has a characteristic of: 6E400002-B5A3-F393-E0A9-E50E24DCCA9E - used for receiving data with "WRITE" 
   Has a characteristic of: 6E400003-B5A3-F393-E0A9-E50E24DCCA9E - used to send data with  "NOTIFY"

   The design of creating the BLE server is:
   1. Create a BLE Server
   2. Create a BLE Service
   3. Create a BLE Characteristic on the Service
   4. Create a BLE Descriptor on the characteristic
   5. Start the service.
   6. Start advertising.

   In this example rxValue is the data received (only accessible inside that function).
   And txValue is the data to be sent, in this example just a byte incremented every second. 
*/
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>
#include <BLEServer.h>
#include <BLE2902.h>
#include "Arduino.h"
#include <FastLED.h>


//definitions


// configure led
#define NUM_LEDS 1
#define DATA_PIN 27
CRGB leds[NUM_LEDS];

//defining pins
const int EN = 33;                                                                                      //pin 33 on ESP32 connect to EEP on DRV8833
const int PWM1 = 22;                                                                                     //pin 22 on ESP32 connect to output 1 on DRV8833
const int In2 = 21;                                                                                     //pin 21 on ESP32 connect to output 2 on DRV8833
const int PWM3 = 19;                                                                                     //pin 19 on ESP32 connect to output 3 on DRV8833
const int In4 = 18;                                                                                     //pin 18 on ESP32 connect to output 4 on DRV8833

//defining PWM
const int freq = 5000;                                                                                  //defines frequency of PWM in Hz
const int speedChannel = 0;                                                                             //determines the duty cycle of the PWM wave
const int resolution  = 8;  

BLECharacteristic *pCharacteristic;
bool deviceConnected = false;
float txValue = 0;

//std::string rxValue; // Could also make this a global var to access it in loop()

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID           "6E400001-B5A3-F393-E0A9-E50E24DCCA9E" // UART service UUID
#define CHARACTERISTIC_UUID_RX "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_TX "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
    }
};

class MyCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string rxValue = pCharacteristic->getValue();

      if (rxValue.length() > 0) {
        Serial.println("*********");
        Serial.print("Received Value: ");

        for (int i = 0; i < rxValue.length(); i++) {
          Serial.print(rxValue[i]);
        }

        Serial.println();

        // Do stuff based on the command received from the app
        if (rxValue.find("A") != -1) { 
          Serial.print("Low");
          ledcWrite(speedChannel, 180);  
          leds[0] = 0xf00000;                                                                                 //Green
          FastLED.show();
        }
        if (rxValue.find("B") != -1) { 
          Serial.print("Medium");
          ledcWrite(speedChannel, 215);  
          leds[0] = 0xFFFF00;                                                                                 //Yellow                                                   
          FastLED.show();
        }
         if (rxValue.find("C") != -1) { 
          Serial.print("High");
          ledcWrite(speedChannel, 255);  
          leds[0] = 0xFF0000;                                                                                 //Red                                                      
          FastLED.show();
         } 
        else if (rxValue.find("D") != -1) {
          Serial.print("Default");
          ledcWrite(speedChannel, 0);
          leds[0] = 0x0000FF;                                                                                 //Blue
          FastLED.show();
        }

        Serial.println();
        Serial.println("*********");
      }
    }
};

void setup() {
  pinMode(PWM1, OUTPUT);                                                                                                                                                   
  pinMode(EN, OUTPUT);
  pinMode(In2, OUTPUT);
  pinMode(PWM3, OUTPUT);
  pinMode(In4, OUTPUT);
  digitalWrite(EN, HIGH);
  Serial.begin(115200);

  FastLED.addLeds<SK6812, DATA_PIN, RGB>(leds, NUM_LEDS);

  //configure SPEED PWM functions 
  ledcSetup(speedChannel, freq, resolution);                                                           
  ledcAttachPin(PWM1, speedChannel);
  ledcAttachPin(PWM3, speedChannel); 

  // Create the BLE Device
  BLEDevice::init("ESP32 UART Test"); // Give it a name

  // Create the BLE Server
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a BLE Characteristic
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID_TX,
                      BLECharacteristic::PROPERTY_NOTIFY
                    );
                      
  pCharacteristic->addDescriptor(new BLE2902());

  BLECharacteristic *pCharacteristic = pService->createCharacteristic(
                                         CHARACTERISTIC_UUID_RX,
                                         BLECharacteristic::PROPERTY_WRITE
                                       );

  pCharacteristic->setCallbacks(new MyCallbacks());

  // Start the service
  pService->start();

  // Start advertising
  pServer->getAdvertising()->start();
  Serial.println("Waiting a client connection to notify...");
}

void loop() {
}
