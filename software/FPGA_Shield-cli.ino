/*
 */

#include <SPI.h>
#define XON  0x11
#define XOFF 0x13

//Arduino R4 MISO(CIPO)=D12; MOSI(COPI)=D11; SCK=D13
#define SCK 13  // Chip Select SPI Flash
#define CS_FLASH 10  // Chip Select SPI Flash
#define RST_FLASH 2  // Reset SPI Flash
#define PROGRAM_B 9  // Reset FPGA
#define INIT_B 8  // FPGA INIT_B
#define DONE 7  // FPGA DONE
#define PG A5  // Power Good

bool status_INIT_B=false;

const int BUFFER_SIZE = 256; // byte
char buffer[BUFFER_SIZE];
int bufferIndex = 0;
bool receiving = false;
bool inWriteLoop_SPI = false;
bool Attend_buffer = true;
unsigned long execStart = 0;
unsigned long execStop = 0;
unsigned long lastWriteTime = 0;
unsigned long totalBytesWritten = 0;
unsigned long totalBlocksWritten = 0;
uint32_t crc = ~0L;  // Inizializza CRC32 con tutti i bit a 1
bool flagADVMenu = false;
bool pg_value = true;
String pg_fail= " ";
int command=99;
//SPI
uint32_t clkSPI = 2000000;
BitOrder bitOrder = MSBFIRST;
uint8_t spiMode = SPI_MODE0;
bool swSPIFlag = true; // SPI Software D12=MOSI D11=MISO
// SPI-NOR
uint32_t flashAddress = 0;
bool inWriteLoop_FLASH = false;
uint32_t addr;
uint32_t numByte;
int blockSize, numBlocks;

//XMODEM
#define SOH  0x01  // Start of Header (inizio blocco)
#define EOT  0x04  // End of Transmission (fine trasmissione)
#define ACK  0x06  // Acknowledge (dati ricevuti correttamente)
#define NAK  0x15  // Negative Acknowledge (errore, ritrasmetti)
#define CAN  0x18  // Cancel
#define XMODEM_BUFFER_SIZE 128  // Evita conflitti con BUFFER_SIZE


void setup() {
    Serial.begin(115200);
    delay(1000);
    //Arduino R4 MISO(CIPO)=D12; MOSI(COPI)=D11; SCK=D13
    //init_default_SPI();
    pinMode(PG, INPUT_PULLUP);
    attachInterrupt(digitalPinToInterrupt(PG), ISR, FALLING );
    pinMode(INIT_B, INPUT_PULLUP);
    pinMode(DONE, INPUT);
    pinMode(CS_FLASH,INPUT_PULLUP);
    pinMode(12, INPUT_PULLUP);
    pinMode(SCK, INPUT_PULLUP);
    pinMode(11, INPUT_PULLUP);
    delay(1000);
    showMenu();
}


void loop() {
    if (inWriteLoop_SPI || inWriteLoop_FLASH ) {
      if(inWriteLoop_SPI) { UART_to_SPI();return;}
      if(inWriteLoop_FLASH) { UART_to_FLASH();return;} 
    }
    else{
    
        Serial.print(" ");
        String input = readSerialCommand();  // Legge il comando
        if (input.length() == 0) return;
        // Serial.println();

        command = input.toInt();  // Converte l'input in numero
        //Initialized variable:
        bufferIndex=0;
        addr=0;
        numByte=0;
        blockSize=0;
        numBlocks=0;
        bufferIndex=0;
        flashAddress=0;        
    }

    if (command >12 && !flagADVMenu){ //Reduce menu
      command = 99;
    }

    switch (command) {
        case 0: // Solo invio
            showMenu();  // Mostra di nuovo il menu
            break;  

        case 1: { // UART to SPI FPGA programming
                        
            //disable_SPI();
            UART_to_SPI();
            return;
        }
        case 2: // XMODEM to SPI FPGA programming

            resetCycle_FPGA();
            if (status_MasterMODE_FPGA() == true) { // FPGA MASTER MODE
              Serial.println("\033[30;41m!\033[0m FPGA in MASTER MODE remove jumper FLASH. Aborting...");
              Serial.print(">");
              break;
            }            
            init_default_SPI(0);
            init_FPGA();    
            if (status_INIT_B == false) { // Se INIT_B è basso, indica errore
              Serial.println("FPGA initialization failed. Aborting...");
              Serial.print(">");
              break;
            }
            receiveXmodem_SPI();
            waiting_DONE_FPGA();
            Serial.print(">");
            disable_SPI();
            break;
        case 3: //Reset Cycle FPGA
            resetCycle_FPGA();
            Serial.print(">");
            break;            
        case 4: //Status FPGA DONE
            status_DONE_FPGA();
            Serial.print(">");
            break;      
        case 5: // UART bridge
            echoUART();
            Serial.print(">");
            break;                  
        case 6: // Reset arduino
            Serial.println("\n Resetting Arduino...");
            delay(100);
            NVIC_SystemReset();
            Serial.print(">");
            break;   

        case 7: // chip Erase    
            resetHold_FPGA();
            init_default_SPI(1);            
            chipErase();
            disable_SPI();
            resetRelease_FPGA();
            Serial.print(">");
            break; 
        case 8: // CRC32
            resetHold_FPGA();
            init_default_SPI(1);
            calcCRC32();
            disable_SPI();
            resetRelease_FPGA();
            Serial.print(">");
            break;
        case 9: // UART to SPI-NOR FLASH
            resetHold_FPGA();
            init_default_SPI(1);
            UART_to_FLASH();
            break;     
        case 10: // Receive Xmodem to SPI-NOR
            resetHold_FPGA();
            init_default_SPI(1);
            receiveXmodem();
            disable_SPI();
            resetRelease_FPGA();
            Serial.print(">");
            break;                
        case 11: // Read device ID    
            resetHold_FPGA();
            init_default_SPI(1);
            readRDID();
            disable_SPI();
            resetRelease_FPGA();
            Serial.print(">");
            break;                
        case 12: // ADV Menu
            flagADVMenu = ! flagADVMenu;
            if ( flagADVMenu ){
              Serial.println(" Advanced MENU: Enabled");
            } else{
              Serial.println(" Advanced MENU: Disabled");
            }
            
            Serial.print(">");
            break;   

        case 13: // Set SPI
            setSPI();
            Serial.print(">");
            disable_SPI();
            break;   
        case 14: // Block Erase
            resetHold_FPGA();
            init_default_SPI(1);
            blockErase();
            disable_SPI();
            resetRelease_FPGA();
            Serial.print(">");
            break;
        case 15: // write Enable
            resetHold_FPGA();
            init_default_SPI(1);
            writeEnable();
            Serial.println(" WREN enabled,latch/self clear ");
            disable_SPI();
            resetRelease_FPGA();
            Serial.print(">");
            break;
        case 16: // Read Flash
            resetHold_FPGA();
            init_default_SPI(1);
            readFlash();
            disable_SPI();
            resetRelease_FPGA();
            Serial.print(">");
            break;
        case 17: // Fast reed Flash
            resetHold_FPGA();
            init_default_SPI(1);
            readFastFlash();
            disable_SPI();
            resetRelease_FPGA();
            Serial.print(">");
            break;     
        case 18: // Status Register
            resetHold_FPGA();
            init_default_SPI(1);
            printStatusRegister();
            disable_SPI();
            resetRelease_FPGA();
            Serial.print(">");
            break;
        case 19: {// Write Data
            resetHold_FPGA();
            init_default_SPI(1);
            Serial.println("Erase block before write! ");
            Serial.print(" Enter start address (hex): ");
            addr = strtoul(readSerialCommand().c_str(), NULL, 16);
            Serial.print(" Enter data byte (hex): ");
            byte data = (byte) strtoul(readSerialCommand().c_str(), NULL, 16);
            writeByte(addr, data);                       
            disable_SPI();
            resetRelease_FPGA();
            Serial.print(">");
            break;
        }
        case 20: // Read device ID
            resetHold_FPGA();
            init_default_SPI(1);
            readREMS();
            disable_SPI();
            resetRelease_FPGA();
            Serial.print(">");
            break;        

        case 21: // Dump flash to UART
            resetHold_FPGA();
            init_default_SPI(1);
            dumpFlashToUART();
            disable_SPI();
            resetRelease_FPGA();
            Serial.print(">");
            break;                                     
        case 22: // Dump flash to Xmodem
            resetHold_FPGA();
            init_default_SPI(1);
            sendXmodem();
            disable_SPI();
            resetRelease_FPGA();
            Serial.print(">");
            break;  
        case 23: // Custom SPI command
            resetHold_FPGA();
            init_default_SPI(1);
            customSPITransaction();
            disable_SPI();
            resetRelease_FPGA();
            Serial.print(">");
            break;
        case 24: // Reset Hold
            resetHold_FPGA();
            Serial.print(">");
            break;
        case 25: // Reset Hold
            resetRelease_FPGA();
            Serial.print(">");
            break;                                             

        default:
            Serial.println(" Command not found!");
            showMenu();  // Mostra di nuovo il menu
            break;
    }
    
}

