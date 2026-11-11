; Module tape: $C621-
.segment "PRG"

CopyTrackDesignToBackup:
  ldx #$00                     ; $C621
Loc_C623:
  lda TrackDesignWork,x        ; $C623
  sta TrackDesign,x            ; $C626
  dex                          ; $C629
  bne Loc_C623                 ; $C62A
  rts                          ; $C62C
TapeStrobe:
  lda #$05                     ; $C62D
  sta JOYPAD1                  ; $C62F
  pha                          ; $C632
  pla                          ; $C633
  pha                          ; $C634
  pla                          ; $C635
  pha                          ; $C636
  pla                          ; $C637
  rts                          ; $C638
TapeWaitEdges:
  jsr TapeStrobe               ; $C639
  lda JOYPAD1                  ; $C63C
  and #$02                     ; $C63F
  beq TapeWaitEdges            ; $C641
Loc_C643:
  jsr TapeStrobe               ; $C643
  lda JOYPAD1                  ; $C646
  and #$02                     ; $C649
  bne Loc_C643                 ; $C64B
  rts                          ; $C64D
TapeWriteZeroPulse:
  pha                          ; $C64E
  lda #$34                     ; $C64F
  bne Loc_C656                 ; $C651
TapeWritePulse:
  pha                          ; $C653
  lda #$6A                     ; $C654
Loc_C656:
  sta z:$07                    ; $C656
  sta z:$0C                    ; $C658
  lda #$04                     ; $C65A
  sta JOYPAD1                  ; $C65C
Loc_C65F:
  dec z:$07                    ; $C65F
  bne Loc_C65F                 ; $C661
  lda #$FF                     ; $C663
  sta JOYPAD1                  ; $C665
Loc_C668:
  dec z:$0C                    ; $C668
  bne Loc_C668                 ; $C66A
  pla                          ; $C66C
  rts                          ; $C66D
TapeWriteByte:
  jsr TapeWritePulse           ; $C66E
  ldx #$08                     ; $C671
Loc_C673:
  sta z:$00                    ; $C673
  clc                          ; $C675
  adc z:$00                    ; $C676
  bcs Loc_C681                 ; $C678
  jsr TapeWriteZeroPulse       ; $C67A
Loc_C67D:
  dex                          ; $C67D
  bne Loc_C673                 ; $C67E
  rts                          ; $C680
Loc_C681:
  jsr TapeWritePulse           ; $C681
  jsr TapeCountBit             ; $C684
  jmp Loc_C67D                 ; $C687
TapeCountBit:
  inc z:$08                    ; $C68A
  bne Loc_C690                 ; $C68C
  inc z:$09                    ; $C68E
Loc_C690:
  rts                          ; $C690
TapeReadHalfBit:
  jsr TapeWaitEdges            ; $C691
  lda #$4E                     ; $C694
  sta z:$01                    ; $C696
Loc_C698:
  dec z:$01                    ; $C698
  bne Loc_C698                 ; $C69A
  jsr TapeStrobe               ; $C69C
  lda JOYPAD1                  ; $C69F
  and #$02                     ; $C6A2
  rts                          ; $C6A4
TapeReadByte:
  lda #$08                     ; $C6A5
  sta z:$03                    ; $C6A7
  lda #$00                     ; $C6A9
  sta z:$04                    ; $C6AB
Loc_C6AD:
  lda z:$04                    ; $C6AD
  clc                          ; $C6AF
  adc z:$04                    ; $C6B0
  sta z:$04                    ; $C6B2
  jsr TapeReadHalfBit          ; $C6B4
  bne Loc_C6BE                 ; $C6B7
  jsr TapeCountBit             ; $C6B9
  inc z:$04                    ; $C6BC
Loc_C6BE:
  dec z:$03                    ; $C6BE
  bne Loc_C6AD                 ; $C6C0
  jsr TapeWaitEdges            ; $C6C2
  lda z:$04                    ; $C6C5
  rts                          ; $C6C7
TapeSaveDesigns:
  jsr TapeSelectBlockA         ; $C6C8
  jsr TapeWriteBlock           ; $C6CB
  jsr TapeSelectBlockB         ; $C6CE
TapeWriteBlock:
  lda #$20                     ; $C6D1
  sta z:$0A                    ; $C6D3
  lda #$4E                     ; $C6D5
  sta z:$0B                    ; $C6D7
Loc_C6D9:
  jsr TapeWriteZeroPulse       ; $C6D9
  dec z:$0A                    ; $C6DC
  bne Loc_C6D9                 ; $C6DE
  dec z:$0B                    ; $C6E0
  bne Loc_C6D9                 ; $C6E2
Loc_C6E4:
  jsr TapeWritePulse           ; $C6E4
  dec z:$05                    ; $C6E7
  bne Loc_C6E4                 ; $C6E9
Loc_C6EB:
  jsr TapeWriteZeroPulse       ; $C6EB
  dec z:$06                    ; $C6EE
  bne Loc_C6EB                 ; $C6F0
  jsr TapeWritePulse           ; $C6F2
  lda #$00                     ; $C6F5
  sta z:$08                    ; $C6F7
  sta z:$09                    ; $C6F9
  ldy #$00                     ; $C6FB
