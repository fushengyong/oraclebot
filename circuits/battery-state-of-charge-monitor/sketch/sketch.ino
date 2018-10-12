
/*
This unit was designed to be used on 12V battery systems only.

FEATURES
========
6 LEDs to display voltage level (< 20%, >20%, >40%, >60%, >80%, 100% and above)
Programmable maximum LED displayed voltage
Programmable minimum LED displayed voltage
3 Independant programmable undervoltage alarms (independant of LED display)

SPECIFICATIONS
==============
Supply                     8 to 18V
Max measureable voltage    14.5V
Min measureable voltage    8.0V
Average current drain      0.25mA with display off @ 12.8V
A/D Converter              10 bit
A/D Resolution             about 15.0mV 
Sample method              Average of 100 samples taken every 8 seconds
Prevered alarm settings    >100mV between alarms

BUTTON
======
Pressing the button will display voltage level for 30 seconds
if Alarm 1 or Alarm 2 is active, pressing the button will silence the alarms
Pressing button while powering up device, will enter CALIBRATION mode (see CALIBRATION)
While display is on, pressing the button has no effect

BUZZER
======
Beep 1 time  every 8 seconds - voltage lower than ALARM 1 level. Press button to silence alarm
Beep 2 times every 8 seconds - voltage lower than ALARM 2 level. Press button to silence alarm
Beep 3 times every 8 seconds - voltage lower than ALARM 3 level. Alarm can not be silenced
Alarms that was silenced, will be reset once voltage exceeds 60% of display voltage for longer than 10 seconds

DISPLAY
=======
While display is on, no alarms will sound
Display will turn off automatically after 30 seconds to conserve battery

CALIBRATION
===========
Before applying power, press button and keep pressed for longer than 5 seconds
Device will beep constant
Release button 
6 Beeps - program max display voltage
Top LED on
Device is now in CALIBRATE mode
To exit CALIBRATE mode, remove power from device before preesing the button again
Adjust to max display voltage and press button to save
5 Beeps - program min display voltage
Display will show lowest LED
Adjust to min display voltage and press button to save
4 Beeps - program alarm 1 voltage
Display will show lowest 4 LED
Adjust to alarm 1 voltage and press button to save
3 Beeps - program alarm 2 voltage
Display will show lowest 3 LED
Adjust to alarm 2 voltage and press button to save
2 Beeps - program alarm 3 voltage
Display will show lowest 2 LED
Adjust to alarm 3 voltage and press button to save
Device will give a long beep
Actual voltage is now displayed for 30 seconds
Calibration complete

! ! ! ! ! SPECIAL NOTE ON THE PROJECT ! ! ! ! ! !
To make use of the power saving options available on the AtMega328P, this
program was written with the clock speed at 8MHz, instead of 16MHz. I also
programmed the chip to use the internal 8MHz oscillator for maximum energy
saving.
This means all delays and millis() routines will run at half the speed.

*/

// Include this 3 files for the low power setups
#include <avr/sleep.h>
#include <avr/wdt.h>
#include <avr/power.h>

#include <EEPROM.h>

#define DEBUG

// define constants
const byte BTN    =  2; // test button
const byte LED1   =  8; //   0%
const byte LED2   =  7; //  20%
const byte LED3   =  6; //  40%
const byte LED4   =  5; //  60%
const byte LED5   =  4; //  80%
const byte LED6   =  3; // 100%
const byte Buzzer = A4; // buzzer
const byte BatIn  = A5; // battery monitor pin

// define variables
byte    oldADCSRA = 0;
boolean BtnDwn    = 0;
byte    Range     = 0;

// define battery settings
unsigned int Vmin   = 0;        // minimum displayed battery voltage
unsigned int Vmax   = 0;        // maximum displayed battery voltage
unsigned int Alm1   = 0;        // alarm 1
unsigned int Alm2   = 0;        // alarm 2
unsigned int Alm3   = 0;        // alarm 4
unsigned int Batt   = 0;        // calculated voltage reading
long         Told   = 0;        // ms timers
boolean      Mute1  = 0;        // 1st alarm buzzer mute flag
boolean      Mute2  = 0;        // 2nd alarm buzzer mute flag
boolean      Beep1  = 0;        // 1st alarm beep status
boolean      Beep2  = 0;        // 2nd alarm beep status

