/* 少年创客 & 创趣天地 */
/* YoungMaker & CFunWorld */
/* www.youngmaker.com */
/* www.cfunworld.com */
#include "CFunPort.h"
#include "CFunLiquidCrystal.h" 
CFunLiquidCrystal lcd(0x20, 16, 2);

void setup(){
delay(20);
lcd.init();
lcd.LiquidCrystaldisplay(String("hello xuhy"));
}

void loop(){
}
