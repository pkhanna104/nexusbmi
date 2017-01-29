#include <Wire.h>
#include <SPI.h>
#include "quaternionFilters.h"
#include "MPU9250.h"

// Hardware setup:
// MPU9250 Breakout --------- Arduino
// VDD ---------------------- 3.3V
// SDA ----------------------- A4
// SCL ----------------------- A5
// GND ---------------------- GND

#define AHRS false         // Set to false for basic data read
#define SerialDebug false  // Set to true to get Serial output for debugging

int intPin = 12;  // These can be changed, 2 and 3 are the Arduinos ext int pins
int myLed  = 13;  // Set up pin 13 led for toggling

const int cap = 11;
const int acc_L_z = A3;
const int acc_L_x = A1;
const int hr = A0;
char cc;

int capValue;
int cap1 = 1;
int v = 10;
int x = 20;
int y = 30;
int z = 40;

MPU9250 myIMU;

void setup()
{
  Wire.begin();
  // TWBR = 12;  // 400 kbit/sec I2C speed
  Serial.begin(115200);

  // Set up the interrupt pin, its set as active high, push-pull
  pinMode(intPin, INPUT);
  digitalWrite(intPin, LOW);
  pinMode(myLed, OUTPUT);
  digitalWrite(myLed, HIGH);
  
  // Pin modes for other sensors: 
  pinMode(cap, INPUT);
  pinMode(acc_L_z, INPUT);
  pinMode(acc_L_x, INPUT);
  pinMode(hr, INPUT);

  
  // Read the WHO_AM_I register, this is a good test of communication
  byte c = myIMU.readByte(MPU9250_ADDRESS, WHO_AM_I_MPU9250);
  // Serial.print("MPU9250 "); Serial.print("I AM "); Serial.print(c, HEX);
  // Serial.print(" I should be "); Serial.println(0x71, HEX);

  if (c == 0x71) // WHO_AM_I should always be 0x71
  {
    // Serial.println("MPU9250 is online...");

    // Start by performing self test and reporting values
    myIMU.MPU9250SelfTest(myIMU.SelfTest);
    
    if (SerialDebug) {
    Serial.print("x-axis self test: acceleration trim within : ");
    Serial.print(myIMU.SelfTest[0],1); Serial.println("% of factory value");
    Serial.print("y-axis self test: acceleration trim within : ");
    Serial.print(myIMU.SelfTest[1],1); Serial.println("% of factory value");
    Serial.print("z-axis self test: acceleration trim within : ");
    Serial.print(myIMU.SelfTest[2],1); Serial.println("% of factory value");
    Serial.print("x-axis self test: gyration trim within : ");
    Serial.print(myIMU.SelfTest[3],1); Serial.println("% of factory value");
    Serial.print("y-axis self test: gyration trim within : ");
    Serial.print(myIMU.SelfTest[4],1); Serial.println("% of factory value");
    Serial.print("z-axis self test: gyration trim within : ");
    Serial.print(myIMU.SelfTest[5],1); Serial.println("% of factory value");
    }

    // Calibrate gyro and accelerometers, load biases in bias registers
    myIMU.calibrateMPU9250(myIMU.gyroBias, myIMU.accelBias);

    myIMU.initMPU9250();
    // Initialize device for active mode read of acclerometer, gyroscope, and
    // temperature
    // Serial.println("MPU9250 initialized for active data mode....");

    // Read the WHO_AM_I register of the magnetometer, this is a good test of
    // communication
    byte d = myIMU.readByte(AK8963_ADDRESS, WHO_AM_I_AK8963);
    
    if (SerialDebug) {
    Serial.print("AK8963 ");
    Serial.print("I AM ");
    Serial.print(d, HEX);
    Serial.print(" I should be ");
    Serial.println(0x48, HEX);
    }

    // Get magnetometer calibration from AK8963 ROM
    myIMU.initAK8963(myIMU.factoryMagCalibration);
    // Initialize device for active mode read of magnetometer
    // Serial.println("AK8963 initialized for active data mode....");

    if (SerialDebug)
    {
      //  Serial.println("Calibration values: ");
      Serial.print("X-Axis factory sensitivity adjustment value ");
      Serial.println(myIMU.factoryMagCalibration[0], 2);
      Serial.print("Y-Axis factory sensitivity adjustment value ");
      Serial.println(myIMU.factoryMagCalibration[1], 2);
      Serial.print("Z-Axis factory sensitivity adjustment value ");
      Serial.println(myIMU.factoryMagCalibration[2], 2);
    }

    // Get sensor resolutions, only need to do this once
    myIMU.getAres();
    myIMU.getGres();
    myIMU.getMres();

    // The next call delays for 4 seconds, and then records about 15 seconds of
    // data to calculate bias and scale.
    myIMU.magCalMPU9250(myIMU.magBias, myIMU.magScale);
    if (SerialDebug) {
    Serial.println("AK8963 mag biases (mG)");
    Serial.println(myIMU.magBias[0]);
    Serial.println(myIMU.magBias[1]);
    Serial.println(myIMU.magBias[2]);

    Serial.println("AK8963 mag scale (mG)");
    Serial.println(myIMU.magScale[0]);
    Serial.println(myIMU.magScale[1]);
    Serial.println(myIMU.magScale[2]);
    }
    delay(2000); // Add delay to see results before serial spew of data

    if(SerialDebug)
    {
      Serial.println("Magnetometer:");
      Serial.print("X-Axis sensitivity adjustment value ");
      Serial.println(myIMU.factoryMagCalibration[0], 2);
      Serial.print("Y-Axis sensitivity adjustment value ");
      Serial.println(myIMU.factoryMagCalibration[1], 2);
      Serial.print("Z-Axis sensitivity adjustment value ");
      Serial.println(myIMU.factoryMagCalibration[2], 2);
    }
  }
  else
  {
    Serial.print("Could not connect to MPU9250: 0x");
    Serial.println(c, HEX);
    while(1) ; // Loop forever if communication doesn't happen
  }
}