// Mostra il menu
void showMenu() {
    delay(100);
    Serial.println("\033[7m            MENU  Main         Ver0.0 \033[0m");
    Serial.println(pg_fail);
    Serial.println(" 1. Load FPGA: UART to SPI               ");
    Serial.println(" 2. Load FPGA: UART-XMODEM to SPI        ");
    Serial.println(" 3. FPGA reset cycle                     ");    
    Serial.println(" 4. FPGA status DONE                     ");        
    Serial.println(" 5. UART bridge                          ");
    Serial.println(" 6. Reset Arduino or CTRL+R              ");
    Serial.println(" \033[7m    MENU SPI-NOR                 \033[0m");
    Serial.println(" 7.  chipErase [Opcode C7h]");
    Serial.println(" 8.  CRC32 calc"); 
    Serial.println(" 9.  Download bin: UART mode");
    Serial.println(" 10. Download bin: UART-XMODEM mode");
    Serial.println(" 11. deviceID  [Opcode 9Fh RDID]");
    Serial.println(" 12. Enable Advanced SPI-NOR menu");
    
    if (flagADVMenu){
      Serial.println(" \033[7m      MENU Advanced               \033[0m");
      Serial.println(" 13. Set SPI");
      Serial.println(" 14. blockErase 4096/32768/65536 [Opcode 20h/52h/D8h]");
      Serial.println(" 15. writeEnable [Opcode 06h WREN]");
      Serial.println(" 16. readFlash [Opcode 03h RDSR]");
	    Serial.println(" 17. fast-read Flash [Opcode 0Bh FRD]");
      Serial.println(" 18. statusRegister [Opcode=0x05 RDSR]");
      Serial.println(" 19. writeData [Opcode 02h PP]");
      Serial.println(" 20. deviceID  [Opcode 90h REMS]");    
      Serial.println(" 21. Dump SNOR-Flash: UART mode");
      Serial.println(" 22. Dump SNOR-Flash: UART-XMODEM mode");
      Serial.println(" 23. Custom SPI Transaction");
      Serial.println(" 24. FPGA Reset: Hold");
      Serial.println(" 25. FPGA Reset: Realese");
    } 
    Serial.print(">");
}

String readSerialCommand() {
    String command = "";
    while (true) {
        statusPG();
        if (Serial.available()) {
            char c = Serial.read();
            if (c == 18) {  // Ctrl+R 
                Serial.println("\n Resetting Arduino...");
                delay(100);
                NVIC_SystemReset();
            }            
            if (c == '\n' || c == '\r'){  // Rileva ENTER (CR o LF)
                //if (command.isEmpty()){ // 
                if (command.length() == 0){
                    command = "0";
                }
                break;
            } else if ( c == '\b' ){
                if (command.length() > 0){
                  Serial.print("\b \b");
                  command.remove(command.length() - 1); // Rimuove carattere
                }
            } else {
                Serial.print(c);  // Echo sulla console
                command += c;
            }
        }
    }
    Serial.println();  // Nuova riga dopo l'input
    return command;
}


int readIntInput() {
    String input = readSerialCommand();
    return input.toInt();
}

void init_FPGA (){ //Initialized FPGA for SPI programming 
  pinMode(PROGRAM_B, OUTPUT);
  digitalWrite(PROGRAM_B, LOW);
  status_INIT_B=digitalRead(INIT_B);
  Serial.println("FPGA STATUS: INIT_B LOW <attend>");
  
  for(int i_init = 0; i_init < 10; i_init++){
    status_INIT_B=digitalRead(INIT_B);
    if ( ! status_INIT_B ){
      Serial.println("FPGA STATUS: INIT_B LOW <ready>");
      digitalWrite(PROGRAM_B, HIGH);
      break;
    }
    else{
     delay(1000);
    }
  }
  if ( status_INIT_B == true ){
    Serial.println("FPGA STATUS: INIT_B LOW <\033[31mfail\033[0m>");    
    status_INIT_B = false;
  }else{
    Serial.println("FPGA STATUS: INIT_B HIGH <attend>");
    for(int i_init = 0; i_init < 10; i_init++){
      status_INIT_B=digitalRead(INIT_B);
      if ( status_INIT_B ){
        Serial.println("FPGA STATUS: INIT_B HIGH <ready>");
        break;
      }
      else{
       delay(1000);
      }
    }
    if ( status_INIT_B == false ){
      Serial.println("FPGA STATUS: INIT_B HIGH <\033[31mfail\033[0m>");
    }
    
  }
  pinMode(PROGRAM_B, INPUT_PULLUP);

}

void waiting_DONE_FPGA (){ //check status DONE FPGA
  Serial.println("FPGA STATUS: DONE <attend>");
  execStart = millis();
  bool status_DONE=digitalRead(DONE);
  for(uint8_t  i_done = 0; i_done < 10; i_done++){
    for (uint16_t  i = 0; i < 32000; i++) {
        SPI_TX(0x00); // Invia dummy clock
    }
    status_DONE=digitalRead(DONE);
    if ( status_DONE ){
      Serial.println("FPGA STATUS: DONE <\033[30;42mprogrammed\033[0m>");
      break;
    }
  }
  if ( status_DONE == false ){
    Serial.println("FPGA STATUS: DONE <\033[31mLOW,fail programmed\033[0m>");
  }

  execStop = millis();
  Serial.print("\nExec. : ");Serial.print(execStop - execStart);Serial.println("ms");
}

void resetHold_FPGA(){
  Serial.println("FPGA STATUS: RESET <hold>");
  pinMode(PROGRAM_B, OUTPUT);
  digitalWrite(PROGRAM_B, LOW); 
  delay(20);
}

void resetRelease_FPGA(){
  Serial.println("FPGA STATUS: RESET <release>");
  digitalWrite(PROGRAM_B, HIGH);
  pinMode(PROGRAM_B, INPUT_PULLUP);  
}

void resetCycle_FPGA(){
  resetHold_FPGA();
  delay(1000);
  resetRelease_FPGA();
  delay(500);
  
}

bool status_DONE_FPGA(){
  if ( digitalRead(DONE) ){
    Serial.println("FPGA STATUS: DONE <\033[30;42mprogrammed\033[0m>");//testo nero sfondo verde
    return true;
  }else{
    if (command == 4){
      Serial.println("FPGA STATUS: DONE <\033[30;43mLOW,not programmed\033[0m>");
    }else{
      Serial.println("FPGA STATUS: DONE <LOW,not programmed>");
    }
    
    return false;
  }
}

bool status_MasterMODE_FPGA(){
  pinMode(CS_FLASH, INPUT_PULLUP);
  if ( status_DONE_FPGA() ){
    return true;
  }else if ( digitalRead(CS_FLASH) == false ){
    return true;
  }else{
    return false;
  }
}

