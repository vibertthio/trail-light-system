import codeanticode.syphon.*;
import controlP5.*;
import themidibus.*;
import processing.serial.*;


// controlP5
ControlP5 cp5;
Accordion accordion;

//midi mode monitor
//boolean buttonStatus[] = new boolean[2];

// Syphon
SyphonServer server;
PGraphics canvas;

// MIDI
MidiBus midiA; //APC20
MidiBus midiB; //Midi Fighter

// Arduino
Serial myPort;

System system;

color c = color(0, 160, 100);
float master = 1;


void settings() {
  size(1400, 800, P3D);
  PJOGL.profile=1;
}

void setup() {
  background(0);
  canvas = createGraphics(width, height, P3D);
  system = new System();

  // controlP5
  gui();





  // Syphon
  server = new SyphonServer(this, "Processing Syphon");

  // midi
  midiA = new MidiBus(this, "Akai APC20", -1, "Akai");
  midiB = new MidiBus(this, "Midi Fighter 3D", -1, "DJ TECHTOOLS");

  // Arduino
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[3], 9600);
  // myPort = new Serial(this, Serial.list()[0], 9600);
}

void renderMIDIMode() {

  if (system.getIndependentMode()) {
    fill(255,155,155);
  } else {
    fill(137,201,151);
  }
  rect(50, 250, 30, 30);
  if (system.getFadeControlMode()) {
    fill(255,155,155);
  } else {
    fill(137,201,151);
  }
  rect(100, 250, 30, 30);
}


void draw() {
  background(0);
  system.render();
  // control mode
  renderMIDIMode();
}

void gui() {

  cp5 = new ControlP5(this);

  // group number 1
  Group g1 = cp5.addGroup("bang test")
                .setBackgroundColor(color(0, 64))
                .setBackgroundHeight(100)
                ;

  cp5.addBang("dim_on")
     .setPosition(10,20)
     .setSize(30,30)
     .moveTo(g1)
     .setId(0)
     ;
  cp5.addBang("dim_off")
     .setPosition(60,20)
     .setSize(30,30)
     .moveTo(g1)
     .setId(1)
     ;

  // group number 2
  Group g2 = cp5.addGroup("Slider Control")
                .setBackgroundColor(color(64, 0))
                .setBackgroundHeight(150)
                ;

  cp5.addSlider("master")
     .setPosition(10,20)
     .setSize(100,20)
     .setRange(0,127)
     .setValue(100)
     .moveTo(g2)
     ;

  cp5.addSlider("elapse")
     .setPosition(10,50)
     .setSize(100,20)
     .setRange(0,127)
     .setValue(200)
     .moveTo(g2)
     ;

  // create a new accordion
  // add g1, g2 to the accordion.
  accordion = cp5.addAccordion("acc")
                 .setPosition(40,40)
                 .setWidth(200)
                 .addItem(g1)
                 .addItem(g2)
                 ;

  //cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.open(0,1,2);}}, 'o');
  //cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.close(0,1,2);}}, 'c');
  //cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setWidth(300);}}, '1');
  //cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setPosition(0,0);accordion.setItemHeight(190);}}, '2');
  //cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.ALL);}}, '3');
  //cp5.mapKeyFor(new ControlKey() {public void keyEvent() {accordion.setCollapseMode(ControlP5.SINGLE);}}, '4');
  //cp5.mapKeyFor(new ControlKey() {public void keyEvent() {cp5.remove("myGroup1");}}, '0');

  accordion.open(0);
  accordion.open(1);

  // use Accordion.MULTI to allow multiple group
  // to be open at a time.
  accordion.setCollapseMode(Accordion.MULTI);

  // when in SINGLE mode, only 1 accordion
  // group can be open at a time.
  // accordion.setCollapseMode(Accordion.SINGLE);
}

