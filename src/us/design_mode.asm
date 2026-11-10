; Module design_mode: $EAC5-
.segment "PRG"

DrawFinishGate:
  lda z:RaceEndState           ; $EAC5
  ora z:$3C                    ; $EAC7
  bne Loc_EAC0                 ; $EAC9
  lda z:$3A                    ; $EACB
  beq Loc_EAC4                 ; $EACD
  ldx #$00                     ; $EACF
  ldy #$03                     ; $EAD1
  lda z:$3A                    ; $EAD3
  cmp #$0D                     ; $EAD5
  bcc Loc_EAE0                 ; $EAD7
  lsr a                        ; $EAD9
  bcc Loc_EB16                 ; $EADA
  lda #$40                     ; $EADC
  sta z:MusicRequest           ; $EADE
Loc_EAE0:
  lda #$42                     ; $EAE0
  sta $02B4,x                  ; $EAE2
  inx                          ; $EAE5
  lda Data_E540,y              ; $EAE6
  sta $02B4,x                  ; $EAE9
  inx                          ; $EAEC
  lda #$00                     ; $EAED
  sta $02B4,x                  ; $EAEF
  inx                          ; $EAF2
  lda Data_E543,y              ; $EAF3
  sta $02B4,x                  ; $EAF6
  inx                          ; $EAF9
  dey                          ; $EAFA
  bne Loc_EAE0                 ; $EAFB
  ldx #$06                     ; $EAFD
Loc_EAFF:
  lda #$4A                     ; $EAFF
  sta $02C0,y                  ; $EB01
  iny                          ; $EB04
  iny                          ; $EB05
  lda #$00                     ; $EB06
  sta $02C0,y                  ; $EB08
  iny                          ; $EB0B
  lda Data_E547,x              ; $EB0C
  sta $02C0,y                  ; $EB0F
  iny                          ; $EB12
  dex                          ; $EB13
  bpl Loc_EAFF                 ; $EB14
Loc_EB16:
  rts                          ; $EB16
DesignModeUpdate:
  lda z:$BE                    ; $EB17  [heuristic code]
  bne Loc_EB7E                 ; $EB19
  lda z:$B4                    ; $EB1B
  beq Loc_EB23                 ; $EB1D
  dec z:$B4                    ; $EB1F
  bne Loc_EB5E                 ; $EB21
Loc_EB23:
  lda z:$BD                    ; $EB23
  ora z:$B9                    ; $EB25
  bne Loc_EB5E                 ; $EB27
  sta z:RiderMoveX             ; $EB29
  sta z:RiderTrackPiece        ; $EB2B
  lda z:$BF                    ; $EB2D
  beq Loc_EB35                 ; $EB2F
  cmp #$01                     ; $EB31
  bne Loc_EB9E                 ; $EB33
Loc_EB35:
  lda z:$C1                    ; $EB35
  cmp #$02                     ; $EB37
  beq Loc_EB5E                 ; $EB39
  lda z:$C1                    ; $EB3B
  beq Loc_EB49                 ; $EB3D
  lda #$09                     ; $EB3F
  sta z:RiderY                 ; $EB41
Loc_EB43:
  lda #$02                     ; $EB43
  sta z:$C1                    ; $EB45
  bne Loc_EB93                 ; $EB47
Loc_EB49:
  lda z:$BF                    ; $EB49
  bne Loc_EB5E                 ; $EB4B
  lda z:RiderInput             ; $EB4D
  asl a                        ; $EB4F
  bcc Loc_EB7F                 ; $EB50
  lda #$00                     ; $EB52
  sta z:InputLatch             ; $EB54
  lda z:$2B                    ; $EB56
  bne Loc_EB9D                 ; $EB58
  lda #$05                     ; $EB5A
  sta z:$2B                    ; $EB5C
Loc_EB5E:
  lda #$04                     ; $EB5E
  sta z:RiderMoveX             ; $EB60
  jsr DesignScrollStep         ; $EB62
  ldy z:$B3                    ; $EB65
  lda #$00                     ; $EB67
  sta z:$BD                    ; $EB69
  jsr DesignCheckSlotFree      ; $EB6B
  bne Loc_EB7C                 ; $EB6E
  iny                          ; $EB70
  cpy #$40                     ; $EB71
  bne Loc_EB77                 ; $EB73
  ldy #$00                     ; $EB75
