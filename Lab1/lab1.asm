;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Mall för lab1 i TSEA28 Datorteknik Y
;;
;; 210105 KPa: Modified for distance version
;;

	;; Ange att koden är för thumb mode
	.thumb
	.text
	.align 2

	;; Ange att labbkoden startar här efter initiering
	.global	main
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Ange vem som skrivit koden
;;               student LiU-ID: eskbr129
;; + ev samarbetspartner LiU-ID: gusho710
;;
;; Placera programmet här

main:
	bl inituart ;Initiera programmet
	bl initGPIOE
	bl initGPIOF

	bl setcode ;Sätter koden

	;bl oneSecondTimerReset ;Nollställer 1 sekunds-timern
lockActivate:
	bl activatealarm ;Aktivera alarmet
clearBuffer:
	bl clearinput ;Cleara bufferten
getinput:
	bl getkey ;Hämtar knapptryck till r4
	mov r3, #0x9
	cmp r3, r4; ;kollar om r4 är mindre än 9 eller mindre
	bpl addkeytobuffer ; Om stämmer, lägg in knappen i bufferten, och vänta på nästa knapptryck

	mov r3, #0xE; om knappen är E, töm bufferten
	cmp r3, r4
	bpl clearBuffer

	bl checkcode ; F har tryckts
	cmp r4, #0x1
	beq correctCode ;Om koden är korrekt, gå till det stycket
	mov r5, #0xE ;Längden på textsträng 14
	bl printstring ; skriver ut error
	b clearBuffer ;börja om
correctCode:
	bl deactivatealarm ;deaktiverar alarm
getInputAgain: ;väntar på a knapptryck
	bl getkey
	cmp r4, #0xA
	beq aPressed ;Om a är tryckt aktivera låset
	b getInputAgain
aPressed:
	b lockActivate ; Om a trycks in, aktivera låset igen
addkeytobuffer:
	bl addkey ;Lägger till key
	b getinput ;Hoppa tillbaka


endloop: b endloop ;Endloop, programavslut


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutiner
;

setcode:
	; F ̈orberedelseuppgift: Skriv denna subrutin!
	mov r0,#(0x20001010 & 0xffff) ;Tar första halvan, och lägger i r0
	movt r0,#(0x20001010 >> 16)	; Lägger in andra halvan av adressen i r0
	mov r1,#0x1 ;Fyll r1 med 1:or
	strb r1,[r0] ;Fyll minnet på r0 med 1:or som ligger i r1
	;Samma som ovan
	mov r0,#(0x20001011 & 0xffff)
	movt r0,#(0x20001011 >> 16)
	mov r1,#0x2
	strb r1,[r0]
	;samma som ovan
	mov r0,#(0x20001012 & 0xffff)
	movt r0,#(0x20001012 >> 16)
	mov r1,#0x3
	strb r1,[r0]
	;Samma som ovan
	mov r0,#(0x20001013 & 0xffff)
	movt r0,#(0x20001013 >> 16)
	mov r1,#0x4
	strb r1,[r0]
	;Hoppa tillbaka
	bx lr

FELKOD .string  "Felaktig kod",10,13

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Inga
; Utargument: Sätter r12 till 160000
 ;oneSecondTimerReset:
	;:mov r12,#(0xF42400 & 0xffff)
	;:movt r12,#(0xF42400 >> 16)	;Fyll r12 med 16 000 000
	;:bx lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Inga
; Utargument: Returnerar 1 i r11 om 1 sekund har gått, annars 0 i r11
 ;oneSecondTick:
	;mov r11,#0x0 ;Return är 0 i vanliga fall
	;sub r12,r12, #0x1 ;Substractar 1 från timern
	;cmp r12, #0x1 ; Se om timern är nere på 1
	;beq r11True;


	;bx lr ;Hoppa tillbaka

 ;r11True:
	;mov r11,#0x1
	;bx lr


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Inga
; Utargument: Returnerar 1 i r4 om koden var korrekt, annars 0 i r4

