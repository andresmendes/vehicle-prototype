// servo
#include <Servo.h>
#define SERVO 6 // Porta Digital 6 PWM
Servo s;      // Variável Servo

// sensor ultrassonico
#include <Ultrasonic.h>
//Define os pinos para o trigger e echo
#define pino_triggerS1 4
#define pino_echoS1 5
//Inicializa o sensor nos pinos definidos acima
Ultrasonic ultrasonicS1(pino_triggerS1, pino_echoS1);

#define pino_triggerS2 2
#define pino_echoS2 3
//Inicializa o sensor nos pinos definidos acima
Ultrasonic ultrasonicS2(pino_triggerS2, pino_echoS2);

#define pino_triggerS3 9
#define pino_echoS3 8
//Inicializa o sensor nos pinos definidos acima
Ultrasonic ultrasonicS3(pino_triggerS3, pino_echoS3);

// motor dc
#include <Wire.h>
#include <Adafruit_MotorShield.h>
// Create the motor shield object with the default I2C address
Adafruit_MotorShield AFMS = Adafruit_MotorShield();
// Adafruit_MotorShield AFMS = Adafruit_MotorShield(0x61);
// Select which 'port' M1, M2, M3 or M4. In this case, M1
Adafruit_DCMotor *myMotor1 = AFMS.getMotor(1);
Adafruit_DCMotor *myMotor2 = AFMS.getMotor(2);
Adafruit_DCMotor *myMotor3 = AFMS.getMotor(3);
Adafruit_DCMotor *myMotor4 = AFMS.getMotor(4);

// ======================= VARIÁVEIS =======================
float cmMsecS1, cmMsecS2, cmMsecS3;
long microsecS1, microsecS2, microsecS3;

// Inicialização do tempo
float timeStart;
float timeCurrent;
int entrada = 0;

// ======================= LATERAL =======================
int pos;      // Posição Servo
int erroS1;   // Erro do ultrassom lateral dianteiro
int erroS2;   // Erro do ultrassom lateral traseiro
int angulo;   // Ângulo de guinada do veículo
// Calibração
// Lateral
// Acerta o esterçamento na posição calibrada do servo
// A poisção não é 90, pois depende da geometria da direção do carro.
int alignVal = 83; // Esta variável precisa ser calibrada devido ao mecanismo de direção
// Parâmetros
// Lateral
int Kangulo = 1;    //ganho do controlador lateral para o angulo
int Klateral = 10; //ganho do controlador lateral para o angulo
int distDesired = 22; // Distância lateral desejada

// ======================= LONGITUDINAL =======================
int distLongDes = 30;// desired longitudinal distance
int distmax = 35;
int veloDC;
int Klong = 10; // ganho do controlador proporcional longitudinal

double Kfeedforward = 83;


void setup() {
  Serial.begin(9600);           // set up Serial library at 9600 bps

  // servo setup
  s.attach(SERVO);
  Serial.begin(9600);

  s.write(alignVal); // Inicia motor posição zero

  AFMS.begin();  // create with the default frequency 1.6KHz

  // Set the speed to start, from 0 (off) to 255 (max speed)
  myMotor1->setSpeed(150);
  myMotor1->run(FORWARD);
  myMotor1->run(RELEASE);

  myMotor2->setSpeed(150);
  myMotor2->run(FORWARD);
  myMotor2->run(RELEASE);

  myMotor3->setSpeed(150);
  myMotor3->run(FORWARD);
  myMotor3->run(RELEASE);

  myMotor4->setSpeed(150);
  myMotor4->run(FORWARD);
  myMotor4->run(RELEASE);

  timeStart = millis();
  timeCurrent = millis(); //


}

void loop() {
  // Update current time variable
  timeCurrent = millis();

  //Le as informacoes do sensor, em cm e pol
  microsecS3 = ultrasonicS3.timing();
  cmMsecS3 = ultrasonicS3.convert(microsecS3, Ultrasonic::CM);
  //  inMsecS3 = ultrasonicS3.convert(microsecS3, Ultrasonic::IN);
  //  //Exibe informacoes no serial moniultor
  //  Serial.print("Distancia em cm: ");
  //  Serial.print(cmMsecS3);
  //  Serial.print(" - Distancia em polegadas: ");
  //  Serial.println(inMsecS3);

  // ===================================================

  if (timeCurrent > timeStart + 10000 && timeCurrent < timeStart + 15000) {
    distLongDes = 25;
  }
  if (timeCurrent > timeStart + 15000 && timeCurrent < timeStart + 20000) {
    distLongDes = 35;
  }
  if (timeCurrent > timeStart + 20000 && timeCurrent < timeStart + 25000) {
    distLongDes = 25;
  }
  if (timeCurrent > timeStart + 25000 && timeCurrent < timeStart + 30000) {
    distLongDes = 35;
  }
  if (timeCurrent > timeStart + 30000) {
    distLongDes = 30;
  }

  veloDC = Klong * (cmMsecS3 - distLongDes) + Kfeedforward;

  // Saturation
  if (veloDC < 0) {
    veloDC = 0;
  }
  if (veloDC > 255) {
    veloDC = 255;
  }

  myMotor1->run(FORWARD);
  myMotor2->run(FORWARD);
  myMotor3->run(FORWARD);
  myMotor4->run(FORWARD);
  myMotor1->setSpeed(veloDC);
  myMotor2->setSpeed(veloDC);
  myMotor3->setSpeed(veloDC);
  myMotor4->setSpeed(veloDC);

  // ===================================================
  // Controle lateral
  // São dois sensores laterais para medição da posição e orientação
  //Sensor ultrassom - Lateral dianteiro
  microsecS1 = ultrasonicS1.timing();
  cmMsecS1 = ultrasonicS1.convert(microsecS1, Ultrasonic::CM);
  //  inMsecS1 = ultrasonicS1.convert(microsecS1, Ultrasonic::IN);
  // Sensor ultrassom - Lateral traseiro
  microsecS2 = ultrasonicS2.timing();
  cmMsecS2 = ultrasonicS2.convert(microsecS2, Ultrasonic::CM);
  //  inMsecS2 = ultrasonicS2.convert(microsecS2, Ultrasonic::IN);

  // Os erros das duass distâncias
  erroS1 = cmMsecS1 - distDesired;
  erroS2 = cmMsecS2 - distDesired;
  // Ângulo de orientação do carro
  angulo = erroS1 - erroS2;

  // o erroS1 define a posição lateral
  pos = alignVal + Kangulo * angulo + Klateral * erroS1 ;

  s.write(pos);

  //AQUISIÇÃO
  // Para vídeo
  //  Serial.print(cmMsecS3);
  //  Serial.print(",");
  //  Serial.println(distLongDes);
  // Para matlab
  Serial.print(cmMsecS3);
  Serial.print(",");
  Serial.print(distLongDes);
  Serial.print(",");
  Serial.print(veloDC);
  Serial.print(",");
  Serial.println(timeCurrent);
  //  delay(10);


}
