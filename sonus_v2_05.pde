//　スイッチの説明 ///////////////// //<>//
// INPUT3,4,5,6,7,8　が　箱の中のスイッチ
// INPUT9が録音のスイッチ
// INPUT10が引き金のスイッチ

//・INPUT3 感謝　リバーブ
//・INPUT4 怒り　雷
//・INPUT5 悲しみ　しずく
//・INPUT6 喜び　拍手
//・INPUT7 恋 心臓音
//・INPUT8 敬い　

import processing.serial.*;

import cc.arduino.*;
import org.firmata.*;

import controlP5.*;

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

//ケースモジュール　クラス
Arduino arduino;

//録音モジュールクラス
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim minim;
AudioInput in;
AudioRecorder recorder;

// 以下ケースモジュール(変数) //

int[] input = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13};
int[] digital = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}; //1,0の値が代入されている。
int i = 0; //変数iは、今取った弾。変数は、発射する弾の総数に必要。
int s = 0; //変数sは、取った弾の総数。
int before = 0;
int[] memory = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}; //配列[memory]は、1回目、2回目に入れた弾番号を挿入。
int[] l = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}; 
//変数lはロック用。lが0の時、プログラム実行可能。
int n = 0; //変数nは、弾を打つ時の回数。

//　以下録音モジュール（変数）//

int m = 0;

//　以下　光モジュール

int input0 = 0;

//　以下エフェクトモジュール(変数) //

float FS = 44100.0;
float DELAY_TIME = 0.2;
float DELAY_LEVEL = 0.3;
int FEEDBACK = 5;

EchoClass echo;

//　以下　音量モジュール //
float  myGain;

//　以下　再生モジュール //

AudioPlayer player;
String fileName; 
PImage img;
int launch = 0;
int count = 1;
int ix, iy;
int p = 0;
int q = 0;

// 以下OSC通信モジュール
//OSC関連のライブラリーをインポート
import oscP5.*;
import netP5.*;

//OSCP5クラスのインスタンス
OscP5 oscP5;
//OSC送出先のネットアドレス
NetAddress myRemoteLocation;

//緊急モジュール
int k = 0;
int h = 0;
int h1 = 0;

void setup() {
  //frameRate( 20 );
  //以下ケースモジュール（setup）
  for (int x = 0; x < 13; x++) { //digital[]初期化
    digital[x] = 0;
  }
  //size(512, 300);

  arduino = new Arduino(this, "/dev/cu.usbmodem1421", 57600); 
  //　ここの[1411]の部分は自分で変更してください。

  for (int a=2; a<13; a++) {
    arduino.pinMode(a, Arduino.INPUT);
  }
  
  arduino.pinMode(13, Arduino.OUTPUT);

  //以下録音モジュール（setup）
  size(512, 512);
  minim = new Minim(this);
  in = minim.getLineIn(Minim.MONO, 512);
  recorder = minim.createRecorder(in, "./record_1/" + launch + ".wav", true);
  textFont(createFont("Arial", 12));


  //以下エフェクトモジュール

  echo = new EchoClass(FS, DELAY_TIME, DELAY_LEVEL, FEEDBACK);



  //以下再生モジュール　(setup)
  player = minim.loadFile("./record_1/" + i + ".wav");

  if ( player == null ) {
    //読み込み失敗時
    println( fileName + "の読み込み失敗" );
    exit();
  }

  //　以下OSC通信モジュール
  //ポートを12001に設定して新規にOSCP5のインスタンスを生成
  oscP5 = new OscP5(this, 12001);
  //OSC送信先のIPアドレスとポートを指定
  myRemoteLocation = new NetAddress("192.168.3.34", 12000);
}


