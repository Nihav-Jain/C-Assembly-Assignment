*-----------------------------------------------------------
* Program Number: 4
* Written by    : Nihav Jain
* Date Created  : 10/23/2015
* Description   : Read a chunk of data from a binary file and print out the average of the chunk selected by user
*-----------------------------------------------------------

ALL_REGS            REG     D0-D7/A0
REGS_SUM_OF_SECTION REG     D0-D5
        
*-------------------
* MAIN
*-------------------
START   ORG     $1000
        
*        lea     InputMessage, a1
*        move.b  #CMD_PRINT_STRING, d0
*        TRAP    #15
*        
*        move.b  #CMD_INPUT_NUMBER, d0
*        TRAP    #15
        
        lea     Section1, a0
        JSR     SUM_OF_BYTES
        JSR     SUM_OF_SHORTS
        JSR     SUM_OF_LONGS
        
        move.b  $9,d0
        TRAP    #15

        STOP #$1000
        

*-------------------
* Returns the sum of bytes in the given section in d7.L, and adds number of bytes in d6
*-------------------
SUM_OF_BYTES:
        movem.l REGS_SUM_OF_SECTION, -(sp)
        
        move.l  (a0)+, d5        ; number of bytes
        JSR     SWAP_LONG        
        move.l  d5, d0
        move.l  d5, d6
        subi.l  #1, d0
        
        clr.l   d7       
    ADD_BYTES:
        add.b   (a0)+, d7
        dbra    d0, ADD_BYTES

        move.b  d6, d0
        andi.b  #1, d0
        tst.b   d0
        beq     RETURN_SUM_OF_BYTES
        add.l   #1, a0
        
    RETURN_SUM_OF_BYTES:    
        movem.l (sp)+, REGS_SUM_OF_SECTION
        RTS
        
SUM_OF_SHORTS:
        movem.l REGS_SUM_OF_SECTION, -(sp)
        
        move.l  (a0)+, d5        ; number of bytes
        JSR     SWAP_LONG        
        move.l  d5, d0
        move.l  d5, d6
        subi.l  #1, d0
        
        clr.l   d7 
    ADD_SHORTS:
        move.w  (a0)+, d5
        JSR     SWAP_WORD
        add.w   d5, d7
        dbra    d0, ADD_SHORTS
        
        movem.l (sp)+, REGS_SUM_OF_SECTION
        RTS

SUM_OF_LONGS:
        movem.l REGS_SUM_OF_SECTION, -(sp)
        
        move.l  (a0)+, d5        ; number of bytes
        JSR     SWAP_LONG        
        move.l  d5, d0
        move.l  d5, d6
        subi.l  #1, d0
        
        clr.l   d7 
    ADD_LONGS:
        move.l  (a0)+, d5
        JSR     SWAP_LONG
        add.l   d5, d7
        dbra    d0, ADD_LONGS
        
        movem.l (sp)+, REGS_SUM_OF_SECTION
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
* Uses      : d5, d6
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

*-------------------
* 
*-------------------
InputMessage        dc.b    'Enter the section number ',0
LifeSaver           ds.l    0                    ; make memory boundary even
DataFile            INCBIN  "datachunk.dat"
NumberOfSections    EQU     DataFile
Section1            EQU     (DataFile+4)

        END     START
        

        








*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
