*-----------------------------------------------------------
* Program Number: 4
* Written by    : Nihav Jain
* Date Created  : 10/23/2015
* Description   : Read a chunk of data from a binary file and print out the average of the chunk selected by user
*-----------------------------------------------------------

REGS_SUM_OF_SECTION REG     D0-D5

*-------------------
* Structure of input data file - 
* - First long word is the number of sections followed by the data of each section
* - Each section follows the given structure :
*    - Long word representing number of byte sized data, followed by the actual data
*    - Long word representing number of word sized data, followed by the actual data
*    - Long word representing number of long sized data, followed by the actual data
*-------------------
*-------------------
* MAIN
*-------------------
START   ORG     $1000
        
        lea     InputMessage, a1
        move.b  #CMD_PRINT_STRING_THEN_INPUT, d0        ; input goes into d1
        TRAP    #15
                
        lea     Section1, a0
        subi.l  #2, d1
        bmi     CALCULATE_AVERAGE                       ; if input was section 1, go directly to calculating average
                                                        ; otherwise move the pointer to the head of the section
    GET_TO_SECTION:
        move.l  (a0)+, d5                               ; read the number of byte sized data in this section
        ;JSR     SWAP_LONG
        move.b  d5, d4
        andi.b  #1, d4
        beq     EVEN_NUMBER_OF_BYTES                    ; if the number of bytes is odd, there is a padding byte in the end to make the address for the later data on an even boundary
        addi.l  #1, d5
    EVEN_NUMBER_OF_BYTES:
        add.l   d5, a0                                  ; move file pointer to chunk of words
        
        move.l  (a0)+, d5                               ; read the number of word sized data in this section
        ;JSR     SWAP_LONG
        lsl.l   #1, d5                                  ; word = 2 bytes, so distance to move = 2xNumberOfWords
        add.l   d5, a0                                  ; move file pointer to chunk of longs
        
        move.l  (a0)+, d5                               ; read the number of long sized data in this section
        ;JSR     SWAP_LONG
        lsl.l   #2, d5                                  ; long = 4 bytes, so distance to move = 4xNumberOfLongs
        add.l   d5, a0                                  ; move file pointer to start of next section
        dbra    d1, GET_TO_SECTION
    
    CALCULATE_AVERAGE:
        JSR     COMPUTE_AND_PRINT_AVERAGE
        
        move.b  $9,d0
        TRAP    #15

        STOP #$1000
        
*-------------------
* Makes function calls for calculating and printing the average of bytes, words and longs in the section indicated by address in a0
*-------------------
COMPUTE_AND_PRINT_AVERAGE:
        movem.l REGS_SUM_OF_SECTION, -(sp)
        
        JSR     GET_NUMBER_OF_VALUES        
        JSR     SUM_OF_BYTES
        lea     SumOfBytes, a1
        JSR     CALCULATE_AVERAGE_AND_PRINT

        JSR     GET_NUMBER_OF_VALUES        
        JSR     SUM_OF_SHORTS
        lea     SumOfShorts, a1
        JSR     CALCULATE_AVERAGE_AND_PRINT

        JSR     GET_NUMBER_OF_VALUES        
        JSR     SUM_OF_LONGS
        lea     SumOfLongs, a1
        JSR     CALCULATE_AVERAGE_AND_PRINT
        
        movem.l (sp)+, REGS_SUM_OF_SECTION
        RTS
        
*-------------------
* Get the number of data values for the current chunk into d6
*-------------------
GET_NUMBER_OF_VALUES:
        move.l  (a0)+, d5
        ;JSR     SWAP_LONG        
        move.l  d5, d0
        move.l  d5, d6
        RTS
        

*-------------------
* Calculates the sum of bytes in the given section indicated by address in a0
*-------------------
SUM_OF_BYTES:
        subi.l  #1, d0                                  ; loop invariant        
        clr.l   d7
        clr.l   d4
    ADD_BYTES:
        move.b  (a0)+, d4                               ; calculating sum of bytes
        add.l   d4, d7
        dbra    d0, ADD_BYTES

        move.b  d6, d0
        andi.b  #1, d0
        tst.b   d0                                      ; if the number of bytes is odd, there is a padding byte in the end
        beq     RETURN_SUM_OF_BYTES
        add.l   #1, a0                                  ; move pointer to ahead of padding byte
        
    RETURN_SUM_OF_BYTES:        
        RTS
        
