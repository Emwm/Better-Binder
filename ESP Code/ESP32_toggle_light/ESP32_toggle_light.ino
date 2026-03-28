#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
int sensPin = 34;
int value = 0;
int prevValue = 0;
int turnCount = 2;

// MARK: - UUIDs (must match iOS)
static BLEUUID SERVICE_UUID("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
static BLEUUID CMD_CHAR_UUID("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
static BLEUUID STATUS_CHAR_UUID("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");

// MARK: - GPIO
static const int LED_PIN = 2;

// MARK: - Global handles 
static BLECharacteristic* g_statusChar = nullptr;

// Send a status string to iOS 
static void sendStatus(const String& msg) {
  if (!g_statusChar) return;
  g_statusChar->setValue(msg.c_str());
  g_statusChar->notify();
}

class ServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) override {
    Serial.println("Client connected");
  }

  void onDisconnect(BLEServer* pServer) override {
    Serial.println("Client disconnected");

    BLEDevice::startAdvertising();  // restart advertising
  }
};

//THIS IS WHERE WE WILL BE EDITING THINGS FOR RECIVING COMMANDS FROM THE MACBOOKS 
// MARK: - Command callback 
class CmdCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* c) override {
    String cmd = c->getValue();   // whatever iOS wrote
    cmd.trim();

    if (cmd == "LED:1") {
      digitalWrite(LED_PIN, HIGH);
      sendStatus("LED:1");
    } else if (cmd == "LED:0") {
      digitalWrite(LED_PIN, LOW);
      sendStatus("LED:0");
    } else {
      sendStatus("UNKNOWN");
    }
  }
};


void setup() {

  Serial.begin(9600);
  pinMode(LED_PIN, OUTPUT);
  pinMode(sensPin, INPUT);
  digitalWrite(LED_PIN, LOW);

  BLEDevice::init("ESP32-BLE-Demo");

  
  BLEServer* server = BLEDevice::createServer();
  server->setCallbacks(new ServerCallbacks());
  BLEService* service = server->createService(SERVICE_UUID);


  // CMD characteristic (client -> esp32)
  BLECharacteristic* cmdChar = service->createCharacteristic(
    CMD_CHAR_UUID,
    BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_WRITE_NR
  );
  cmdChar->setCallbacks(new CmdCallbacks());

  // STATUS characteristic (esp32 -> client)
  g_statusChar = service->createCharacteristic(
    STATUS_CHAR_UUID,
    BLECharacteristic::PROPERTY_NOTIFY
  );
  g_statusChar->addDescriptor(new BLE2902()); // required for iOS notify subscribe


  service->start();
  // Advertise service UUID so iOS can filter-scan by it
  BLEAdvertising* adv = BLEDevice::getAdvertising();
  adv->addServiceUUID(SERVICE_UUID);
  adv->start();

  sendStatus("READY");
}




void loop() {
  delay(50);
  prevValue = value;
  value = map(analogRead(sensPin), 0, 4095, 0, 1000);
  int delta = prevValue - value;

  if(delta > 550){
    turnCount++;
  }else if(delta < - 550){
    turnCount--;
  }
  int location = value + turnCount*1000;
  Serial.println(location);
  sendStatus((String) location);
/*
  if(delta > 550){
    turnCount++;
    display[turnCount+1] = "I";
    Serial.print("PLUS TURN!!!, new count is:");
    Serial.print(turnCount);
    Serial.println(display);
  }else if(delta < -550){
    turnCount--;
    display[turnCount+1] = "I";
    Serial.print("MINUS TURN!!!, new count is:");
    Serial.print(turnCount);
    Serial.println(display);
  }*/
}
