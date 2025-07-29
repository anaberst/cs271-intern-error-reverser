TITLE Intern Error Reverser    (Proj6_bersta.asm)

; Author: Anastasiya Berst
; Course number/section:   CS271 Section 402
; Project Number: 6         Due Date: 03/16/2025 (uploaded to GitHub 07/29/2025)
; Description: 
	; This program opens a user-specified temperature data file, stores the first line of values in an array, and closes the file.
	; It then converts the ASCII-coded values into signed integers, stores them in another array, and then prints them in reverse order on screen.


INCLUDE Irvine32.inc

; --------------------------------------------------------------------------------- 
; Name: mGetString
; 
; Gets string as user-entered keyboard input and saves it to a memory location.
; 
; Preconditions: 
;   +EAX, ECX, EDX must not be used as arguments
;   +promptOffset / userInputOffset is memory address offset
;	+promptOffset / userInputOffset variable is type BYTE, null-terminated
;   +userInputBuffer is type BYTE, size 21, no initial value
;   +byteCount is type DWORD, no initial value
; 
; Receives: 
;   +prompOffset = welcome message
;   +userInputOffset = user input prompt
;   +userInputBuffer = to store file name
;   +byteCount = to store file name byte count
;
; Returns: 
;   +userInputBuffer = user-entered file name
;   +byteCount = file name byte count
; --------------------------------------------------------------------------------- 

mGetString	MACRO	promptOffset, userInputOffset, userInputBuffer, byteCount

	; preserve general-purpose registers
	PUSH  EDX
	PUSH  ECX
	PUSH  EAX

	; display prompt for user
	mDisplayString  promptOffset

	; get user-input string
	MOV   EDX, userInputOffset
	MOV   ECX, SIZEOF userInputBuffer - 1
	CALL  ReadString
	MOV   byteCount, EAX

	; restore general-purpose registers
	POP  EAX
	POP  ECX
	POP  EDX

ENDM


; --------------------------------------------------------------------------------- 
; Name: mDisplayString
; 
;  Prints a string to the console.
; 
; Preconditions: 
;   +EDX must not be used as an argument
;   +prompOffset is memory address offset
;   +promptOffset variable is type BYTE, null-terminated
; 
; Receives: 
;   +promptOffset = string to be printed
;
; Returns: None
; --------------------------------------------------------------------------------- 

mDisplayString	MACRO	promptOffset

	; preserve general-purpose registers
	PUSH  EDX

	; display prompt for user
	MOV   EDX, promptOffset
	CALL  WriteString

	; restore general-purpose registers
	POP  EDX

ENDM


; --------------------------------------------------------------------------------- 
; Name: mDisplayChar 
; 
; Prints an ASCII-formatted character to the console.
; 
; Preconditions: 
;   +EAX must not be used as an argument
;   +charVal is immediate, constant, or register
; 
; Receives: 
;   +charVal = character to be printed
;
; Returns: None
; --------------------------------------------------------------------------------- 

mDisplayChar	MACRO	charVal

	; preserve general-purpose registers
	PUSH  EAX

	; display character for user
	MOV   AL, charVal
	CALL  WriteChar

	; restore general-purpose registers
	POP  EAX

ENDM


;-------------------------------------
;             Constants
;-------------------------------------

TEMPS_PER_DAY = 24
DELIMITER = ','    
MAX_BYTE = TEMPS_PER_DAY * 4
MINUS_SIGN = 45
NEG_VAL = -1
ASCII_ZERO = 48


.data
;-------------------------------------
;             Variables
;-------------------------------------

greeting			BYTE    "Uh Oh! Did the intern make a mistake? Not to worry... Welcome to the Intern Error Reverser!",13,10, \
							"This programs reads a '",DELIMITER,"'-delimited file storing various temperature values, in ASCII format.",13,10, \
							"It'll then convert the ASCII to signed integers and print them out in the corrected reverse order.",13,10,13,10, \
							"Enter the name of the file (20 characters max) to be read: ",0
error_msg			BYTE    13,10,"Oops, there was a file error.",0
temp_prompt			BYTE    13,10,"Here's the corrected temperature order:",13,10,0
farewell			BYTE	13,10,13,10,"Thank you for using the Intern Error Reverser! Goodbye!",13,10,0
fileName			BYTE	21 DUP(?)
fileNameByteCount	DWORD	?
fileBuffer			BYTE    MAX_BYTE DUP(?) ; to accommodate TEMPS_PER_DAY values at 4 characters each (e.g. '-100') 
fileHandle			DWORD   ?
tempArray			SDWORD  TEMPS_PER_DAY DUP(0)


.code
main PROC
;-------------------------------------
;      Macro & Procedure Calls
;-------------------------------------

  ; print welcome message and get user-input file name
  mGetString OFFSET greeting, OFFSET fileName, fileName, fileNameByteCount


  ; open file
  MOV	EDX, OFFSET fileName
  CALL	OpenInputFile
  MOV   fileHandle, EAX


  ; read and store file contents
  MOV   EAX, fileHandle
  MOV   EDX, OFFSET fileBuffer
  MOV   ECX, MAX_BYTE
  CALL  ReadFromFile
  JC	_errorMsg	 ; CF = 1 if error occurred


  ; close file
  MOV   EAX, fileHandle
  CALL  CloseFile
  CMP   EAX, 0
  JE	_errorMsg    ; EAX = 0 if error occurred


  ; parse the first line of temperature values from the file,
  ; convert from ASCII to signed integer, and store in array
  PUSH  OFFSET fileBuffer
  PUSH  OFFSET tempArray
  CALL  ParseTempsFromString


  ; print temperature value prompt
  mDisplayString OFFSET temp_prompt


  ; print the temperature values in reverse order
  PUSH  OFFSET tempArray
  CALL  WriteTempsReverse
  JMP   _farewell


 _errorMsg:
  ; print error message for file error
  mDisplayString OFFSET error_msg


 _farewell:
  ; print farewell message
  mDisplayString OFFSET farewell


	Invoke ExitProcess,0	; exit to operating system