Loc_EB77:
  jsr DesignCheckSlotFree      ; $EB77
  beq Loc_EB9D                 ; $EB7A
Loc_EB7C:
  inc z:$BD                    ; $EB7C
Loc_EB7E:
  rts                          ; $EB7E
Loc_EB7F:
  asl a                        ; $EB7F
  bcc Loc_EBF6                 ; $EB80
  lda z:InputLatch             ; $EB82
  bne Loc_EB9D                 ; $EB84
  jsr DesignLoadPiece          ; $EB86
  lda z:RiderY                 ; $EB89
  cmp #$FF                     ; $EB8B
  beq Loc_EB9D                 ; $EB8D
  cmp #$09                     ; $EB8F
  beq Loc_EB43                 ; $EB91
Loc_EB93:
  lda #$01                     ; $EB93
  sta z:$BE                    ; $EB95
  sta z:InputLatch             ; $EB97
  lda #$40                     ; $EB99
  sta z:MusicRequest           ; $EB9B
Loc_EB9D:
  rts                          ; $EB9D
Loc_EB9E:
  lda z:InputLatch             ; $EB9E
  bne Loc_EBB6                 ; $EBA0
  lda z:RiderInput             ; $EBA2
  asl a                        ; $EBA4
  asl a                        ; $EBA5
  bcc Loc_EBBD                 ; $EBA6
  jsr Sub_C3B1                 ; $EBA8
  jsr CopyBackupToDesign       ; $EBAB
  stx z:RaceActive             ; $EBAE
  stx z:MenuCursor             ; $EBB0
  lda #$08                     ; $EBB2
  sta z:GameState              ; $EBB4
Loc_EBB6:
  lda z:RiderInput             ; $EBB6
  bne Loc_EBBC                 ; $EBB8
  sta z:InputLatch             ; $EBBA
Loc_EBBC:
  rts                          ; $EBBC
Loc_EBBD:
  jsr DesignBlinkCursor        ; $EBBD
  lda z:$3A                    ; $EBC0
  bne Loc_EBBC                 ; $EBC2
  inc z:$3A                    ; $EBC4
  lda z:RiderInput             ; $EBC6
  cmp #$80                     ; $EBC8
  beq Loc_EBD0                 ; $EBCA
  cmp #$08                     ; $EBCC
  bne Loc_EBE9                 ; $EBCE
Loc_EBD0:
  inc TrackDesign              ; $EBD0
  lda TrackDesign              ; $EBD3
  cmp #$0A                     ; $EBD6
  bmi Loc_EBDF                 ; $EBD8
  lda #$01                     ; $EBDA
Loc_EBDC:
  sta TrackDesign              ; $EBDC
Loc_EBDF:
  lda #$01                     ; $EBDF
  sta z:SfxPulse1Request       ; $EBE1
  lsr a                        ; $EBE3
  sta z:InputLatch             ; $EBE4
  jmp Loc_EC47                 ; $EBE6
Loc_EBE9:
  cmp #$04                     ; $EBE9
  bne Loc_EBB6                 ; $EBEB
  dec TrackDesign              ; $EBED
  bne Loc_EBDF                 ; $EBF0
  lda #$09                     ; $EBF2
  bne Loc_EBDC                 ; $EBF4
Loc_EBF6:
  lda z:$2C                    ; $EBF6
  bne Loc_EC3A                 ; $EBF8
  lda #$08                     ; $EBFA
  sta z:$2C                    ; $EBFC
  lda z:RiderInput             ; $EBFE
  lsr a                        ; $EC00
  bcs Loc_EC10                 ; $EC01
  lsr a                        ; $EC03
  bcc Loc_EC3A                 ; $EC04
  dec z:$C2                    ; $EC06
  lda z:$C2                    ; $EC08
  bpl Loc_EC1C                 ; $EC0A
  lda #$14                     ; $EC0C
  bne Loc_EC1A                 ; $EC0E
Loc_EC10:
  inc z:$C2                    ; $EC10
  lda z:$C2                    ; $EC12
  cmp #$15                     ; $EC14
  bcc Loc_EC1C                 ; $EC16
  lda #$00                     ; $EC18
Loc_EC1A:
  sta z:$C2                    ; $EC1A
