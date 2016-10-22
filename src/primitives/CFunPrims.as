/*
 * Scratch Project Editor and Player
 * Copyright (C) 2014 Massachusetts Institute of Technology
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

// CFunPrims.as
// Wanghui, 2015.2
//
// Arduino Blocks primitives.

package primitives
{
	//import flash.utils.ByteArray;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.*;
	
	import blocks.Block;
	
	import interpreter.Interpreter;
	
	import scratch.ScratchSprite;

//ByteArray定义用_wh
	
	public class CFunPrims
	{
		public static var testnum:int;//输出testnum用_wh；注意必须为静态属性
		private var app:Scratch;
		private var interp:Interpreter;
		//以下为交互协议类别表参量_wh
		public static const ID_SetDigital:int = 0x81;//写数字口输出_wh
		public static const ID_SetPWM:int = 0x82;//写pwm口输出_wh
		public static const ID_SetSG:int = 0x83;//写舵机输出角度_wh
		public static const ID_SetMUS:int = 0x84;//写无源蜂鸣器音乐输出_wh
		public static const ID_SetNUM:int = 0x85;//写数码管输出值_wh
		public static const ID_SetDM:int = 0x86;//写舵机输出角度_wh
		public static const ID_SetRGB:int = 0x87;//三色LED_wh
		public static const ID_SetLCD1602String:int = 0x88 //LCD1602写字符串
		
		public static const ID_SetFORWARD:int = 0xA0;//机器人前进_wh
		public static const ID_SetBACK:int = 0xA1;//机器人后退_wh
		public static const ID_SetLEFT:int = 0xA2;//机器人左转弯_wh
		public static const ID_SetRIGHT:int = 0xA3;//机器人右转弯_wh
		//public static const ID_SetBUZZER:int = 0xA4;//机器人蜂鸣器_wh
		public static const ID_SetGRAY:int = 0xA5;//机器人灰度阀值_wh
		//public static const ID_SetARM:int = 0xA5;//机器人机械臂_wh
		
		public static const ID_ReadDigital:int = 0x01;//读数字口输入_wh
		public static const ID_ReadAnalog:int = 0x02;//读模拟口输入_wh
		public static const ID_ReadAFloat:int = 0x03;//读模拟口输入float值_wh
		public static const ID_ReadPFloat:int = 0x04;//超声波传感器输入float值_wh
		public static const ID_ReadCap:int = 0x08;//读取电容byte值_wh
		
		public static const ID_ReadTRACK:int = 0x52;//读机器人循迹输入_wh
		public static const ID_ReadAVOID:int = 0x50;//读机器人避障输入_wh
		public static const ID_ReadULTR:int = 0x51;//读机器人超声波输入_wh
		public static const ID_ReadPOWER:int = 0x53;//读机器人电量输入_wh
		public static const ID_READFRAREDR:int = 0x54;//读机器人红外遥控输入_wh
		
		public static const ID_CarDC:int = 0x0100;//机器人前进方式_wh
		public static const ID_DIR:int = 0x0101;//方向电机变量_wh
		
		
		public function CFunPrims(app:Scratch,interpreter:Interpreter)
		{
			this.app = app;
			this.interp = interpreter;
		}
		
		public function addPrimsTo(primTable:Dictionary):void
		{
			primTable['test:'] = function(b:*):* { test(b, 'talk') };
			
			primTable["setdigital:"] = primSetDigital;//写数字口输出_wh
			primTable["setpwm:"] = primSetPWM;//写PWM口输出_wh
			primTable["readdigital:"] = primReadBit;//读数字口输入_wh
			primTable["readdigitalSend:"] = primReadDigital;//读数字口输入命令发送_wh
			primTable["readanalog:"] = primReadShort;//读模拟口输入_wh
			primTable["readanalogSend:"] = primReadAnalog;//读模拟口输入命令发送_wh
			
			primTable["setMpwm:"] = primSetPWM;//写PWM口输出_wh
			primTable["setsg:"] = primSetSG;//写舵机输出角度_wh
			primTable["setdm:"] = primSetDM;//写电机正负PWM输出_wh
			primTable["setrgb:"] = primSetRGB;//写电机正负PWM输出_wh
			primTable["setnum:"] = primSetNUM;//写数码管输出值_wh
			primTable["setmusic:"] = primSetMUS;//写无源蜂鸣器音乐输出值_wh
			primTable["setdigitals:"] = primSetDigitals;//写数字口输出_wh
			
			primTable["setforward:"] = primSetforward;//写机器人前进速度_wh
			primTable["setback:"] = primSetback;//写机器人后退速度_wh
			primTable["setleft:"] = primSetleft;//写机器人左转弯速度_wh
			primTable["setright:"] = primSetright;//写机器人右转弯速度_wh
			primTable["setgray:"] = primSetgray;//写机器人灰度阀值_wh
			//primTable["setbuzzer:"] = primSetbuzzer;//写机器人蜂鸣器_wh
			primTable["setarm:"] = primSetarm;//写机器人机械臂_wh
			
			primTable["setckled:"] = primSetCkled;//ck_wh
			primTable["setLCD1602string:"] = primSetLCD1602String;  //
			
			
			//primTable["readdigitalj:"] = primReadBit;//读数字口输入_wh
			//primTable["readdigitaljSend:"] = primReadDigital;//读数字口输入命令发送_wh
			primTable["readcap:"] = primReadByte;//读数字口输入_wh
			primTable["readcapSend:"] = primReadCap;//读数字口输入命令发送_wh
			
			primTable["readAfloat:"] = primReadFloat;//读模拟口输入float值_wh
			primTable["readAfloatSend:"] = primReadAFloat;//读模拟口输入float值命令发送_wh
			primTable["readPfloat:"] = primReadFloat;//读超声波输入float值_wh
			primTable["readPfloatSend:"] = primReadPFloat;//读超声波输入float值命令发送_wh
			
			primTable["readdigitals:"] = primReadBit;//读数字口输入_wh
			primTable["readdigitalsSend:"] = primReadDigitals;//读数字口输入命令发送_wh
			primTable["readanalogs:"] = primReadShort;//读模拟口输入_wh
			primTable["readanalogsSend:"] = primReadAnalogs;//读模拟口输入命令发送_wh
			primTable["readanalogsj:"] = primReadShort;//读模拟口输入_wh
			primTable["readanalogsjSend:"] = primReadAnalogs;//读模拟口输入命令发送_wh
			
			primTable["readtrack:"] = primReadShort;//读循迹输入_wh
			primTable["readtrackSend:"] = primReadTrack;//读循迹输入_wh
			
			primTable["readavoid:"] = primReadShort;//读红外避障输入_wh
			primTable["readavoidSend:"] = primReadAvoid;//读红外避障输入_wh
			
//			primTable["readultrs:"] = primReadFloat;//读超声波输入_wh
//			primTable["readultrsSend:"] = primReadUltr;//读超声波输入_wh
			
			primTable["readpower:"] = primReadFloat;//读电量输入_wh
			primTable["readpowerSend:"] = primReadPower;//读电量输入_wh
			
			primTable["readfraredR:"] = primReadByte;//读红外遥控输入_wh
			primTable["readfraredRSend:"] = primReadFraredR;//读红外遥控输入_wh
			
			
			primTable["readcksound"]			= function(b:*):* { return app.arduinoSoundValue};
			primTable["readckslide"]	        = function(b:*):* { return app.arduinoSlideValue};
			primTable["readcklight"]		    = function(b:*):* { return app.arduinoLightValue};
			primTable["readckUltrasonicSensor"]	= function(b:*):* { return app.arduinoUltrasonicValue};
			
			primTable["readckjoyx"] = primReadShort;//ck_wh
			primTable["readckjoyxSend"] = primReadCkJX;//ck_wh
			primTable["readckjoyy"] = primReadShort;//ck_wh
			primTable["readckjoyySend"] = primReadCkJY;//ck_wh
			
			
			primTable["readckkey1"] = primReadBit;//ck_wh
			primTable["readckkey1Send"] = primReadCkK1;//ck_wh
			primTable["readckkey2"] = primReadBit;//ck_wh
			primTable["readckkey2Send"] = primReadCkK2;//ck_wh
			
			primTable["whenArduino"] = primArduino;//Arduino程序头_wh
		}
		
//		//输出testnum用_wh
//		public static function setTestnum(num:int):void//静态变量不能外部赋值_wh
//		{
//			testnum = num;
//		}

		//Arduino程序头_wh
		private function primArduino(b:Block):void
		{	
			clearInterval(app.IntervalID);
			app.ArduinoLoopFlag = false;
			app.ArduinoBracketFlag = 0;
			app.ArduinoMathFlag = false;
			app.ArduinoReadFlag = false;
			app.ArduinoValueFlag = false;
			app.ArduinoIEFlag = 0;
			app.ArduinoIEElseFlag = 0;
			app.ArduinoIEFlagIE = false;
			app.ArduinoIEFlagAll = 0;
			app.ArduinoIEElseNum = 0;
			app.ArduinoWarnFlag = false;
			app.ArduinoIEFlag2 = 0;
			//app.ArduinoIEBracketFlag = 0;
			
			app.ArduinoUs = false;//超声波_wh
			app.ArduinoSeg = false;//数码管_wh
			app.ArduinoRGB = false;//三色灯_wh
			app.ArduinoBuz = false;//无源蜂鸣器_wh
			app.ArduinoCap = false;//电容值_wh
			app.ArduinoDCM = false;//方向电机_wh
			app.ArduinoSer = false;//舵机_wh
			app.ArduinoIR = false;//红外遥控_wh
			app.ArduinoTem = false;//温度_wh
			app.ArduinoAvo = false;//避障_wh
			app.ArduinoTra = false;//循迹_wh
			
			//app.ArduinoNAN = false;//_wh
			
			app.ArduinoFlag = true;
			app.ArduinoPin = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
			var j:Number = 0;
			for(var i:Number = 0; i <= 0xfff; i++)
			{
				switch (i)
				{
					case ID_ReadAFloat:for(j = 0; j <= 13; j++)  app.ArduinoBlock[ID_ReadAFloat][j] = 0;break;
					case ID_ReadPFloat:for(j = 0; j <= 13; j++)  app.ArduinoBlock[ID_ReadPFloat][j] = 0;break;
					case ID_SetSG:for(j = 0; j <= 13; j++)  app.ArduinoBlock[ID_SetSG][j] = 0;break;
					case ID_SetDM:for(j = 0; j <= 13; j++)  app.ArduinoBlock[ID_SetDM][j] = 0;break;
					case ID_SetNUM:for(j = 0; j <= 13; j++)  app.ArduinoBlock[ID_SetNUM][j] = 0;break;
					case ID_SetMUS:for(j = 0; j <= 13; j++)  app.ArduinoBlock[ID_SetMUS][j] = 0;break;
					default:app.ArduinoBlock[i] = 0;break;
				}
			}
			
			app.ArduinoPinFs.open(app.ArduinoPinFile,FileMode.WRITE);
			app.ArduinoPinFs.position = 0;
			
			app.ArduinoDoFs.open(app.ArduinoDoFile,FileMode.WRITE);
			app.ArduinoDoFs.position = 0;
			
			app.ArduinoHeadFs.open(app.ArduinoHeadFile,FileMode.WRITE);
			app.ArduinoHeadFs.position = 0;
			
			app.ArduinoLoopFs.open(app.ArduinoLoopFile,FileMode.WRITE);
			app.ArduinoLoopFs.position = 0;
			
			app.ArduinoFs.open(app.ArduinoFile,FileMode.WRITE);
			app.ArduinoFs.position = 0;
//			app.ArduinoFs.writeUTFBytes("void setup(){"+'\n');
//			app.ArduinoFs.writeUTFBytes('\n'+"}"+'\n');
//			app.ArduinoFs.writeUTFBytes('\n'+"void loop(){"+'\n');
//			app.ArduinoFs.writeUTFBytes('\n'+"}"+'\n');
		}
		
		private function test(b:Block,type:String=null):void
		{
			var text:*,secs:Number;
			var s:ScratchSprite = interp.targetSprite();
			if ((s == null))
			{
				return;
			}
			
			// talk or think command
			text = interp.arg(b,0);//模块参数第一个，参数类型为字符串_wh
			//testnum ++;
			//text = String(testnum);//调试用变量，在test模块显示_wh
			
			//如果未定义，则不显示，主要针对读取类积木模块循环等待用_wh
			if(text == undefined)
				;
			else
			{
				s.showBubble(text,type,b);
				if (s.visible)
				{
					interp.redraw();
				}
			}
		}

        //写数字口输出_wh
		private function primSetDigital(b:Block):void
		{
			var pin:Number = interp.numarg(b,0);//引脚号，模块参数第一个，参数类型为数字_wh
			var hl:Number;
			if(interp.arg(b,1) == 'low')
				hl = 0;
			else
				hl =1;
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				app.ArduinoMathNum = 0;
				if(app.ArduinoPin[pin] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + pin + ",OUTPUT);" + '\n');
					app.ArduinoPin[pin] = 2;
				}
				var strcp:String = new String();
				strcp = pin.toString();
					
				if(app.ArduinoLoopFlag == true)
					app.ArduinoLoopFs.writeUTFBytes("digitalWrite(" + strcp + "," + hl + ");" + '\n');
				else
					app.ArduinoDoFs.writeUTFBytes("digitalWrite(" + strcp + "," + hl + ");" + '\n');

			}
			else//正常上位机运行模式_wh
			{
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_SetDigital);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(hl);
				app.CFunDelayms(10);//延时15ms_wh
			}
		}
		
		//写数字口输出_wh
		private function primSetDigitals(b:Block):void
		{
			var pin:Number = interp.numarg(b,1);//引脚号，模块参数第一个，参数类型为数字_wh
			var hl:Boolean;
			if(interp.arg(b,2) == 'off')
				hl = false;
			else
				hl =true;
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				app.ArduinoMathNum = 0;
				if(app.ArduinoPin[pin] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + pin + ",OUTPUT);" + '\n');
					app.ArduinoPin[pin] = 2;
				}
				var strcp:String = new String();
				strcp = pin.toString();
				
				if(app.ArduinoLoopFlag == true)
					app.ArduinoLoopFs.writeUTFBytes("digitalWrite(" + strcp + "," + hl + ");" + '\n');
				else
					app.ArduinoDoFs.writeUTFBytes("digitalWrite(" + strcp + "," + hl + ");" + '\n');
				
			}
			else//正常上位机运行模式_wh
			{
				//通信协议：0xff 0x55; 0x81（IO输出高低电平类型）; pin（管脚号）; 00 00 00 hl（高低电平）_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_SetDigital);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(int(hl));
				app.CFunDelayms(5);//延时15ms_wh
			}
		}
		
		//ckled_wh
		private function primSetCkled(b:Block):void
		{
			var pin:Number = 13;//引脚号，模块参数第一个，参数类型为数字_wh
			var hl:Boolean;
			if(interp.arg(b,0) == 'off')
				hl = false;
			else
				hl =true;
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				app.ArduinoMathNum = 0;
				if(app.ArduinoPin[pin] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + pin + ",OUTPUT);" + '\n');
					app.ArduinoPin[pin] = 2;
				}
				var strcp:String = new String();
				strcp = pin.toString();
				
				if(app.ArduinoLoopFlag == true)
					app.ArduinoLoopFs.writeUTFBytes("digitalWrite(" + strcp + "," + hl + ");" + '\n');
				else
					app.ArduinoDoFs.writeUTFBytes("digitalWrite(" + strcp + "," + hl + ");" + '\n');
				
			}
			else//正常上位机运行模式_wh
			{
				//通信协议：0xff 0x55; 0x81（IO输出高低电平类型）; pin（管脚号）; 00 00 00 hl（高低电平）_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_SetDigital);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(int(hl));
				app.CFunDelayms(5);//延时15ms_wh
			}
		}
		
		private function primSetLCD1602String(b:Block):void
		{
			app.ArduinoLCD1602 = true;
			var strLCD1602:String = new String();
			strLCD1602 = interp.arg(b,0);			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{	
				app.ArduinoDoFs.writeUTFBytes("delay(20);" + '\n');
				app.ArduinoDoFs.writeUTFBytes("lcd.init();" + '\n');
				if(app.ArduinoLoopFlag == true)
					app.ArduinoLoopFs.writeUTFBytes("lcd.LiquidCrystaldisplay(String(" + '"'+strLCD1602+ '"'+"));" + '\n');
				else
					app.ArduinoDoFs.writeUTFBytes("lcd.LiquidCrystaldisplay(String(" + '"'+strLCD1602+ '"'+"));" + '\n');
				
			}
			else//正常上位机运行模式_wh
			{
				//通信协议：0xff 0x55; 0x88（LCD1602控制ID号）; pin（管脚号）; char(最多32位)   _xuhy
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_SetLCD1602String);
				app.arduino.writeByte(0x00);  //该值没有用，所以添加值为任意值
				
				app.arduino.writeString(strLCD1602);
				
				for(var i:int = 0x00;i<= 0x20;i++)
				{
					app.arduino.writeByte(0x20);
				}
				
				app.CFunDelayms(5);//延时15ms_wh
				
			}
		}
		
		//机器人行进初始化_wh
		private function CarDCInit():void
		{
			app.ArduinoDCM = true;
			app.ArduinoMathNum = 0;
			if(app.ArduinoPin[5] == 0)
			{
				app.ArduinoPinFs.writeUTFBytes("pinMode(5,OUTPUT);" + '\n');
				app.ArduinoPin[5] = 2;
			}
			if(app.ArduinoPin[7] == 0)
			{
				app.ArduinoPinFs.writeUTFBytes("pinMode(7,OUTPUT);" + '\n');
				app.ArduinoPin[7] = 2;
			}
			if(app.ArduinoPin[6] == 0)
			{
				app.ArduinoPinFs.writeUTFBytes("pinMode(6,OUTPUT);" + '\n');
				app.ArduinoPin[6] = 2;
			}
			if(app.ArduinoPin[8] == 0)
			{
				app.ArduinoPinFs.writeUTFBytes("pinMode(8,OUTPUT);" + '\n');
				app.ArduinoPin[8] = 2;
			}
			
			if(app.ArduinoBlock[ID_CarDC] == 0)
			{
				app.ArduinoHeadFs.writeUTFBytes("CFunDCMotor  dc_cfun;" + '\n');
				app.ArduinoBlock[ID_CarDC] = 1;
			}
		}
		
		//写机器人前进速度输出_wh
		private function primSetforward(b:Block):void
		{
			var speed:Number = interp.numarg(b,0);
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				CarDCInit();
				
				var strcp:String = new String();
				if(app.ArduinoValueFlag == true)
				{
					strcp = app.ArduinoValueStr;
					app.ArduinoValueFlag = false;
				}
				else
					if(app.ArduinoMathFlag == true)
					{
						strcp = app.ArduinoMathStr[0];
						app.ArduinoMathFlag = false;
					}
					else
						if(app.ArduinoReadFlag == true)
						{
							strcp = app.ArduinoReadStr[0];
							app.ArduinoReadFlag = false;
						}
						else
							strcp = speed.toString();
				
				if(app.ArduinoLoopFlag == true)
					app.ArduinoLoopFs.writeUTFBytes("dc_cfun.forward(" + strcp + ");" + '\n');
				else
					app.ArduinoDoFs.writeUTFBytes("dc_cfun.forward(" + strcp + ");" + '\n');
				
			}
			else//正常上位机运行模式_wh
			{
				//内嵌模块，没有有效返回_wh
				if(app.interp.activeThread.ArduinoNA)//加有效性判断_wh
				{
					app.interp.activeThread.ArduinoNA = false;
					return;
				}
				
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_SetFORWARD);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(speed);
				app.CFunDelayms(5);//延时15ms_wh
			}
		}
		
		//写机器人后退速度输出_wh
		private function primSetback(b:Block):void
		{
			var speed:Number = interp.numarg(b,0);
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				CarDCInit();
				
				var strcp:String = new String();
				if(app.ArduinoValueFlag == true)
				{
					strcp = app.ArduinoValueStr;
					app.ArduinoValueFlag = false;
				}
				else
					if(app.ArduinoMathFlag == true)
					{
						strcp = app.ArduinoMathStr[0];
						app.ArduinoMathFlag = false;
					}
					else
						if(app.ArduinoReadFlag == true)
						{
							strcp = app.ArduinoReadStr[0];
							app.ArduinoReadFlag = false;
						}
						else
							strcp = speed.toString();
				
				if(app.ArduinoLoopFlag == true)
					app.ArduinoLoopFs.writeUTFBytes("dc_cfun.back(" + strcp + ");" + '\n');
				else
					app.ArduinoDoFs.writeUTFBytes("dc_cfun.back(" + strcp + ");" + '\n');
				
			}
			else//正常上位机运行模式_wh
			{
				//内嵌模块，没有有效返回_wh
				if(app.interp.activeThread.ArduinoNA)//加有效性判断_wh
				{
					app.interp.activeThread.ArduinoNA = false;
					return;
				}
				
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_SetBACK);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(speed);
				app.CFunDelayms(5);//延时15ms_wh
			}
		}
		
		//写机器人左转弯速度输出_wh
		private function primSetleft(b:Block):void
		{
			var speed:Number = interp.numarg(b,0);
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				CarDCInit();
				
				var strcp:String = new String();
				if(app.ArduinoValueFlag == true)
				{
					strcp = app.ArduinoValueStr;
					app.ArduinoValueFlag = false;
				}
				else
					if(app.ArduinoMathFlag == true)
					{
						strcp = app.ArduinoMathStr[0];
						app.ArduinoMathFlag = false;
					}
					else
						if(app.ArduinoReadFlag == true)
						{
							strcp = app.ArduinoReadStr[0];
							app.ArduinoReadFlag = false;
						}
						else
							strcp = speed.toString();
				
				if(app.ArduinoLoopFlag == true)
					app.ArduinoLoopFs.writeUTFBytes("dc_cfun.turnleft(" + strcp + ");" + '\n');
				else
					app.ArduinoDoFs.writeUTFBytes("dc_cfun.turnleft(" + strcp + ");" + '\n');
				
			}
			else//正常上位机运行模式_wh
			{
				//内嵌模块，没有有效返回_wh
				if(app.interp.activeThread.ArduinoNA)//加有效性判断_wh
				{
					app.interp.activeThread.ArduinoNA = false;
					return;
				}
				
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_SetLEFT);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(speed);
				app.CFunDelayms(5);//延时15ms_wh
			}
		}
		
		//写机器人右转弯速度输出_wh
		private function primSetright(b:Block):void
		{
			var speed:Number = interp.numarg(b,0);
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				CarDCInit();
				
				var strcp:String = new String();
				if(app.ArduinoValueFlag == true)
				{
					strcp = app.ArduinoValueStr;
					app.ArduinoValueFlag = false;
				}
				else
					if(app.ArduinoMathFlag == true)
					{
						strcp = app.ArduinoMathStr[0];
						app.ArduinoMathFlag = false;
					}
					else
						if(app.ArduinoReadFlag == true)
						{
							strcp = app.ArduinoReadStr[0];
							app.ArduinoReadFlag = false;
						}
						else
							strcp = speed.toString();
				
				if(app.ArduinoLoopFlag == true)
					app.ArduinoLoopFs.writeUTFBytes("dc_cfun.turnright(" + strcp + ");" + '\n');
				else
					app.ArduinoDoFs.writeUTFBytes("dc_cfun.turnright(" + strcp + ");" + '\n');
				
			}
			else//正常上位机运行模式_wh
			{
				//内嵌模块，没有有效返回_wh
				if(app.interp.activeThread.ArduinoNA)//加有效性判断_wh
				{
					app.interp.activeThread.ArduinoNA = false;
					return;
				}
				
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_SetRIGHT);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(speed);
				app.CFunDelayms(5);//延时15ms_wh
			}
		}
		
		//写机器人灰度阀值_wh
		private function primSetgray(b:Block):void
		{
/*			var gray:Number = interp.arg(b,0);
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				app.ArduinoMathNum = 0;
				
				if(app.ArduinoBlock[ID_ReadTRACK] == 0)
					if(app.ArduinoBlock[ID_SetGRAY] == 0)
					{
						app.ArduinoHeadFs.writeUTFBytes("unsigned int Tgray_cfun = 600;" + '\n');
						app.ArduinoBlock[ID_SetGRAY] = 1;
					}
				
				var strcp:String = new String();
				if(app.ArduinoValueFlag == true)
				{
					strcp = app.ArduinoValueStr;
					app.ArduinoValueFlag = false;
				}
				else
					if(app.ArduinoMathFlag == true)
					{
						strcp = app.ArduinoMathStr[0];
						app.ArduinoMathFlag = false;
					}
					else
						if(app.ArduinoReadFlag == true)
						{
							strcp = app.ArduinoReadStr[0];
							app.ArduinoReadFlag = false;
						}
						else
							strcp = gray.toString();
				
				if(app.ArduinoLoopFlag == true)
					app.ArduinoLoopFs.writeUTFBytes("Tgray_cfun = " + strcp + ";" + '\n');
				else
					app.ArduinoDoFs.writeUTFBytes("Tgray_cfun = " + strcp + ";" + '\n');
			}
			else
			{
				//内嵌模块，没有有效返回_wh
				if(app.interp.activeThread.ArduinoNA)//加有效性判断_wh
				{
					app.interp.activeThread.ArduinoNA = false;
					return;
				}
				
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_SetGRAY);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(gray>>8);
				app.arduino.writeByte(gray);
				app.CFunDelayms(5);//延时15ms_wh
			}*/
		}
		
		//写机器人蜂鸣器输出_wh