main ENDP


; --------------------------------------------------------------------------------- 
; Name: ParseTempsFromString 
;  
;  Parses the first line of temperature values, converts them from ASCII to ...
;   to signed integer format, and stores the values in an array.
; 
; Preconditions: 
;   +Input parameter is passed on the stack first
;   +Input must be type BYTE, length MAX_BYTE, no initial value
;	+Output parameter is passed on the stack second
;   +Output must be type SDWORD, length TEMPS_PER_DAY, initialized to 0
; 
; Postconditions: None 
; 
; Receives:
;   +fileBuffer = array of first day's temperature values, in ASCII format, from user-specified file
;   +tempArray  = array to store temperature values from fileBuffer, in signed integer format
; 
; Returns: 
;	+tempArray = array of first day's temperature values, in signed integer format
; --------------------------------------------------------------------------------- 
ParseTempsFromString PROC

  ; preserve EBP and set to top of stack
  PUSH   EBP
  MOV    EBP, ESP
    
  ; preserve general-purpose registers
  PUSH   ESI
  PUSH   EDI
  PUSH   EAX
  PUSH   ECX
  PUSH   EBX

  ; cheat sheet:
  ; [EBP] = old ebp
  ; [EBP + 4] = return address
  ; [EBP + 8] = OFFSET tempArray
  ; [EBP + 12] = OFFSET fileBuffer

  ; store memory address of first element in tempArray in destination register
  MOV   EDI, [EBP + 8]

  ; store memory address of first element in fileBuffer in source register
  MOV   ESI, [EBP + 12]

  ; set loop counter to TEMPS_PER_DAY
  MOV   ECX, TEMPS_PER_DAY

 _parseTemps:
  ; parse through file contents
  CLD
  MOV   EAX, 0           ; reset EAX
  LODSB
  CMP   AL, MINUS_SIGN
  JE    _negVal

 _continueParse:
  CMP   AL, DELIMITER
  JE    _endVal
  SUB   AL, ASCII_ZERO  ; subtract 48 from ASCII to get numeric value
  PUSH  EAX
  PUSH  EBX
  MOV   EAX, [EDI]
  MOV   EBX, +10        
  IMUL	EBX             ; current numeric value * 10
  MOV   [EDI], EAX      
  POP   EBX
  POP   EAX
  ADD   [EDI], EAX      ; sum to get signed integer
  JMP  _parseTemps

 _negVal:
  ; if value is negative
  MOV   EBX, NEG_VAL    ; store negative for later
  MOV   EAX, 0          ; reset EAX
  LODSB
  JMP   _continueParse

 _negateVal:
  ; negate final signed integer
  MOV   EAX, [EDI]
  NEG   EAX
  MOV   [EDI], EAX
  MOV   EBX, +1          ; reset EBX to 1
  JMP   _nextVal

 _endVal:
  ; if delimiter encountered
  CMP   EBX, -1
  JE    _negateVal

 _nextVal:
  ; move on to next value in fileBuffer	
  ADD   EDI, 4		    ; next val in tempArray
  LOOP  _parseTemps

  ; restore general-purpose registers
  POP   EBX
  POP   ECX
  POP   EAX
  POP   EDI
  POP   ESI

  ; restore EBP
  POP   EBP

  ; return to main and restore the stack
  RET   8

ParseTempsFromString ENDP


; --------------------------------------------------------------------------------- 
; Name: WriteTempsReverse 
;  
; Prints signed integer temperature values stored in an array, in reverse order.
; 
; Preconditions:
;   +Input paramater is passed on the stack
;   +Input parameter is type SDWORD, length TEMPS_PER_DAY
; 
; Postconditions: None
; 
; Receives: 
;   +tempArray = array of first day's temperature values, in signed integer format
; 
; Returns: None
; --------------------------------------------------------------------------------- 
WriteTempsReverse PROC

  ; preserve EBP and set to top of stack
  PUSH	EBP
  MOV	EBP, ESP

  ; preserve general-purpose registers
  PUSH  ESI
  PUSH  ECX

  ; cheat sheet:
  ; [EBP] = old ebp
  ; [EBP + 4] = return address
  ; [EBP + 8] = OFFSET tempArray

  ; store memory address of first element in tempArray in source register
  MOV	ESI, [EBP + 8]

  ; go to memory address of last element in tempArray
  ADD   ESI, MAX_BYTE - 4

  ; set loop count
  MOV   ECX, TEMPS_PER_DAY

 _printInt:
  ; print signed integers to console, in reverse order
  STD
  LODSD
  CALL   WriteInt
  mDisplayChar	DELIMITER    ; invoke macro to print delimiter
  LOOP	 _printInt	

  ; restore general-purpose registers
  POP  ECX
  POP  ESI

  ; restore EBP
  POP  EBP

  ; return to main and restore the stack
  RET  4

WriteTempsReverse ENDP


END main