public void controlEvent(ControlEvent theEvent) {
  if (theEvent.isController()) {
    // println(
    // "## controlEvent / id:"+theEvent.controller().getId()+
    //   " / name:"+theEvent.controller().getName()+
    //   " / value:"+theEvent.controller().getValue()
    //   );

    // test for fader
    if (theEvent.controller().getName() == "master") {
      float value = theEvent.controller().getValue() / 127.0;
      master = value;
    } else if (theEvent.controller().getName() == "elapse") {
      float value = theEvent.controller().getValue() / 127.0;
      // TODO
      system.setFadeControlValue(value);
    }

    //g1 bang effects
    switch(theEvent.controller().getId()) {
      case(0):
        system.turnOn(300);
        break;
      case(1):
        system.turnOff(300);
        break;
    }
  }
}


//---------------------------------------------------------------------------
// midi mapping
void noteOn(int channel, int pitch, int velocity) {
  //piano //CC是有區間,連續變化的
  // Receive a noteOn
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
  println("****************************");

  //==============================================================
  //APC20
  //Bang effects (先排完一列，再換下一列) (以pitch為主，再分channel)

  //First Row ******************************** 全部
  if (pitch == 53) {
    if (channel == 0) {
      system.dimRepeat(1, 20);              // blink
    } else if(channel == 1) {
      system.turnOnEasingFor(250);          // 前緩後急閃
    } else if(channel == 2) {
      system.dimRepeat(3, 50);              // 連閃 3 次
    } else if(channel == 3) {
      system.bangComplexSequence(0);        // 閃 ->
      //system.turnRandMultipleOnFor(20, 20);       // randon strobe (multiple)
    } else if(channel == 4) {
      system.bangComplexSequence(1);        // 閃 <-
      //system.turnRandOneOnFor(20, 20);            // randon strobe (one)
    } else if(channel == 5) {
      system.bangComplexSequence(2);        // 四列輪閃
    } else if(channel == 6) {
      system.bangFourRandSequence(50);    // randon strobe (取 4 個輪流)
    }
  }
  //Second Row ******************************** 三面輪流
  /*if (pitch == 54) {
    if (channel == 0) {
      system.bangComplexSequence(0);         // 閃 ->
    } else if(channel == 1) {
      system.bangComplexSequence(1);         // 閃 <-
    } else if(channel == 2) {
      system.bangSequence(0, 30);            // 0, 7, 8
    } else if(channel == 3) {
      system.bangSequence(1, 30);            // 3, 4, 11
    } else if(channel == 4) {
      system.bangSequence(2, 30);            // 0, 3, 4, 7, 8, 11
    } else if(channel == 5) {
      system.bangComplexSequence(2);         // 四列輪閃
    } else if(channel == 6) {
      system.bangSequence(4, 30);            // 0, 11, 4, 8
    } else if(channel == 7) {
      system.bangSequence(5, 30);            // 9, 2, 1, 10
    }
  }
  */
  //Third Row ******************************** 左(0-3)
  if (pitch == 55) {
    if (channel == 0) {
      system.dimRepeatCol(1, 20, 0);         // 閃
    } else if(channel == 1) {
      system.turnOnEasingForCol(250, 0);     // 前緩後急閃
    } else if(channel == 2) {
      system.bangSequence(10, 30);           // (▼)往下閃
    } else if(channel == 3) {
      system.bangSequence(11, 30);           // (▲)往上閃
    } else if(channel == 4) {
      system.bangSequence(12, 30);           // 0, 3, 2, 1
    } else if(channel == 5) {
      system.bangAsyncSequence(3);           // dim on (▲), then dim off (▼)
    } else if(channel == 6) {
      system.bangAsyncSequence(0);           // dim on (▼), then dim off (▲)
    } else if(channel == 7) {
      system.bangSequence(13, 30);           // 0, 2, 1, 3
    }
  }
  //Fourth Row ******************************** 中(4-7)
  if (pitch == 56) {
    if (channel == 0) {
      system.dimRepeatCol(1, 20, 1);         // 閃
    } else if(channel == 1) {
      system.turnOnEasingForCol(250, 1);     // 前緩後急閃
    } else if(channel == 2) {
      system.bangSequence(14, 30);           // (▼)往下閃
    } else if(channel == 3) {
      system.bangSequence(15, 30);           // (▲)往上閃
    } else if(channel == 4) {
      system.bangSequence(16, 30);           // 4, 7, 5, 6
    } else if(channel == 5) {
      system.bangAsyncSequence(4);           // dim on (▲), then dim off (▼)
    } else if(channel == 6) {
      system.bangAsyncSequence(1);           // dim on (▼), then dim off (▲)
    } else if(channel == 7)  {
      system.bangSequence(17, 30);           // 7, 5, 6, 4
    }
  }
  //Fifth Row ******************************** 右(8-11)
  if (pitch == 57) {
    if (channel == 0) {
      system.dimRepeatCol(1, 20, 2);         // 閃
    } else if(channel == 1) {
      system.turnOnEasingForCol(250, 2);     // 前緩後急閃
    } else if(channel == 2) {
      system.bangSequence(18, 30);           // (▼)往下閃
    } else if(channel == 3) {
      system.bangSequence(19, 30);           // (▲)往上閃
    } else if(channel == 4) {
      system.bangSequence(20, 30);           // 8, 11, 10, 9
    } else if(channel == 5) {
      system.bangAsyncSequence(5);           // dim on (▲), then dim off (▼)
    } else if(channel == 6) {
      system.bangAsyncSequence(2);           // dim on (▼), then dim off (▲)
    } else if(channel == 7) {
      system.bangSequence(21, 30);           // 8, 10, 9, 11
    }
  }

  //The Rightest Column ********************************
  if (channel == 0) {
    if (pitch == 82) {
      system.turnRandOneOn();               // dim on one (rand)
    } else if (pitch == 83) {
      system.turnRandOneOff();              // dim off one (rand)
    }
  }

  //***************************************************************************
  //IndependentControl for elapse effects
  //trigger Independent mode
  if (channel == 0){
    if (pitch == 81){
      system.triggerIndependentControl();
      //midi mode monitor change color
      //buttonStatus[0] = !buttonStatus[0];
      //render(0);
      //reRenderAll();
    }
  }

  //elapse effects
  if (pitch == 52) {
    if (channel == 0) {
      system.randomBangElapseLeft();
    } else if (channel == 1) {
      system.randomBangElapseRight();
    } else if (channel == 2) {
      system.bangElapseLeft();
    } else if (channel == 3) {
      system.bangElapseRight();
    } else if (channel == 4) {
      system.bangComplexAsyncElapse(0);
    } else if (channel == 5) {
      system.bangComplexAsyncElapse(1);
    } else if (channel == 6) {

    }
  }

  //***************************************************************************
  //AUTO EFFECTS turn-On (以縱行先排完，再換下一行)
  // first column (左至右輪閃)
  if (channel == 0) {
    if (pitch == 50) {
      system.triggerSequence(22);               // 從左至右往下輪閃
    } else if(pitch == 49) {
      system.triggerSequence(24);               // 從左至右往上輪閃
    } else if(pitch == 48) {
      system.triggerSequence(6);                // 左到右, 上到下 輪閃
    }
  }
  // second column (右至左輪閃)
  if (channel == 1) {
    if (pitch == 50) {
      system.triggerSequence(23);               // 從右至左往下輪閃
    } else if(pitch == 49) {
      system.triggerSequence(25);               // 從右至左往上輪閃
    } else if(pitch == 48) {
      system.triggerSequence(7);                // 右到左, 上到下 輪閃
    }
  }
  // third column (往上下閃)
  if (channel == 2) {
    if (pitch == 50) {
      system.triggerSequence(28);               // 左至右上到下輪閃,右至左下至上閃回來
    } else if(pitch == 49) {
      system.triggerSequence(29);               // 左至右下到上輪閃,右至左上到下閃回來
    }
  }
  // fourth column (往上下亮暗)
  if (channel == 3) {
    if (pitch == 50) {
      system.triggerAsyncSequence(6);           // 左至右上到下亮暗,右至左下至上亮暗回來
    } else if(pitch == 49) {
      system.triggerAsyncSequence(7);           // 左至右下到上亮暗,右至左上到下亮暗回來
    }
  }
  // fifth column (三行同步閃)
  if (channel == 4) {
    if (pitch == 50) {
      system.triggerComplexSequence(2);         // 往下輪閃
    } else if(pitch == 49) {
      system.triggerComplexSequence(3);         // 往上輪閃
    }
  }
  // sixth column (三行同步亮暗)
  if (channel == 5) {
    if (pitch == 50) {
      system.triggerComplexAsyncSequence(0);    // 往下全開/關
    } else if(pitch == 49) {
      system.triggerComplexAsyncSequence(1);    // 往上全開/關
    }
  }

  //***************************************************************************

  //Switch
  //trigger Fade Control mode
  if (channel == 7) {
    if (pitch == 52) {
      system.triggerFadeControl();
      //midi mode monitor change color
      //buttonStatus[1] = !buttonStatus[1];
      //render(1);
      //reRenderAll();
    }
  }

  //==============================================================

  //Midi Fighter
  //page 1 ************************* dim on/off for LED strips
  if (channel == 11) {
    //for Single
    if (pitch == 48) {
      system.turnOneOnFor(8, 30, 50);
    } else if (pitch == 44) {
      system.turnOneOnFor(9, 30, 50);
    } else if (pitch == 40) {
      system.turnOneOnFor(10, 30, 50);
    } else if (pitch == 36) {
      system.turnOneOnFor(11, 30, 50);
    } else if (pitch == 49) {
      system.turnOneOnFor(4, 30, 50);
    } else if (pitch == 45) {
      system.turnOneOnFor(5, 30, 50);
    } else if (pitch == 41) {
      system.turnOneOnFor(6, 30, 50);
    } else if (pitch == 37) {
      system.turnOneOnFor(7, 30, 50);
    } else if (pitch == 50) {
      system.turnOneOnFor(0, 30, 50);
    } else if (pitch == 46) {
      system.turnOneOnFor(1, 30, 50);
    } else if (pitch == 42) {
      system.turnOneOnFor(2, 30, 50);
    } else if (pitch == 38) {
      system.turnOneOnFor(3, 30, 50);
    }
    //for All
      else if (pitch == 51) {
      system.turnOn(50);
    } else if (pitch == 47) {
      system.dimRepeat(1, 30);
    } else if (pitch == 43) {
      system.dimRepeat(3, 30);
    } else if (pitch == 39) {
      system.turnOff(50);
    }
  //page 2 ************************* elapse independentControl
    //for Single elapse
      else if (pitch == 64) {
      system.elapseStateControls[1].bang();
    } else if (pitch == 60) {
      system.elapseStateControls[3].bang();
    } else if (pitch == 56) {
      system.elapseStateControls[5].bang();
    } else if (pitch == 52) {
      system.elapseStateControls[7].bang();
    } else if (pitch == 65) {
      system.elapseStateControls[0].bang();
    } else if (pitch == 61) {
      system.elapseStateControls[2].bang();
    } else if (pitch == 57) {
      system.elapseStateControls[4].bang();
    } else if (pitch == 53) {
      system.elapseStateControls[8].bang();
    }
    //for All elapse
      else if (pitch == 66) {
      system.bangElapseLeft();
    } else if (pitch == 62) {
      system.bangElapseRight();
    } else if (pitch == 58) {
      system.bangComplexAsyncElapse(0);
    } else if (pitch == 54) {
      system.bangComplexAsyncElapse(1);
    }
    //trigger for independentControl mode
      else if (pitch == 67) {

    } else if (pitch == 63) {

    } else if (pitch == 59) {

    } else if (pitch == 55) {
      system.triggerIndependentControl();
    }
  //page 3 ************************* LED strips bang patterns
    //for sequences / complex sequences
      else if (pitch == 80) {
      system.bangSequence(22, 30);           // 從左至右往下輪閃
    } else if (pitch == 76) {
      system.bangSequence(24, 30);           // 從左至右往上輪閃
    } else if (pitch == 72) {
      system.bangSequence(23, 30);           // 從右至左往下輪閃
    } else if (pitch == 68) {
      system.bangSequence(25, 30);           // 從右至左往上輪閃
    } else if (pitch == 81) {
      system.bangSequence(28, 30);           // 左至右上到下輪閃,右至左下至上閃回來
    } else if (pitch == 77) {
      system.bangSequence(29, 30);           // 左至右下到上輪閃,右至左上到下閃回來
    } else if (pitch == 73) {
      system.bangComplexSequence(2);         // 往下輪閃
    } else if (pitch == 69) {
      system.bangComplexSequence(3);         // 往上輪閃
    }
    //for async sequences / async complex sequences
      else if (pitch == 82) {
      system.bangAsyncSequence(6);           // 左至右上到下亮暗,右至左下至上亮暗回來
    } else if (pitch == 78) {
      system.bangAsyncSequence(7);           // 左至右下到上亮暗,右至左上到下亮暗回來
    } else if (pitch == 74) {
      system.bangComplexAsyncSequence(0);    // 往下全開/關
    } else if (pitch == 70) {
      system.bangComplexAsyncSequence(1);    // 往上全開/關
    }
    //for All
      else if (pitch == 83) {
      system.turnOn(50);
    } else if (pitch == 79) {
      system.dimRepeat(1, 30);
    } else if (pitch == 75) {
      system.dimRepeat(3, 30);
    } else if (pitch == 71) {
      system.turnOff(50);
    }
  }
}

