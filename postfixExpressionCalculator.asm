; partners: amanda51, bigoucl2
; Introduction: This program uses subroutines based on postfix equations that the user inputs. Each time a symbol is printed, the evaluate subroutine puts the two numbers into a stack and performs the operation. The subroutines also translate ASCII codes. If underflow occurs, the operation does not run because it is an invalid case. Once successfully run, the program will output the contents of R5.
; Shailee Patel (shailee2)


.ORIG x3000

	
NEXTCHAR
	GETC
	OUT
	JSR EVALUATE
	BRnzp NEXTCHAR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R3- value to print in hexadecimal
A		.FILL #65	;
ZERO		.FILL #48	;

PRINT_HEX
	AND R4,R4,#0
	ADD R4,R4,#4	; hexadecimal counter
NEXTDIGIT
EXTRACT
	AND R2,R2,#0
	AND R3,R3,#0
	ADD R3,R3,#4	; bit counter
EXTRACT_LOOP
	ADD R2,R2,R2	; leftshifts R2
	ADD R1,R1,#0	; reiterate
	BRzp SHIFT	; if R1 is positive, go to SHIFT
	ADD R2,R2,#1	; if R1 is negative, increment R2 (destination register)
	SHIFT
		ADD R1,R1,R1	; leftshifts R1
		ADD R3,R3,#-1	; decrement R3 (bit counter)
	BRp EXTRACT_LOOP
	ADD R0,R2,#-9	; compare input to 9
	BRnz PRINT_NUM	; if input is a digit, break to PRINT_NUM
	LD R0,A		; if input is not a digit, load ASCII of A
	ADD R0,R0,R2	; A+R2
	ADD R0,R0,#-10	; A+R2-10
	BRnzp NUM_LOOP	; done with NUM_LOOP
PRINT_NUM
	LD R0,ZERO	; load ASCII of 0
	ADD R0,R0,R2	; R0 is R2 + 0
NUM_LOOP
	AND R3,R3,#0
	ADD R3,R3,R7	; copies PC to R3
	OUT		; prints R0
	AND R7,R7,#0
	ADD R7,R7,R3	; restore PC 
	ADD R4,R4,#-1	; decrements hexadecimal counter because we have one less to print
BRp NEXTDIGIT
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R0 - character input from keyboard
;R6 - current numerical output
;
;
ASC_EQUAL	.FILL #-61	;
ASC_SPACE	.FILL #-32	;
ASC_ZERO	.FILL #-48	;
ASC_NINE	.FILL #-57	;
ASC_PLUS	.FILL #-43	;
ASC_MINUS	.FILL #-45	;
ASC_MUL		.FILL #-42	;
ASC_DIV		.FILL #-47	;
ASC_POW		.FILL #-94	;
EVALUATE
	LD R1,ASC_EQUAL	; loads R1 with the ascii value of the equal sign
	AND R6,R6,#0	
	AND R6,R0,R1	; checks for the equal sign
	BRz RESULT
	
	LD R1,ASC_SPACE	; loads R1 with the ascii value of the equal sign
	AND R6,R6,#0	
	AND R6,R0,R1	; checks for the space sign
	BRz SPACE
	
	LD R1,ASC_PLUS	; loads R1 with the ascii value of the plus sign
	AND R6,R6,#0	
	AND R6,R0,R1	; checks for the plus sign
	BRz N1		; if there is a plus, check for the next number being a negative
	AND R6,R6,#0	
	ADD R6,R6,R7	; copies PC to R6
	JSR CHECK2NUM	; go check for two numbers
	AND R7,R7,#0
	ADD R7,R7,R6	; restore PC
	ADD R5,R5,#0
	BRz VALID_ADD
	BRnp INVALID
	HALT		; it you can't add these numners, then halt the program