//		private function primSetbuzzer(b:Block):void
//		{
//			var hl:Boolean;
//			if(interp.arg(b,0) == 'off')
//				hl = false;
//			else
//				hl =true;
//			
//			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
//			{
//				if(app.ArduinoBlock[ID_SetBUZZER] == 0)
//				{
//					app.ArduinoHeadFs.writeUTFBytes("CFunPort  buzz(6);" + '\n');
//					app.ArduinoBlock[ID_SetBUZZER] = 1;
//				}
//				
//				if(app.ArduinoPin[6] == 0)
//				{
//					app.ArduinoPinFs.writeUTFBytes("pinMode(6,OUTPUT);" + '\n');
//					app.ArduinoPin[6] = 2;
//				}
//				
//				if(app.ArduinoLoopFlag == true)
//					app.ArduinoLoopFs.writeUTFBytes("buzz.dWrite1(" + int(hl) + ");" + '\n');
//				else
//					app.ArduinoDoFs.writeUTFBytes("buzz.dWrite1(" + int(hl) + ");" + '\n');
//			}
//			else
//			{
//				app.arduino.writeByte(0xff);
//				app.arduino.writeByte(0x55);
//				app.arduino.writeByte(ID_SetBUZZER);
//				app.arduino.writeByte(0x00);
//				app.arduino.writeByte(0x00);
//				app.arduino.writeByte(0x00);
//				app.arduino.writeByte(0x00);
//				app.arduino.writeByte(int(hl));
//			}
//		}
		
		//写机器人机械臂输出_wh
		private function primSetarm(b:Block):void
		{
			var pin:Number;
			var angle:Number = interp.numarg(b,1);
			var flag:Boolean = false;
			if(interp.arg(b,0) == 'updown')
				pin = 9;
			else
				pin = 10;
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				app.ArduinoSer = true;
				app.ArduinoMathNum = 0;
				if(app.ArduinoBlock[ID_SetSG][pin] == 0)

				{
					app.ArduinoHeadFs.writeUTFBytes("Servo myservo_cfun" + pin +";" + '\n');
					//app.ArduinoHeadFs.writeUTFBytes("CFunPort  servo_pin" + pin + "(" + pin +");" + '\n');
					app.ArduinoBlock[ID_SetSG][pin] = 1;
				}
				
				if(app.ArduinoPin[pin] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + pin + ",OUTPUT);" + '\n');
					app.ArduinoPin[pin] = 2;
				}
				
				var strcp:String = new String();
				if(app.ArduinoValueFlag == true)
				{
					strcp = app.ArduinoValueStr;
					app.ArduinoValueFlag = false;
				}
				else
					if(app.ArduinoMathFlag == true)
					{
						strcp = app.ArduinoMathStr[0];
						app.ArduinoMathFlag = false;
					}
					else
						if(app.ArduinoReadFlag == true)
						{
							strcp = app.ArduinoReadStr[0];
							app.ArduinoReadFlag = false;
						}
						else
						{
							strcp = angle.toString();
							flag = true;
						}
				
				if(app.ArduinoLoopFlag == true)
				{
					if(flag == false)//数值不能赋值给赋值_wh
					{
						app.ArduinoLoopFs.writeUTFBytes("if(" + strcp + " > 80) " + strcp + " = 80;" + '\n');
					}
					app.ArduinoLoopFs.writeUTFBytes("myservo_cfun" +pin + ".attach(" + pin + ");" + '\n');
					app.ArduinoLoopFs.writeUTFBytes("myservo_cfun" +pin + ".write(" + strcp + ");" + '\n');
				}
				else
				{
					if(flag == false)//数值不能赋值给赋值_wh
					{
						app.ArduinoDoFs.writeUTFBytes("if(" + strcp + " > 80) " + strcp + " = 80;" + '\n');
					}
					app.ArduinoDoFs.writeUTFBytes("myservo_cfun" +pin + ".attach(" + pin + ");" + '\n');
					app.ArduinoDoFs.writeUTFBytes("myservo_cfun" +pin + ".write(" + strcp + ");" + '\n');
				}
			}
			else
			{
				if(angle > 80)
					angle = 80;
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_SetSG);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(angle);
				app.CFunDelayms(5);//延时15ms_wh
			}
		}
		
		//写PWM口输出_wh
		private function primSetPWM(b:Block):void
		{
			//var pin:Number = interp.numarg(b,0);//引脚号，模块参数第一个，参数类型为数字_wh
			//var pwm:Number = interp.numarg(b,1);//PWM值，模块参数第一个，参数类型为数字_wh
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				app.ArduinoMathNum = 0;
				var pin:Number = interp.numarg(b,0);//引脚号，模块参数第一个，参数类型为数字_wh
				if(app.ArduinoPin[pin] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + pin + ",OUTPUT);" + '\n');
					app.ArduinoPin[pin] = 2;
				}
				
				var strcp:Array = new Array();
				strcp[0] = pin.toString();
				
				var pwm:Number = interp.numarg(b,1);//PWM值，模块参数第一个，参数类型为数字_wh
				if(app.ArduinoValueFlag == true)
				{
					strcp[1] = app.ArduinoValueStr;
					app.ArduinoValueFlag = false;
				}
				else
					if(app.ArduinoMathFlag == true)
					{
						strcp[1] = app.ArduinoMathStr[0];
						app.ArduinoMathFlag = false;
					}
					else
						if(app.ArduinoReadFlag == true)
						{
							strcp[1] = app.ArduinoReadStr[0];
							app.ArduinoReadFlag = false;
						}
						else
							strcp[1] = pwm.toString();
				
				if(app.ArduinoLoopFlag == true)
					app.ArduinoLoopFs.writeUTFBytes("analogWrite(" + strcp[0] + "," + strcp[1] + ");" + '\n');
				else
					app.ArduinoDoFs.writeUTFBytes("analogWrite(" + strcp[0] + "," + strcp[1] + ");" + '\n');
			}
			else//正常上位机运行模式_wh
			{
				pin = interp.numarg(b,0);//引脚号，模块参数第一个，参数类型为数字_wh
				pwm = interp.numarg(b,1);//PWM值，模块参数第一个，参数类型为数字_wh
				//内嵌模块，没有有效返回_wh
				if(app.interp.activeThread.ArduinoNA)//加有效性判断_wh
				{
					app.interp.activeThread.ArduinoNA = false;
					return;
				}
				
				//通信协议：0xff 0x55; 0x82（IO输出PWM类型）; pin（管脚号）; pwm（WPM量）_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_SetPWM);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(pwm);
				app.CFunDelayms(5);//延时15ms_wh
			}
		}
		
		//写舵机输出角度_wh
		private function primSetSG(b:Block):void
		{
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				app.ArduinoSer = true;
				app.ArduinoMathNum = 0;
				var pin:Number = interp.numarg(b,0);//引脚号，模块参数第一个，参数类型为数字_wh
				if(app.ArduinoBlock[ID_SetSG][pin] == 0)
				{
					app.ArduinoHeadFs.writeUTFBytes("Servo myservo_cfun" + pin +";" + '\n');
					//app.ArduinoHeadFs.writeUTFBytes("CFunPort servo_pin" + pin + "(" + pin +");" + '\n');
					app.ArduinoBlock[ID_SetSG][pin] = 1;
				}
				
				if(app.ArduinoPin[pin] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + pin + ",OUTPUT);" + '\n');
					app.ArduinoPin[pin] = 2;
				}
				
				var strcp:String = new String();
				var angle:Number = interp.numarg(b,1);//角度值，模块参数第一个，参数类型为数字_wh
				if(app.ArduinoValueFlag == true)
				{
					strcp = app.ArduinoValueStr;
					app.ArduinoValueFlag = false;
				}
				else
					if(app.ArduinoMathFlag == true)
					{
						strcp = app.ArduinoMathStr[0];
						app.ArduinoMathFlag = false;
					}
					else
						if(app.ArduinoReadFlag == true)
						{
							strcp = app.ArduinoReadStr[0];
							app.ArduinoReadFlag = false;
						}
						else
							strcp = angle.toString();
				
				if(app.ArduinoLoopFlag == true)
				{
					app.ArduinoLoopFs.writeUTFBytes("myservo_cfun" +pin + ".attach(" + pin + ");" + '\n');
					app.ArduinoLoopFs.writeUTFBytes("myservo_cfun" +pin + ".write(" + strcp + ");" + '\n');
				}
				else
				{
					app.ArduinoDoFs.writeUTFBytes("myservo_cfun" +pin + ".attach(" + pin + ");" + '\n');
					app.ArduinoDoFs.writeUTFBytes("myservo_cfun" +pin + ".write(" + strcp + ");" + '\n');
				}
			}
			else
			{
				pin = interp.numarg(b,0);//引脚号，模块参数第一个，参数类型为数字_wh
				angle = interp.numarg(b,1);//角度值，模块参数第一个，参数类型为数字_wh
				//内嵌模块，没有有效返回_wh
				if(app.interp.activeThread.ArduinoNA)//加有效性判断_wh
				{
					app.interp.activeThread.ArduinoNA = false;
					return;
				}
				
				//通信协议：0xff 0x55; 0x83（舵机角度类型）; pin（管脚号）; 角度_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_SetSG);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(angle);
				app.CFunDelayms(5);//延时15ms_wh
			}
		}
		
		//写无源蜂鸣器音乐输出_wh
		private function primSetMUS(b:Block):void
		{
			var pin:Number = interp.numarg(b,0);//引脚号，模块参数第一个，参数类型为数字_wh
			var tone:Number;//音调，模块参数第一个，参数类型为数字_wh
			var meter:Number;//节拍_wh
			switch(interp.arg(b,1))
			{
				case "C2":tone = 65;break;
				case "D2":tone = 73;break;
				case "E2":tone = 82;break;
				case "F2":tone = 87;break;
				case "G2":tone = 98;break;
				case "A2":tone = 110;break;
				case "B2":tone = 123;break;
				case "C3":tone = 134;break;
				case "D3":tone = 147;break;
				case "E3":tone = 165;break;
				case "F3":tone = 175;break;
				case "G3":tone = 196;break;
				case "A3":tone = 220;break;
				case "B3":tone = 247;break;
				case "C4":tone = 262;break;
				case "D4":tone = 294;break;
				case "E4":tone = 330;break;
				case "F4":tone = 349;break;
				case "G4":tone = 392;break;
				case "A4":tone = 440;break;
				case "B4":tone = 494;break;
				case "C5":tone = 523;break;
				case "D5":tone = 587;break;
				case "E5":tone = 659;break;
				case "F5":tone = 698;break;
				case "G5":tone = 784;break;
				case "A5":tone = 880;break;
				case "B5":tone = 998;break;
				case "C6":tone = 1047;break;
				case "D6":tone = 1175;break;
				case "E6":tone = 1319;break;
				case "F6":tone = 1397;break;
				case "G6":tone = 1568;break;
				case "A6":tone = 1760;break;
				case "B6":tone = 1976;break;
				case "C7":tone = 2093;break;
				case "D7":tone = 2349;break;
				case "E7":tone = 2637;break;
				case "F7":tone = 2794;break;
				case "G7":tone = 3136;break;
				case "A7":tone = 3520;break;
				default:break;
			}
			switch(interp.arg(b,2))
			{
				case "1/2":meter = 500;break;
				case "1/4":meter = 250;break;
				case "1/8":meter = 125;break;
				case "whole":meter = 1000;break;
				case "double":meter = 2000;break;
				case "stop":meter = 0;break;
				default:break;
			}
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				app.ArduinoBuz = true;
				app.ArduinoMathNum = 0;
				
				if(app.ArduinoBlock[ID_SetMUS][pin] == 0)
				{
					app.ArduinoHeadFs.writeUTFBytes("CFunBuzzer buzzer_cfun" + pin + "(" + pin + ");" + '\n');
					app.ArduinoBlock[ID_SetMUS][pin] = 1;
				}
				
				if(app.ArduinoPin[pin] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + pin + ",OUTPUT);" + '\n');
					app.ArduinoPin[pin] = 2;
				}
				
				if(app.ArduinoLoopFlag == true)
				{
					app.ArduinoLoopFs.writeUTFBytes("buzzer_cfun" + pin + ".tone(" + pin + "," + tone + "," +meter + ");" + '\n');
					app.ArduinoLoopFs.writeUTFBytes("delay(" + meter  + ");" + '\n');
				}
				else
				{
					app.ArduinoDoFs.writeUTFBytes("buzzer_cfun" + pin + ".tone(" + pin + "," + tone + "," +meter + ");" + '\n');
					app.ArduinoDoFs.writeUTFBytes("delay(" + meter  + ");" + '\n');
				}
			}
			else//正常上位机运行模式_wh
			{
				var numf:Array = new Array();
				var numfs:ByteArray = new ByteArray();
				numfs.writeShort(tone);
				numfs.position = 0;
				numf[0] = numfs.readByte();
				numf[1] = numfs.readByte();
				
				var numfm:Array = new Array();
				var numfms:ByteArray = new ByteArray();
				numfms.writeShort(meter);
				numfms.position = 0;
				numfm[0] = numfms.readByte();
				numfm[1] = numfms.readByte();
				
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_SetMUS);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(numf[0]);
				app.arduino.writeByte(numf[1]);
				app.arduino.writeByte(numfm[0]);
				app.arduino.writeByte(numfm[1]);
				app.CFunDelayms(5);//延时15ms_wh
			}
		}
		
		//写数码管输出数值_wh
		private function primSetNUM(b:Block):void
		{
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				app.ArduinoSeg = true;
				app.ArduinoMathNum = 0;
				var pin:Number = interp.numarg(b,0);//引脚号，模块参数第一个，参数类型为数字_wh
				if(app.ArduinoBlock[ID_SetNUM][pin] == 0)
				{
					app.ArduinoHeadFs.writeUTFBytes("CFun7SegmentDisplay seg_cfun" + pin + "(" + pin + ");" + '\n');
					app.ArduinoHeadFs.writeUTFBytes("unsigned long _distime;" + '\n');
					app.ArduinoHeadFs.writeUTFBytes("float  _disvalue;" + '\n');
					app.ArduinoBlock[ID_SetNUM][pin] = 1;
				}
				
				if(app.ArduinoPin[pin] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + pin + ",OUTPUT);" + '\n');
					app.ArduinoPin[pin] = 2;
				}
				if(app.ArduinoPin[pin+1] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + (pin+1) + ",OUTPUT);" + '\n');
					app.ArduinoPin[pin+1] = 2;
				}
				if(app.ArduinoPin[pin+2] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + (pin+2) + ",OUTPUT);" + '\n');
					app.ArduinoPin[pin+2] = 2;
				}
				
				var strcp:Array = new Array;
				strcp[0] = pin.toString();
				
				var num:Number = interp.numarg(b,1);
				if(app.ArduinoValueFlag == true)
				{
					strcp[1] = app.ArduinoValueStr;
					app.ArduinoValueFlag = false;
				}
				else
					if(app.ArduinoMathFlag == true)
					{
						strcp[1] = app.ArduinoMathStr[0];
						app.ArduinoMathFlag = false;
					}
					else
						if(app.ArduinoReadFlag == true)
						{
							strcp[1] = app.ArduinoReadStr[0];
							app.ArduinoReadFlag = false;
						}
						else
							strcp[1] = num.toString();
				
				if(app.ArduinoLoopFlag == true)
				{
					app.ArduinoLoopFs.writeUTFBytes("seg_cfun" + strcp[0] + ".display(" + strcp[1] + ");" + '\n');
				}
				else
				{
					app.ArduinoDoFs.writeUTFBytes("seg_cfun" + strcp[0] + ".display(" + strcp[1] + ");" + '\n');
				}
			}
			else
			{
				pin = interp.numarg(b,0);
				num = interp.numarg(b,1);
				//内嵌模块，没有有效返回_wh
				if(app.interp.activeThread.ArduinoNA)//加有效性判断_wh
				{
					app.interp.activeThread.ArduinoNA = false;
					return;
				}
				
				var numf:Array = new Array();
				var numfs:ByteArray = new ByteArray();
				numfs.writeFloat(num);
				numfs.position = 0;
				numf[0] = numfs.readByte();
				numf[1] = numfs.readByte();
				numf[2] = numfs.readByte();
				numf[3] = numfs.readByte();
				
				
				//通信协议：0xff 0x55; 0x85（数码管类型）; pin（管脚号）; 数值_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_SetNUM);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(numf[0]);
				app.arduino.writeByte(numf[1]);
				app.arduino.writeByte(numf[2]);
				app.arduino.writeByte(numf[3]);
				app.CFunDelayms(5);//延时15ms_wh
			}
		}
		
		//写电机输出正负PWM_wh
		private function primSetDM(b:Block):void
		{
			var pins:String;
			var pin:Number;
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				app.ArduinoDCM = true;
				app.ArduinoMathNum = 0;
				pins = interp.arg(b,0);//引脚号，模块参数第一个，参数类型为数字_wh
				if(pins == "M1")
					pin = 5;
				else
					pin = 6;
				
				if(app.ArduinoBlock[ID_SetDM][pin] == 0)
				{
					app.ArduinoHeadFs.writeUTFBytes("CFunDCMotor   dc_cfun" + pin + "(" + pin + ");" + '\n');
					app.ArduinoBlock[ID_SetDM][pin] = 1;
				}
//				if(app.ArduinoBlock[ID_DIR] == 0)
//				{
//					app.ArduinoHeadFs.writeUTFBytes("double dir_cfun;" + '\n');
//					app.ArduinoBlock[ID_DIR] = 1;
//				}
				
				if(app.ArduinoPin[pin] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + pin + ",OUTPUT);" + '\n');
					app.ArduinoPin[pin] = 2;
				}
				if(app.ArduinoPin[pin+2] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + (pin+2) + ",OUTPUT);" + '\n');
					app.ArduinoPin[pin+1] = 2;
				}
				
				var strcp:Array = new Array;
				strcp[0] = pin.toString();
				
				//注意：方向电机中不能为
				var dirs:String = interp.arg(b,1);
				var pwm:Number = interp.numarg(b,2);//角度值，模块参数第一个，参数类型为数字_wh
				if(app.ArduinoValueFlag == true)
				{
					strcp[1] = app.ArduinoValueStr;
					app.ArduinoValueFlag = false;
				}
				else
					if(app.ArduinoMathFlag == true)
					{
						strcp[1] = app.ArduinoMathStr[0];
						app.ArduinoMathFlag = false;
					}
					else
						if(app.ArduinoReadFlag == true)
						{
							strcp[1] = app.ArduinoReadStr[0];
							app.ArduinoReadFlag = false;
						}
						else
							strcp[1] = pwm.toString();
				
				if(app.ArduinoLoopFlag == true)
				{
					if(dirs == "forward")
						app.ArduinoLoopFs.writeUTFBytes("dc_cfun" + strcp[0] + ".motorrun(1,"  +strcp[1] + ");" + '\n');
					else
						app.ArduinoLoopFs.writeUTFBytes("dc_cfun" + strcp[0] + ".motorrun(0,"  +strcp[1] + ");" + '\n');
				}
				else
				{
					if(dirs == "forward")
						app.ArduinoDoFs.writeUTFBytes("dc_cfun" + strcp[0] + ".motorrun(1," +  strcp[1] + ");" + '\n');
					else
						app.ArduinoDoFs.writeUTFBytes("dc_cfun" + strcp[0] + ".motorrun(0," +  strcp[1] + ");" + '\n');
				}
			}
			else
			{
				pins = interp.arg(b,0);//引脚号，模块参数第一个，参数类型为数字_wh
				if(pins == "M1")
					pin = 5;
				else
					pin = 6;
				dirs = interp.arg(b,1);//角度值，模块参数第一个，参数类型为数字_wh
				pwm = interp.numarg(b,2);//角度值，模块参数第一个，参数类型为数字_wh
				//内嵌模块，没有有效返回_wh
				if(app.interp.activeThread.ArduinoNA)//加有效性判断_wh
				{
					app.interp.activeThread.ArduinoNA = false;
					return;
				}
				
				var dir:uint = 1;
				if(dirs == "back")
				{
					dir = 0;
				}
				
				//通信协议：0xff 0x55; 0x86（电机正负PWM类型）; pin（管脚号）; pwm（WPM量）_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_SetDM);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(dir);
				app.arduino.writeByte(pwm);
				app.CFunDelayms(5);//延时15ms_wh
			}
		}
		
		//写三色LED_wh
		private function primSetRGB(b:Block):void
		{
			//var pin:Number = interp.numarg(b,0);//引脚号，模块参数第一个，参数类型为数字_wh
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				app.ArduinoRGB = true;//三色灯_wh
				if(app.ArduinoBlock[ID_SetRGB] == 0)
				{
					app.ArduinoHeadFs.writeUTFBytes("CFunRGBLed led_cfun(9);" + '\n');
					app.ArduinoBlock[ID_SetRGB] = 1;
				}
				
				if(app.ArduinoPin[9] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(9,OUTPUT);" + '\n');
					app.ArduinoPin[9] = 2;
				}
				if(app.ArduinoPin[10] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(10,OUTPUT);" + '\n');
					app.ArduinoPin[10] = 2;
				}
				if(app.ArduinoPin[11] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(11,OUTPUT);" + '\n');
					app.ArduinoPin[11] = 2;
				}
				
				var strcp:Array = new Array;
				app.ArduinoMathNum = 0;
				var red:Number = interp.numarg(b,0);//red_wh
				if(app.ArduinoValueFlag == true)
				{
					strcp[0] = app.ArduinoValueStr;
					app.ArduinoValueFlag = false;
				}
				else
					if(app.ArduinoMathFlag == true)
					{
						strcp[0] = app.ArduinoMathStr[0];
						app.ArduinoMathFlag = false;
					}
					else
						if(app.ArduinoReadFlag == true)
						{
							strcp[0] = app.ArduinoReadStr[0];
							app.ArduinoReadFlag = false;
						}
						else
							strcp[0] = red.toString();
				app.ArduinoMathNum = 0;
				var green:Number = interp.numarg(b,1);//red_wh
				if(app.ArduinoValueFlag == true)
				{
					strcp[1] = app.ArduinoValueStr;
					app.ArduinoValueFlag = false;
				}
				else
					if(app.ArduinoMathFlag == true)
					{
						strcp[1] = app.ArduinoMathStr[0];
						app.ArduinoMathFlag = false;
					}
					else
						if(app.ArduinoReadFlag == true)
						{
							strcp[1] = app.ArduinoReadStr[0];
							app.ArduinoReadFlag = false;
						}
						else
							strcp[1] = green.toString();
				app.ArduinoMathNum = 0;
				var bule:Number = interp.numarg(b,2);//red_wh
				if(app.ArduinoValueFlag == true)
				{
					strcp[2] = app.ArduinoValueStr;
					app.ArduinoValueFlag = false;
				}
				else
					if(app.ArduinoMathFlag == true)
					{
						strcp[2] = app.ArduinoMathStr[0];
						app.ArduinoMathFlag = false;
					}
					else
						if(app.ArduinoReadFlag == true)
						{
							strcp[2] = app.ArduinoReadStr[0];
							app.ArduinoReadFlag = false;
						}
						else
							strcp[2] = bule.toString();
				
				if(app.ArduinoLoopFlag == true)
				{
					app.ArduinoLoopFs.writeUTFBytes("led_cfun.setColorAt(" + strcp[0] + "," + strcp[1] + "," + strcp[2] + ");" + '\n');
				}
				else
				{
					app.ArduinoDoFs.writeUTFBytes("led_cfun.setColorAt(" + strcp[0] + "," + strcp[1] + "," + strcp[2] + ");" + '\n');
				}
			}
			else
			{
				red = interp.numarg(b,0);//red_wh
				green = interp.numarg(b,1);//red_wh
				bule = interp.numarg(b,2);//red_wh
				//内嵌模块，没有有效返回_wh
				if(app.interp.activeThread.ArduinoNA)//加有效性判断_wh
				{
					app.interp.activeThread.ArduinoNA = false;
					return;
				}
				
				//通信协议：0xff 0x55; 0x87（三色LED）; pin（0x09）; 三色pwm（WPM量）_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_SetRGB);
				app.arduino.writeByte(0x09);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(red);
				app.arduino.writeByte(green);
				app.arduino.writeByte(bule);
				app.CFunDelayms(5);//延时15ms_wh
			}
		}
		
		//读外设数据输入，读之前的命令发送在Interpreter.as的evalCmd(b:Block)处理_wh
		//读数字口输入_wh
		private function primReadBit(b:Block):Boolean
		{			
			var hl:Boolean = app.comDataArray[7];
			app.comDataArray.length = 0;//数组清零_wh
			app.comDataArrayOld.length = 0;//数组清零_wh
			return hl;
		}
		
		//_wh
		private function primReadByte(b:Block):int
		{			
			var byte:Number = app.comDataArray[7];
			app.comDataArray.length = 0;//数组清零_wh
			app.comDataArrayOld.length = 0;//数组清零_wh
			return byte;
		}
		
		//读数字口输入命令发送_wh
		private function primReadDigital(b:Block):void
		{
			var pin:Number = interp.numarg(b,0);//引脚号，模块参数第一个，参数类型为数字_wh
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				if(app.ArduinoPin[pin] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + pin + ",INPUT);" + '\n');
					app.ArduinoPin[pin] = 1;
				}
				
				var strcp:String = new String();
				strcp = pin.toString();
				//app.ArduinoDoFs.writeUTFBytes("digitalRead(" + pin + ")");
				app.ArduinoReadStr[0] = "digitalRead(" + strcp + ")";
				app.ArduinoReadFlag = true;
			}
			else//正常上位机运行模式_wh
			{
				//通信协议：0xff 0x55; 0x01（IO输入高低电平类型）; pin（管脚号）; 00 00 00 00_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_ReadDigital);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
			}
		}
		
		//读数字口输入命令发送_wh
		private function primReadDigitals(b:Block):void
		{
			var pin:Number = interp.numarg(b,1);//引脚号，模块参数第一个，参数类型为数字_wh
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				if(app.ArduinoPin[pin] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + pin + ",INPUT);" + '\n');
					app.ArduinoPin[pin] = 1;
				}
				
				var strcp:String = new String();
				strcp = pin.toString();
				//app.ArduinoDoFs.writeUTFBytes("digitalRead(" + pin + ")");
				app.ArduinoReadStr[0] = "digitalRead(" + strcp + ")";
				app.ArduinoReadFlag = true;
			}
			else//正常上位机运行模式_wh
			{
				//通信协议：0xff 0x55; 0x01（IO输入高低电平类型）; pin（管脚号）; 00 00 00 00_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_ReadDigital);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
			}
		}
		
		//ckd_wh
		private function primReadCkK1(b:Block):void
		{
			var pin:Number=2;
			
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				if(app.ArduinoPin[pin] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + pin + ",INPUT);" + '\n');
					app.ArduinoPin[pin] = 1;
				}
				
				var strcp:String = new String();
				strcp = pin.toString();
				//app.ArduinoDoFs.writeUTFBytes("digitalRead(" + pin + ")");
				app.ArduinoReadStr[0] = "digitalRead(" + strcp + ")";
				app.ArduinoReadFlag = true;
			}
			else//正常上位机运行模式_wh
			{
				//通信协议：0xff 0x55; 0x01（IO输入高低电平类型）; pin（管脚号）; 00 00 00 00_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_ReadDigital);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
			}
		}
		
		//ckd_wh
		private function primReadCkK2(b:Block):void
		{
			var pin:Number=3;
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				if(app.ArduinoPin[pin] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + pin + ",INPUT);" + '\n');
					app.ArduinoPin[pin] = 1;
				}
				
				var strcp:String = new String();
				strcp = pin.toString();
				//app.ArduinoDoFs.writeUTFBytes("digitalRead(" + pin + ")");
				app.ArduinoReadStr[0] = "digitalRead(" + strcp + ")";
				app.ArduinoReadFlag = true;
			}
			else//正常上位机运行模式_wh
			{
				//通信协议：0xff 0x55; 0x01（IO输入高低电平类型）; pin（管脚号）; 00 00 00 00_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_ReadDigital);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
			}
		}
		
		//读循迹输入命令发送_wh
		private function primReadTrack(b:Block):void
		{
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				app.ArduinoTra = true;
				if(app.ArduinoBlock[ID_ReadTRACK] == 0)
				{
					app.ArduinoHeadFs.writeUTFBytes("CFunTrack  tk_cfun;" + '\n');
					app.ArduinoBlock[ID_ReadTRACK] = 1;
					if(app.ArduinoBlock[ID_SetGRAY] == 0)
					{
						app.ArduinoHeadFs.writeUTFBytes("unsigned int Tgray_cfun = 600;" + '\n');
						app.ArduinoBlock[ID_SetGRAY] = 1;
					}
				}
				
				app.ArduinoReadStr[0] = "tk_cfun.Track(Tgray_cfun)";
				app.ArduinoReadFlag = true;
			}
			else
			{
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_ReadTRACK);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
			}
		}
		
		//读避障输入命令发送_wh
		private function primReadAvoid(b:Block):void
		{
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				app.ArduinoAvo = true;
				if(app.ArduinoBlock[ID_ReadAVOID] == 0)
				{
					app.ArduinoHeadFs.writeUTFBytes("CFunAvoid av_cfun;" + '\n');
					app.ArduinoBlock[ID_ReadAVOID] = 1;
				}
				
				if(app.ArduinoPin[12] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(12,INPUT);" + '\n');
					app.ArduinoPin[12] = 1;
				}
				if(app.ArduinoPin[13] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(13,INPUT);" + '\n');
					app.ArduinoPin[13] = 1;
				}
				
				app.ArduinoReadStr[0] = "av_cfun.Avoid()";
				app.ArduinoReadFlag = true;
			}
			else
			{
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_ReadAVOID);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
			}
		}
		
