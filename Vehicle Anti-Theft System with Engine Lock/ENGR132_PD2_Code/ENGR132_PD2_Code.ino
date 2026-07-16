/*
  Vehicle Anti-Theft System
*/

#include <LiquidCrystal.h>
#include <Servo.h>

const int  VIBRATION = A0;
const int  BUZZER = 10;
const int  RED_LED = 9;
const int  GREEN_LED = 8;
const int  SERVO_PIN = 11;
const int  RESET_BTN = 2;

LiquidCrystal lcd(13, 12, 6, 5, 4, 3);
Servo servo;

bool alarm = false;
unsigned long lastBlink = 0;
bool ledOn = false;

void setup() {
  pinMode(VIBRATION, INPUT);
  pinMode(BUZZER, OUTPUT);
  pinMode(RED_LED, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);
  pinMode(RESET_BTN, INPUT_PULLUP);
  
  lcd.begin(16, 2);
  servo.attach(SERVO_PIN);
  servo.write(0);  // Unlocked
  lcd.print("System Armed");

  delay(2000);
}

void loop() {
  // Check reset button
  if (digitalRead(RESET_BTN) == LOW) {
    delay(50);  // Debounce
    alarm = false;
    digitalWrite(RED_LED, LOW);
    digitalWrite(BUZZER, LOW);
    servo.write(0);  // Unlock
    lcd.clear();
    lcd.print("System Armed");
  }
  
  // Blink LED every 500ms
  if (millis() - lastBlink >= 500) {
    lastBlink = millis();
    ledOn = !ledOn;
    
    if (alarm) {
      digitalWrite(RED_LED, ledOn);
      digitalWrite(BUZZER, ledOn);
      digitalWrite(GREEN_LED, LOW);
    } else {
      digitalWrite(GREEN_LED, ledOn);
      digitalWrite(RED_LED, LOW);
    }
  }
  
  // Check vibration
  if (!alarm && analogRead(VIBRATION) > 350) {
    alarm = true;
    servo.write(90);  // Lock engine
    lcd.clear();
    lcd.print("!! WARNING !!");
    lcd.setCursor(0, 1);
    lcd.print("THEFT DETECTED!");
  }
}
