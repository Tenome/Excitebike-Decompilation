; Module results: $CB06-
.segment "PRG"

TimeTableIndexForSelection:
  jsr TimeTableIndexForTrack   ; $CB06
  ldy SelectionB               ; $CB09
  beq Loc_CB11                 ; $CB0C
  clc                          ; $CB0E
  adc #$23                     ; $CB0F
Loc_CB11:
  tay                          ; $CB11
  rts                          ; $CB12
TimeTableIndexForTrack:
  lda #$20                     ; $CB13
  ldy z:$02                    ; $CB15
  cpy #$05                     ; $CB17
  beq Loc_CB2B                 ; $CB19
  lda #$00                     ; $CB1B
Loc_CB1D:
  dey                          ; $CB1D
  bmi Loc_CB25                 ; $CB1E
  clc                          ; $CB20
  adc #$03                     ; $CB21
  bne Loc_CB1D                 ; $CB23
Loc_CB25:
  ldy z:ModeFlagB              ; $CB25
  beq Loc_CB2B                 ; $CB27
  ora #$10                     ; $CB29
Loc_CB2B:
  rts                          ; $CB2B
StateSubStepDispatch:
  ldy z:GameSubStep            ; $CB2C
  lda Data_C12C,y              ; $CB2E
  sta z:$00                    ; $CB31
  lda Data_C130,y              ; $CB33
Loc_CB36:
  sta z:$01                    ; $CB36
  jmp ($0000)                  ; $CB38
ResultsStepInit:
  lda z:GameState              ; $CB3B
  cmp #$08                     ; $CB3D
  bcs Loc_CB73                 ; $CB3F
  lda SelectionB               ; $CB41
  sta z:MenuCursor             ; $CB44
  lda z:PlaceResult            ; $CB46
  cmp #$04                     ; $CB48
  bcs Loc_CB73                 ; $CB4A
  lda z:ModeFlagB              ; $CB4C
  beq Loc_CB6D                 ; $CB4E
  lda z:TrackIndex             ; $CB50
  cmp #$04                     ; $CB52
  bne Loc_CB69                 ; $CB54
  inc $03F3                    ; $CB56
  lda $03F3                    ; $CB59
  lsr a                        ; $CB5C
  bcs Loc_CB6D                 ; $CB5D
  lda LapSpeedScale            ; $CB5F
  lsr a                        ; $CB62
  beq Loc_CB6D                 ; $CB63
  sta LapSpeedScale            ; $CB65
  sec                          ; $CB68
Loc_CB69:
  bcs Loc_CB6D                 ; $CB69
  inc z:TrackIndex             ; $CB6B
Loc_CB6D:
  lda #$01                     ; $CB6D
  sta z:ModeFlagB              ; $CB6F
  sta z:ResultsFlag            ; $CB71
Loc_CB73:
  lda #$04                     ; $CB73
  bne Loc_CB9F                 ; $CB75
ResultsStepDrawText:
  ldy z:$33                    ; $CB77
  bne Loc_CBA3                 ; $CB79
  lda #$04                     ; $CB7B
  sta z:$03                    ; $CB7D
  ldx PpuBufferLen             ; $CB7F
Loc_CB82:
  lda $03D9,y                  ; $CB82
  sta $0304,x                  ; $CB85
  inx                          ; $CB88
  iny                          ; $CB89
  cpy #$07                     ; $CB8A
  bne Loc_CB82                 ; $CB8C
  jsr WriteTimeTextHeader      ; $CB8E
  lda #$20                     ; $CB91
  ldx z:ResultsFlag            ; $CB93
  bne Loc_CB99                 ; $CB95
  lda #$31                     ; $CB97
Loc_CB99:
  sta $03AD                    ; $CB99
  clc                          ; $CB9C
  adc #$03                     ; $CB9D
Loc_CB9F:
  sta z:$33                    ; $CB9F
  inc z:GameSubStep            ; $CBA1
Loc_CBA3:
  rts                          ; $CBA3
ResultsStepWait:
  lda z:$33                    ; $CBA4
  beq Loc_CB9F                 ; $CBA6
  cmp $03AD                    ; $CBA8
  beq Loc_CBC9                 ; $CBAB
  bcs Loc_CBA3                 ; $CBAD
  lda z:ResultsFlag            ; $CBAF
  bne Loc_CBB9                 ; $CBB1
  lda z:Joy1Held               ; $CBB3
  and #$F0                     ; $CBB5
  bne Loc_CBBF                 ; $CBB7