checkcode:
	; F ̈orberedelseuppgift: Skriv denna subrutin!
	mov r0,#(0x20001000 & 0xffff) ;laddar in inputkoden addressen
	movt r0,#(0x20001000 >> 16)
	mov r1,#(0x20001010 & 0xffff) ;Laddar in pinkoden addressen
	movt r1,#(0x20001010 >> 16)

	ldr r2, [r0] ; r2 = inputkoden
	ldr r3, [r1] ; r3 = pinkoden
	cmp r2, r3 ; Jämför input och pinkod
	bne wrongCode ; Om koden är fel, brancha

	mov r4, #0x1 ; Om rätt kod, returna 1
	bx lr

wrongCode:
	mov r4, #0x0 ; Om fel kod returna 0
	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Vald tangent i r4
; Utargument: Inga
;
; Funktion: Flyttar inneh ̊allet p ̊a 0x20001000-0x20001002 fram ̊at en byte
; till 0x20001001-0x20001003. Lagrar sedan inneh ̊allet i r4 p ̊a
; adress 0x20001000.
addkey:
	; F ̈orberedelseuppgift: Skriv denna subrutin!
	mov r0,#(0x20001000 & 0xffff) ;r0 blir första minnesadressen
	movt r0,#(0x20001000 >> 16)

	mov r1,#(0x20001001 & 0xffff) ;r1 blir andra minnesadressen
	movt r1,#(0x20001001 >> 16)

	mov r2,#(0x20001002 & 0xffff) ;r2 blir tredje minnesadressen
	movt r2,#(0x20001002 >> 16)

	mov r3,#(0x20001003 & 0xffff) ;r3 blir fjärde minnesadressen
	movt r3,#(0x20001003 >> 16)

	ldrb r5,[r2] ; Flyttar fram alla värden 1 steg mellan r0-r3
	strb r5,[r3]
	ldrb r5,[r1]
	strb r5,[r2]
	ldrb r5,[r0]
	strb r5,[r1]

	strb r4,[r0] ; laddar in nya värdet i r0

	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Inga
; Utargument: Tryckt knappt returneras i r4
getkey:
	; F ̈orberedelseuppgift: Skriv denna subrutin!
	mov r1,#(GPIOE_GPIODATA & 0xffff) ;Lägger in adressen till tangentbordets data till r1
	movt r1,#(GPIOE_GPIODATA >> 16)
waitForStrobe1:
	PUSH { LR } ;Sparar vart man är

	;bl oneSecondTick
	;cmp r11, #0x1
	;bl turnOffLamp
	;bl oneSecondTimerReset


	POP { LR } ; Hämtar vart man kom ifrån

	ldrb r0,[r1] ;Hämtar tangentbordsdata till r0
	ands r2,r0,#0x10 ; kolla om bit 4 är 1
	beq waitForStrobe1 ; Om övre raden är 0, fortsätt loopa.
	mov r4, r0 ; Lagra knapptrycket i r4
	and r4,r4,#0xF ; Spara bara sista 4 bitarna
waitForStrobe0:

	ldrb r0,[r1] ;Hämtar tangentbordsdata till r0
	ands r2,r0,#0x10 ; kolla om bit 4 är 1
	bne waitForStrobe0 ; fortsätt loopa om knappen är intryckt

	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Pekare till str ̈angen i r4
; L ̈angd p ̊a str ̈angen i r5
; Utargument: Inga
;
; Funktion: Skriver ut str ̈angen mha subrutinen printchar
printstring:
	; F ̈orberedelseuppgift: Skriv denna subrutin!
	PUSH { LR } ;Sparar vart man är
	mov r6, #0x0 ; ;Räknare för hur många tecken som skrivits
	adr r7, FELKOD ; lägger adressen i r7
