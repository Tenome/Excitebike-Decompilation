; Module rider_overlap: $E4C8-
.segment "PRG"

DetectRiderOverlap:
  ldx #$01                     ; $E4C8
Loc_E4CA:
  stx z:$0C                    ; $E4CA
  lda z:RiderXHi,x             ; $E4CC
  lsr a                        ; $E4CE
  bcs Loc_E4D9                 ; $E4CF
  bne Loc_E50A                 ; $E4D1
  lda z:RiderXLo,x             ; $E4D3
  cmp #$F8                     ; $E4D5
  bcc Loc_E50A                 ; $E4D7
Loc_E4D9:
  lda #$00                     ; $E4D9
  sta z:$0A                    ; $E4DB
  txa                          ; $E4DD
  tay                          ; $E4DE
  iny                          ; $E4DF
Loc_E4E0:
  sty z:$05                    ; $E4E0
  lda a:RiderXHi,y             ; $E4E2
  lsr a                        ; $E4E5
  bcs Loc_E4F0                 ; $E4E6
  bne Loc_E4FF                 ; $E4E8
  lda z:RiderXLo,x             ; $E4EA
  cmp #$F8                     ; $E4EC
  bcc Loc_E4FF                 ; $E4EE
Loc_E4F0:
  jsr RiderYOverlapTest        ; $E4F0
  beq Loc_E4FF                 ; $E4F3
  inc z:$0A                    ; $E4F5
  lda z:$0B                    ; $E4F7
  asl a                        ; $E4F9
  asl a                        ; $E4FA
  ora z:$05                    ; $E4FB
  sta z:$0B                    ; $E4FD
Loc_E4FF:
  iny                          ; $E4FF
  cpy #$04                     ; $E500
  bcc Loc_E4E0                 ; $E502
  lda z:$0A                    ; $E504
  cmp #$02                     ; $E506
  bcs Loc_E513                 ; $E508
Loc_E50A:
  ldx z:$0C                    ; $E50A
  dex                          ; $E50C
  bpl Loc_E4CA                 ; $E50D
  lda #$00                     ; $E50F
  beq Loc_E528                 ; $E511
Loc_E513:
  bne Loc_E526                 ; $E513
  lda z:$0B                    ; $E515
  pha                          ; $E517
  and #$03                     ; $E518
  tay                          ; $E51A
  pla                          ; $E51B
  lsr a                        ; $E51C
  lsr a                        ; $E51D
  and #$03                     ; $E51E
  tax                          ; $E520
  jsr RiderYOverlapTest        ; $E521
  beq Loc_E50A                 ; $E524
Loc_E526:
  lda #$01                     ; $E526
Loc_E528:
  sta RidersOverlap            ; $E528
  rts                          ; $E52B
RiderYOverlapTest:
  lda z:RiderScreenY,x         ; $E52C
  sec                          ; $E52E
  sbc a:RiderScreenY,y         ; $E52F
  cmp #$EC                     ; $E532
  bcs Loc_E53C                 ; $E534
  cmp #$12                     ; $E536
  bcc Loc_E53C                 ; $E538
  lda #$00                     ; $E53A
Loc_E53C:
  rts                          ; $E53C
Data_E53D:
  .incbin "prg_bank_0.bin", $253D, $3  ; $E53D
Data_E540:
  .incbin "prg_bank_0.bin", $2540, $3  ; $E540
Data_E543:
  .incbin "prg_bank_0.bin", $2543, $4  ; $E543
Data_E547:
  .incbin "prg_bank_0.bin", $2547, $7  ; $E547
Data_E54E:
  .incbin "prg_bank_0.bin", $254E, $6  ; $E54E
Data_E554:
  .incbin "prg_bank_0.bin", $2554, $5  ; $E554
Data_E559:
  .incbin "prg_bank_0.bin", $2559, $15  ; $E559
Data_E56E:
  .incbin "prg_bank_0.bin", $256E, $12C  ; $E56E
Data_E69A:
  .incbin "prg_bank_0.bin", $269A, $7  ; $E69A
Data_E6A1:
  .incbin "prg_bank_0.bin", $26A1, $C  ; $E6A1
Data_E6AD:
  .incbin "prg_bank_0.bin", $26AD, $A  ; $E6AD
Data_E6B7:
  .addr Sub_E963, Sub_E8E3, Sub_E85D, Sub_E86A, Sub_E845, Sub_E854, Sub_E934, Sub_E818, TrackScriptFinishLine, Sub_E879, Sub_E89D, Sub_E8EE, Sub_E8FF, Sub_E956, Sub_E8BF, Sub_E8C6, Sub_E8FA  ; $E6B7 pointer table
  .incbin "prg_bank_0.bin", $26D9, $8  ; $E6D9
Data_E6E1:
  .incbin "prg_bank_0.bin", $26E1, $15  ; $E6E1
Data_E6F6:
  .incbin "prg_bank_0.bin", $26F6, $5  ; $E6F6
Data_E6FB:
  .incbin "prg_bank_0.bin", $26FB, $8  ; $E6FB
Data_E703:
  .incbin "prg_bank_0.bin", $2703, $8  ; $E703
