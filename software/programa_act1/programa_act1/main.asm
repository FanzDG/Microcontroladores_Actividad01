;
; programa_act1.asm
;
; Created: 28/09/2026 10:28:47 p. m.
; Author : alfonso
;
.include "m328Pdef.inc"

;---------- configuracion de puertos ------------
RESET:
    ldi  r16, (1<<PB5)      ; mascara de PB5 (se conserva en r16)
    out  DDRB, r16          ; PB5 como salida
    ldi  r17, 0x00
    out  DDRD, r17          ; PORTD como entrada (PD2 y PD3)

;---------- lectura y seleccion -----------------
LEER:
    in   r17, PIND
    andi r17, 0x0C          ; aislar PD3 y PD2
    cpi  r17, 0x00
    breq F100K
    cpi  r17, 0x04
    breq F500K
    cpi  r17, 0x08
    breq F1M
    rjmp F2M                ; 0x0C

;---------- 100 kHz (medio periodo = 80 ciclos) --
F100K:
    out  PINB, r16          ; conmuta PB5 (alto)
    ldi  r18, 26            ; 78 ciclos
D1: dec  r18
    brne D1
    nop                     ; +1 -> 79 de retardo
    out  PINB, r16          ; conmuta PB5 (bajo)
    ldi  r18, 24            ; 72 ciclos
D2: dec  r18
    brne D2
    nop
    nop                     ; +2 -> 74 de retardo
    in   r17, PIND
    andi r17, 0x0C
    cpi  r17, 0x00
    breq F100K              ; sigue igual -> repetir
    rjmp LEER               ; cambio -> volver a leer

;---------- Modulo 4: 500 kHz (medio periodo = 16 ciclos) --
F500K:
    out  PINB, r16
    ldi  r18, 5             ; 15 ciclos
D3: dec  r18
    brne D3
    out  PINB, r16
    ldi  r18, 3             ; 9 ciclos
D4: dec  r18
    brne D4
    nop                     ; +1 -> 10
    in   r17, PIND
    andi r17, 0x0C
    cpi  r17, 0x04
    breq F500K
    rjmp LEER

;---------- 1 MHz (medio periodo = 8 ciclos) -----
F1M:
    out  PINB, r16
    ldi  r18, 2             ; 6 ciclos
D5: dec  r18
    brne D5
    nop                     ; +1 -> 7
    out  PINB, r16
    nop
    nop                     ; 2 de retardo
    in   r17, PIND
    andi r17, 0x0C
    cpi  r17, 0x08
    breq F1M
    rjmp LEER

;---------- Modulo 6: 2 MHz (medio periodo = 4 ciclos) -----
F2M:
    out  PINB, r16          ; t=0
    in   r17, PIND          ; t=1
    andi r17, 0x0C          ; t=2
    cpi  r17, 0x0C          ; t=3
    out  PINB, r16          ; t=4
    nop                     ; t=5
    breq F2M                ; t=6-7 (tomado = 2 ciclos) -> periodo 8
    rjmp LEER