Loc_CBB9:
  jsr ResultsDrawRank          ; $CBB9
  jmp Loc_CC7D                 ; $CBBC
Loc_CBBF:
  jsr ResultsStepFinish        ; $CBBF
  lda z:GameState              ; $CBC2
  bne Loc_CBA3                 ; $CBC4
  jmp Sub_C3AF                 ; $CBC6
Loc_CBC9:
  lda z:TimerPrescaler         ; $CBC9
  bne Loc_CBA3                 ; $CBCB
  ldx #$03                     ; $CBCD
  stx z:$2F                    ; $CBCF
  stx z:$0D                    ; $CBD1
  dex                          ; $CBD3
Loc_CBD4:
  lda Data_C0DE,x              ; $CBD4
  sta z:$01                    ; $CBD7
  lda Data_C0E2,x              ; $CBD9
  sta z:$02                    ; $CBDC
  lda Data_C0E5,x              ; $CBDE
  sta z:$0B                    ; $CBE1
  jsr ResultsDrawLine          ; $CBE3
  dex                          ; $CBE6
  bpl Loc_CBD4                 ; $CBE7
  lda #$01                     ; $CBE9
  ldx z:PlaceResult            ; $CBEB
  dex                          ; $CBED
  stx z:$00                    ; $CBEE
  cpx #$03                     ; $CBF0
  bcs Loc_CBF8                 ; $CBF2
  stx z:$0D                    ; $CBF4
  lda #$02                     ; $CBF6
Loc_CBF8:
  sta z:MusicRequest           ; $CBF8
  eor #$02                     ; $CBFA
  sta z:$56                    ; $CBFC
  ldx z:$0D                    ; $CBFE
  lda Data_C0DA,x              ; $CC00
  sta z:$54                    ; $CC03
  lda Data_C0DE,x              ; $CC05
  sta z:$55                    ; $CC08
  sta $03F1                    ; $CC0A
  lda z:$00                    ; $CC0D
  bne Loc_CC6A                 ; $CC0F
  lda #$0A                     ; $CC11
  bne Loc_CC2F                 ; $CC13
ResultsDrawRank:
  lda $03AD                    ; $CC15
  sec                          ; $CC18
  sbc #$10                     ; $CC19
  cmp z:$33                    ; $CC1B
  bne Loc_CC32                 ; $CC1D
  lda z:TimerPrescaler         ; $CC1F
  bne Loc_CC32                 ; $CC21
  lda #$0D                     ; $CC23
  ldy z:RaceEndState           ; $CC25
  dey                          ; $CC27
  bne Loc_CC2F                 ; $CC28
  lda z:ResultsFlag            ; $CC2A
  clc                          ; $CC2C
  adc #$0B                     ; $CC2D
Loc_CC2F:
  sta z:PpuUpdateIndex         ; $CC2F
  rts                          ; $CC31
Loc_CC32:
  lda #$07                     ; $CC32
  tay                          ; $CC34
  jsr AdvanceBufferPos         ; $CC35
  stx z:$05                    ; $CC38
Loc_CC3A:
  lda Data_C134,y              ; $CC3A
  sta PpuBuffer,x              ; $CC3D
  inx                          ; $CC40
  dey                          ; $CC41
  bpl Loc_CC3A                 ; $CC42
  lda z:FrameCounter           ; $CC44
  and #$10                     ; $CC46
  bne Loc_CC6A                 ; $CC48
  ldy z:$05                    ; $CC4A
  lda z:PlaceResult            ; $CC4C
  jsr DivMod10                 ; $CC4E
  sta $0307,y                  ; $CC51
  txa                          ; $CC54
  jsr DivMod10                 ; $CC55
  sta z:$00                    ; $CC58
  txa                          ; $CC5A
  bne Loc_CC62                 ; $CC5B
  lda z:$00                    ; $CC5D
  bne Loc_CC65                 ; $CC5F
  rts                          ; $CC61
Loc_CC62:
  sta $0305,y                  ; $CC62
