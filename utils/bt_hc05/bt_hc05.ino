// Basic Bluetooth sketch HC-05_01
// Sends "Bluetooth Test" to the serial monitor and the software serial once every second.
//
// Connect the HC-05 module and data over Bluetooth
//
// The HC-05 defaults to commincation mode when first powered on.
// The default baud rate for communication is 9600
 
#include <SoftwareSerial.h>
SoftwareSerial BTserial(2, 3); // RX | TX
// Connect the HC-05 TX to Arduino pin 2 RX. 
// Connect the HC-05 RX to Arduino pin 3 TX through a voltage divider.
// 

int val=0;
int sens = 0;

void setup() 
{
    Serial.begin(9600);
    Serial.println("Enter AT commands:");
    // HC-06 default serial speed for communcation mode is 9600
    BTserial.begin(9600);  
}
 
void loop() 
{
  if (Serial.available()>0){
    val = Serial.read();
    
    //Serial.println("Rec'd");
    //Serial.println(val);
    
    if(val==8) {
      sens = digitalRead(9);
    }

    else if(val==0) {
      sens = analogRead(A0);
    }

    else if(val==1) {
      sens = analogRead(A1);
    }
 
    else if(val==2) {
      sens = analogRead(A3);    
    }
    
    Serial.println(sens);
  }
  delay(.5);
}