//------------------------------------------------------------------------------------------------------------------------------------
// Setup 
//------------------------------------------------------------------------------------------------------------------------------------
void setup () { 

#ifdef DEBUG  
  Serial.begin(9600);
#endif  
  
  // setup hardware
  pinMode(BTN, INPUT_PULLUP);  // enable pull-up  
  pinMode(LED1,OUTPUT);
  pinMode(LED2,OUTPUT);
  pinMode(LED3,OUTPUT);
  pinMode(LED4,OUTPUT);
  pinMode(LED5,OUTPUT);
  pinMode(LED6,OUTPUT);
  pinMode(Buzzer,OUTPUT);
  
  // turn off LEDS
  digitalWrite(LED1,LOW);
  digitalWrite(LED2,LOW);
  digitalWrite(LED3,LOW);
  digitalWrite(LED4,LOW);
  digitalWrite(LED5,LOW);
  digitalWrite(LED6,LOW);
  digitalWrite(Buzzer,LOW);
  
  //load calibration from EEPROM
  if (EEPROM.read(11) == 123) {
    //EEPROM contains valid data
    Read_EEPROM();
  }
  else {

    // no calibration data. Enter calibration mode
#ifdef DEBUG  
  Serial.println("######## NO DATA IN EEPROM  ########");
  delay(50);
#endif
    Do_Calibrate();
  }
  // Button pressed during power up - start calibration mode
  if (digitalRead(BTN) == 0) {
    Told = millis();
    while (digitalRead(BTN) == 0) {
      if ( (millis() - Told) > 5000) {
        digitalWrite(Buzzer,HIGH);
        while (digitalRead(BTN) == 0) {
          delay(40);
        }
        digitalWrite(Buzzer,LOW);
        
        delay(500);
        Do_Calibrate();
      }
    }
  }
  analogReference(INTERNAL);
  oldADCSRA = ADCSRA;    
  delay(10);           // delay for A/D to set
  //wakeup();/
  BtnDwn = 1;
  // start-up test
  digitalWrite(Buzzer,HIGH);
  delay(1000);
  digitalWrite(Buzzer,LOW);
  
  Told = millis();
#ifdef DEBUG  
  Serial.println("######## SETUP Function Finished  ########");
  delay(50);
#endif  
}

//------------------------------------------------------------------------------------------------------------------------------------
// Main Loop
//------------------------------------------------------------------------------------------------------------------------------------
void loop () {
  BattLoop:
  Do_Batt();
  // if button is pressed, show voltage for 30 seconds
  if (BtnDwn == 1) {
#ifdef DEBUG
  Serial.println("BUTTON DOWN");
  delay(50);    
#endif
    Do_LEDs();
    delay(25);
    if ( (millis() - Told) < 15000) goto BattLoop;
    BtnDwn = 0;
  }
  Do_Buzzer();
  sleep();
  sleep_disable();
  wakeup();  
}