Loc_CC65:
  lda z:$00                    ; $CC65
  sta $0306,y                  ; $CC67
Loc_CC6A:
  rts                          ; $CC6A
ResultsStepFinish:
  jsr Sub_C3AF                 ; $CC6B
  lda z:ResultsFlag            ; $CC6E
  bne Loc_CC7C                 ; $CC70
  ldy z:GameState              ; $CC72
  cpy #$09                     ; $CC74
  bcc Loc_CC7A                 ; $CC76
  lda #$08                     ; $CC78
Loc_CC7A:
  sta z:GameState              ; $CC7A
Loc_CC7C:
  rts                          ; $CC7C
Loc_CC7D:
  lda z:$55                    ; $CC7D
  sta z:$01                    ; $CC7F
  lda z:$56                    ; $CC81
  bne Loc_CCB9                 ; $CC83
  lda z:$2F                    ; $CC85
  beq Loc_CCA3                 ; $CC87
  lda #$1F                     ; $CC89
  sta $0380                    ; $CC8B
  sta $038C                    ; $CC8E
  lda #$AF                     ; $CC91
  sta $0378                    ; $CC93
  lda #$01                     ; $CC96
  sta $037C                    ; $CC98
  lsr a                        ; $CC9B
  sta $0384                    ; $CC9C
  ldy #$BD                     ; $CC9F
  bne Loc_CCBB                 ; $CCA1
Loc_CCA3:
  ldx #$00                     ; $CCA3
  jsr JumpArcStep              ; $CCA5
  sta z:$55                    ; $CCA8
  sta z:$01                    ; $CCAA
  lda $03F1                    ; $CCAC
  cmp z:$55                    ; $CCAF
  bcs Loc_CCB9                 ; $CCB1
  sta z:$55                    ; $CCB3
  lda #$0A                     ; $CCB5
  sta z:$2F                    ; $CCB7
Loc_CCB9:
  ldy #$BB                     ; $CCB9
Loc_CCBB:
  sty z:$02                    ; $CCBB
  ldx z:PlaceResult            ; $CCBD
  dex                          ; $CCBF
  cpx #$03                     ; $CCC0
  bcc Loc_CCC6                 ; $CCC2
  ldx #$03                     ; $CCC4
Loc_CCC6:
  lda #$02                     ; $CCC6
  sta z:$0B                    ; $CCC8
ResultsDrawLine:
  lda Data_C0DA,x              ; $CCCA
  sta z:$00                    ; $CCCD
  lda #$21                     ; $CCCF
  sta z:$03                    ; $CCD1
  lda Data_C0E8,x              ; $CCD3
  sta z:$04                    ; $CCD6
  lda #$00                     ; $CCD8
  jmp DrawMetasprite           ; $CCDA
Loc_CCDD:
  lda z:$3C                    ; $CCDD
  lsr a                        ; $CCDF
  bcc Loc_CD12                 ; $CCE0
  lda #$40                     ; $CCE2
  sta z:MusicRequest           ; $CCE4
  lda #$58                     ; $CCE6
  sta z:$00                    ; $CCE8
  ldx #$08                     ; $CCEA
Loc_CCEC:
  txa                          ; $CCEC
  asl a                        ; $CCED
  asl a                        ; $CCEE
  tay                          ; $CCEF
  lda #$44                     ; $CCF0
  sta $02C0,y                  ; $CCF2
  lda Data_C147,x              ; $CCF5
  sta $02C1,y                  ; $CCF8
  lda #$00                     ; $CCFB
  sta $02C2,y                  ; $CCFD
  lda z:$00                    ; $CD00
  sta $02C3,y                  ; $CD02
  clc                          ; $CD05
  adc #$0A                     ; $CD06
  sta z:$00                    ; $CD08
  dex                          ; $CD0A
  bpl Loc_CCEC                 ; $CD0B
  lda #$F8                     ; $CD0D
  sta $02D0                    ; $CD0F
Loc_CD12:
  rts                          ; $CD12
Loc_CD13:
  ldx #$07                     ; $CD13
Loc_CD15:
  lda Data_C150,x              ; $CD15
  sta $02C0,x                  ; $CD18
  dex                          ; $CD1B
  bpl Loc_CD15                 ; $CD1C
  rts                          ; $CD1E
