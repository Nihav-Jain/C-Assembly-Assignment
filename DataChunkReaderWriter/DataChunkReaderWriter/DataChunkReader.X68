*-----------------------------------------------------------
* Program Number: 4
* Written by    : Nihav Jain
* Date Created  : 10/23/2015
* Description   : Read a chunk of data from a binary file and print out the average of the chunk selected by user
*-----------------------------------------------------------

ALL_REGS            REG     D0-D7/A0
        
*-------------------
* MAIN
*-------------------
START   ORG     $1000
        
        lea     InputMessage, a1
        move.b  #CMD_PRINT_STRING, d0
        TRAP    #15
        
        move.b  #CMD_INPUT_NUMBER, d0
        TRAP    #15
        
        move.b  $9,d0
        TRAP    #15

        STOP #$1000
        
*-------------------
* Subroutine: Swaps the bytes of the lower word in d5
* Uses      : d5, d6 
*-------------------
SR_SWAP_WORD:
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
SR_SWAP_LONG:
        JSR     SR_SWAP_WORD
        swap    d5
        JSR     SR_SWAP_WORD
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