void noteOff(int channel, int pitch, int velocity) {
  //piano //CC是有區間,連續變化的
  // Receive a noteOn
  println();
  println("Note Off:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
  println("****************************");

  //Switch
  //turn off fade control mode
  /*
  if (channel == 4) {
    if(number == 21) {
    system.triggerFadeControl();
    }
  }
  */
  //AUTO EFFECTS turn-off
  // first column (左至右輪閃)
  if (channel == 0) {
    if (pitch == 50) {
      system.triggerSequence(22);               // 從左至右往下輪閃
    } else if(pitch == 49) {
      system.triggerSequence(24);               // 從左至右往上輪閃
    } else if(pitch == 48) {
      system.triggerSequence(6);                // 左到右, 上到下 輪閃
    }
  }
  // second column (右至左輪閃)
  if (channel == 1) {
    if (pitch == 50) {
      system.triggerSequence(23);               // 從右至左往下輪閃
    } else if(pitch == 49) {
      system.triggerSequence(25);               // 從右至左往上輪閃
    } else if(pitch == 48) {
      system.triggerSequence(7);                // 右到左, 上到下 輪閃
    }
  }
  // third column (往上下閃)
  if (channel == 2) {
    if (pitch == 50) {
      system.triggerSequence(28);               // 左至右上到下輪閃,右至左下至上閃回來
    } else if(pitch == 49) {
      system.triggerSequence(29);               // 左至右下到上輪閃,右至左上到下閃回來
    }
  }
  // fourth column (往上下亮暗)
  if (channel == 3) {
    if (pitch == 50) {
      system.triggerAsyncSequence(6);           // 左至右上到下亮暗,右至左下至上亮暗回來
    } else if(pitch == 49) {
      system.triggerAsyncSequence(7);           // 左至右下到上亮暗,右至左上到下亮暗回來
    }
  }
  // fifth column (三行同步閃)
  if (channel == 4) {
    if (pitch == 50) {
      system.triggerComplexSequence(2);         // 往下輪閃
    } else if(pitch == 49) {
      system.triggerComplexSequence(3);         // 往上輪閃
    }
  }
  // sixth column (三行同步亮暗)
  if (channel == 5) {
    if (pitch == 50) {
      system.triggerComplexAsyncSequence(0);    // 往下全開/關
    } else if(pitch == 49) {
      system.triggerComplexAsyncSequence(1);    // 往上全開/關
    }
  }
}

void controllerChange(int channel, int number, int value) {
  // Receive a controllerChange
  println();
  println("Controller Change:");
  println("--------");
  println("Channel:"+channel);
  println("Number:"+number);
  println("Value:"+value);
  println("****************************");

  //Slider Control
  //master lighting value
  if (channel == 0) {
    if(number == 14) {
    master = value/127.0;
    }
  }
  //Fade control
  //fade control slider
  if (channel == 4) {
    if(number == 7) {
      system.setFadeControlValue(value/127.0);
    }
  }
}

//Processing to Arduino (for tube control)
void keyPressed() {
  if (key == 'q') {
    myPort.write(1);
  }
  if (key == 'w') {
    myPort.write(2);
  }
  if (key == 'e') {
    myPort.write(3);
  }
  if (key == 'r') {
    myPort.write(4);
  }
  if (key == 't') {
    myPort.write(5);
  }
  if (key == 'a') {
    myPort.write(7);
  }
  if (key == 'b') {
    myPort.write(8);
  }


  if (key == 'x') {
    system.triggerIndependentControl();
  }

  if (key == 'v') {
    system.triggerFadeControl();
  }
  if (key == 'c') {
    system.setElapseCountLimit(5);
    system.bangComplexAsyncElapse(1);
  }
  if (key == 'n') {
    system.setElapseCountLimit(0);
    system.elapseStateControls[1].bang();
  }



  /*******
  First Row
  *******/

  // system.dimRepeat(1, 20);              // blink
  // system.turnOnEasingFor(800);          // 前緩後急閃
  // system.dimRepeat(3, 50);              // 連閃 3 次
  // system.turnRandMultipleOnFor(20, 20); // randon strobe (multiple)
  // system.turnRandOneOnFor(20, 20);      // randon strobe (one)
  // system.bangFourRandSequence(50);      // randon strobe (取 4 個輪流)
  // system.turnOn(100);                   // dim on
  // system.turnOff(100);                  // dim off

  /*******
  Second Row
  *******/
  // system.bangComplexSequence(0);         // 閃 ->
  // system.bangComplexSequence(1);         // 閃 <-
  // system.bangSequence(0);                // 0, 7, 8
  // system.bangSequence(1);                // 3, 4, 11
  // system.bangSequence(2);                // 0, 3, 4, 7, 8, 11
  // system.bangComplexSequence(2);         // 四列輪閃
  // system.bangSequence(4);                // 0, 11, 4, 8
  // system.bangSequence(5);                // 9, 2, 1, 10

  /*******
  Third Row
  *******/
  // system.dimRepeatCol(1, 20, 0);         // 閃
  // turnOnEasingForCol(800, 0);            // 前緩後急閃
  // system.bangSequence(10);               // (▼)往下閃
  // system.bangSequence(11);               // (▲)往上閃
  // system.bangSequence(12);               // 0, 3, 2, 1
  // system.bangAsyncSequence(3);           // dim on (▲), then dim off (▼)
  // system.bangAsyncSequence(0);           // dim on (▼), then dim off (▲)
  // system.bangSequence(13);               // 0, 2, 1, 3


  /*******
  Auto Effect
  *******/
  // first column
  // system.triggerSequence(22);         // 往下輪閃
  // system.triggerSequence(23);         // 網上輪閃
  // system.triggerSequence(6);          // 左到右, 上到下 輪閃
  //
  // second column
  // system.triggerComplexAsyncSequence(0);    // 往下全開/關
  // system.triggerComplexAsyncSequence(1);    // 往上全開/關
  // system.triggerSequence(7);                // 右到左, 上到下 輪閃
  //
  // third column
  // system.triggerSequence(28);
  // system.triggerSequence(29);
  //
  // fourth column
  // system.triggerAsyncSequence(6);
  // system.triggerAsyncSequence(7);

  /*******
  The Rightest Column
  *******/
  // system.turnRandOneOn();                   // dim on one (rand)
  // system.turnRandOneOff();                  // dim off one (rand)


  /*******
  Test for trigger logic
  *******/
  // system.triggerComplexSequence(0);


  //  system.triggerIndependentControl();

  //}

  //if (key == 'b') {
  /*******
  Test for trigger logic
  *******/
  // system.triggerComplexSequence(2);


  // system.bangElapseLeft();
  // system.bangElapseRight();
  // system.elapseStateControls[1].bang();
  //  system.bangComplexAsyncElapse(1);
  //}

}