*-------------------
* Calculates the sum of words in the given section indicated by address in a0
*-------------------
SUM_OF_SHORTS:
        subi.l  #1, d0                                  ; loop invariant
        clr.l   d7 
        clr.l   d4
    ADD_SHORTS:
        move.w  (a0)+, d5                               ; calculating sum of bytes
        ;JSR     SWAP_WORD
        move.w  d5, d4
        add.l   d5, d7
        dbra    d0, ADD_SHORTS
        
        RTS

*-------------------
* Calculates the sum of longs in the given section indicated by address in a0
*-------------------
SUM_OF_LONGS:
        subi.l  #1, d0                                  ; loop invariant        
        clr.l   d7 
    ADD_LONGS:
        move.l  (a0)+, d5                               ; calculating sum of longs
        ;JSR     SWAP_LONG
        add.l   d5, d7
        dbra    d0, ADD_LONGS
        RTS
        
*-------------------
* Calculates the average and prints the result
* d7 = sum of the values, d6 = number of values
*-------------------
CALCULATE_AVERAGE_AND_PRINT:
        move.l  d7, d1                                  ; printing sum of numbers
        move.b  #CMD_PRINT_STRING_AND_NUMBER, d0
        TRAP    #15
        
        divu    d6, d7                                  ; divide sum by number of values to get integer part of the average

        lea     AverageValue, a1        
        clr.l   d1
        move.w  d7, d1                                  ; print "average value" string and the integer part of the average
        move.b  #CMD_PRINT_STRING_AND_NUMBER, d0
        TRAP    #15
        
        move.l  d6, d5                                  ; make a copy of the denominator
        lsr.l   #1, d5                                  ; divide by 2
        swap    d7
        ext.l   d7                                      ; get remainder of average into d7
        mulu    #100, d7                                ; multiply by 100 to get accuracy up to a hundredths
        add.l   d5, d7                                  ; add half-of-denominator to remainder for rounding up
        divu    d6, d7                                  ; divide again by number of values
        
        lea     DecimalPoint, a1
        move.b  #CMD_PRINT_WO_CRLF, d0
        TRAP    #15
        
        clr.l   d1
        move.w  d7, d1                                  ; print decimal point '.' and fractional part
        cmpi.l  #10, d1
        bge     PRINT_FRACTION
        lea     Zero, a1 
        move.b  #CMD_PRINT_WO_CRLF, d0
        TRAP    #15 
    PRINT_FRACTION:
        move.b  #CMD_PRINT_NUMBER, d0
        TRAP    #15
        
        lea     CRLF, a1
        move.b  #CMD_PRINT_STRING, d0
        TRAP    #15
        
        RTS

        
*-------------------
* Subroutine: Swaps the bytes of the lower word in d5
* Uses      : d5
*-------------------
SWAP_WORD:
        movem.l d6, -(sp)
        clr.w   d6
        move.b  d5, d6
        lsr.w   #8, d5
        lsl.w   #8, d6
        or.w    d6, d5
        movem.l (sp)+, d6
        RTS
        
        
*-------------------
* Subroutine: Swaps the bytes of the long word in d5
* Uses      : d5
*-------------------
SWAP_LONG:
        JSR     SWAP_WORD
        swap    d5
        JSR     SWAP_WORD
        RTS

        
*----------------------------------------------------------*
*----------------------------------------------------------*

*-------------------
* Trap codes
*-------------------
CMD_INPUT_NUMBER    EQU     4
CMD_PRINT_STRING    EQU     13
CMD_PRINT_WO_CRLF   EQU     14
CMD_PRINT_STRING_AND_NUMBER EQU 17
CMD_PRINT_STRING_THEN_INPUT EQU 18
CMD_PRINT_NUMBER    EQU     3

*-------------------
* 
*-------------------
InputMessage        dc.b    'Enter the section number = ',0
LifeSaver           ds.l    0                    ; make memory boundary even
DataFile            INCBIN  "datachunk.dat"
NumberOfSections    EQU     DataFile
Section1            EQU     (DataFile+4)

SumOfBytes          dc.b    'Sum of bytes = ',0
SumOfShorts         dc.b    'Sum of shorts = ',0
SumOfLongs          dc.b    'Sum of longs = ',0
AverageValue        dc.b    ', average value = ',0
DecimalPoint        dc.b    '.',0
Zero                dc.b    '0',0
CRLF                dc.b    '',0

        END     START
        

        










*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