stringLoop:
	ldrb r0, [r7] ;r0 startadress för felkod
	bl printchar ; printa en char
	add r7,r7,#0x1 ; läs nästa adress
	add r6,r6,#0x1 ; räknaren för karaktär
	cmp r6, r5 ;
	bne stringLoop ;fortsätt om r7 och r6 inte är samma.
	POP { LR } ; Hämtar vart man kom ifrån
	bx  lr ;Hoppa tillbaka
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Inga
; Utargument: Inga
;
; Funktion: Sätter inehållet på 0x20001000-0x20001003 till 0xFF
clearinput:
; F ̈orberedelseuppgift: Skriv denna subrutin!
	mov r0,#(0x20001000 & 0xffff) ;Tar första halvan, och lägger i r0
	movt r0,#(0x20001000 >> 16)	; Lägger in andra halvan av adressen i r0
	mov r1,#0xFF ;Fyll r1 med 1:or
	strb r1,[r0] ;Fyll minnet på r0 med 1:or som ligger i r1
	;Samma som ovan
	mov r0,#(0x20001001 & 0xffff)
	movt r0,#(0x20001001 >> 16)
	mov r1,#0xFF
	strb r1,[r0]
	;samma som ovan
	mov r0,#(0x20001002 & 0xffff)
	movt r0,#(0x20001002 >> 16)
	mov r1,#0xFF
	strb r1,[r0]
	;Samma som ovan
	mov r0,#(0x20001003 & 0xffff)
	movt r0,#(0x20001003 >> 16)
	mov r1,#0xFF
	strb r1,[r0]
	;Hoppa tillbaka
	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Inga
; Utargument: Inga
;
; Funktion: T ̈ander röd lysdiod (bit 3 = 0, bit 2 = 0, bit 1 = 1)
activatealarm:
	mov r0, #0x2 ;Laddar in 0000 0010. För att skapa rött
	mov r1,#(GPIOF_GPIODATA & 0xffff) ;laddar in halva adressen
	movt r1,#(GPIOF_GPIODATA >> 16); laddar in andra halvan av adressen
	strb r0, [r1] ; Lägger koden för färgen röd i r
	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Inga
; Utargument: Inga
;
; Funktion: T ̈ander svart lysdiod (bit 3 = 0, bit 2 = 0, bit 1 = 0)
turnOffLamp:
	mov r0, #0x0 ;Laddar in 0000 0010. För att skapa svart
	mov r1,#(GPIOF_GPIODATA & 0xffff) ;laddar in halva adressen
	movt r1,#(GPIOF_GPIODATA >> 16); laddar in andra halvan av adressen
	strb r0, [r1] ; Lägger koden för färgen svart i r
	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Inargument: Inga
; Utargument: Inga
;
; Funktion: T ̈ander gron lysdiod (bit 3 = 1, bit 2 = 0, bit 1 = 0)
deactivatealarm:
	mov r0, #0x8 ;Laddar in 0000 1000. För att skapa rött
	mov r1,#(GPIOF_GPIODATA & 0xffff)
	movt r1,#(GPIOF_GPIODATA >> 16)
	strb r0, [r1]
	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,
;;;
;;; Allt här efter ska inte ändras
;;;
;;; Rutiner för initiering
;;; Se labmanual för vilka namn som ska användas
;;;
	
	.align 4

;; 	Initiering av seriekommunikation
;;	Förstör r0, r1 
	