void UART_to_SPI() {  

  if (inWriteLoop_SPI == false){
    crc = ~0L;
    inWriteLoop_SPI = true;
    resetCycle_FPGA();
    if (status_MasterMODE_FPGA() == true) { // FPGA MASTER MODE
      Serial.println("\033[30;41m!\033[0m FPGA in MASTER MODE remove jumper FLASH. Aborting...");
      Serial.print(">");
      inWriteLoop_SPI=false;
      return;
    }       
    init_default_SPI(0);
    init_FPGA();    
    if (status_INIT_B == false) { // Se INIT_B è basso, indica errore
      Serial.println("FPGA initialization failed. Aborting...");
      return;
    }
    delay(100);
    Attend_buffer = false; // Si avvia solo dopo 1 buffer 256
    Serial.println("\n ****** TERATEM ******");
    Serial.println(" * General Setting: ");
    Serial.println(" *     -Setup>Terminal> Receive=CR; Transmit=CR");
    Serial.println(" *     -Setup>Serial port> ");
    Serial.println(" *       Speed=115200; Data=8b; Parity=none; Stop bits=1");
    Serial.println(" *       Flowcontrol=Xon/Xoff; Transmit delay=0msec");
    Serial.println(" * Version:");
    Serial.println(" *     -Tested with verion 5.3");
    Serial.println(" * Tranfer setting:");
    Serial.println(" *     -File>Send file> ");
    Serial.println(" *         Filename: <file>");
    Serial.println(" *         Binary:[checked]");
    Serial.println(" *         delay type: <per sendsize>");
    Serial.println(" *         [send size(bytes): 256 ]");
    Serial.println(" *         delay time(ms): <0 or 1>");
    Serial.println("\nMinimun file size is 256byte!");
    Serial.println("\nReady to recive data from UART...");
      
  }
  
  if (Serial.available()) {
      if (!receiving) {
          Serial.write(XOFF);
          Serial.println("Writing to SPI started...");
          execStart = millis();
          receiving = true;
      }
      
      while (Serial.available() && bufferIndex < BUFFER_SIZE) {
          buffer[bufferIndex++] = Serial.read();
      }
  
      // Se il buffer è pieno, scrivi direttamente su SPI
      if (bufferIndex == BUFFER_SIZE) {
          Serial.write(XOFF);
          SPI_TX_bytes(buffer, BUFFER_SIZE);  // Scrive i dati direttamente su SPI
          totalBytesWritten += BUFFER_SIZE;
          totalBlocksWritten++;
  
        // Calcola CRC32 per i dati nel buffer
        for (int i = 0; i < BUFFER_SIZE; i++) {
          uint8_t data = buffer[i];
          // Aggiornamento CRC con il nuovo byte letto
          crc ^= data;
          for (uint8_t j = 0; j < 8; j++) {
            crc = (crc >> 1) ^ (0xEDB88320 & -(crc & 1));
          }
        }
  
        Serial.print("Send ");
        Serial.print(BUFFER_SIZE);
        Serial.print(" bytes");
        Serial.print(" Tot= ");
        Serial.print(totalBytesWritten);
        Serial.print(" bytes");
        Serial.print("\r");
        Serial.flush();
  
        bufferIndex = 0;  
        Attend_buffer = true ;
        lastWriteTime = millis();
        Serial.write(XON);
      }
  }
  
  // Scrittura finale se ci sono dati rimasti nel buffer
  if (receiving && Serial.available() == 0 && bufferIndex > 0 && Attend_buffer) {
      unsigned long currentTime = millis();
      
      // Se è passato un tempo sufficiente dall'ultima scrittura
      if (currentTime - lastWriteTime >= 1000) {
          Serial.print("\nWriting last buffer: ");
          Serial.println(bufferIndex);
  
          SPI_TX_bytes(buffer, bufferIndex);
          
          // Calcola CRC32 per i dati nel buffer
          for (int i = 0; i < bufferIndex; i++) {
            uint8_t data = buffer[i];
            // Aggiornamento CRC con il nuovo byte letto
            crc ^= data;
            for (uint8_t j = 0; j < 8; j++) {
              crc = (crc >> 1) ^ (0xEDB88320 & -(crc & 1));
            }
          }   
            
          totalBytesWritten += bufferIndex;
          totalBlocksWritten++;
  
          
          Serial.print("Last buffer size: ");
          Serial.print(bufferIndex);
          Serial.println(" bytes!");
  
          bufferIndex = 0;  // Reset del buffer
          Serial.print("Total blocks written: ");
          Serial.println(totalBlocksWritten);
          Serial.print("Total bytes written: ");
          Serial.println(totalBytesWritten);     
          Serial.print("CRC32: ");
          Serial.println(~crc, HEX);        
          
          Serial.println("Data transfer to SPI completed!");
          receiving = false;  // Fine della ricezione dei dati
          inWriteLoop_SPI = false;  // Esci dal ciclo di scrittura
          execStop = millis();
          Serial.print("\nExec. : ");Serial.print(execStop - execStart);Serial.println("ms");
          bufferIndex=0;
          
          waiting_DONE_FPGA();
          bufferIndex=0;
          totalBytesWritten=0;
          totalBlocksWritten=0;
          Serial.print("> ");
          //disable_SPI();	
          pinMode(12, INPUT_PULLUP);
      }
  }
}

void SPI_TX_bytes(char *data, int length) {
    if( swSPIFlag == true ){
      for (int j = 0; j < length; j++) {  // Ciclo per ogni byte
          for (int i = 7; i >= 0; i--) {  // Invia un byte bit per bit
              uint8_t bitValue = (data[j] >> i) & 1;
              digitalWrite(12, bitValue);  // Imposta il MOSI
              digitalWrite(SCK, HIGH);   
              digitalWrite(SCK, LOW);   
          }
      }      
    }else{
      for (int i = 0; i < length; i++) {
        SPI.transfer(data[i]); // Invia i dati uno per uno
      }
    }

}

void SPI_TX(char data) {
    if( swSPIFlag == true ){
      for (int i = 7; i >= 0; i--) {  // Ciclo per inviare un byte bit per bit
          uint8_t bitValue = (data >> i) & 1;  // Estrai il bit
          digitalWrite(12, bitValue);  // Imposta il MOSI
          digitalWrite(SCK, HIGH);   // Imposta il clock
          digitalWrite(SCK, LOW);    // Abbassa il clock
      }
    }
    else{
      SPI.transfer(data);
    }

}

// Funzione per leggere un singolo byte via SPI software
char SPI_RX() {
    char receivedByte = 0;  // Variabile per memorizzare il byte ricevuto
    if( swSPIFlag == true ){      
      for (int i = 7; i >= 0; i--) {  // Ciclo per leggere un byte bit per bit
          digitalWrite(SCK, HIGH);  // Imposta il clock
          uint8_t bitValue = digitalRead(11);  // Legge il bit dal MISO (pin 11)
          receivedByte |= (bitValue << i);  // Aggiungi il bit al byte ricevuto
          digitalWrite(SCK, LOW);   // Abbassa il clock
      }
      return receivedByte;  // Restituisce il byte ricevuto
    }
    else {
      receivedByte=SPI.transfer(0x00);
      return receivedByte;
    }
}



void setSPI() {
    Serial.println("Default: 2000000Hz - MSBFIRST - SPI_MODE0\n");
    Serial.print("Enter SPI Clock (max 20000000 Hz): ");
    clkSPI = readSerialCommand().toInt();

    Serial.print("Enter SPI Bit Order (\033[7m0\033[0m=LSBFIRST, \033[7m1\033[0m=MSBFIRST): ");
    int bitOrderInput = readSerialCommand().toInt();
    bitOrder = (bitOrderInput == 0) ? LSBFIRST : MSBFIRST; 

    Serial.print("Enter SPI Mode (\033[7m0\033[0m, \033[7m1\033[0m, \033[7m2\033[0m, \033[7m3\033[0m): ");
    int spiModeInput = readSerialCommand().toInt();
    
    switch (spiModeInput) {
        case 0: spiMode = SPI_MODE0; break;
        case 1: spiMode = SPI_MODE1; break;
        case 2: spiMode = SPI_MODE2; break;
        case 3: spiMode = SPI_MODE3; break;
        default:
            Serial.println("Invalid mode");
            return;
    }
    SPI.begin();
    SPI.beginTransaction(SPISettings(clkSPI, bitOrder, spiMode));
}

