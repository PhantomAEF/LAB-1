//*****************************************************************
// Universidad del Valle de Guatemala
// IE2023: Programacion de microcontroladores
// Proyecto: Lab 1
// Created: 30/1/2024 18:40:44
// Author : alane
//*****************************************************************
// Encabezado
//*****************************************************************
.INCLUDE "M328PDEF.inc"
.CSEG //Inicio del código
.ORG 0x00 //Vector RESET, dirección incial

//***********************
// Stack Pointer
//***********************
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17

//***********************
// Configuracion 
//***********************
Setup:
	
    LDI R16, (1 << CLKPCE) //Prescaler habilitado
    STS CLKPR, R16

	LDI R16, 0b0000_0100 //Defino la frecuencia
	STS CLKPR, R16

	LDI R16, 0b0000_0000 //PORTC como entradas
	OUT DDRC, R16
	LDI R16, 0b1111_1111 //PORTC con Pull_ups
	OUT PORTC, R16

	LDI R16, 0b1111_1111 //PORTD como salidas
	OUT DDRD, R16

	LDI R16, 0b0010_1111 //PORTb como salidas
	OUT DDRB, R16

	LDI R19, 0x00 //reset de variables de cuenta
	LDI R17, 0x00
	LDI R18, 0x00

	LDI R16, 0b0000_0000 //reset de salidas en los puertos
	OUT PORTB, R16
	OUT PORTD, R16


	

loop:
PrimerBoton: //Lectura del primer boton
    IN R16, PINC
	SBRS R16, PC0
	CALL Pres1
//******************************************
SegundoBoton: //Lectura del segundo boton
	IN R16, PINC
	SBRS R16, PC1
	CALL Pres2
//******************************************
TercerBoton: //Lectura del tercer boton
	IN R16, PINC
	SBRS R16, PC2
	CALL Pres3
//******************************************
CuartoBoton: //Lectura del cuarto boton
	IN R16, PINC
	SBRS R16, PC3
	CALL Pres4
//******************************************
QuintoBoton: //Lectura del quinto boton
	IN R16, PINC
	SBRS R16, PC4
	CALL Pres5
Regresaralloop:
	RJMP loop
//***********************
// Sub-rutinas 
//***********************

delay: //Funcion delay general
	LDI R16, 100

	delay1:
		DEC R16
		BRNE delay1
	ret

Pres1: //Funcion luego de detectar un boton presionado
	NOP
	CALL delay //Espera el delay para no sumar valores fantasmas
	SBIS PINC, PC0 //Sigue la funcion hasta que el usuario haya soltado el boton
	JMP Pres1 //Si aun no lo suelta regresa al incio del Delay
	RJMP incre //Si ya lo solto podemos sumar el valor ya que estamos seguros de que no es un valor fantasma

Pres2:
	NOP
	CALL delay
	SBIS PINC, PC1
	JMP Pres2
	RJMP decre

Pres3:
	NOP
	CALL delay
	SBIS PINC, PC2
	JMP Pres3
	RJMP incre2

Pres4:
	NOP
	CALL delay
	SBIS PINC, PC3
	JMP Pres4
	RJMP decre2

Pres5:
	NOP
	CALL delay
	SBIS PINC, PC4
	JMP Pres5
	RJMP suma

incre:
    INC R19 //Incrementa la cuenta de la primera fila de leds
    SBRC R19, 4 // Limitar el contador a 4 bits
    CLR R19 //De ser necesario elimina el registro por overflow
	RJMP LEDS1
	RJMP loop

decre:
	DEC R19 //Decrementa la cuenta de la primera fila de leds
    SBRC R19, 7 // Limitar el contador a no tener numeros negativos
	CLR R19 //De ser necesario elimina el registro por overflow
	RJMP LEDS1
	RJMP loop

incre2:
	INC R17 //Incrementa la cuenta de la segunda fila de leds
    SBRC R17, 4 // Limitar el contador a 4 bits
    CLR R17 //De ser necesario elimina el registro por overflow
	RJMP LEDS2 //Llama a la funcion para desplegar los valores
	RJMP loop

decre2:
	DEC R17 //Decrementa la cuenta de la segunda fila de leds
    SBRC R17, 7 // Limitar el contador a no tener numeros negativos
    CLR R17 //De ser necesario elimina el registro por overflow
	RJMP LEDS2 //Llama a la funcion para desplegar los valores
	RJMP loop

suma:
	MOV R18, R19 // Mueve la primera cuenta a un registro temporal
    ADD R18, R17 // Suma el registro temporal con la segunda cuenta
	SBRC R18, 4 //Limita a 4 bits
	CALL carry //Si se sobre pasa hay carry
	MOV R21, R18 //Mueve la sumatoria a un registro temporal
	ANDI R20, 0b1111_0000
	OR R21, R20 //Realiza un OR con los valores que puede tener la primera cuenta
	OUT PORTD, R21 //Realiza el out del puerto completo
	RJMP loop
LEDS1:
	OUT PORTB, R19
	RJMP loop

LEDS2:
    IN R20, PORTD //Lee en una variable temporal los valores del PORTD
	ANDI R20, 0b0000_1111 //Realiza un AND para eliminar los valores sobrantes de la cuenta anterior y mantiene los valores que se despliegan de la suma
	MOV R16, R17 //Mueve la cuenta a una variable temporal
	SWAP R16 //Realiza un swap para pasar los valores del R17 a el HIGH Byte de R16
	OR R20, R16 //Realiza un OR logico para mostra en R20 los valores de la segunda cuenta y de la sumatoria
	OUT PORTD, R20 //Realiza el out del puerto completo
	RJMP loop

carry:
	SBI PORTB, PB5 //Setea el bit de carry en caso de haber uno 
	CLR R18
	RET