void loop()
{
  if (Serial.available() >= 1) // if receive signal to send data
  
  // If intPin goes high, all data registers have new data
  // On interrupt, check if data ready interrupt
  // if (myIMU.readByte(MPU9250_ADDRESS, INT_STATUS) & 0x01)  {
    
    myIMU.readAccelData(myIMU.accelCount);  // Read the x/y/z adc values

    // Now we'll calculate the accleration value into actual g's
    // This depends on scale being set
    myIMU.ax = (float)myIMU.accelCount[0] * myIMU.aRes; // - myIMU.accelBias[0];
    myIMU.ay = (float)myIMU.accelCount[1] * myIMU.aRes; // - myIMU.accelBias[1];
    myIMU.az = (float)myIMU.accelCount[2] * myIMU.aRes; // - myIMU.accelBias[2];

    myIMU.readGyroData(myIMU.gyroCount);  // Read the x/y/z adc values

    // Calculate the gyro value into actual degrees per second
    // This depends on scale being set
    myIMU.gx = (float)myIMU.gyroCount[0] * myIMU.gRes;
    myIMU.gy = (float)myIMU.gyroCount[1] * myIMU.gRes;
    myIMU.gz = (float)myIMU.gyroCount[2] * myIMU.gRes;

    myIMU.readMagData(myIMU.magCount);  // Read the x/y/z adc values

    // Calculate the magnetometer values in milliGauss
    // Include factory calibration per data sheet and user environmental
    // corrections
    // Get actual magnetometer value, this depends on scale being set
    myIMU.mx = (float)myIMU.magCount[0] * myIMU.mRes
               * myIMU.factoryMagCalibration[0] - myIMU.magBias[0];
    myIMU.my = (float)myIMU.magCount[1] * myIMU.mRes
               * myIMU.factoryMagCalibration[1] - myIMU.magBias[1];
    myIMU.mz = (float)myIMU.magCount[2] * myIMU.mRes
               * myIMU.factoryMagCalibration[2] - myIMU.magBias[2];
    
    cc = Serial.read();

    // Get Data
    if (cc == 'd') {
      
      capValue = digitalRead(cap);
      //Serial.println(capValue);
      Serial.println(capValue);
      Serial.println(analogRead(acc_L_x));
      Serial.println(analogRead(acc_L_z));
      Serial.println(analogRead(hr));
      
    }
    else if (cc == 'e') {
      Serial.println(v);
      Serial.println(x);
      Serial.println(y);
      Serial.println(z);
    }

    // Must be called before updating quaternions!
    myIMU.updateTime();

    // Sensors x (y)-axis of the accelerometer is aligned with the y (x)-axis of
    // the magnetometer; the magnetometer z-axis (+ down) is opposite to z-axis
    // (+ up) of accelerometer and gyro! We have to make some allowance for this
    // orientationmismatch in feeding the output to the quaternion filter. For the
    // MPU-9250, we have chosen a magnetic rotation that keeps the sensor forward
    // along the x-axis just like in the LSM9DS0 sensor. This rotation can be
    // modified to allow any convenient orientation convention. This is ok by
    // aircraft orientation standards! Pass gyro rate as rad/s
    MahonyQuaternionUpdate(myIMU.ax, myIMU.ay, myIMU.az, myIMU.gx * DEG_TO_RAD,
                           myIMU.gy * DEG_TO_RAD, myIMU.gz * DEG_TO_RAD, myIMU.my,
                           myIMU.mx, myIMU.mz, myIMU.deltat);

    myIMU.delt_t = millis() - myIMU.count;
    if (cc == 'd') {
      // Print acceleration values in milligs!
      //Serial.print("X-acceleration: "); 
      Serial.println(1000 * myIMU.ax);
      //Serial.print(" mg "); 
      //Serial.print("Y-acceleration: "); 
      Serial.println(1000 * myIMU.ay);
      //Serial.print(" mg ");
      //Serial.print("Z-acceleration: "); 
      Serial.println(1000 * myIMU.az);
      //Serial.println(" mg ");
      
      // Print gyro values in degree/sec
      //Serial.print("X-gyro rate: "); 
      Serial.println(myIMU.gx, 3);
      //Serial.print(" degrees/sec ");
      //Serial.print("Y-gyro rate: "); 
      Serial.println(myIMU.gy, 3);
      //Serial.print(" degrees/sec ");
      //Serial.print("Z-gyro rate: "); 
      Serial.println(myIMU.gz, 3);
      //Serial.println(" degrees/sec");

      // Print mag values in degree/sec
      //Serial.print("X-mag field: "); 
      Serial.println(myIMU.mx);
      //Serial.print(" mG ");
      //Serial.print("Y-mag field: "); 
      Serial.println(myIMU.my);
      //Serial.print(" mG ");
      //Serial.print("Z-mag field: "); 
      Serial.println(myIMU.mz);
      //Serial.println(" mG");

      myIMU.tempCount = myIMU.readTempData();  // Read the adc values
      // Temperature in degrees Centigrade
      myIMU.temperature = ((float) myIMU.tempCount) / 333.87 + 21.0;
      // Print temperature in degrees Centigrade
      //Serial.print("Temperature is ");  
      Serial.println(myIMU.temperature, 1);
      //Serial.println(" degrees C");
    }

    myIMU.count = millis();
    digitalWrite(myLed, !digitalRead(myLed));  // toggle led
     // if (myIMU.delt_t > 500)
  } // if (!AHRS)