void init_default_SPI(bool swFlag) {
    pinMode(CS_FLASH,OUTPUT);
    if (swFlag == false){
      SPI.begin();
      SPI.beginTransaction(SPISettings(clkSPI, bitOrder, spiMode));
      swSPIFlag = false;
    } else{
      pinMode(11, INPUT_PULLUP); 
      pinMode(12, OUTPUT); 
      pinMode(SCK, OUTPUT);
      swSPIFlag = true;
    }
   
    
}

void disable_SPI() {
    if (swSPIFlag == false){
      SPI.end();
    }
    pinMode(11, INPUT_PULLUP); 
    pinMode(12, INPUT_PULLUP); 
    pinMode(SCK, INPUT_PULLUP);
    pinMode(CS_FLASH,INPUT_PULLUP);
}

void receiveXmodem_SPI() {
    char buffer[XMODEM_BUFFER_SIZE];  // Buffer per i dati
    bool receiving = true;
    uint32_t fileSize = 0;
    uint32_t bytesWritten = 0; // Numero di byte già scritti in flash
    uint8_t lastBlockNum = 0;
    uint8_t retryCount = 0;
    const uint8_t MAX_RETRIES = 10;

    Serial.print("Enter FPGA size (\033[7m1\033[0m=7S6, \033[7m2\033[0m=7S15, \033[7m3\033[0m=7S25, \033[7m4\033[0m=7S50, \033[7m5\033[0m=custom): ");
    int typeFPGA = readSerialCommand().toInt();
    
    switch (typeFPGA) {
        case 0: Serial.println("Invalid value");return; break;
        case 1: fileSize = 0x838DC; break;
        case 2: fileSize = 0x838DC; break;
        case 3: fileSize = 0x12F2CC; break;
        case 4: fileSize = 0x21728C; break;
        case 5: 
          Serial.print("Enter file size (hex): ");
          fileSize = strtoul(readSerialCommand().c_str(), NULL, 16);
          break;
        default:
            Serial.println("Invalid value");
            return;
    }

    Serial.print("Parsed file size byte: ");
    Serial.println(fileSize);
    Serial.print("Ready to receive...");

    while (!Serial.available()) {
      Serial.write(NAK);  // Segnala che Arduino è pronto
      delay(500);
    }
    execStart = millis();    

    while (receiving) {
        if (!Serial.available()) continue;  

        uint8_t header = Serial.read();

        if (header == SOH) { // Start of Header 128-byte packet
        Serial.print("Header received: ");
            uint8_t blockNum = Serial.read();
            uint8_t blockNumInv = Serial.read();
            Serial.readBytes(buffer, XMODEM_BUFFER_SIZE); // Legge 128 byte
            uint8_t checksum = Serial.read(); // Riceve checksum       

            // Verifica il numero di blocco
            if (blockNum != (uint8_t)~blockNumInv) {
                Serial.write(NAK); // Errore, richiedi il blocco
                retryCount++;
                if (retryCount >= MAX_RETRIES) {
                    Serial.println("Too many errors. Aborting.");
                    Serial.write(CAN);
                    receiving = false;
                }
                continue;
            }

            // Se il blocco è duplicato, inviamo comunque ACK e lo ignoriamo
            if (blockNum == lastBlockNum) {
                Serial.write(ACK);
                continue;
            }
            
            // Calcola checksum sommando tutti i bit, va in overflow unit8
            // ovviamente fa parte del calcolo del chechsum.
            uint8_t calcChecksum = 0;
            for (int i = 0; i < XMODEM_BUFFER_SIZE; i++) {
                calcChecksum += buffer[i];
            }

            if (calcChecksum != checksum) {
                Serial.write(NAK);
                retryCount++;
                if (retryCount >= MAX_RETRIES) {
                    Serial.println("Too many errors. Aborting.");
                    Serial.write(CAN);
                    receiving = false;
                }
                continue;
            }
            
            // Determina quanti byte scrivere
            uint32_t bytesToWrite = XMODEM_BUFFER_SIZE;
            if (bytesWritten + XMODEM_BUFFER_SIZE > fileSize) {
                bytesToWrite = fileSize - bytesWritten;
            }      

            SPI_TX_bytes(buffer, bytesToWrite);
            bytesWritten += bytesToWrite;

            lastBlockNum = blockNum;  // Salva l'ultimo blocco ricevuto
            retryCount = 0;  // Reset contatore errori

            Serial.write(ACK);  // Conferma ricezione del pacchetto
        }

        else if (header == EOT) { // End of Transmission
            Serial.write(ACK);
            Serial.println("XMODEM Transfer Completed!");
            Serial.print("Total bytes written: ");
            Serial.println(bytesWritten);   
            execStop = millis();
            Serial.print("\nExec. : ");Serial.print(execStop - execStart);Serial.println("ms");                  
            receiving = false;
        }

        else if (header == CAN) { // Cancellazione da parte del trasmettitore
            Serial.println("XMODEM Transfer Canceled.");
            receiving = false;
        }
    }
}

// ###### SPI-NOR FLASH ######################################################

// **Abilita la scrittura**
void writeEnable() {
    digitalWrite(CS_FLASH, LOW);
    SPI_TX(0x06);
    digitalWrite(CS_FLASH, HIGH);
}


// **Verifica se la memoria è occupata**
bool isBusy() {
    digitalWrite(CS_FLASH, LOW);
    SPI_TX(0x05); // Comando RDSR (Read Status Register)
    bool busy = SPI_RX() & 0x01;
    digitalWrite(CS_FLASH, HIGH);
    return busy;
}

// **Cancella più settori specifici (4KB, 32KB, 64KB)**
void blockErase() {
    Serial.print(" Enter start address (hex): ");
    addr = strtoul(readSerialCommand().c_str(), NULL, 16);
    
    Serial.print(" Enter block size (\033[7m4096\033[0m, \033[7m32768\033[0m, \033[7m65536\033[0m): ");
    blockSize = readIntInput();
    
    Serial.print(" Enter number of blocks: ");
    numBlocks = readIntInput();

    execStart = millis(); 
    
    if (blockSize != 4096 && blockSize != 32768 && blockSize != 65536) {
        Serial.println("Unsupported size! Use 4096, 32768, or 65536.");
        return;
    }

    for (int i = 0; i < numBlocks; i++) {
        writeEnable();
        digitalWrite(CS_FLASH, LOW);

        if (blockSize == 4096) SPI_TX(0x20);  // Sector Erase (4KB)
        else if (blockSize == 32768) SPI_TX(0x52);  // Block Erase (32KB)
        else if (blockSize == 65536) SPI_TX(0xD8);  // Block Erase (64KB)

        SPI_TX((addr >> 16) & 0xFF);
        SPI_TX((addr >> 8) & 0xFF);
        SPI_TX(addr & 0xFF);

        digitalWrite(CS_FLASH, HIGH);

        Serial.print("Block erase ");
        Serial.print(blockSize / 1024);
        Serial.print("KB from address 0x");
        Serial.println(addr, HEX);

        while (isBusy()) {
            delay(100);
        }
        addr += blockSize;
    }
    Serial.println("All blocks are erased!");
    execStop = millis();  
    Serial.print("\nExec. : ");Serial.print(execStop - execStart);Serial.println(" ms");	
}

// Cancella tutta la memoria [Opcode 0xC7]
void chipErase() {  
    Serial.print(" You want erase whole chip [\033[7mY\033[0m/\033[7mN\033[0m]: ");
    String flag = readSerialCommand();
    
    if( flag == "Y" || flag == "y"){
      execStart = millis();
      writeEnable();
      digitalWrite(CS_FLASH, LOW);
      SPI_TX(0xC7);
      digitalWrite(CS_FLASH, HIGH);
      int i=0;

      Serial.println("Chip Erase in progress...");
      while (isBusy()) {
          delay(500);
          Serial.print(".");
          i++;
          if (i == 16){
            Serial.println(".");
            i=0;
          }

      }
      Serial.println("Chip Erase completed!");
      execStop = millis();
      Serial.print("\nExec. : ");Serial.print(execStop - execStart);Serial.println(" ms");


    }else{
      Serial.println("Chip Erase Aborted");
    }


}