Loc_EC1C:
  lda #$01                     ; $EC1C
  sta z:SfxPulse1Request       ; $EC1E
  lsr a                        ; $EC20
  sta z:InputLatch             ; $EC21
  lda #$D0                     ; $EC23
DrawDesignCursorSprite:
  sta $0230                    ; $EC25
  lda #$CA                     ; $EC28
  sta $0231                    ; $EC2A
  lda #$00                     ; $EC2D
  sta $0232                    ; $EC2F
  ldx z:$C2                    ; $EC32
  lda Data_E6F6,x              ; $EC34
  sta $0233                    ; $EC37
Loc_EC3A:
  rts                          ; $EC3A
CopyBackupToDesign:
  ldx #$00                     ; $EC3B  [heuristic code]
Loc_EC3D:
  lda TrackDesign,x            ; $EC3D
  sta TrackDesignWork,x        ; $EC40
  dex                          ; $EC43
  bne Loc_EC3D                 ; $EC44
  rts                          ; $EC46
Loc_EC47:
  lda #$CF                     ; $EC47
  sta $0234                    ; $EC49
  lda TrackDesign              ; $EC4C
  sta $0235                    ; $EC4F
  lda #$00                     ; $EC52
  sta $0236                    ; $EC54
  lda #$E4                     ; $EC57
  sta $0237                    ; $EC59
  rts                          ; $EC5C
DesignBlinkCursor:
  lda #$F8                     ; $EC5D  [heuristic code]
  jsr DrawDesignCursorSprite   ; $EC5F
  lda z:FrameCounter           ; $EC62
  and #$10                     ; $EC64
  beq Loc_EC6C                 ; $EC66
  lda #$F8                     ; $EC68
  bne Loc_EC6E                 ; $EC6A
Loc_EC6C:
  lda #$C7                     ; $EC6C
Loc_EC6E:
  sta $0228                    ; $EC6E
  sta $022C                    ; $EC71
  rts                          ; $EC74
DesignLoadPiece:
  lda #$00                     ; $EC75
  sta z:$CA                    ; $EC77
  sta z:$C8                    ; $EC79
  sta z:$C9                    ; $EC7B
  lda z:$B2                    ; $EC7D
  sta z:$BA                    ; $EC7F
  lda z:RiderAirborne          ; $EC81
  sta z:$BB                    ; $EC83
  lda z:$B1                    ; $EC85
  sta z:RiderHeight            ; $EC87
  ldy z:$C2                    ; $EC89
  lda Data_E6E1,y              ; $EC8B
  sta z:RiderY                 ; $EC8E
  cmp #$11                     ; $EC90
  bcc Loc_EC98                 ; $EC92
  and #$0F                     ; $EC94
  sta z:$C8                    ; $EC96
Loc_EC98:
  rts                          ; $EC98
DesignScrollStep:
  lda z:RiderMoveX             ; $EC99
  beq Loc_EC98                 ; $EC9B
  clc                          ; $EC9D
  adc z:$B9                    ; $EC9E
  sta z:$B9                    ; $ECA0
  cmp #$08                     ; $ECA2
  bne Loc_EC98                 ; $ECA4
  lda #$01                     ; $ECA6
  sta z:RiderTrackPiece        ; $ECA8
  lsr a                        ; $ECAA
  sta z:$B9                    ; $ECAB
  jsr DrawTrackColumn          ; $ECAD
  lda z:$B2                    ; $ECB0
  jsr IncMod64                 ; $ECB2
  sta z:$B2                    ; $ECB5
  lda z:$B3                    ; $ECB7
  jsr IncMod64                 ; $ECB9
  sta z:$B3                    ; $ECBC
  rts                          ; $ECBE
IncMod64:
  clc                          ; $ECBF
  adc #$01                     ; $ECC0
  cmp #$40                     ; $ECC2
  bne Loc_ECC8                 ; $ECC4
Loc_ECC6:
  lda #$00                     ; $ECC6
Loc_ECC8:
  rts                          ; $ECC8
DesignCheckSlotFree:
  lda #$3D                     ; $ECC9  [heuristic code]
  cmp $0540,y                  ; $ECCB
  bne Loc_ECE1                 ; $ECCE
  cmp $0480,y                  ; $ECD0
  bne Loc_ECE1                 ; $ECD3
  lda #$3B                     ; $ECD5
  cmp $0400,y                  ; $ECD7
  bne Loc_ECE1                 ; $ECDA
  cmp $04C0,y                  ; $ECDC
  beq Loc_ECC6                 ; $ECDF