//------------------------------------------------------------------------------------------------------------------------------------
// Calibration routine
//------------------------------------------------------------------------------------------------------------------------------------
void Do_Calibrate() {
#ifdef DEBUG 
  Serial.println("######## Entering Caliberation Mode  ########");
  delay(50);
#endif  
  // calibrate max voltage
  digitalWrite(LED6,HIGH);
  // beep 6 times
  for (byte i = 1; i <= 6; i++) {
    digitalWrite(Buzzer,HIGH);
    delay(100);
    digitalWrite(Buzzer,LOW);
    delay(200);
  }
  while (digitalRead(BTN) == 0) {
    delay(40);
  }
  calMax:
  Do_Batt();
  delay(100);
  if (digitalRead(BTN) == 1) goto calMax;
  // Done, save value
  EEPROM.write(3,Batt >> 8);
  EEPROM.write(4,Batt & 255);
  // reset calibrated flag;
  EEPROM.write(11,0);
  digitalWrite(LED6,LOW);
  while (digitalRead(BTN) == 0) {
    delay(40);
  }    
  // calibrate min voltage
  digitalWrite(LED1,HIGH);
  // beep 5 times
  for (byte i = 1; i <= 5; i++) {
    digitalWrite(Buzzer,HIGH);
    delay(100);
    digitalWrite(Buzzer,LOW);
    delay(200);
  }
  calMin:
  Do_Batt();
  delay(100);
  if (digitalRead(BTN) == 1) goto calMin;
  // Done, save value
  EEPROM.write(1,Batt >> 8);
  EEPROM.write(2,Batt & 255);
  digitalWrite(LED1,LOW);
  while (digitalRead(BTN) == 0) {
    delay(40);
  }    
  // calibrate alarm 1 voltage
  digitalWrite(LED4,HIGH);
  digitalWrite(LED3,HIGH);
  digitalWrite(LED2,HIGH);
  digitalWrite(LED1,HIGH);
  // beep 4 times
  for (byte i = 1; i <= 4; i++) {
    digitalWrite(Buzzer,HIGH);
    delay(100);
    digitalWrite(Buzzer,LOW);
    delay(200);
  }
  calAlm1:
  Do_Batt();
  delay(100);
  if (digitalRead(BTN) == 1) goto calAlm1;
  // Done, save value
  EEPROM.write(5,Batt >> 8);
  EEPROM.write(6,Batt & 255);
  digitalWrite(LED4,LOW);
  digitalWrite(LED3,LOW);
  digitalWrite(LED2,LOW);
  digitalWrite(LED1,LOW);
  while (digitalRead(BTN) == 0) {
    delay(40);
  }    
  // calibrate alarm 2 voltage
  digitalWrite(LED3,HIGH);
  digitalWrite(LED2,HIGH);
  digitalWrite(LED1,HIGH);
  // beep 3 times
  for (byte i = 1; i <= 3; i++) {
    digitalWrite(Buzzer,HIGH);
    delay(100);
    digitalWrite(Buzzer,LOW);
    delay(200);
  }
  calAlm2:
  Do_Batt();
  delay(100);
  if (digitalRead(BTN) == 1) goto calAlm2;
  // Done, save value
  EEPROM.write(7,Batt >> 8);
  EEPROM.write(8,Batt & 255);
  digitalWrite(LED3,LOW);
  digitalWrite(LED2,LOW);
  digitalWrite(LED1,LOW);
  while (digitalRead(BTN) == 0) {
    delay(40);
  }    
  // calibrate alarm 3 voltage
  digitalWrite(LED2,HIGH);
  digitalWrite(LED1,HIGH);
  // beep 2 times
  for (byte i = 1; i <= 2; i++) {
    digitalWrite(Buzzer,HIGH);
    delay(100);
    digitalWrite(Buzzer,LOW);
    delay(200);
  }
  calAlm3:
  Do_Batt();
  delay(100);
  if (digitalRead(BTN) == 1) goto calAlm3;
  // Done, save value
  EEPROM.write(9,Batt >> 8);
  EEPROM.write(10,Batt & 255);
  digitalWrite(LED2,LOW);
  digitalWrite(LED1,LOW);
  while (digitalRead(BTN) == 0) {
    delay(40);
  }    
  // read EEPROM data
  Read_EEPROM();
  
  // set calibrate flag
  EEPROM.write(11,123);
#ifdef DEBUG 
  Serial.println("######## Exiting Caliberation Mode  ########");
  delay(50);
#endif  
}

void Read_EEPROM() {
  // min voltage
    Vmin = EEPROM.read(1);
    Vmin = Vmin << 8;
    Vmin = Vmin + EEPROM.read(2);
    // max voltage
    Vmax = EEPROM.read(3);
    Vmax = Vmax << 8;
    Vmax = Vmax + EEPROM.read(4);
    // alarm 1 voltage
    Alm1 = EEPROM.read(5);
    Alm1 = Alm1 << 8;
    Alm1 = Alm1 + EEPROM.read(6);
    // alarm 2 voltage
    Alm2 = EEPROM.read(7);
    Alm2 = Alm2 << 8;
    Alm2 = Alm2 + EEPROM.read(8);
    // alarm 3 voltage
    Alm3 = EEPROM.read(9);
    Alm3 = Alm3 << 8;
    Alm3 = Alm3 + EEPROM.read(10);

#ifdef DEBUG 
    Serial.print("Vmin: ");
    Serial.println(Vmin);
    Serial.print("Vmax: ");
    Serial.println(Vmax);
    Serial.print("Alm1: ");
    Serial.println(Alm1);
    Serial.print("Alm2: ");
    Serial.println(Alm2);
    Serial.print("Alm3: ");
    Serial.println(Alm3);
    delay(50);
#endif    
}