VALID_ADD
	AND R6,R6,#0
	ADD R6,R6,R7	; copies PC to R6
	JSR PLUS	; since this is a valid add method, go to PLUS subroutine
	AND R7,R7,#0
	ADD R7,R7,R6	; restore PC
	RET		; once done, return to EVALUATE
N1	
	LD R1,ASC_MINUS	; loads R1 with the ascii value of the minus sign
	AND R6,R6,#0
	ADD R6,R0,R1	; checks for the minus sign
	BRnp N2		; if there is no negative sign, go to N2
	AND R6,R6,#0
	ADD R6,R6,R7	; copies PC to R6
	JSR CHECK2NUM	; go check if there are 2 numbers that you can subtract
	AND R7,R7,#0	
	ADD R7,R7,R6	; restore PC
	ADD R5,R5,#0	
	BRz VALID_SUB	
	BRnp INVALID
	HALT		; if you can't subtract these numbers, then halt the program
VALID_SUB
	AND R6,R6,#0	
	ADD R6,R6,R7	; copies PC to R6
	JSR MIN		; since this is a valid subtract method, go to MIN subroutine
	AND R7,R7,#0
	ADD R7,R6,R7	; restore PC
	RET
N2
	LD R1,ASC_MUL	; loads R1 with the ascii character of the multiply sign
	AND R6,R6,#0
	ADD R6,R0,R1	; checks for the multiply sign
	BRnp N3		; if not a multiply sign, go to case 3
	AND R6,R6,#0
	ADD R6,R6,R7	; copies PC to R6
	JSR CHECK2NUM	; go check if there are two numbers you can multiply
	AND R7,R7,#0
	ADD R7,R6,R7	; restore PC
	ADD R5,R5,#0
	BRz VALID_MUL
	BRnp INVALID
	HALT		; if you can't multiply these numbers, then halt the program
VALID_MUL
	AND R6,R6,#0	
	ADD R6,R6,R7	; copies PC to R6
	JSR MUL		; since this is a valid multiply method, go to MUL subroutine
	AND R7,R7,#0
	ADD R7,R6,R7	; restore PC
	RET
N3
	LD R1,ASC_DIV	; loads R1 with the ascii character of the divide sign
	AND R6,R6,#0
	ADD R6,R0,R1	; checks for the divide sign
	BRnp N4		; if not a divide sign, go to case 4
	AND R6,R6,#0
	ADD R6,R6,R7	; copies PC to R6
	JSR CHECK2NUM	; go check if there are two numbers you can multiply
	AND R7,R7,#0
	ADD R7,R6,R7	; restore PC
	ADD R5,R5,#0
	BRz VALID_DIVIDE
	BRnp INVALID
	HALT		; if you can't divide these numbers, then halt the program
VALID_DIVIDE
	AND R6,R6,#0	
	ADD R6,R6,R7	; copies PC to R6
	JSR DIV		; since this is a valid divide method, go to DIV subroutine
	AND R7,R7,#0
	ADD R7,R6,R7	; restore PC
	RET
N4
	LD R1,ASC_POW	; loads R1 with the ascii character of the exponent sign
	AND R6,R6,#0
	ADD R6,R0,R1	; checks for the exponent sign
	BRnp N5		; if not an exponent sign, go to case 5
	AND R6,R6,#0
	ADD R6,R6,R7	; copies PC to R6
	JSR CHECK2NUM	; go check if there are two numbers you can multiply
	AND R7,R7,#0
	ADD R7,R6,R7	; restore PC
	ADD R5,R5,#0
	BRz VALID_POW
	BRnp INVALID
	HALT		; if you can't take the power of these numbers, then halt the program
VALID_POW
	AND R6,R6,#0	
	ADD R6,R6,R7	; copies PC to R6
	JSR EXP		; since this is a valid power method, go to EXP subroutine
	AND R7,R7,#0
	ADD R7,R6,R7	; restore PC
	RET
N5
	LD R1,ASC_NINE	; loads R1 with the ascii character of 9
	AND R6,R6,#0
	ADD R6,R0,R1	; checks if it's a 9
	Brnz NUMERICAL
