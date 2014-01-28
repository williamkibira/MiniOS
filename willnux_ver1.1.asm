;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;:: NEW VERSION OF THE WILLNUX BOOT LOADER FOR FLOPPY DRIVES :::
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


;***************************************
;* INITIAL LOADING STAGE FOR SYSTEM    *
;[1] Declare the 16 bit mode           *
;[2] Start to load at bios from 0x7c00 *
;[3] Run to the loader set function    *
;***************************************

bits 16 ; Engage the 16 bit mode
org 0x7c00
start:	jmp loader

;*******************************************
;* MY MESSAGE TO THE SCREEN TO BE SEEN :) **
;*******************************************

msg_1 db "*** WILLNUX BOOT-LOADER ***", 0x0
msg_2 db "*** LOADING FROM FLOPPY DRIVE ...", 0x0

;*************************************************
;* SOME FUNCTIONS THAT I NEED TO PRINT MESSAGES **
;*************************************************

Print:
    lodsb
    or	al, al
    jz complete
    mov ah, 0x0e
    int 0x10
    jmp Print
complete:
    ret



;*************************************************
;* OEM PARAMETER BLOCK TO DEFINE SET PROPERTIES **
;* LIKE SECTOR SIZE FILE SYSTEM e.t.c		**
;*************************************************
bpbOEM	db "WILLNUX OS"
bpbBytesPerSector: DW 512
bpbSectorsPerCluster: DB 1
bpbReservedSectors: DW 1
bpbNumberOfFATS: DB 2
bpbRootEntries: DW 224
bpbTotalSectors: DW 2880
bpbMedia: DB 0xF0
bpbSectorsPerFAT: DW 9
bpbSectorsPerTrack: DW 18
bpbHeadsPerCylinder: DW 2
bpbHiddenSectors: DD 0
bpbTotalSectorsBig: DD 0
bsDriveNumber: DB 0
bsUnused: DB 0
bsExtBootSignature: DB 0x29
bsSerialNumber: DD 0xa0a1a2a3
bsVolumeLabel: DB "MOS FLOPPY"
bsFileSystem: DB "FAT 12"


;***************************************************
;* BOOT LOADER ENTRY POINTS : WHERE I GET TO JUMP ** 
;* INTO THE SYSTEM AND DO SOME COOL  STUFF :)     **
;***************************************************

loader:			; THE LOADER FUNCTION THAT CALLS THE RESET FUNCTION

.reset:
    mov ah, 0			;; RESET FLOPPY DISK FUNCTION
    mov dl, 0			;; DRIVE 0 IS A FLOPPY DRIVE
    int 0x13			;; INTERRUPT TO CALL BIOS
    jc  .reset			;; IF CARRY FLAG IS SET, THERE WAS AN ERROR, RETRY
    mov ax, 0x1000		;;WE ARE GOING TO READ SECTOR INTO ADDRESS 0x1000:0
    
    mov es, ax			
    xor bx, bx
    mov ah, 0x02		;; READ THE FLOPPY SECTOR FUNCTION
    mov al, 1			;; READ SECTOR 1
    mov ch, 1			;; WE ARE READING THE SECOND SECTOR PAST US, SO THIS IS TRACK 1
    
    mov cl, 2			;;SECTOR TO READ(second sector)
    mov dh, 0			;; HEAD NUMBER
    mov dl, 0			;; DRIVE NUMBER,[Remember , drive 0 is floppy]
    int 0x13			;; CALL BIOS
    
    jmp 0x1000:0x0		;; JUMP TO EXECUTE SECTOR
    
    
    cli  ; CLEAR ALL INTERRUPTS
    hlt  ; HALT THE SYSTEM   
times 510 - ($-$$) db 0		;;WE HAVE TO BE 512 BYTES, CLEAR THE REST OF THE BYTES WITH 0

dw 0xAA55			;;BOOT SIGNATURE

;************************************************************
;* END OF THE FIRST [1] SECTOR, BEGINNING NEW SECTOR [2] ****
;************************************************************

    

    