//------------------------------------------------------------------------------------------------------------------------------------
// Read A/D and convert reading
//------------------------------------------------------------------------------------------------------------------------------------
void Do_Batt() {
  analogReference(INTERNAL);
  delay(20);           // delay for A/D to set
  // read batt voltage (take average of 100 readings)
  long TempBatt = 0;
  for (byte i = 1; i <=100; i++) {
    TempBatt = TempBatt + analogRead(BatIn);
  }
  TempBatt = TempBatt/100;
  TempBatt = TempBatt;
  Batt = TempBatt;
  unsigned int DisplayBat = Batt;
  DisplayBat = constrain(DisplayBat, Vmin, Vmax);
  Range = map(DisplayBat, Vmin, Vmax, 1, 6);
  oldADCSRA = ADCSRA;

#ifdef DEBUG 
  Serial.print("Batt :");
  Serial.println(Batt);
  Serial.print("Range :");
  Serial.println(Range);
  delay(50);
#endif  
}

//------------------------------------------------------------------------------------------------------------------------------------
// Display on LEDs
//------------------------------------------------------------------------------------------------------------------------------------
void Do_LEDs() {
  // Full
  if (Range == 6) {
    digitalWrite(LED6,HIGH);
    digitalWrite(LED5,HIGH);
    digitalWrite(LED4,HIGH);
    digitalWrite(LED3,HIGH);
    digitalWrite(LED2,HIGH);
    digitalWrite(LED1,HIGH);
  }
  // > 80%
  if (Range == 5){
    digitalWrite(LED6,LOW);
    digitalWrite(LED5,HIGH);
    digitalWrite(LED4,HIGH);
    digitalWrite(LED3,HIGH);
    digitalWrite(LED2,HIGH);
    digitalWrite(LED1,HIGH);
  }
  // > 60%
  if (Range == 4){
    digitalWrite(LED6,LOW);
    digitalWrite(LED5,LOW);
    digitalWrite(LED4,HIGH);
    digitalWrite(LED3,HIGH);
    digitalWrite(LED2,HIGH);
    digitalWrite(LED1,HIGH);

  }
  // > 40%
  if (Range == 3) {
    digitalWrite(LED6,LOW);
    digitalWrite(LED5,LOW);
    digitalWrite(LED4,LOW);
    digitalWrite(LED3,HIGH);
    digitalWrite(LED2,HIGH);
    digitalWrite(LED1,HIGH);
  }
  // > 20%
  if (Range == 2) {
    digitalWrite(LED6,LOW);
    digitalWrite(LED5,LOW);
    digitalWrite(LED4,LOW);
    digitalWrite(LED3,LOW);
    digitalWrite(LED2,HIGH);
    digitalWrite(LED1,HIGH);
  }
  // < 20%
  if (Range == 1) {
    digitalWrite(LED6,LOW);
    digitalWrite(LED5,LOW);
    digitalWrite(LED4,LOW);
    digitalWrite(LED3,LOW);
    digitalWrite(LED2,LOW);
    digitalWrite(LED1,HIGH);
  }
}

//------------------------------------------------------------------------------------------------------------------------------------
// Sound buzzer
//------------------------------------------------------------------------------------------------------------------------------------
void Do_Buzzer() {
  // Reset Mutes
  if (Range == 4) {
    Mute1 = 0;
    Mute2 = 0;
  }
  // Reset beep flags
  if (Batt > Alm1) {
    Beep1 = 0;
    Beep2 = 0;
  }
  // Alarm 1
  if ( (Batt > Alm2) and (Batt <= Alm1) ) {
    Beep1 = 1;
    if (Mute1 == 0) {
      digitalWrite(Buzzer,HIGH);
      delay(100);
      digitalWrite(Buzzer,LOW);
    }
  }
  // Alarm 2
  if ( (Batt > Alm3) and (Batt <= Alm2) ) {
    Beep2 = 1;
    if (Mute2 == 0) {
      for (byte i = 1; i <=2; i++) {
        digitalWrite(Buzzer,HIGH);
        delay(100);
        digitalWrite(Buzzer,LOW);
        delay(200);
      }
    }
  }
  // Alarm 3
  if (Batt <= Alm3) {
    for (byte i = 1; i <=3; i++) {
      digitalWrite(Buzzer,HIGH);
      delay(100);
      digitalWrite(Buzzer,LOW);
      delay(200);
    }
  }

#ifdef DEBUG 
  Serial.print("Beep1 :");
  Serial.println(Beep1);
  Serial.print("Mute1 :");
  Serial.println(Mute1);
  Serial.print("Beep2 :");
  Serial.println(Beep2);  
  Serial.print("Mute2 :");
  Serial.println(Mute2);
  delay(50);
#endif  
  
}