inituart:
	mov r1,#(RCGCUART & 0xffff)		; Koppla in serieport
	movt r1,#(RCGCUART >> 16)
	mov r0,#0x01
	str r0,[r1]

	mov r1,#(RCGCGPIO & 0xffff)
	movt r1,#(RCGCGPIO >> 16)
	ldr r0,[r1]
	orr r0,r0,#0x01
	str r0,[r1]		; Koppla in GPIO port A

	nop			; vänta lite
	nop
	nop

	mov r1,#(GPIOA_GPIOAFSEL & 0xffff)
	movt r1,#(GPIOA_GPIOAFSEL >> 16)
	mov r0,#0x03
	str r0,[r1]		; pinnar PA0 och PA1 som serieport

	mov r1,#(GPIOA_GPIODEN & 0xffff)
	movt r1,#(GPIOA_GPIODEN >> 16)
	mov r0,#0x03
	str r0,[r1]		; Digital I/O på PA0 och PA1

	mov r1,#(UART0_UARTIBRD & 0xffff)
	movt r1,#(UART0_UARTIBRD >> 16)
	mov r0,#0x08
	str r0,[r1]		; Sätt hastighet till 115200 baud
	mov r1,#(UART0_UARTFBRD & 0xffff)
	movt r1,#(UART0_UARTFBRD >> 16)
	mov r0,#44
	str r0,[r1]		; Andra värdet för att få 115200 baud

	mov r1,#(UART0_UARTLCRH & 0xffff)
	movt r1,#(UART0_UARTLCRH >> 16)
	mov r0,#0x60
	str r0,[r1]		; 8 bit, 1 stop bit, ingen paritet, ingen FIFO
	
	mov r1,#(UART0_UARTCTL & 0xffff)
	movt r1,#(UART0_UARTCTL >> 16)
	mov r0,#0x0301
	str r0,[r1]		; Börja använda serieport

	bx  lr

; Definitioner för registeradresser (32-bitars konstanter) 
GPIOHBCTL	.equ	0x400FE06C
RCGCUART	.equ	0x400FE618
RCGCGPIO	.equ	0x400fe608
UART0_UARTIBRD	.equ	0x4000c024
UART0_UARTFBRD	.equ	0x4000c028
UART0_UARTLCRH	.equ	0x4000c02c
UART0_UARTCTL	.equ	0x4000c030
UART0_UARTFR	.equ	0x4000c018
UART0_UARTDR	.equ	0x4000c000
GPIOA_GPIOAFSEL	.equ	0x40004420
GPIOA_GPIODEN	.equ	0x4000451c
GPIOE_GPIODATA	.equ	0x400240fc
GPIOE_GPIODIR	.equ	0x40024400
GPIOE_GPIOAFSEL	.equ	0x40024420
GPIOE_GPIOPUR	.equ	0x40024510
GPIOE_GPIODEN	.equ	0x4002451c
GPIOE_GPIOAMSEL	.equ	0x40024528
GPIOE_GPIOPCTL	.equ	0x4002452c
GPIOF_GPIODATA	.equ	0x4002507c
GPIOF_GPIODIR	.equ	0x40025400
GPIOF_GPIOAFSEL	.equ	0x40025420
GPIOF_GPIODEN	.equ	0x4002551c
GPIOF_GPIOLOCK	.equ	0x40025520
GPIOKEY		.equ	0x4c4f434b
GPIOF_GPIOPUR	.equ	0x40025510
GPIOF_GPIOCR	.equ	0x40025524
GPIOF_GPIOAMSEL	.equ	0x40025528
GPIOF_GPIOPCTL	.equ	0x4002552c

