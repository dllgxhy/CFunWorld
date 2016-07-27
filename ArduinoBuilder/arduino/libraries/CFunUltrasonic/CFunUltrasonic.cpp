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
  attachInterrupt(1, ius, FALLING);
}


double CFunUltrasonic::distanceCm()
{
    long distance = measure();
    return ((double)distance / 58.0-10);//58
}

long CFunUltrasonic::measure1ms()
{
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
