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
int touch=0;
int acc_x=0;
int acc_y=0;
int acc_z=0;

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
    if(val==8);
    {
      // BTserial.println("Tent"); 
      touch = digitalRead(9);
      Serial.println(touch);
    }

    if(val==0); {
    acc_x = analogRead(A0);
    Serial.println(acc_x);
    }

    if(val==1); {
      acc_y = analogRead(A1);
      Serial.println(acc_y);
    }
 
    if(val==2); {
      acc_z = analogRead(A3); 
      Serial.println(acc_z);     
    }
  }
  delay(.5);
}