;; Initiering av port F
;; Förstör r0, r1, r2
initGPIOF:
	mov r1,#(RCGCGPIO & 0xffff)
	movt r1,#(RCGCGPIO >> 16)
	ldr r0,[r1]
	orr r0,r0,#0x20		; Koppla in GPIO port F
	str r0,[r1]
	nop 			; Vänta lite
	nop
	nop

	mov r1,#(GPIOHBCTL & 0xffff)	; Använd apb för GPIO
	movt r1,#(GPIOHBCTL >> 16)
	ldr r0,[r1]
	mvn r2,#0x2f		; bit 5-0 = 0, övriga = 1
	and r0,r0,r2
	str r0,[r1]

	mov r1,#(GPIOF_GPIOLOCK & 0xffff)
	movt r1,#(GPIOF_GPIOLOCK >> 16)
	mov r0,#(GPIOKEY & 0xffff)
	movt r0,#(GPIOKEY >> 16)
	str r0,[r1]		; Lås upp port F konfigurationsregister

	mov r1,#(GPIOF_GPIOCR & 0xffff)
	movt r1,#(GPIOF_GPIOCR >> 16)
	mov r0,#0x1f		; tillåt konfigurering av alla bitar i porten
	str r0,[r1]

	mov r1,#(GPIOF_GPIOAMSEL & 0xffff)
	movt r1,#(GPIOF_GPIOAMSEL >> 16)
	mov r0,#0x00		; Koppla bort analog funktion
	str r0,[r1]

	mov r1,#(GPIOF_GPIOPCTL & 0xffff)
	movt r1,#(GPIOF_GPIOPCTL >> 16)
	mov r0,#0x00		; använd port F som GPIO
	str r0,[r1]

	mov r1,#(GPIOF_GPIODIR & 0xffff)
	movt r1,#(GPIOF_GPIODIR >> 16)
	mov r0,#0x0e		; styr LED (3 bits), andra bitar är ingångar
	str r0,[r1]

	mov r1,#(GPIOF_GPIOAFSEL & 0xffff)
	movt r1,#(GPIOF_GPIOAFSEL >> 16)
	mov r0,#0		; alla portens bitar är GPIO
	str r0,[r1]

	mov r1,#(GPIOF_GPIOPUR & 0xffff)
	movt r1,#(GPIOF_GPIOPUR >> 16)
	mov r0,#0x11		; svag pull-up för tryckknapparna
	str r0,[r1]

	mov r1,#(GPIOF_GPIODEN & 0xffff)
	movt r1,#(GPIOF_GPIODEN >> 16)
	mov r0,#0xff		; alla pinnar som digital I/O
	str r0,[r1]

	bx lr


;; Initiering av port E
;; Förstör r0, r1
initGPIOE:
	mov r1,#(RCGCGPIO & 0xffff)    ; Clock gating port (slå på I/O-enheter)
	movt r1,#(RCGCGPIO >> 16)
	ldr r0,[r1]
	orr r0,r0,#0x10		; koppla in GPIO port B
	str r0,[r1]
	nop			; vänta lite
	nop
	nop

	mov r1,#(GPIOE_GPIODIR & 0xffff)
	movt r1,#(GPIOE_GPIODIR >> 16)
	mov r0,#0x0		; alla bitar är ingångar
	str r0,[r1]

	mov r1,#(GPIOE_GPIOAFSEL & 0xffff)
	movt r1,#(GPIOE_GPIOAFSEL >> 16)
	mov r0,#0		; alla portens bitar är GPIO
	str r0,[r1]

	mov r1,#(GPIOE_GPIOAMSEL & 0xffff)
	movt r1,#(GPIOE_GPIOAMSEL >> 16)
	mov r0,#0x00		; använd inte analoga funktioner
	str r0,[r1]

	mov r1,#(GPIOE_GPIOPCTL & 0xffff)
	movt r1,#(GPIOE_GPIOPCTL >> 16)
	mov r0,#0x00		; använd inga specialfunktioner på port B	
	str r0,[r1]

	mov r1,#(GPIOE_GPIOPUR & 0xffff)
	movt r1,#(GPIOE_GPIOPUR >> 16)
	mov r0,#0x00		; ingen pullup på port B
	str r0,[r1]

	mov r1,#(GPIOE_GPIODEN & 0xffff)
	movt r1,#(GPIOE_GPIODEN >> 16)
	mov r0,#0xff		; alla pinnar är digital I/O
	str r0,[r1]

	bx lr


;; Utskrift av ett tecken på serieport
;; r0 innehåller tecken att skriva ut (1 byte)
;; returnerar först när tecken skickats
;; förstör r0, r1 och r2 
printchar:
	mov r1,#(UART0_UARTFR & 0xffff)	; peka på serieportens statusregister
	movt r1,#(UART0_UARTFR >> 16)
loop1:
	ldr r2,[r1]			; hämta statusflaggor
	ands r2,r2,#0x20		; kan ytterligare tecken skickas?
	bne loop1			; nej, försök igen
	mov r1,#(UART0_UARTDR & 0xffff)	; ja, peka på serieportens dataregister
	movt r1,#(UART0_UARTDR >> 16)
	str r0,[r1]			; skicka tecken
	bx lr