Loc_ECE1:
  lda #$01                     ; $ECE1
  rts                          ; $ECE3
InitHudSprite:
  ldy #$03                     ; $ECE4
Loc_ECE6:
  lda Data_E6A1,x              ; $ECE6
  inx                          ; $ECE9
  sta a:$02,y                  ; $ECEA
  dey                          ; $ECED
  bpl Loc_ECE6                 ; $ECEE
  lda z:$05                    ; $ECF0
  sta $0400                    ; $ECF2
  lda z:$02                    ; $ECF5
  sta $0401                    ; $ECF7
  ldx #$20                     ; $ECFA
  stx $0402                    ; $ECFC
Loc_ECFF:
  lda z:$03                    ; $ECFF
  sta $0403,x                  ; $ED01
  dex                          ; $ED04
  lda z:$04                    ; $ED05
  sta $0403,x                  ; $ED07
  dex                          ; $ED0A
  bpl Loc_ECFF                 ; $ED0B
  lda z:$05                    ; $ED0D
  eor #$04                     ; $ED0F
  sta $0423                    ; $ED11
  lda z:$02                    ; $ED14
  sta $0424                    ; $ED16
  ldx #$20                     ; $ED19
  stx $0425                    ; $ED1B
Loc_ED1E:
  lda z:$03                    ; $ED1E
  sta $0426,x                  ; $ED20
  dex                          ; $ED23
  lda z:$04                    ; $ED24
  sta $0426,x                  ; $ED26
  dex                          ; $ED29
  bpl Loc_ED1E                 ; $ED2A
  lda #$00                     ; $ED2C
  sta $0446                    ; $ED2E
  lda #$00                     ; $ED31
  sta z:$00                    ; $ED33
  lda #$04                     ; $ED35
  jmp Loc_C289                 ; $ED37
Data_ED3A:
  .incbin "prg_bank_0.bin", $2D3A, $6  ; $ED3A
Data_ED40:
  .incbin "prg_bank_0.bin", $2D40, $323  ; $ED40
Data_F063:
  .byte <(Data_F0AB), <(Data_F0B3), <(Data_F101), <(Data_F101), <(Data_F10A), <(Data_F112), <(Data_F16B), <(Data_F1A4), <(Data_F1D1), <(Data_F1EB), <(Data_F25E), <(Data_F297), <(Data_F2E2), <(Data_F2CC), <(Data_F4B4), <(Data_F496), <(Data_F4A5), <(Data_F456), <(Data_F32D), <(Data_F335), <(Data_F35D), <(Data_F2F8), <(Data_F45E), <(Data_F466), <(Data_F34D), <(Data_F33D), <(Data_F355), <(Data_F345), <(Data_F3C0), <(Data_F46E), <(Data_F46E), <(Data_F3CE), <(Data_F30A), <(Data_F314), <(Data_F3DC), <(Data_F3EA)  ; $F063 pointer table (low bytes)
Data_F087:
  .byte >(Data_F0AB), >(Data_F0B3), >(Data_F101), >(Data_F101), >(Data_F10A), >(Data_F112), >(Data_F16B), >(Data_F1A4), >(Data_F1D1), >(Data_F1EB), >(Data_F25E), >(Data_F297), >(Data_F2E2), >(Data_F2CC), >(Data_F4B4), >(Data_F496), >(Data_F4A5), >(Data_F456), >(Data_F32D), >(Data_F335), >(Data_F35D), >(Data_F2F8), >(Data_F45E), >(Data_F466), >(Data_F34D), >(Data_F33D), >(Data_F355), >(Data_F345), >(Data_F3C0), >(Data_F46E), >(Data_F46E), >(Data_F3CE), >(Data_F30A), >(Data_F314), >(Data_F3DC), >(Data_F3EA)  ; $F087 pointer table (high bytes)
Data_F0AB:
  .incbin "prg_bank_0.bin", $30AB, $8  ; $F0AB
Data_F0B3:
  .incbin "prg_bank_0.bin", $30B3, $2  ; $F0B3
Data_F0B5:
  .incbin "prg_bank_0.bin", $30B5, $4C  ; $F0B5
Data_F101:
  .incbin "prg_bank_0.bin", $3101, $9  ; $F101