RESULT
	AND R6,R6,#0
	ADD R6,R6,R7	; copies PC to R6
	JSR CHECK1NUM	; go check if there is one result in the stack
	AND R7,R7,#0
	ADD R7,R6,R7	; restore PC
	ADD R5,R5,#0	
	BRz VALID

INVALID
	LEA R0,MESSAGE	; if result is invalid, print a message onscreen
	PUTS
	HALT
VALID
	AND R6,R6,#0
	ADD R6,R6,R7	; copies PC to R6
	JSR POP		; jump to POP subroutine
	AND R7,R7,#0
	ADD R7,R7,R6	; restore PC

	AND R5,R5,#0
	ADD R5,R5,R0	; put the input into R5
	
	AND R1,R1,#0
	ADD R1,R1,R5	; stores result in R5

	AND R6,R6,#0
	ADD R6,R6,R7	; copies PC to R6
	JSR PRINT_HEX	; jump to PRINT_HEX
	AND R7,R7,#0
	ADD R7,R7,R6	; restore PC
	HALT
SPACE
	RET
NUMERICAL
	LD R1,ASC_ZERO	; loads the ascii value of zero into R1
	ADD R0,R0,R1	; loads the ascii value of zero into R0
	AND R6,R6,#0
	ADD R6,R6,R7	; copies PC to R6
	JSR PUSH	; jump to PUSH subroutine
	AND R7,R7,#0
	ADD R7,R7,R6	; restore PC
	RET

MESSAGE .STRINGZ "Invalid expression"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
PLUS	
	AND R1,R1,#0
	ADD R1,R1,R7	; copies PC to R1
	JSR POP		; jump to POP subroutine
	AND R7,R7,#0
	ADD R7,R7,R1	; restore PC

	AND R3,R3,#0
	ADD R3,R3,R0	; put the input into R3
	
	AND R1,R1,#0
	ADD R1,R1,R7	; copies PC to R1
	JSR POP		; jump to POP subroutine
	AND R7,R7,#0
	ADD R7,R7,R1	; restore PC
	
	AND R4,R4,#0
	ADD R4,R4,R0	; put the input into R4
	
	AND R0,R0,#0
	ADD R0,R3,R4	; add both numbers

	AND R1,R1,#0
	ADD R1,R1,R7	; copies PC to R1
	JSR PUSH	; jump to PUSH subroutine
	AND R7,R7,#0
	ADD R7,R7,R1	; restore PC
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
MIN	
	AND R1,R1,#0
	ADD R1,R1,R7	; copies PC to R1
	JSR POP		; jump to POP subroutine
	AND R7,R7,#0
	ADD R7,R7,R1	; restore PC

	AND R3,R3,#0
	ADD R3,R3,R0	; put the input into R3
	
	AND R1,R1,#0
	ADD R1,R1,R7	; copies PC to R1
	JSR POP		; jump to POP subroutine
	AND R7,R7,#0
	ADD R7,R7,R1	; restore PC
	
	AND R4,R4,#0
	ADD R4,R4,R0	; put the input into R4

	AND R0,R0,#0
	NOT R3,R3
	ADD R3,R3,#1
	ADD R0,R4,R3	; subtracts both numbers

	AND R1,R1,#0
	ADD R1,R1,R7	; copies PC to R1
	JSR PUSH	; jump to PUSH subroutine
	AND R7,R7,#0
	ADD R7,R7,R1	; restore PC
	RET
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
MUL	
	AND R1,R1,#0
	ADD R1,R1,R7	; copies PC to R1
	JSR POP		; jump to POP subroutine
	AND R7,R7,#0
	ADD R7,R7,R1	; restore PC

	AND R3,R3,#0
	ADD R3,R3,R0	; put the input into R3
	
	AND R1,R1,#0
	ADD R1,R1,R7	; copies PC to R1
	JSR POP		; jump to POP subroutine
	AND R7,R7,#0
	ADD R7,R7,R1	; restore PC
	
	AND R4,R4,#0
	ADD R4,R4,R0	; put the input into R4

	ST R6,MULTDATA	; saves R6 into DATA
	AND R0,R0,#0	

	ADD R3,R3,#0
	BRz MULT_RET
	ADD R4,R4,#0
	BRz MULT_RET	; this block of code performs the operation

	LD R6,POSITIVE
	ADD R3,R3,#0
	BRp POSR3
	
	NOT R3,R3
	ADD R3,R3,#1	; result is negative if next check shows R4 is positive
	LD R6,NEGATIVE

	ADD R4,R4,#0
	BRp MULT_CONT
	NOT R4,R4
	ADD R4,R4,#1	; twos comp of R4 so you can add
	LD R6,POSITIVE	; the result is negative because R3 and R4 are negative
	BRnzp MULT_CONT
