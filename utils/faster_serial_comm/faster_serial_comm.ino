const int cap = 11;
const int acc_x = A0;
const int acc_y = A1;
const int acc_z = A2;
const int acc_L_z = A3;
const int acc_L_x = A4;

int capValue;
int acc_xValue;
int acc_yValue;
int acc_zValue;

int cap1 = 1;
int v = 10;
int x = 20;
int y = 30;
int z = 40;

char c;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  pinMode(cap, INPUT);
  pinMode(acc_x, INPUT);
  pinMode(acc_y, INPUT);
  pinMode(acc_z, INPUT);
  pinMode(acc_L_z, INPUT);
  pinMode(acc_L_x, INPUT);
}

void loop() {
  if (Serial.available() >= 1) {
    digitalWrite(13, HIGH);
    c = Serial.read();

    // Get Data
    if (c == 'd') {
      
      capValue = digitalRead(cap);
      //Serial.println(capValue);
      Serial.println(capValue);
      
      acc_xValue = analogRead(acc_x);
      Serial.println(acc_xValue);
      
      acc_yValue = analogRead(acc_y);
      Serial.println(acc_yValue);      
      
      acc_zValue = analogRead(acc_z);
      Serial.println(acc_zValue); 

      Serial.println(analogRead(acc_L_x));
      Serial.println(analogRead(acc_L_z));
    }
    else if (c == 'e') {
      Serial.println(v);
      Serial.println(x);
      Serial.println(y);
      Serial.println(z);
    }
  }
}
