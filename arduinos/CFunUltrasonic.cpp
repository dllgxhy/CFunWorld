#include "CFunUltrasonic.h"
/*           UltrasonicSenser                 */
unsigned long _ustime;
long _distance;
CFunUltrasonic::CFunUltrasonic()
{
  _Trig = 2;
  _Echo = 3;
  pinMode(_Trig,OUTPUT);
  pinMode(_Echo,INPUT);
/*
attachInterrupt(1, ius, FALLING);
*/
}


double CFunUltrasonic::distanceCm()
{
  long duration;
  pinMode(_Trig, OUTPUT);
  pinMode(_Echo, INPUT);
  digitalWrite(_Trig, LOW);
  delayMicroseconds(2);
  digitalWrite(_Trig, HIGH);
  delayMicroseconds(20);
  digitalWrite(_Trig, LOW);
  duration = pulseIn(_Echo, HIGH);
  duration = duration / 59;
  if ((duration < 2) || (duration > 300)) return false;
  return duration;
}
/*
//改用无中断
long CFunUltrasonic::measure1ms()
{
    pinMode(_Trig,OUTPUT);
    pinMode(_Echo,INPUT);
    digitalWrite(_Trig,LOW);
    delayMicroseconds(2);
    digitalWrite(_Trig,HIGH);
    delayMicroseconds(10);
    digitalWrite(_Trig,LOW);
    _itime=micros();
    interrupts();
//    iustime = pulseIn(_Echo,HIGH,(400*55+200))/58.0;
    _itime=micros();
   // noInterrupts();
    return _iustime;
}

long CFunUltrasonic::measure()
{
   if((millis()-_ustime)>10)
   {
     _distance=measure1ms();
     _ustime=millis();
   }
   return _distance;
}
*/