Data_F10A:
  .incbin "prg_bank_0.bin", $310A, $8  ; $F10A
Data_F112:
  .incbin "prg_bank_0.bin", $3112, $59  ; $F112
Data_F16B:
  .incbin "prg_bank_0.bin", $316B, $39  ; $F16B
Data_F1A4:
  .incbin "prg_bank_0.bin", $31A4, $2D  ; $F1A4
Data_F1D1:
  .incbin "prg_bank_0.bin", $31D1, $1A  ; $F1D1
Data_F1EB:
  .incbin "prg_bank_0.bin", $31EB, $73  ; $F1EB
Data_F25E:
  .incbin "prg_bank_0.bin", $325E, $39  ; $F25E
Data_F297:
  .incbin "prg_bank_0.bin", $3297, $35  ; $F297
Data_F2CC:
  .incbin "prg_bank_0.bin", $32CC, $16  ; $F2CC
Data_F2E2:
  .incbin "prg_bank_0.bin", $32E2, $16  ; $F2E2
Data_F2F8:
  .incbin "prg_bank_0.bin", $32F8, $12  ; $F2F8
Data_F30A:
  .incbin "prg_bank_0.bin", $330A, $A  ; $F30A
Data_F314:
  .incbin "prg_bank_0.bin", $3314, $19  ; $F314
Data_F32D:
  .incbin "prg_bank_0.bin", $332D, $8  ; $F32D
Data_F335:
  .incbin "prg_bank_0.bin", $3335, $8  ; $F335
Data_F33D:
  .incbin "prg_bank_0.bin", $333D, $8  ; $F33D
Data_F345:
  .incbin "prg_bank_0.bin", $3345, $8  ; $F345
Data_F34D:
  .incbin "prg_bank_0.bin", $334D, $8  ; $F34D
Data_F355:
  .incbin "prg_bank_0.bin", $3355, $8  ; $F355
Data_F35D:
  .incbin "prg_bank_0.bin", $335D, $63  ; $F35D
Data_F3C0:
  .incbin "prg_bank_0.bin", $33C0, $E  ; $F3C0
Data_F3CE:
  .incbin "prg_bank_0.bin", $33CE, $A  ; $F3CE
Data_F3D8:
  .incbin "prg_bank_0.bin", $33D8, $4  ; $F3D8
Data_F3DC:
  .incbin "prg_bank_0.bin", $33DC, $E  ; $F3DC
Data_F3EA:
  .incbin "prg_bank_0.bin", $33EA, $6C  ; $F3EA
Data_F456:
  .incbin "prg_bank_0.bin", $3456, $8  ; $F456
Data_F45E:
  .incbin "prg_bank_0.bin", $345E, $8  ; $F45E
Data_F466:
  .incbin "prg_bank_0.bin", $3466, $8  ; $F466
Data_F46E:
  .incbin "prg_bank_0.bin", $346E, $28  ; $F46E
Data_F496:
  .incbin "prg_bank_0.bin", $3496, $F  ; $F496
Data_F4A5:
  .incbin "prg_bank_0.bin", $34A5, $F  ; $F4A5
Data_F4B4:
  .incbin "prg_bank_0.bin", $34B4, $12  ; $F4B4
Data_F4C6:
  .incbin "prg_bank_0.bin", $34C6, $7  ; $F4C6
Data_F4CD:
  .incbin "prg_bank_0.bin", $34CD, $5  ; $F4CD
Data_F4D2:
  .incbin "prg_bank_0.bin", $34D2, $5  ; $F4D2
Data_F4D7:
  .incbin "prg_bank_0.bin", $34D7, $5  ; $F4D7
Data_F4DC:
  .incbin "prg_bank_0.bin", $34DC, $5  ; $F4DC
Data_F4E1:
  .incbin "prg_bank_0.bin", $34E1, $C  ; $F4E1
Data_F4ED:
  .incbin "prg_bank_0.bin", $34ED, $8  ; $F4ED
Data_F4F5:
  .byte <(Data_F4DC), <(Data_F4D2), <(Data_F4D7), <(Data_F4E1), <(Data_F4ED)  ; $F4F5 pointer table (low bytes)
Data_F4FA:
  .byte >(Data_F4DC), >(Data_F4D2), >(Data_F4D7), >(Data_F4E1), >(Data_F4ED)  ; $F4FA pointer table (high bytes)