// **Lettura di verifica con formattazione esadecimale**
// **Lettura di verifica con formattazione esadecimale e ASCII**
void readFlash() {
    Serial.print(" Enter start address (hex): ");
    addr = strtoul(readSerialCommand().c_str(), NULL, 16);

    Serial.print(" Enter number of bytes (hex): ");
    numByte = strtoul(readSerialCommand().c_str(), NULL, 16);

    execStart = millis();    

    const int bytesPerRow = 16; // Stampa massimo 16 byte per riga
    uint32_t bytesToRead = numByte;
    char asciiBuffer[bytesPerRow + 1]; // Buffer per i caratteri ASCII
    asciiBuffer[bytesPerRow] = '\0'; // Null terminator per la stringa

    Serial.println(" Reading SNOR:");

    digitalWrite(CS_FLASH, LOW);
    SPI_TX(0x03); // Opcode Read Data

    SPI_TX((addr >> 16) & 0xFF);
    SPI_TX((addr >> 8) & 0xFF);
    SPI_TX(addr & 0xFF);

    
    for (uint32_t i = 0; i < bytesToRead; i++) {
        if (i % bytesPerRow == 0) { 
            // Stampa il buffer ASCII della riga precedente
            if (i != 0) {
                Serial.print("  |");
                Serial.print(asciiBuffer);
                Serial.println("|");
            }
            // Inizia una nuova riga
            //Serial.print("\n\r0x");
            //Serial.print(addr + i, HEX);
            //Serial.print(": ");
            Serial.print("0x");
            char addrBuffer[5];
            sprintf(addrBuffer, "%05lX", (addr + i));
            Serial.print(addrBuffer);
            Serial.print(": ");
        }

        byte data = SPI_RX();
        
        // Stampa esadecimale con zero padding se minore di 16
        Serial.print(data < 16 ? "0" : "");
        Serial.print(data, HEX);
        Serial.print(" ");

        // Conversione in ASCII o sostituzione con un punto se non stampabile
        asciiBuffer[i % bytesPerRow] = (data >= 32 && data <= 126) ? (char)data : '.';
    }
    digitalWrite(CS_FLASH, HIGH);

    // Stampa l'ultima riga del buffer ASCII
    uint32_t remainingBytes = bytesToRead % bytesPerRow;
    if (remainingBytes > 0) {
        // Aggiunge spazi per allineare l'output ASCII
        for (uint32_t j = remainingBytes; j < bytesPerRow; j++) {
            Serial.print("   "); // Spazio per ogni byte mancante
        }
    }
    
    Serial.print("  |");
    Serial.print(asciiBuffer);
    Serial.print("|");

    Serial.println("\n\r Read complete!");
    execStop = millis();
    Serial.print("\nExec. : ");
    Serial.print(execStop - execStart);Serial.println(" ms");
}

void readFastFlash() {
    Serial.print(" Enter start address (hex): ");
    addr = strtoul(readSerialCommand().c_str(), NULL, 16);

    Serial.print(" Enter number of bytes (hex): ");
    numByte = strtoul(readSerialCommand().c_str(), NULL, 16);

    execStart = millis();    

    const int bytesPerRow = 16; // Stampa massimo 16 byte per riga
    uint32_t bytesToRead = numByte;
    char asciiBuffer[bytesPerRow + 1]; // Buffer per i caratteri ASCII
    asciiBuffer[bytesPerRow] = '\0'; // Null terminator per la stringa

    Serial.println(" Reading SNOR:");

    digitalWrite(CS_FLASH, LOW);
    SPI_TX(0x0B); // Opcode Fast Read

    SPI_TX((addr >> 16) & 0xFF);
    SPI_TX((addr >> 8) & 0xFF);
    SPI_TX(addr & 0xFF);
    SPI_RX(); // Dummy byte

    for (uint32_t i = 0; i < bytesToRead; i++) {
        if (i % bytesPerRow == 0) { 
            // Stampa il buffer ASCII della riga precedente
            if (i != 0) {
                Serial.print("  |");
                Serial.print(asciiBuffer);
                Serial.print("|");
            }
            // Inizia una nuova riga
            Serial.print("\n\r0x");
            Serial.print(addr + i, HEX);
            Serial.print(": ");
        }

        byte data = SPI_RX();
        
        // Stampa esadecimale con zero padding se minore di 16
        Serial.print(data < 16 ? "0" : "");
        Serial.print(data, HEX);
        Serial.print(" ");

        // Conversione in ASCII o sostituzione con un punto se non stampabile
        asciiBuffer[i % bytesPerRow] = (data >= 32 && data <= 126) ? (char)data : '.';
    }

    digitalWrite(CS_FLASH, HIGH);

    // Stampa l'ultima riga del buffer ASCII
    uint32_t remainingBytes = bytesToRead % bytesPerRow;
    if (remainingBytes > 0) {
        // Aggiunge spazi per allineare l'output ASCII
        for (uint32_t j = remainingBytes; j < bytesPerRow; j++) {
            Serial.print("   "); // Spazio per ogni byte mancante
        }
    }
    
    Serial.print("  |");
    Serial.print(asciiBuffer);
    Serial.print("|");

    Serial.println("\n\rFast Read complete!");
    execStop = millis();
    Serial.print("\nExec. : ");
    Serial.print(execStop - execStart);Serial.println(" ms");

}

// **Legge lo Status Register e lo stampa**
void printStatusRegister() {
    digitalWrite(CS_FLASH, LOW);
    SPI_TX(0x05); // Comando RDSR (Read Status Register)
    byte status = SPI_RX();
    digitalWrite(CS_FLASH, HIGH);

    Serial.print("Status Register: 0x");
    Serial.println(status, HEX);

    if (status & 0x01) Serial.println("Memory BUSY");
    if (status & 0x02) Serial.println("Write Enabled");
    if (status & 0x0C) Serial.println("Write protection");
}

// Scrive un singolo byte [Opcode 0x02]
void writeByte(uint32_t addr, byte data) {
    writeEnable();
    digitalWrite(CS_FLASH, LOW);
    SPI_TX(0x02);  // PP PageProgram

    SPI_TX((addr >> 16) & 0xFF);
    SPI_TX((addr >> 8) & 0xFF);
    SPI_TX(addr & 0xFF);

    SPI_TX(data);

    digitalWrite(CS_FLASH, HIGH);
    waitForWriteCompletion();
    Serial.print(" Byte written to address 0x");
    Serial.print(addr, HEX);
    Serial.print(": 0x");
    Serial.println(data, HEX);
}

// Legge il Device ID della memoria [Opcode 0x90]
void readREMS() {
    digitalWrite(CS_FLASH, LOW);
    SPI_TX(0x90); 
    SPI_TX(0x00);
    SPI_TX(0x00);
    SPI_TX(0x00);
    
    byte manufacturerID = SPI_RX();
    byte deviceID = SPI_RX();
    digitalWrite(CS_FLASH, HIGH);

    Serial.print("Manufacturer ID: 0x");
    Serial.println(manufacturerID, HEX);
    Serial.print("Device ID: 0x");
    Serial.println(deviceID, HEX);
}

// **Legge il Device ID della memoria Opcode 0x9F**
void readRDID() {
    digitalWrite(CS_FLASH, LOW);
    
    SPI_TX(0x9F);  // Comando per leggere Device ID   
    byte manufacturerID = SPI_RX();
    byte memoryType = SPI_RX();
    byte memoryCapacity = SPI_RX();

    digitalWrite(CS_FLASH, HIGH);

    Serial.print("Manufacturer ID: 0x");
    Serial.println(manufacturerID, HEX);
    Serial.print("Memory Type: 0x");
    Serial.println(memoryType, HEX);
    Serial.print("Memory Capacity: 0x");
    Serial.println(memoryCapacity, HEX);
}
// **Attende il completamento della scrittura leggendo lo Status Register**
void waitForWriteCompletion() {
    digitalWrite(CS_FLASH, LOW);
    SPI_TX(0x05); // Comando RDSR (Read Status Register)

    while (SPI_RX() & 0x01) {  // Controlla il bit BUSY
        delayMicroseconds(10);
    }

    digitalWrite(CS_FLASH, HIGH);
}