POSR3
	ADD R4,R4,#0
	BRp MULT_CONT
	NOT R4,R4
	ADD R4,R4,#1
	LD R6,NEGATIVE	;the result is negative because R3 is positive and R4 is negative
MULT_CONT
	ADD R0,R0,R3
	ADD R4,R4,#-1
	BRp MULT_CONT
	ADD R6,R6,#0
	BRp MULT_RET	; if a negative result is to be outputted, negate R0
	NOT R0,R0
	ADD R0,R0,#1
MULT_RET
	LD R6,MULTDATA	; get R6 from DATA
	AND R1,R1,#0
	ADD R1,R1,R7	; copies PC to R1
	JSR PUSH	; jump to PUSH subroutine
	AND R7,R7,#0
	ADD R7,R7,R1	; restore PC
	RET
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
DIV	
	AND R1,R1,#0
	ADD R1,R1,R7	; copies PC to R1
	JSR POP		; jump to POP subroutine
	AND R7,R7,#0
	ADD R7,R7,R1	; restore PC

	AND R3,R3,#0
	ADD R3,R3,R0	; put the input into R3
	
	AND R1,R1,#0
	ADD R1,R1,R7	; copies PC to R1
	JSR POP		; jump to POP subroutine
	AND R7,R7,#0
	ADD R7,R7,R1	; restore PC
	
	AND R4,R4,#0
	ADD R4,R4,R0	; put the input into R4

	AND R0,R0,#0

	ADD R3,R3,#0	
	BRnp VALID_DIV
	LEA R0,MESSAGE
	PUTS
	HALT
VALID_DIV
	ADD R4,R4,#0
	BRz DIV_RET
	AND R0,R0,#0
	NOT R3,R3
	ADD R3,R3,#1
DIV_CONT
	ADD R4,R4,R3
	BRn DIV_RET
	ADD R0,R0,#1
	BRnzp DIV_CONT
DIV_RET
	AND R1,R1,#0
	ADD R1,R1,R7	; copies PC to R1
	JSR PUSH	; jump to POP subroutine
	AND R7,R7,#0
	ADD R7,R7,R1	; restore PC
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
EXP
	AND R1,R1,#0
	ADD R1,R1,R7	; copies PC to R1
	JSR POP		; jump to POP subroutine
	AND R7,R7,#0
	ADD R7,R7,R1	; restore PC

	AND R3,R3,#0
	ADD R3,R3,R0	; put the input into R3
	
	AND R1,R1,#0
	ADD R1,R1,R7	; copies PC to R1
	JSR POP		; jump to POP subroutine
	AND R7,R7,#0
	ADD R7,R7,R1	; restore PC
	
	AND R4,R4,#0
	ADD R4,R4,R0	; put the input into R4

	AND R1,R1,#0
	ADD R1,R1,R7	; copies PC to R1
	JSR PUSH	; jump to POP subroutine
	AND R7,R7,#0
	ADD R7,R7,R1	; restore PC
	ADD R3,R3,#-1