void draw() {


  //以下ケースモジュール
  background(0);
  stroke(255);

  for (int x = 0; x < 13; x++) { //digital[]初期化
    digital[x] = arduino.digitalRead(input[x]);
  }

  if (s == 0) { // memory[x],count初期化
    for (int x=0; x <= 6; x++ ) {
      //memory[x] = 0;
      //count= 1;
    }
  }

  for (int x = 4; x <= 8; x++) {
    if (l[x] == 0) {
      if (digital[x] == 0) {
        i = x;
        s = s + 1;
        memory[s] = i;
        l[x] = 1;
        l[x+15] = 0;
      }
    }

    if (l[x+15] == 0) {
      if (digital[x] == 1) {
        i = memory[s-1];
        memory[s] = 0;
        s = s - 1;
        l[x+15] = 1;
        l[x] = 0;
      }
    }
  }

  //for (int x=1; x<7; x++) { //弾を全部打ち終わって、全ての弾を箱に戻したら、countを1にするプログラム。
  //  if (memory[x] == 0) {
  //    count = 1;
  //  }
  //}

  if ( recorder.isRecording() )
  {
    text("Currently recording...", 5, 15);
  } else
  {
    text("Not recording.", 5, 15);
  }

  if (m == 0) {
    if (digital[10] == 1) {
      if (i != 0) {
         arduino.digitalWrite(13, Arduino.HIGH);
        recorder = minim.createRecorder(in, "./record_1/" + i + ".wav", true);
        recorder.beginRecord();
        player = minim.loadFile("./music/suna01.mp3");
        player.play( 0 );
        m = 1;
      }
    }
  }

  if (recorder.isRecording()) {
    if (digital[10] == 0) {
      arduino.digitalWrite(13, Arduino.LOW);
      recorder.endRecord();
      recorder.save();
      println("Done saving.");
      m = 0;
    }
  }
  //　録音モジュールここまで


  text("input" + 4 + "(感謝)=" + digital[4], 10, 40);
  text("input" + 5 + "(怒り)=" + digital[5], 10, 60);
  text("input" + 6 + "(悲しみ)=" + digital[6], 10, 80);
  text("input" + 7 + "(喜び)=" + digital[7], 10, 100);
  text("input" + 8 + "(恋)=" + digital[8], 10, 120);
  text("input" + 9 + "(尊敬)=" + digital[9], 10, 140);
  text("input" + 10 + "(録音)=" + digital[10], 10, 160);
  text("input" + 2 + "(発射)=" + digital[2], 10, 180);

  //text("input" + 11 + "=" + digital[11], 10, 200);
  text("i" + "=" + i, 10, 220);
  text("s" + "=" + s, 10, 240);
  text("memory[1]" + "=" + memory[1], 10, 260);
  text("memory[2]" + "=" + memory[2], 10, 280);
  text("memory[3]" + "=" + memory[3], 10, 300);
  text("memory[4]" + "=" + memory[4], 10, 320);
  text("memory[5]" + "=" + memory[5], 10, 340);
  text("memory[6]" + "=" + memory[6], 10, 360);
  text("launch" + "=" + launch, 10, 380);
  text("count" + "=" + count, 10, 400);
  text("player" + "=" + player, 10, 420);
  text("p" + "=" + p, 10, 440);
  text( "Gain : " + player.getGain(), 10, 460 );
  // 音量モジュール

  if ( p == 0 ) { //多重進入禁止変数

    //　ここから、発射する番号を選択するアルゴリズム

    for (int x=1; x<7; x++) {
      if (s == x) {
        launch = memory[count];
        if (count == x + 1) {
          
          count = 1;
          launch = memory[count];
        }
      }
    }

    if ( digital[2] == 1 ) { //発射ボタンが押されたら

      count++;
      //if(launch == 3 ) {
      //  echo = new EchoClass(FS, DELAY_TIME, DELAY_LEVEL, FEEDBACK);
      //  player.addEffect(echo);
      //}

      player = minim.loadFile("./record_1/" + launch + ".wav");
      if ( player.isPlaying() == false ) {
        if (launch == 7) {
          echo = new EchoClass(FS, DELAY_TIME, DELAY_LEVEL, FEEDBACK);
          player.addEffect(echo);
        }
        //arduino.digitalWrite(12, Arduino.HIGH);
        player.play( 0 );
        //再生中でなければ、演奏開始


        //OscMessage msg = new OscMessage("/mouse/cliked");
        //msg.add(launch); //lauchを送信
        //oscP5.send(msg, myRemoteLocation);
        // 以下音量モジュール
        //myGain = player.getGain();
        //if(  analog0 >= 650.0 ){
        // //MAXまでゲインを上げる
        // myGain = myGain +5; 
        //}
        //音量モジュールここまで

        //text("input" + 4 + "(感謝)=" + digital[4], 10, 40);
        //text("input" + 5 + "(怒り)=" + digital[5], 10, 60);
        //text("input" + 6 + "(悲しみ)=" + digital[6], 10, 80);
        //text("input" + 7 + "(喜び)=" + digital[7], 10, 100);
        //text("input" + 8 + "(恋)=" + digital[8], 10, 120);
        //text("input" + 9 + "(尊敬　今だけ録音ボタン)=" + digital[9], 10, 140);
        //text("input" + 10 + "(録音　今だけ発射ボタン)=" + digital[10], 10, 160);
        //text("input" + 2 + "(発射　今は故障中)=" + digital[2], 10, 180);
        
        if (launch == 4) {
          player = minim.loadFile("./music/applause.mp3"); 
          player.play( 0 );
        }

        if (launch == 5) {
          float  myGain;
          myGain = player.getGain();
          myGain = myGain -40.0;
          player.setGain( myGain );
          player = minim.loadFile("./music/kan_ge_kaminari07.mp3"); 
          player.play( 0 );
        }

        if (launch == 6) {
          player = minim.loadFile("./music/sizuku3_garage.mp3"); 
          player.play( 0 );
        }

        if (launch == 8) {
          player = minim.loadFile("./music/heartbeats_garage.mp3"); 
          player.play( 0 );
        }

        if (launch == 9) {
          //player = minim.loadFile("./music/sonkei.wav"); 
          //player.play( 0 );
        }
        p = 1;
      }
    }
  }
  if ( digital[2] == 0 ) {
    //OscMessage msg = new OscMessage("/mouse/cliked");
    //msg.add(0); //0を送信
    //oscP5.send(msg, myRemoteLocation);
    p = 0;
  }


  //if (keyPressed) {
  //  //if (k == 0 && h1 == 0) {
  //  //  if (key == '3') {

  //  //    digital[3] = 1;
  //  //    k = 1;
  //  //    h = 0;
  //  //  }
  //  //}
  //  //if (k == 1 && h == 1) {
  //  //  if (key == '3') {
  //  //    digital[3] = 0;
  //  //    k = 0;
  //  //    h = 0;
  //  //    h1 = 1;
  //  //  }
  //  //}

  //  if (k == 0 && h1 == 0) {
  //    if (key == '4') {

  //      digital[4] = 1;
  //      k = 1;
  //      h = 0;
  //    }
  //  }
  //  if (k == 1 && h == 1) {
  //    if (key == '4') {
  //      digital[4] = 0;
  //      k = 0;
  //      h = 0;
  //      h1 = 1;
  //    }
  //  }
  //}

  //if (k == 0 && h1 == 0) {
  //  if (key == '5') {

  //    digital[5] = 1;
  //    k = 1;
  //    h = 0;
  //  }
  //}
  //if (k == 1 && h == 1) {
  //  if (key == '5') {
  //    digital[5] = 0;
  //    k = 0;
  //    h = 0;
  //    h1 = 1;
  //  }
  //}

  //if (k == 0 && h1 == 0) {
  //  if (key == '6') {

  //    digital[6] = 1;
  //    k = 1;
  //    h = 0;
  //  }
  //}
  //if (k == 1 && h == 1) {
  //  if (key == '6') {
  //    digital[6] = 0;
  //    k = 0;
  //    h = 0;
  //    h1 = 1;
  //  }
  //}

  //if (k == 0 && h1 == 0) {
  //  if (key == '7') {

  //    digital[7] = 1;
  //    k = 1;
  //    h = 0;
  //  }
  //}
  //if (k == 1 && h == 1) {
  //  if (key == '7') {
  //    digital[7] = 0;
  //    k = 0;
  //    h = 0;
  //    h1 = 1;
  //  }
  //}

  //if (k == 0 && h1 == 0) {
  //  if (key == '8') {

  //    digital[8] = 1;
  //    k = 1;
  //    h = 0;
  //  }
  //}
  //if (k == 1 && h == 1) {
  //  if (key == '8') {
  //    digital[8] = 0;
  //    k = 0;
  //    h = 0;
  //    h1 = 1;
  //  }
  //}

  //if (k == 0 && h1 == 0) {
  //  if (key == '9') {

  //    digital[9] = 1;
  //    k = 1;
  //    h = 0;
  //  }
  //}
  //if (k == 1 && h == 1) {
  //  if (key == '9') {
  //    digital[9] = 0;
  //    k = 0;
  //    h = 0;
  //    h1 = 1;
  //  }
  //}

  //if (k == 0 && h1 == 0) {
  //  if (key == '0') {

  //    digital[10] = 1;
  //    k = 1;
  //    h = 0;
  //  }
  //}
  //if (k == 1 && h == 1) {
  //  if (key == '0') {
  //    digital[10] = 0;
  //    k = 0;
  //    h = 0;
  //    h1 = 1;
  //  }
  //}
}

void keyReleased() {
  h = 1;
  h1 = 0;
  //digital[3] = 1;
  //digital[3] = 1;
  //OscMessage msg = new OscMessage("/mouse/cliked");
  //msg.add(0); //0を送信
  //oscP5.send(msg, myRemoteLocation);
}

void stop()
{
  player.close();
  minim.stop();
  super.stop();
}