// Scrive una pagina da 256 byte [Opcode 0x02]
void writePage(uint32_t addr, char *data, int len) {
    digitalWrite(CS_FLASH, LOW);
    SPI_TX(0x02);  

    SPI_TX((addr >> 16) & 0xFF);
    SPI_TX((addr >> 8) & 0xFF);
    SPI_TX(addr & 0xFF);

    for (int i = 0; i < len; i++) {
        SPI_TX(data[i]);
    }

    digitalWrite(CS_FLASH, HIGH);
}

void UART_to_FLASH(){
  if (inWriteLoop_FLASH == false){
    inWriteLoop_FLASH = true;
    Serial.print("Enter start address (hex): ");
    flashAddress = strtoul(readSerialCommand().c_str(), NULL, 16); //
    inWriteLoop_FLASH = true;
    delay(100);
    Attend_buffer = false; // Si avvia solo dopo 1 buffer 256
    Serial.println(" ****** TERATEM ******");
    Serial.println(" * General Setting: ");
    Serial.println(" *     -Setup>Terminal> Receive=CR; Transmit=CR");
    Serial.println(" *     -Setup>Serial port> ");
    Serial.println(" *       Speed=115200; Data=8b; Parity=none; Stop bits=1");
    Serial.println(" *       Flowcontrol=Xon/Xoff; Transmit delay=0msec");
    Serial.println(" * Version:");
    Serial.println(" *     -Tested with verion 5.3");
    Serial.println(" * Tranfer setting:");
    Serial.println(" *     -File>Send file> ");
    Serial.println(" *         Filename: <file>");
    Serial.println(" *         Binary:[checked]");
    Serial.println(" *         delay type: <per sendsize>");
    Serial.println(" *         [send size(bytes): 256 ]");
    Serial.println(" *         delay time(ms): <0 or 1>");
    Serial.println("\nExecute chip Erase or erase blocks equal to the file size!");
    Serial.println("\nMinimun file size is 256byte!");
    Serial.println("\nReady to recive data from UART...");
  }	      
  
  if (Serial.available()) {
      if (!receiving) {
          Serial.write(XOFF);  
          Serial.println("Writing to SPI NOR started...");
          execStart = millis();
		      receiving = true;
      }
      
	  while (Serial.available() && bufferIndex < BUFFER_SIZE) {
          buffer[bufferIndex++] = Serial.read();
      }
  
      // Se il buffer è pieno, esegui la scrittura su SPI NOR
      if (bufferIndex == BUFFER_SIZE) {
        Serial.write(XOFF);
        writeEnable();  // Abilita la scrittura sulla memoria flash
        writePage(flashAddress, buffer, BUFFER_SIZE);  // Scrive i dati
        waitForWriteCompletion();  // Aspetta che la scrittura sia completata

        flashAddress += BUFFER_SIZE;  // Aggiorna l'indirizzo
        totalBytesWritten += BUFFER_SIZE;
        totalBlocksWritten++;

        // Calcola CRC32 per i dati nel buffer
        for (int i = 0; i < BUFFER_SIZE; i++) {
          uint8_t data = buffer[i];
          // Aggiornamento CRC con il nuovo byte letto
          crc ^= data;
          for (uint8_t j = 0; j < 8; j++) {
            crc = (crc >> 1) ^ (0xEDB88320 & -(crc & 1));
          }
        }


        Serial.print("Write ");
        Serial.print(BUFFER_SIZE);
        Serial.print(" bytes - Block #");
        Serial.print(totalBlocksWritten);
        Serial.print("\r");
        Serial.flush();        

        bufferIndex = 0;  
        Attend_buffer = true ;
        lastWriteTime = millis();  // Memorizza il tempo dell'ultima scrittura
        Serial.write(XON);  // Riabilita l'invio dei dati dalla seriale
      }
  }
  
  // Se la scrittura è in corso e ci sono ancora dati nel buffer
  if (receiving && Serial.available() == 0 && bufferIndex > 0 && Attend_buffer) {
      unsigned long currentTime = millis();  // Ottieni il tempo corrente
  
      // Se è passato un tempo sufficiente dall'ultima scrittura
      if (currentTime - lastWriteTime >= 1000) {
          Serial.print("\nWriting last byte buffer: ");
          Serial.println(bufferIndex);
  
          writeEnable();
          writePage(flashAddress, buffer, bufferIndex);  // Scrivi l'ultimo buffer
          waitForWriteCompletion();  // Attendi la fine della scrittura

          // Calcola CRC32 per i dati nel buffer
          for (int i = 0; i < bufferIndex; i++) {
            uint8_t data = buffer[i];
            // Aggiornamento CRC con il nuovo byte letto
            crc ^= data;
            for (uint8_t j = 0; j < 8; j++) {
              crc = (crc >> 1) ^ (0xEDB88320 & -(crc & 1));
            }
          }   

  
          totalBytesWritten += bufferIndex;
          totalBlocksWritten++;
  
          Serial.print("Last buffer size");
          Serial.print(bufferIndex);
          Serial.println(" byte!");
  
          bufferIndex = 0;  // Reset del buffer
          Serial.println("File saved into SPI NOR!");
          Serial.print("Total blocks written: ");
          Serial.println(totalBlocksWritten);
          Serial.print("Total bytes written: ");
          Serial.println(totalBytesWritten);
          Serial.print("CRC32: ");
          Serial.println(~crc, HEX);   		  
  
          receiving = false;  // Fine della ricezione dei dati
          inWriteLoop_FLASH = false;  // Esci dal ciclo di scrittura
          execStop = millis();
          Serial.print("\nExec. : ");Serial.print(execStop - execStart);Serial.println(" ms");
          disable_SPI();
          resetRelease_FPGA();
          Serial.print(">");
          addr=0;
          numByte=0;
          blockSize=0;
          numBlocks=0;
          bufferIndex=0;
          flashAddress=0;
          totalBytesWritten=0;
          totalBlocksWritten=0;
      }
  }
}

void calcCRC32() {
    
    crc = ~0L;  // Inizializza CRC32 con tutti i bit a 1
    uint8_t data;

    Serial.print(" Enter start address (hex): ");
    addr = strtoul(readSerialCommand().c_str(), NULL, 16);
    Serial.print("Enter FPGA size (\033[7m1\033[0m=7S6, \033[7m2\033[0m=7S15, \033[7m3\033[0m=7S25, \033[7m4\033[0m=7S50, \033[7m5\033[0m=custom): ");
    int typeFPGA = readSerialCommand().toInt();
    
    switch (typeFPGA) {
        case 0: Serial.println("Invalid value");return; break;
        case 1: numByte = 0x838DC; break;
        case 2: numByte = 0x838DC; break;
        case 3: numByte = 0x12F2CC; break;
        case 4: numByte = 0x21728C; break;
        case 5: 
          Serial.print("Enter file size (hex): ");
          numByte = strtoul(readSerialCommand().c_str(), NULL, 16);
          break;
        default:
            Serial.println("Invalid value");
            return;
    }

    Serial.print("Parsed file size byte: ");
    Serial.println(numByte);
    Serial.println("Opcode 03h");
    Serial.print("Ready to receive...");

    execStart = millis();

    Serial.println("Calculating CRC32...");

    while (numByte--) {
        // Lettura di un byte dalla memoria SPI
        digitalWrite(CS_FLASH, LOW);
        SPI_TX(0x03); // Opcode READ DATA
        SPI_TX((addr >> 16) & 0xFF);
        SPI_TX((addr >> 8) & 0xFF);
        SPI_TX(addr & 0xFF);
        data = SPI_RX();
        digitalWrite(CS_FLASH, HIGH);

        // Aggiornamento CRC con il nuovo byte letto
        crc ^= data;
        for (uint8_t i = 0; i < 8; i++) {
            crc = (crc >> 1) ^ (0xEDB88320 & -(crc & 1));
        }

        addr++;  // Incrementa l'indirizzo per il prossimo byte
    }

    Serial.print("CRC32 : ");
    Serial.println(~crc, HEX);  // XOR finale per completare il calcolo CRC32
    execStop = millis();
    Serial.print("\nExec. : ");Serial.print(execStop - execStart);Serial.println(" ms");
}