POWER_CONT
	AND R1,R1,#0
	ADD R1,R1,R7	; copies PC to R1
	JSR PUSH	; jump to POP subroutine
	AND R7,R7,#0
	ADD R7,R7,R1	; restore PC
	ADD R3,R3,#-1
DATA
	ST R7,POWERDATA1
	ST R3,POWERDATA2
	ST R4,POWERDATA3
	JSR MUL
	LD R7,POWERDATA1
	LD R4,POWERDATA3
	LD R3,POWERDATA2
	BRz POWER_RET
	AND R0,R0,#0
	ADD R0,R0,R4
	BRnzp POWER_CONT
POWER_RET
	RET

CHECK1NUM
	ST R3,POP_SaveR3
	ST R4,POP_SaveR4
	AND R5,R5,#0
	LD R3,STACK_START
	LD R4,STACK_TOP
	ADD R3,R3,#-1
	BRnp NOTONE
	BRz DONE_CHECK1NUM
	
NOTONE
	ADD R5,R5,#1
DONE_CHECK1NUM
	LD R3,POP_SaveR3
	LD R4,POP_SaveR4
	RET

CHECK2NUM
	ST R3,POP_SaveR3
	ST R4,POP_SaveR4
	AND R5,R5,#0
	LD R3,STACK_START
	LD R4,STACK_TOP
	ADD R3,R3,#-2
	NOT R3,R3
	ADD R3,R3,#1
	ADD R3,R3,R4
	BRp LESSTHANTWO
	BRnzp DONE_CHECK2NUM
LESSTHANTWO
	ADD R5,R5,#1
DONE_CHECK2NUM
	LD R3,POP_SaveR3
	LD R4,POP_SaveR4
	RET

	
;IN:R0, OUT:R5 (0-success, 1-fail/overflow)
;R3: STACK_END R4: STACK_TOP
;
PUSH	
	ST R3, PUSH_SaveR3	;save R3
	ST R4, PUSH_SaveR4	;save R4
	AND R5, R5, #0		;
	LD R3, STACK_END	;
	LD R4, STACK_TOP	;
	ADD R3, R3, #-1		;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz OVERFLOW		;stack is full
	STR R0, R4, #0		;no overflow, store value in the stack
	ADD R4, R4, #-1		;move top of the stack
	ST R4, STACK_TOP	;store top of stack pointer
	BRnzp DONE_PUSH		;
OVERFLOW
	ADD R5, R5, #1		;
DONE_PUSH
	LD R3, PUSH_SaveR3	;
	LD R4, PUSH_SaveR4	;
	RET


PUSH_SaveR3	.BLKW #1	;
PUSH_SaveR4	.BLKW #1	;


;OUT: R0, OUT R5 (0-success, 1-fail/underflow)
;R3 STACK_START R4 STACK_TOP
;
POP	
	ST R3, POP_SaveR3	;save R3
	ST R4, POP_SaveR4	;save R3
	AND R5, R5, #0		;clear R5
	LD R3, STACK_START	;
	LD R4, STACK_TOP	;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz UNDERFLOW		;
	ADD R4, R4, #1		;
	LDR R0, R4, #0		;
	ST R4, STACK_TOP	;
	BRnzp DONE_POP		;
UNDERFLOW
	ADD R5, R5, #1		;
DONE_POP
	LD R3, POP_SaveR3	;
	LD R4, POP_SaveR4	;
	RET


POP_SaveR3	.BLKW #1	;
POP_SaveR4	.BLKW #1	;
STACK_END	.FILL x3FF0	;
STACK_START	.FILL x4000	;
STACK_TOP	.FILL x4000	;

POSITIVE	.FILL #1
NEGATIVE	.FILL #-1
MULTDATA	.FILL #0
POWERDATA1	.FILL #0
POWERDATA2	.FILL #0
POWERDATA3	.FILL #0


.END