//------------------------------------------------------------------------------------------------------------------------------------
// Put device into sleep
//------------------------------------------------------------------------------------------------------------------------------------
void sleep() {
  pinMode(LED1,INPUT);
  pinMode(LED2,INPUT);
  pinMode(LED3,INPUT);
  pinMode(LED4,INPUT);
  pinMode(LED5,INPUT);
  pinMode(LED6,INPUT);
  pinMode(Buzzer,INPUT);
  
  MCUSR = 0;     // clear various "reset" flags
  WDTCSR = bit (WDCE) | bit (WDE);  // allow changes, disable reset, enable Watchdog interrupt
  // set interval (see datasheet p55)
  //WDTCSR = bit (WDIE) | bit (WDP2) | bit (WDP1);    // 128K cycles = approximativly 1 second
  WDTCSR = bit (WDIE) | bit (WDP3) | bit (WDP0);    // set WDIE, and 8 seconds delay
  wdt_reset();  // start watchdog timer
  set_sleep_mode (SLEEP_MODE_PWR_DOWN); // prepare for powerdown  
  sleep_enable(); 
  // Do not interrupt before we go to sleep, or the
  // ISR will detach interrupts and we won't wake.
  noInterrupts ();
  
  // will be called when pin D2 goes low  
  attachInterrupt (0, Btn_ISR, LOW);
  // turn off brown-out enable in software
  MCUCR = bit (BODS) | bit (BODSE);
  MCUCR = bit (BODS); 
    
  oldADCSRA = ADCSRA;    
  ADCSRA &= ~(1<<ADEN); //Disable ADC
  ACSR = (1<<ACD); //Disable the analog comparator
  DIDR0 = 0x3F; //Disable digital input buffers on all ADC0-ADC5 pins
  DIDR1 = (1<<AIN1D)|(1<<AIN0D); //Disable digital input buffer on AIN1/0

  power_twi_disable();
  power_spi_disable();
#ifndef DEBUG  
  power_usart0_disable(); //Needed for serial.print
#endif  
  power_timer0_disable(); //Needed for delay and millis()
  power_timer1_disable();
  power_timer2_disable(); //Needed for asynchronous 32kHz operation

  // We are guaranteed that the sleep_cpu call will be done
  // as the processor executes the next instruction after
  // interrupts are turned on.
  interrupts ();  // one cycle
  sleep_cpu ();   // power down !
}

//------------------------------------------------------------------------------------------------------------------------------------
// Wake-up device and set up
//------------------------------------------------------------------------------------------------------------------------------------
void wakeup() {
  //power_twi_enable();
  //power_spi_enable();
  //power_usart0_enable();
  power_timer0_enable();
  //power_timer1_enable();
  //power_timer2_enable();
  power_adc_enable();
  ADCSRA = oldADCSRA;
  // re-enable output pins    
  pinMode(LED1,OUTPUT);
  pinMode(LED2,OUTPUT);
  pinMode(LED3,OUTPUT);
  pinMode(LED4,OUTPUT);
  pinMode(LED5,OUTPUT);
  pinMode(LED6,OUTPUT);
  pinMode(Buzzer,OUTPUT);
  Told = millis();
}  
//------------------------------------------------------------------------------------------------------------------------------------
// watchdog interrupt
//------------------------------------------------------------------------------------------------------------------------------------
ISR (WDT_vect) 
{
   wdt_disable();  // disable watchdog
}
 
//------------------------------------------------------------------------------------------------------------------------------------
// Button interrupt
//------------------------------------------------------------------------------------------------------------------------------------
void Btn_ISR () { // button interrupt
  // cancel sleep as a precaution
  sleep_disable();
  BtnDwn = 1;
  if (Beep1 == 1) Mute1 = 1;
  if (Beep2 == 1) Mute2 = 1;
  // must do this as the pin will probably stay low for a while
  detachInterrupt (0);
}