void hardwareRST() {
    digitalWrite(RST_FLASH, HIGH);
    delay(100);
    digitalWrite(RST_FLASH, LOW);
    delay(100);
    digitalWrite(RST_FLASH, HIGH);
}

void dumpFlashToUART() {

    Serial.println(" ****** TERATEM ******");
    Serial.println(" * General Setting: ");
    Serial.println(" *     -Setup>Terminal> Receive=AUTO; Transmit=CR");
    Serial.println(" *     -Setup>Serial port> Speed=115200; Data=8b; Parity=none; Stop bits=1;");
    Serial.println(" *       Flowcontrol=Xon/Xoff; Transmit delay=0msec");
    Serial.println(" * Version:");
    Serial.println(" *     -Tested with verion 5.3");
    Serial.println(" * Acquire setting:");
    Serial.println(" *     -File>Log...> ");
    Serial.println(" *         Filename: <file>");
    Serial.println(" *         Write mode: Append");
    Serial.println(" *         Binary:[checked]");
    Serial.println(" *Execute this configuration then set waiting time");
    Serial.println(" * 1-Start log file while LED is blinking");
    Serial.println(" * 2-When the LED is ON,the acquisition is in progress");
    Serial.println(" * 3-When the LED is OFF,close the log file\n");

    Serial.println(" Opcode 03h");
    Serial.print(" Enter start address (hex): ");
    uint32_t addr = strtoul(readSerialCommand().c_str(), NULL, 16);

    Serial.print(" Enter number of bytes (hex): ");
    uint32_t numBytes = strtoul(readSerialCommand().c_str(), NULL, 16);

    Serial.print(" Enter the waiting time before/after acquisition: ");
    int wait = strtoul(readSerialCommand().c_str(), NULL, 10);

    pinMode(SCK, OUTPUT);
    for (int i = 0;i < wait; i++){
      digitalWrite(SCK, HIGH);
      delay(500);
      digitalWrite(SCK, LOW);
      delay(500);
    }

    init_default_SPI(1);

    uint32_t bytesRead = 0;

    while (bytesRead < numBytes) {
        //Se i byte rimanenti sono meno di 256.
        uint32_t chunkSize = min((uint32_t)BUFFER_SIZE, numBytes - bytesRead);

        // Inizio lettura SPI Flash
        digitalWrite(CS_FLASH, LOW);
        SPI_TX(0x03); // Comando Read Data
        SPI_TX((addr >> 16) & 0xFF);
        SPI_TX((addr >> 8) & 0xFF);
        SPI_TX(addr & 0xFF);

        // Attendere XON prima di inviare i dati
        while (Serial.available() && Serial.read() == XOFF) {
            delayMicroseconds(10); // Aspetta XON
        }

        // Lettura e invio dei dati via UART
        for (uint32_t i = 0; i < chunkSize; i++) {
            byte data = SPI_RX();
            Serial.write(data);
        }

        digitalWrite(CS_FLASH, HIGH);

        // Aggiornamento indici
        bytesRead += chunkSize;
        addr += chunkSize;
    }
}


void customSPITransaction() {
    Serial.print("Enter Write Byte (hex, e.g. opcode): ");
    uint8_t writeByte = strtoul(readSerialCommand().c_str(), NULL, 16);

    Serial.print("How many dummy bytes? ");
    uint8_t numDummyBytes = readSerialCommand().toInt();


    Serial.print("Dummy byte value (\033[7m0\033[0m0=0x00, \033[7m1\033[0m=0xFF): ");
    uint8_t dummyType = readSerialCommand().toInt();
    uint8_t dummyByte = (dummyType == 1) ? 0xFF : 0x00;
   
    Serial.print("How many bytes do you want to read? ");
    uint32_t numReadBytes = readSerialCommand().toInt();

    execStart = millis();
    // Inizio Transazione SPI
    digitalWrite(CS_FLASH, LOW);
    SPI_TX(writeByte);  // Invia l'OpCode o Write Byte
    
    // Invio dummy bytes se necessario
    for (uint8_t i = 0; i < numDummyBytes; i++) {
        SPI_TX(dummyByte);
    }

    // Lettura risposta
    Serial.print("Response: ");
    for (uint32_t i = 0; i < numReadBytes; i++) {
        uint8_t data = SPI_RX();
        Serial.print(data < 16 ? "0" : "");
        Serial.print(data, HEX);
        Serial.print(" ");
    }
    execStop = millis();
    digitalWrite(CS_FLASH, HIGH);
    Serial.print("\nExec. : ");Serial.print(execStop - execStart);Serial.println("ms");
}

void receiveXmodem() {
    uint8_t buffer[XMODEM_BUFFER_SIZE];  // Buffer per i dati
    bool receiving = true;
    uint32_t fileSize = 0;
    uint32_t bytesWritten = 0; // Numero di byte già scritti in flash
    uint8_t lastBlockNum = 0;
    uint8_t retryCount = 0;
    const uint8_t MAX_RETRIES = 10;
    // Chiedi la dimensione del file
    Serial.println(" Opcode 02h");


    Serial.print("Enter FPGA size (\033[7m1\033[0m=7S6, \033[7m2\033[0m=7S15, \033[7m3\033[0m=7S25, \033[7m4\033[0m=7S50, \033[7m5\033[0m=custom): ");
    int typeFPGA = readSerialCommand().toInt();
    
    switch (typeFPGA) {
        case 0: Serial.println("Invalid value");return; break;
        case 1: fileSize = 0x838DC; break;
        case 2: fileSize = 0x838DC; break;
        case 3: fileSize = 0x12F2CC; break;
        case 4: fileSize = 0x21728C; break;
        case 5: 
          Serial.print("Enter file size (hex): ");
          fileSize = strtoul(readSerialCommand().c_str(), NULL, 16);
          break;
        default:
            Serial.println("Invalid value");
            return;
    }    

    Serial.print("Parsed file size byte: ");
    Serial.println(fileSize);

    Serial.print("Enter start address (hex): ");
    flashAddress = strtoul(readSerialCommand().c_str(), NULL, 16);

    Serial.print("Ready to receive...");    

    while (!Serial.available()) {
      Serial.write(NAK);  // Segnala che Arduino è pronto
      delay(500);
    }
    execStart = millis();    

    while (receiving) {
        if (!Serial.available()) continue;  

        uint8_t header = Serial.read();

        if (header == SOH) { // Start of Header 128-byte packet
            uint8_t blockNum = Serial.read();
            uint8_t blockNumInv = Serial.read();
            Serial.readBytes(buffer, XMODEM_BUFFER_SIZE); // Legge 128 byte
            uint8_t checksum = Serial.read(); // Riceve checksum       

            // Verifica il numero di blocco
            if (blockNum != (uint8_t)~blockNumInv) {
                Serial.write(NAK); // Errore, richiedi il blocco
                retryCount++;
                if (retryCount >= MAX_RETRIES) {
                    Serial.println("Too many errors. Aborting.");
                    Serial.write(CAN);
                    receiving = false;
                }
                continue;
            }

            // Se il blocco è duplicato, inviamo comunque ACK e lo ignoriamo
            if (blockNum == lastBlockNum) {
                Serial.write(ACK);
                continue;
            }
            
            // Calcola checksum sommando tutti i bit, va in overflow unit8
            // ovviamente fa parte del calcolo del chechsum.
            uint8_t calcChecksum = 0;
            for (int i = 0; i < XMODEM_BUFFER_SIZE; i++) {
                calcChecksum += buffer[i];
            }

            if (calcChecksum != checksum) {
                Serial.write(NAK);
                retryCount++;
                if (retryCount >= MAX_RETRIES) {
                    Serial.println("Too many errors. Aborting.");
                    Serial.write(CAN);
                    receiving = false;
                }
                continue;
            }
            
            // Determina quanti byte scrivere
            uint32_t bytesToWrite = XMODEM_BUFFER_SIZE;
            if (bytesWritten + XMODEM_BUFFER_SIZE > fileSize) {
                bytesToWrite = fileSize - bytesWritten;
            }      

            // Scrivi in flash solo i byte validi
            writeEnable();
            writePage(flashAddress, (char*)buffer, bytesToWrite);
            waitForWriteCompletion();
            flashAddress += bytesToWrite;
            bytesWritten += bytesToWrite;

            lastBlockNum = blockNum;  // Salva l'ultimo blocco ricevuto
            retryCount = 0;  // Reset contatore errori

            Serial.write(ACK);  // Conferma ricezione del pacchetto
        }

        else if (header == EOT) { // End of Transmission
            Serial.write(ACK);
            Serial.println("XMODEM Transfer Completed!");
            Serial.println("File saved into SPI NOR!");
            Serial.print("Total bytes written: ");
            Serial.println(bytesWritten);   
            execStop = millis();
            Serial.print("\nExec. : ");Serial.print(execStop - execStart);Serial.println("ms");                  
            receiving = false;
        }

        else if (header == CAN) { // Cancellazione da parte del trasmettitore
            Serial.println("XMODEM Transfer Canceled.");
            receiving = false;
        }
    }
}