//		//读超声波输入命令发送_wh
//		private function primReadUltr(b:Block):void
//		{
//			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
//			{
//				if(app.ArduinoBlock[ID_ReadULTR] == 0)
//				{
//					app.ArduinoHeadFs.writeUTFBytes("CFunUltrasonic us_cfun(2);" + '\n');
//					app.ArduinoBlock[ID_ReadULTR] = 1;
//				}
//				
//				if(app.ArduinoPin[2] == 0)
//				{
//					app.ArduinoPinFs.writeUTFBytes("pinMode(2,INPUT);" + '\n');
//					app.ArduinoPin[2] = 1;
//				}
//				if(app.ArduinoPin[3] == 0)
//				{
//					app.ArduinoPinFs.writeUTFBytes("pinMode(3,OUTPUT);" + '\n');
//					app.ArduinoPin[3] = 2;
//				}
//				
//				app.ArduinoReadStr[0] = "us_cfun.distanceCm()";
//				app.ArduinoReadFlag = true;
//			}
//			else
//			{
//				app.arduino.writeByte(0xff);
//				app.arduino.writeByte(0x55);
//				app.arduino.writeByte(ID_ReadULTR);
//				app.arduino.writeByte(0x00);
//				app.arduino.writeByte(0x00);
//				app.arduino.writeByte(0x00);
//				app.arduino.writeByte(0x00);
//				app.arduino.writeByte(0x00);
//			}
//		}
		
		//读电量输入命令发送_wh
		private function primReadPower(b:Block):void
		{
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				if(app.ArduinoBlock[ID_ReadPOWER] == 0)
				{
					app.ArduinoHeadFs.writeUTFBytes("CFunPort  volt_cfun;" + '\n');
					app.ArduinoBlock[ID_ReadPOWER] = 1;
				}
				
				app.ArduinoReadStr[0] = "volt_cfun.minicarVolt()";
				app.ArduinoReadFlag = true;
			}
			else
			{
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_ReadPOWER);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
			}
		}
		
		//读电量输入命令发送_wh
		private function primReadFraredR(b:Block):void
		{
			var pin:Number = interp.numarg(b,0);//引脚号，模块参数第一个，参数类型为数字_wh
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				app.ArduinoIR = true;
				if(app.ArduinoBlock[ID_READFRAREDR] == 0)
				{
					app.ArduinoHeadFs.writeUTFBytes("CFunIR  ir_cfun" + pin + "(" + pin + ");" + '\n');
					app.ArduinoBlock[ID_READFRAREDR] = 1;
				}
				
				if(app.ArduinoPin[pin] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + pin + ",INPUT);" + '\n');
					app.ArduinoPin[pin] = 1;
				}
				
				app.ArduinoReadStr[0] = "ir_cfun" + pin + ".getCode()";
				app.ArduinoReadFlag = true;
			}
			else
			{
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_READFRAREDR);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
			}
		}
		
		//读电容值输入命令发送_wh
		private function primReadCap(b:Block):void
		{
			var pin:Number = interp.numarg(b,0);//引脚号，模块参数第一个，参数类型为数字_wh
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				app.ArduinoCap = true;
				if(app.ArduinoPin[pin] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + pin + ",INPUT);" + '\n');
					app.ArduinoPin[pin] = 1;
				}
				
				var strcp:String = new String();
				strcp = pin.toString();
				//app.ArduinoDoFs.writeUTFBytes("digitalRead(" + pin + ")");
				app.ArduinoReadStr[0] = "readCapacitivePin(" + strcp + ")";
				app.ArduinoReadFlag = true;
			}
			else//正常上位机运行模式_wh
			{
				//通信协议：0xff 0x55; 0x08（IO输入电容值类型）; pin（管脚号）; 00 00 00 00_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_ReadCap);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
			}
		}
		
		//读外设数据输入，读之前的命令发送在Interpreter.as的evalCmd(b:Block)处理_wh
		//读数字口输入_wh
		private function primReadShort(b:Block):int
		{			
			var numba:ByteArray = new ByteArray();//4字节流转浮点型（注意大端顺序）_wh
			numba.writeByte(app.comDataArray[6]);
			numba.writeByte(app.comDataArray[7]);
			numba.position = 0;
			var num:Number = numba.readShort();
			app.comDataArray.length = 0;//数组清零_wh
			app.comDataArrayOld.length = 0;//数组清零_wh
			return num;
		}
		
		//读模拟口输入命令发送_wh
		private function primReadAnalog(b:Block):void
		{
			var pin:Number = interp.numarg(b,0);//引脚号，模块参数第一个，参数类型为数字_wh

			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				var strcp:String = new String();
				strcp = pin.toString();
				//app.ArduinoDoFs.writeUTFBytes("analogRead(" + pin + ")");
				app.ArduinoReadStr[0] = "analogRead(" + strcp + ")";
				app.ArduinoReadFlag = true;
			}
			else//正常上位机运行模式_wh
			{
				//通信协议：0xff 0x55; 0x02（IO输入模拟量类型）; pin（管脚号）; 00 00 00 00_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_ReadAnalog);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);	
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				//app.CFunDelayms(5);
			}
		}
		
		//读模拟口输入命令发送_wh
		private function primReadAnalogs(b:Block):void
		{
			var pin:Number = interp.numarg(b,1);//引脚号，模块参数第2个，参数类型为数字_wh
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				var strcp:String = new String();
				strcp = pin.toString();
				//app.ArduinoDoFs.writeUTFBytes("analogRead(" + pin + ")");
				app.ArduinoReadStr[0] = "analogRead(" + strcp + ")";
				app.ArduinoReadFlag = true;
			}
			else//正常上位机运行模式_wh
			{
				//通信协议：0xff 0x55; 0x02（IO输入模拟量类型）; pin（管脚号）; 00 00 00 00_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_ReadAnalog);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);	
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
			}
		}
		
		//cka_wh
		private function primReadCkSo(b:Block):void
		{
			var pin:Number = 3;
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				var strcp:String = new String();
				strcp = pin.toString();
				//app.ArduinoDoFs.writeUTFBytes("analogRead(" + pin + ")");
				app.ArduinoReadStr[0] = "analogRead(" + strcp + ")/5";
				app.ArduinoReadFlag = true;
			}
			else//正常上位机运行模式_wh
			{
				//通信协议：0xff 0x55; 0x02（IO输入模拟量类型）; pin（管脚号）; 00 00 00 00_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_ReadAnalog);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);	
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
			}
		}
		
		//cka_wh
		private function primReadCkSi(b:Block):void
		{
			var pin:Number = 4;
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				var strcp:String = new String();
				strcp = pin.toString();
				//app.ArduinoDoFs.writeUTFBytes("analogRead(" + pin + ")");
				app.ArduinoReadStr[0] = "analogRead(" + strcp + ")*100/1023";
				app.ArduinoReadFlag = true;
			}
			else//正常上位机运行模式_wh
			{
				//通信协议：0xff 0x55; 0x02（IO输入模拟量类型）; pin（管脚号）; 00 00 00 00_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_ReadAnalog);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);	
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
			}
		}
		
		//cka_wh
		private function primReadCkLi(b:Block):void
		{
			var pin:Number = 5;
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				var strcp:String = new String();
				strcp = pin.toString();
				//app.ArduinoDoFs.writeUTFBytes("analogRead(" + pin + ")");
				app.ArduinoReadStr[0] = "analogRead(" + strcp + ")*100/1023";
				app.ArduinoReadFlag = true;
			}
			else//正常上位机运行模式_wh
			{
				//通信协议：0xff 0x55; 0x02（IO输入模拟量类型）; pin（管脚号）; 00 00 00 00_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_ReadAnalog);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);	
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
			}
		}
		
		//cka_wh
		private function primReadCkJX(b:Block):void
		{
			var pin:Number = 1;
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				var strcp:String = new String();
				strcp = pin.toString();
				//app.ArduinoDoFs.writeUTFBytes("analogRead(" + pin + ")");
				app.ArduinoReadStr[0] = "(analogRead(" + strcp + ")*200/1023-100)";
				app.ArduinoReadFlag = true;
			}
			else//正常上位机运行模式_wh
			{
				//通信协议：0xff 0x55; 0x02（IO输入模拟量类型）; pin（管脚号）; 00 00 00 00_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_ReadAnalog);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);	
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
			}
		}
		
		//cka_wh
		private function primReadCkJY(b:Block):void
		{
			var pin:Number = 2;
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				var strcp:String = new String();
				strcp = pin.toString();
				//app.ArduinoDoFs.writeUTFBytes("analogRead(" + pin + ")");
				app.ArduinoReadStr[0] = "(analogRead(" + strcp + ")*200/1023-100)";
				app.ArduinoReadFlag = true;
			}
			else//正常上位机运行模式_wh
			{
				//通信协议：0xff 0x55; 0x02（IO输入模拟量类型）; pin（管脚号）; 00 00 00 00_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_ReadAnalog);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);	
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
			}
		}
		
		//读外设数据输入，读之前的命令发送在Interpreter.as的evalCmd(b:Block)处理_wh
		//读数字口输入float值_wh
		private function primReadFloat(b:Block):String
		{			
			var numba:ByteArray = new ByteArray();//4字节流转浮点型（注意大端顺序）_wh
			numba.writeByte(app.comDataArray[4]);
			numba.writeByte(app.comDataArray[5]);
			numba.writeByte(app.comDataArray[6]);
			numba.writeByte(app.comDataArray[7]);
			numba.position = 0;
			var num:Number = numba.readFloat();
			app.comDataArray.length = 0;//数组清零_wh
			app.comDataArrayOld.length = 0;//数组清零_wh
			return num.toFixed(1);
		}
		
		//读模拟口输入float命令发送_wh
		private function primReadAFloat(b:Block):void
		{
			var pin:Number = interp.numarg(b,0);//引脚号，模块参数第一个，参数类型为数字_wh
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				app.ArduinoTem = true;
				if(app.ArduinoBlock[ID_ReadAFloat][pin] == 0)
				{
					app.ArduinoHeadFs.writeUTFBytes("CFunTemperature ts_cfun" +pin + "(" + pin + ");" + '\n');
					app.ArduinoBlock[ID_ReadAFloat][pin] = 1;
				}
				
				app.ArduinoReadStr[0] = "ts_cfun" + pin + ".temperature()";
				app.ArduinoReadFlag = true;
			}
			else
			{
				//通信协议：0xff 0x55; 0x03（IO输入模拟量float类型）; pin（管脚号）; 00 00 00 00_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_ReadAFloat);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);	
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
			}
		}
		
		//超身波输入float命令发送_wh
		private function primReadPFloat(b:Block):void
		{
			//var pin:Number = interp.numarg(b,0);//引脚号，模块参数第一个，参数类型为数字_wh
			var pin:Number = 2;//引脚号，模块参数第一个，参数类型为数字_wh
			
			if(app.ArduinoFlag == true)//判断是否为Arduino语句生成过程_wh
			{
				app.ArduinoUs = true;
				if(app.ArduinoBlock[ID_ReadPFloat][pin] == 0)
				{
					app.ArduinoHeadFs.writeUTFBytes("CFunUltrasonic us_cfun;" + '\n');
					app.ArduinoHeadFs.writeUTFBytes('unsigned long _itime;' + '\n' + 'unsigned long _iustime;' + '\n');
					app.ArduinoBlock[ID_ReadPFloat][pin] = 1;
				}
				
				if(app.ArduinoPin[pin] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + pin + ",OUTPUT);" + '\n');
					app.ArduinoPin[pin] = 1;
				}
				if(app.ArduinoPin[pin+1] == 0)
				{
					app.ArduinoPinFs.writeUTFBytes("pinMode(" + (pin+1) + ",INPUT);" + '\n');
					app.ArduinoPin[pin+1] = 2;
				}
				
				app.ArduinoReadStr[0] = "us_cfun.distanceCm()";
				app.ArduinoReadFlag = true;
			}
			else
			{
				//通信协议：0xff 0x55; 0x04（超声波float类型）; pin（管脚号）; 00 00 00 00_wh 
				app.arduino.writeByte(0xff);
				app.arduino.writeByte(0x55);
				app.arduino.writeByte(ID_ReadPFloat);
				app.arduino.writeByte(pin);
				app.arduino.writeByte(0x00);	
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
				app.arduino.writeByte(0x00);
			}
		}
	}
}