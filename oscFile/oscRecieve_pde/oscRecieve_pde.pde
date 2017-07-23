import oscP5.*;
import netP5.*;

import processing.serial.*;
import cc.arduino.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Arduino arduino;
Minim minim;
AudioPlayer player;

//OSCP5クラスのインスタンス
OscP5 oscP5;
//マウスの位置ベクトル
PVector mouseLoc;
//マウスのクリック検知
int clicked;

//再生モジュール
String fileName; 
PImage img;
int launch = 0;
int count = 1;
int ix, iy;
int p = 0;
int q = 0;

//　以下エフェクトモジュール(変数) //

float FS = 44100.0;
float DELAY_TIME = 0.2;
float DELAY_LEVEL = 0.3;
int FEEDBACK = 5;

EchoClass echo;

void setup() {
  minim = new Minim(this);  //初期化
  player = minim.loadFile("../sonus_v2_01/record_1/" + launch + ".wav");  //0.wavをロードする

  size(400, 300);
  frameRate(60);

  //ポートを12000に設定して新規にOSCP5のインスタンスを生成
  oscP5 = new OscP5(this, 12000);
  //マウスの位置ベクトルを初期化
  mouseLoc = new PVector(width/2, height/2);
  //マウスのクリック状態を初期化
  clicked = 0;
  textFont(createFont("Arial", 16));

  //以下エフェクトモジュール

  echo = new EchoClass(FS, DELAY_TIME, DELAY_LEVEL, FEEDBACK);
}

void draw() {
  background(0);
  stroke(255);

  if (p == 0) {
    if (clicked == 1) {
      player = minim.loadFile("groove.mp3"); 
      player.play(0);
    }

    if (clicked == 4) {
      background(255, 0, 0);
      //if (player.isPlaying() == false) {
      player = minim.loadFile("../../record_1/" + 4 + ".wav");
      player.play( 0 ); 
      //}
      player = minim.loadFile("../../music/applause.mp3"); 
      player.play( 0 );
      p = 1;
    }


    if (clicked == 5) {
      background(255, 0, 0);
      //if (player.isPlaying() == false) {
      player = minim.loadFile("../../record_1/" + 5 + ".wav");
      player.play( 0 );  
      //}
      float  myGain;
      player = minim.loadFile("../../music/kan_ge_kaminari07.mp3"); 
      player.play( 0 );
      myGain = player.getGain();
      myGain = myGain -20;
      player.setGain( myGain );
      p = 1;
    }

    if (clicked == 6) {
      background(255, 0, 0);
      //if (player.isPlaying() == false) {
      player = minim.loadFile("../../record_1/" + 6 + ".wav");
      player.play( 0 );
      //}
      player = minim.loadFile("../../music/sizuku3_garage.mp3"); 
      player.play( 0 );
      p = 1;
    }

    if (clicked == 7) {
      background(255, 0, 0);
      //if (player.isPlaying() == false) {
      player = minim.loadFile("../../record_1/" + 7 + ".wav");

      echo = new EchoClass(FS, DELAY_TIME, DELAY_LEVEL, FEEDBACK);
      player.addEffect(echo);
      player.play( 0 );
      //}
      p = 1;
    }


    if (clicked == 8) {
      background(255, 0, 0);
      //if (player.isPlaying() == false) {
      player = minim.loadFile("../../record_1/" + 8 + ".wav");
      player.play( 0 );
      //}
      player = minim.loadFile("../../music/heartbeats_garage.mp3"); 
      player.play( 0 );
      p = 1;
    }

    if (clicked == 9) {
      background(255, 0, 0);
      //if (player.isPlaying() == false) {
      player = minim.loadFile("../../record_1/" + 9 + ".wav");
      player.play( 0 );
      //}
      //player = minim.loadFile("../../music/sonkei.wav"); 
      //player.play( 0 );
      p = 1;
    } else {
      //  background(0);
    }
  }

  if (clicked == 0) {
    p = 0;
  }

  //OSCで指定された座標に円を描く
  //noFill();
  //stroke(255);
  //ellipse(mouseLoc.x, mouseLoc.y, 10, 10);
  text("clicked=" + clicked, 10, 40);
}


//OSCメッセージを受信した際に実行するイベント
void oscEvent(OscMessage msg) {
  //もしOSCメッセージが /mouse/position だったら
  //if (msg.checkAddrPattern("/mouse/position")==true) {
  //  //最初の値をint方としてX座標に
  //  mouseLoc.x = msg.get(0).intValue();
  //  //次の値をint方としてY座標に
  //  mouseLoc.y = msg.get(1).intValue();
  //}
  if (msg.checkAddrPattern("/mouse/cliked")==true) {
    //Bool値を読み込み


    clicked = msg.get(0).intValue(); 
    println("msg = " + clicked);
    print("*");

    //player = minim.loadFile("groove.mp3"); 
    //player.play();  //再生
  }
}

void stop()
{
  player.close();  //サウンドデータを終了
  minim.stop();
  super.stop();
}