void sendXmodem() {
    uint8_t buffer[XMODEM_BUFFER_SIZE] = {0};  
    uint32_t fileSize = 0;
    uint32_t bytesSent = 0;  
    uint8_t blockNum = 1;
    uint8_t fillByte = 0xFF;  // Default: 0xFF

    Serial.println(" Opcode 03h");
    Serial.print("Enter start address (hex): ");
    uint32_t startAddress = strtoul(readSerialCommand().c_str(), NULL, 16);
    
    Serial.print("Enter FPGA size (\033[7m1\033[0m=7S6, \033[7m2\033[0m=7S15, \033[7m3\033[0m=7S25, \033[7m4\033[0m=7S50, \033[7m5\033[0m=custom): ");
    int typeFPGA = readSerialCommand().toInt();
    
    switch (typeFPGA) {
        case 0: Serial.println("Invalid value");return; break;
        case 1: fileSize = 0x838DC; break;
        case 2: fileSize = 0x838DC; break;
        case 3: fileSize = 0x12F2CC; break;
        case 4: fileSize = 0x21728C; break;
        case 5: 
          Serial.print("Enter file size (hex): ");
          fileSize = strtoul(readSerialCommand().c_str(), NULL, 16);
          break;
        default:
            Serial.println("Invalid value");
            return;
    }

    Serial.print("Parsed file size byte: ");
    Serial.println(fileSize);

    // Controlla se il file è multiplo di 128 byte
    if (fileSize % XMODEM_BUFFER_SIZE != 0) {
        Serial.println("\nWarning: File size is not a multiple of 128 bytes.");
        Serial.print("Enter padding byte (hex, default 1A): ");
        String fillByteStr = readSerialCommand();
        if (fillByteStr.length() > 0) {
            fillByte = strtoul(fillByteStr.c_str(), NULL, 16);
        }
    }

    Serial.println("Waiting for receiver...");

    // Attendi il NAK iniziale
    while (Serial.available() == 0);
    uint8_t response = Serial.read();
    if (response != NAK) {
        Serial.println("Receiver not ready. Aborting.");
        return;
    }

    Serial.println("Sending XMODEM data...");
    execStart = millis();

    while (bytesSent < fileSize) {
        uint32_t bytesToSend = min((uint32_t)XMODEM_BUFFER_SIZE, fileSize - bytesSent);


        // **Leggi i dati dalla memoria SPI NOR**
        digitalWrite(CS_FLASH, LOW);
        SPI_TX(0x03);  
        SPI_TX((startAddress >> 16) & 0xFF);
        SPI_TX((startAddress >> 8) & 0xFF);
        SPI_TX(startAddress & 0xFF);
        for (uint32_t i = 0; i < bytesToSend; i++) {
            buffer[i] = SPI_RX();
        }
        digitalWrite(CS_FLASH, HIGH);

        // **Se l'ultimo pacchetto è inferiore a 128 byte, riempi con il valore scelto**
        for (uint32_t i = bytesToSend; i < XMODEM_BUFFER_SIZE; i++) {
            buffer[i] = fillByte;
        }

        // **Calcola checksum**
        uint8_t checksum = 0;
        for (uint32_t i = 0; i < XMODEM_BUFFER_SIZE; i++) {
            checksum += buffer[i];
        }

        // **Invia pacchetto sempre di 128 byte**
        Serial.write(SOH);
        Serial.write(blockNum);
        Serial.write(~blockNum);
        Serial.write(buffer, XMODEM_BUFFER_SIZE);
        Serial.write(checksum);

        // **Aspetta ACK o NAK**
        while (Serial.available() == 0);
        response = Serial.read();
        if (response == ACK) {
            startAddress += bytesToSend;
            bytesSent += bytesToSend;
            blockNum++;
        } else if (response == NAK) {
            Serial.println("NAK received, resending block...");
            continue;
        } else {
            Serial.println("Transmission aborted by receiver.");
            return;
        }
    }

    // **Invia EOT finché non riceve ACK**
    do {
        Serial.write(EOT);
        delay(100);
        while (Serial.available() == 0);
        response = Serial.read();
    } while (response != ACK);

    Serial.println("XMODEM Transfer Completed!");
    Serial.print("Total bytes sent: ");
    Serial.println(bytesSent);
    execStop = millis();
    Serial.print("\nExec. time: "); Serial.print(execStop - execStart); Serial.println("ms");
}


void echoUART() {
  const int BUFFER_SIZE_UART = 64;
  char rx_buffer[BUFFER_SIZE_UART];
  int buffer_pos_uart = 0;
  unsigned long last_receive_time = 0;
  const unsigned long SEND_TIMEOUT_MS = 10;

  Serial1.begin(115200);
  Serial.begin(115200);

  Serial.println("Exit Ctrl+C");

  while (true) {
    // Ctrl+C da USB
    if (Serial.available()) {
      char pc_char = Serial.read();
      Serial1.write(pc_char);
      if (pc_char == 3) {
        Serial.println("Ctrl+C detected");
        break;
      }
    }

    // Ricezione da FPGA
    while (Serial1.available()) {
      char c = Serial1.read();
      rx_buffer[buffer_pos_uart++] = c;
      last_receive_time = millis(); // aggiorna appena ricevi

      if (buffer_pos_uart >= BUFFER_SIZE_UART) {
        Serial.write(rx_buffer, BUFFER_SIZE_UART);
        Serial.flush();
        buffer_pos_uart = 0;
      }
    }

    // Ogni 10ms invia il buffer
    if (buffer_pos_uart > 0 && (millis() - last_receive_time) > SEND_TIMEOUT_MS) {
      Serial.write(rx_buffer, buffer_pos_uart);
      Serial.flush();
      buffer_pos_uart = 0;
    }
  }
}

void ISR() {
  pg_value = false;
}
void statusPG() {

  if ( ! pg_value){
    if( pg_fail == " " ){
      Serial.print("\033[31mWARNING FAIL PG\033[0m");
    }
    pg_fail= "\033[31mWARNING FAIL PG\033[0m";
  }
}  

/*
Colore	Testo (FG)	Sfondo (BG)
Nero	\033[30m	\033[40m
Rosso	\033[31m	\033[41m
Verde	\033[32m	\033[42m
Giallo	\033[33m	\033[43m
Blu		\033[34m	\033[44m
Magenta	\033[35m	\033[45m
Ciano	\033[36m	\033[46m
Bianco 	\033[37m	\033[47m
*/