Loc_C6FD:
  lda ($0E),y                  ; $C6FD
  jsr TapeWriteByte            ; $C6FF
  iny                          ; $C702
  cpy z:$0D                    ; $C703
  bne Loc_C6FD                 ; $C705
  lda z:$09                    ; $C707
  pha                          ; $C709
  lda z:$08                    ; $C70A
  jsr TapeWriteByte            ; $C70C
  pla                          ; $C70F
  jsr TapeWriteByte            ; $C710
  jmp TapeWritePulse           ; $C713
TapeSelectBlockA:
  lda #$40                     ; $C716
  sta z:$0D                    ; $C718
  lda #$60                     ; $C71A
  sta z:$0E                    ; $C71C
  lda #$00                     ; $C71E
  sta z:$0F                    ; $C720
  lda #$28                     ; $C722
  bne Loc_C734                 ; $C724
TapeSelectBlockB:
  lda #$00                     ; $C726
  sta z:$0D                    ; $C728
  lda #$E0                     ; $C72A
  sta z:$0E                    ; $C72C
  lda #$05                     ; $C72E
  sta z:$0F                    ; $C730
  lda #$14                     ; $C732
Loc_C734:
  sta z:$05                    ; $C734
  sta z:$06                    ; $C736
  rts                          ; $C738
TapeLoadDesigns:
  jsr DisableNmi               ; $C739
  jsr TapeSelectBlockA         ; $C73C
  jsr TapeReadBlock            ; $C73F
  bcc Loc_C751                 ; $C742
Loc_C744:
  lda #$19                     ; $C744
  sta z:PpuUpdateIndex         ; $C746
Loc_C748:
  jsr WaitVblankEndEnableNmi   ; $C748
Loc_C74B:
  lda z:PpuUpdateIndex         ; $C74B
  bne Loc_C74B                 ; $C74D
  beq TapeLoadDesigns          ; $C74F
Loc_C751:
  ldx #$00                     ; $C751
  stx z:RiderActive            ; $C753
  ldy #$01                     ; $C755
Loc_C757:
  lda ($0E),y                  ; $C757
  sta a:$A3,y                  ; $C759
  cmp Data_C17F,y              ; $C75C
  beq Loc_C762                 ; $C75F
  inx                          ; $C761
Loc_C762:
  iny                          ; $C762
  cpy #$05                     ; $C763
  bne Loc_C757                 ; $C765
  lda #$07                     ; $C767
  sta z:RiderBumpState         ; $C769
  lda #$22                     ; $C76B
  sta z:$A1                    ; $C76D
  lda #$4F                     ; $C76F
  sta z:$A2                    ; $C771
  lda #$04                     ; $C773
  sta z:$A3                    ; $C775
  lda #$1A                     ; $C777
  sta z:PpuUpdateIndex         ; $C779
  cpx #$00                     ; $C77B
  bne Loc_C748                 ; $C77D
  jsr WaitVblankEndEnableNmi   ; $C77F
Loc_C782:
  lda z:PpuUpdateIndex         ; $C782
  bne Loc_C782                 ; $C784
  jsr DisableNmi               ; $C786
  jsr TapeSelectBlockB         ; $C789
  jsr TapeReadBlock            ; $C78C
  bcs Loc_C744                 ; $C78F
  rts                          ; $C791
TapeReadBlock:
  lda z:$05                    ; $C792
  sta z:$00                    ; $C794
Loc_C796:
  jsr TapeReadHalfBit          ; $C796
  bne TapeReadBlock            ; $C799
  dec z:$00                    ; $C79B
  bne Loc_C796                 ; $C79D
  lda z:$06                    ; $C79F
  sta z:$00                    ; $C7A1
Loc_C7A3:
  jsr TapeReadHalfBit          ; $C7A3
  beq TapeReadBlock            ; $C7A6
  dec z:$00                    ; $C7A8
  bne Loc_C7A3                 ; $C7AA
  lda #$00                     ; $C7AC
  sta z:$08                    ; $C7AE
  sta z:$09                    ; $C7B0
  jsr TapeWaitEdges            ; $C7B2
  jsr TapeWaitEdges            ; $C7B5
  ldy #$00                     ; $C7B8
Loc_C7BA:
  jsr TapeReadByte             ; $C7BA
  sta ($0E),y                  ; $C7BD
  iny                          ; $C7BF
  cpy z:$0D                    ; $C7C0
  bne Loc_C7BA                 ; $C7C2
  lda z:$08                    ; $C7C4
  sta z:$0A                    ; $C7C6
  lda z:$09                    ; $C7C8
  sta z:$0B                    ; $C7CA
  jsr TapeReadByte             ; $C7CC
  cmp z:$0A                    ; $C7CF
  bne Loc_C7DA                 ; $C7D1
  jsr TapeReadByte             ; $C7D3
  cmp z:$0B                    ; $C7D6
  beq Loc_C7DC                 ; $C7D8
Loc_C7DA:
  sec                          ; $C7DA
  rts                          ; $C7DB
Loc_C7DC:
  clc                          ; $C7DC
  rts                          ; $C7DD
