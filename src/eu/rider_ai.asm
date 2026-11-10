; Module rider_ai: $CD1F-
.segment "PRG"

UpdateRiderControls:
  lda z:RaceStarted            ; $CD1F
  beq Loc_CD40                 ; $CD21
  ldx #$03                     ; $CD23
Loc_CD25:
  lda z:RiderActive,x          ; $CD25
  beq Loc_CD3D                 ; $CD27
  lda z:RiderState,x           ; $CD29
  cmp #$05                     ; $CD2B
  beq Loc_CD3A                 ; $CD2D
  ora z:RiderCrash,x           ; $CD2F
  ora RiderOverheated,x        ; $CD31
  beq Loc_CD3A                 ; $CD34
  lda #$00                     ; $CD36
  sta z:RiderInput,x           ; $CD38
Loc_CD3A:
  jsr RiderControlStep         ; $CD3A
Loc_CD3D:
  dex                          ; $CD3D
  bpl Loc_CD25                 ; $CD3E
Loc_CD40:
  lda z:MenuHintTimer          ; $CD40
  bne Loc_CD58                 ; $CD42
  lda z:RiderInput             ; $CD44
  and #$C0                     ; $CD46
  beq Loc_CD58                 ; $CD48
  lda EngineRunning            ; $CD4A
  ora z:RaceEndState           ; $CD4D
  bne Loc_CD58                 ; $CD4F
  lda #$01                     ; $CD51
  sta EngineRunning            ; $CD53
  sta z:SfxPulse2Request       ; $CD56
Loc_CD58:
  rts                          ; $CD58
RiderControlStep:
  lda z:RiderInput,x           ; $CD59
  and #$03                     ; $CD5B
  sta z:$0A                    ; $CD5D
  ldy #$00                     ; $CD5F
  lda RiderPitchLock,x         ; $CD61
  ora z:RiderCrash,x           ; $CD64
  bne Loc_CDBA                 ; $CD66
  lda z:RiderState,x           ; $CD68
  beq Loc_CD70                 ; $CD6A
  cmp #$05                     ; $CD6C
  bne Loc_CDBA                 ; $CD6E
Loc_CD70:
  txa                          ; $CD70
  bne Loc_CD7B                 ; $CD71
  ldy #$02                     ; $CD73
  lda z:RaceEndState           ; $CD75
  bne Loc_CD9A                 ; $CD77
  ldy #$00                     ; $CD79
Loc_CD7B:
  lda z:RiderAirborne,x        ; $CD7B
  bne Loc_CDB2                 ; $CD7D
  lda z:RiderInput,x           ; $CD7F
  and #$C0                     ; $CD81
  beq Loc_CDBA                 ; $CD83
  stx z:$00                    ; $CD85
  asl a                        ; $CD87
  bcs Loc_CD8C                 ; $CD88
  inc z:$00                    ; $CD8A
Loc_CD8C:
  jsr RiderTerrainSpeedBias    ; $CD8C
  beq Loc_CD95                 ; $CD8F
  lda z:RiderSpeedHi,x         ; $CD91
  bne Loc_CDBA                 ; $CD93
Loc_CD95:
  ldy z:$00                    ; $CD95
  txa                          ; $CD97
  bne Loc_CDAC                 ; $CD98
Loc_CD9A:
  lda z:RiderSpeedHi,x         ; $CD9A
  cmp Data_C0D1,y              ; $CD9C
  bcc Loc_CDAC                 ; $CD9F
  bne Loc_CDB9                 ; $CDA1
  lda z:RiderSpeedLo,x         ; $CDA3
  cmp Data_C0CE,y              ; $CDA5
  beq Loc_CDBD                 ; $CDA8
  bcs Loc_CDB9                 ; $CDAA
Loc_CDAC:
  jsr RiderAccelerate          ; $CDAC
  jmp Loc_CDBD                 ; $CDAF
Loc_CDB2:
  ldy #$04                     ; $CDB2
  lda z:$0A                    ; $CDB4
  beq Loc_CDBA                 ; $CDB6
  tay                          ; $CDB8
Loc_CDB9:
  iny                          ; $CDB9
Loc_CDBA:
  jsr RiderDecelerate          ; $CDBA
Loc_CDBD:
  lda z:RiderCrash,x           ; $CDBD
  bne Loc_CE1C                 ; $CDBF
  lda z:RiderAirborne,x        ; $CDC1
  bne Loc_CDD5                 ; $CDC3
  lda z:RiderScriptId,x        ; $CDC5
  ora z:RaceEndState           ; $CDC7
  bne Loc_CDDE                 ; $CDC9
  lda z:RiderSpeedHi,x         ; $CDCB
  bne Loc_CDD5                 ; $CDCD
  lda z:RiderSpeedLo,x         ; $CDCF
  cmp #$A0                     ; $CDD1
  bcc Loc_CDDE                 ; $CDD3
Loc_CDD5:
  lda z:$0A                    ; $CDD5
  beq Loc_CDDE                 ; $CDD7
  sta z:$00                    ; $CDD9
  jmp Loc_CE83                 ; $CDDB
Loc_CDDE:
  lda z:RiderAirborne,x        ; $CDDE
  bne Loc_CE1C                 ; $CDE0
  lda RiderPitchGoal,x         ; $CDE2
  cmp z:RiderPitch,x           ; $CDE5
  beq Loc_CE1C                 ; $CDE7
  ldy #$05                     ; $CDE9
  jmp Loc_DCC7                 ; $CDEB
RiderTerrainSpeedBias:
  lda z:RiderTrackPiece,x      ; $CDEE
  cmp #$E4                     ; $CDF0
  beq Loc_CE0A                 ; $CDF2
  lda #$03                     ; $CDF4
  cmp z:RiderTerrainState,x    ; $CDF6
  bne Loc_CE00                 ; $CDF8
  lda z:RiderLane,x            ; $CDFA
  cmp #$03                     ; $CDFC
  bcs Loc_CE0A                 ; $CDFE
Loc_CE00:
  lda z:RiderY,x               ; $CE00
  cmp #$38                     ; $CE02
  bcs Loc_CE0A                 ; $CE04
  cmp #$08                     ; $CE06
  bcs Loc_CE1D                 ; $CE08
Loc_CE0A:
  lda #$01                     ; $CE0A
  cmp RiderSkid,x              ; $CE0C
  beq Loc_CE15                 ; $CE0F
  asl a                        ; $CE11
  sta RiderSkid,x              ; $CE12
Loc_CE15:
  txa                          ; $CE15
  bne Loc_CE28                 ; $CE16
  lda #$04                     ; $CE18
  sta z:SfxNoiseRequest        ; $CE1A
Loc_CE1C:
  rts                          ; $CE1C
Loc_CE1D:
  lda #$01                     ; $CE1D
  cmp RiderSkid,x              ; $CE1F
  beq Loc_CE28                 ; $CE22
  lsr a                        ; $CE24
  sta RiderSkid,x              ; $CE25
Loc_CE28:
  rts                          ; $CE28
RiderAccelerate:
  cpx z:FrameMod4              ; $CE29
  bne Loc_CE45                 ; $CE2B
  lda Data_C0BC,y              ; $CE2D
  clc                          ; $CE30
  adc z:RiderSpeedLo,x         ; $CE31
  sta z:RiderSpeedLo,x         ; $CE33
  bcc Loc_CE39                 ; $CE35
  inc z:RiderSpeedHi,x         ; $CE37
Loc_CE39:
  txa                          ; $CE39
  bne Loc_CE45                 ; $CE3A
  lda z:RiderSpeedHi,x         ; $CE3C
  cmp Data_C0D1,y              ; $CE3E
  beq Loc_CE46                 ; $CE41
  bcs Loc_CE4D                 ; $CE43
Loc_CE45:
  rts                          ; $CE45
Loc_CE46:
  lda z:RiderSpeedLo,x         ; $CE46
  cmp Data_C0CE,y              ; $CE48
  bcc Loc_CE45                 ; $CE4B
Loc_CE4D:
  lda Data_C0CE,y              ; $CE4D
  sta z:RiderSpeedLo,x         ; $CE50
  lda Data_C0D1,y              ; $CE52
  sta z:RiderSpeedHi,x         ; $CE55
  rts                          ; $CE57
RiderDecelerate:
  cpx z:FrameMod4              ; $CE58
  bne Loc_CE82                 ; $CE5A
RiderDecelerateBy:
  sty z:$00                    ; $CE5C
  lda z:RiderSpeedHi,x         ; $CE5E
  bne Loc_CE6D                 ; $CE60
  lda z:RiderAirborne,x        ; $CE62
  lsr a                        ; $CE64
  tay                          ; $CE65
  lda z:RiderSpeedLo,x         ; $CE66
  cmp Data_C0CC,y              ; $CE68
  bcc Loc_CE82                 ; $CE6B
Loc_CE6D:
  ldy z:$00                    ; $CE6D
  lda z:RiderSpeedLo,x         ; $CE6F
  sec                          ; $CE71
  sbc Data_C0C1,y              ; $CE72
  sta z:RiderSpeedLo,x         ; $CE75
  bcs Loc_CE82                 ; $CE77
  lda z:RiderSpeedHi,x         ; $CE79
  beq Loc_CE80                 ; $CE7B
  dec z:RiderSpeedHi,x         ; $CE7D
  rts                          ; $CE7F
Loc_CE80:
  sta z:RiderSpeedLo,x         ; $CE80
Loc_CE82:
  rts                          ; $CE82
Loc_CE83:
  lda z:RiderPitchRepeatTimer,x ; $CE83
  bne Loc_CE9F                 ; $CE85
  lda z:RiderAirborne,x        ; $CE87
  lsr a                        ; $CE89
  tay                          ; $CE8A
  lda Data_C0D4,y              ; $CE8B
  sta z:RiderPitchRepeatTimer,x ; $CE8E
  lsr z:$00                    ; $CE90
  bcc Loc_CEA0                 ; $CE92
  lda z:RiderPitch,x           ; $CE94
  cmp Data_C0C8,y              ; $CE96
  beq Loc_CE9F                 ; $CE99
  bcc Loc_CEAF                 ; $CE9B
  dec z:RiderPitch,x           ; $CE9D
Loc_CE9F:
  rts                          ; $CE9F
Loc_CEA0:
  lda RiderJumpMode,x          ; $CEA0
  and #$02                     ; $CEA3
  sta RiderJumpMode,x          ; $CEA5
  lda z:RiderPitch,x           ; $CEA8
  cmp Data_C0CA,y              ; $CEAA
  bcs Loc_CEB2                 ; $CEAD
Loc_CEAF:
  inc z:RiderPitch,x           ; $CEAF
  rts                          ; $CEB1
Loc_CEB2:
  lda z:RiderInput,x           ; $CEB2
  and #$C0                     ; $CEB4
  beq Loc_CECF                 ; $CEB6
  lda z:RiderAirborne,x        ; $CEB8
  bne Loc_CECF                 ; $CEBA
  inc z:RiderPitch,x           ; $CEBC
  lda #$0D                     ; $CEBE
  sta z:RiderPitchRepeatTimer,x ; $CEC0
  lda z:RiderPitch,x           ; $CEC2
  cmp #$0D                     ; $CEC4
  bcc Loc_CECF                 ; $CEC6
  lda #$01                     ; $CEC8
  sta z:RiderCrash,x           ; $CECA
  asl a                        ; $CECC
  sta z:RiderPitchRepeatTimer,x ; $CECD
Loc_CECF:
  rts                          ; $CECF
UpdateAiRiders:
  ldx z:FirstAiRider           ; $CED0
Loc_CED2:
  stx z:$0F                    ; $CED2
  lda z:RiderActive,x          ; $CED4
  beq Loc_CF04                 ; $CED6
  lda z:RiderCrash,x           ; $CED8
  ora z:RiderState,x           ; $CEDA
  bne Loc_CF04                 ; $CEDC
  jsr AiSetPitchInput          ; $CEDE
  lda z:RiderAirborne,x        ; $CEE1
  bne Loc_CEFF                 ; $CEE3
  jsr AiMatchTargetSpeed       ; $CEE5
  jsr AiScanObstacles          ; $CEE8
  bne Loc_CF04                 ; $CEEB
  lda $03A6                    ; $CEED
  beq Loc_CF04                 ; $CEF0
  jsr AiJumpCheck              ; $CEF2
  lda z:RaceEndState           ; $CEF5
  bne Loc_CF04                 ; $CEF7
  jsr AiConsiderLaneChange     ; $CEF9
  jmp Loc_CF04                 ; $CEFC
Loc_CEFF:
  lda RiderPitchGoal,x         ; $CEFF
  sta z:RiderTargetPitch,x     ; $CF02
Loc_CF04:
  ldx z:$0F                    ; $CF04
  inx                          ; $CF06
  cpx #$04                     ; $CF07
  bcc Loc_CED2                 ; $CF09
Loc_CF0B:
  rts                          ; $CF0B
AiConsiderLaneChange:
  lda z:RiderXHi,x             ; $CF0C
  lsr a                        ; $CF0E
  bcc Loc_CF0B                 ; $CF0F
  lda z:RiderLane,x            ; $CF11
  sta z:$02                    ; $CF13
  ldy #$02                     ; $CF15
  jsr AiLaneBlocked            ; $CF17
  bcc Loc_CF2B                 ; $CF1A
  jsr Sub_CFDB                 ; $CF1C
  lda z:RiderXLo,x             ; $CF1F
  asl a                        ; $CF21
  bcc Loc_CF0B                 ; $CF22
  lda z:RandomState,x          ; $CF24
  lsr a                        ; $CF26
  bcs Loc_CF64                 ; $CF27
  bcc AiLaneChangeUp           ; $CF29
Loc_CF2B:
  lda z:RiderLaneStep,x        ; $CF2B
  bne Loc_CF87                 ; $CF2D
  lda z:RiderXHi,x             ; $CF2F
  lsr a                        ; $CF31
  bcc Loc_CF87                 ; $CF32
  lda z:RiderXLo,x             ; $CF34
  cmp #$F0                     ; $CF36
  bcs Loc_CF87                 ; $CF38
  asl a                        ; $CF3A
  bcc Loc_CF87                 ; $CF3B
  lda z:$19,x                  ; $CF3D
  cmp #$E0                     ; $CF3F
  bcc Loc_CF87                 ; $CF41
  cmp #$F8                     ; $CF43
  bcc Loc_CF64                 ; $CF45
AiLaneChangeUp:
  ldy RiderLaneRow,x           ; $CF47
  dey                          ; $CF4A
  cpy #$01                     ; $CF4B
  bmi AiLaneChangeDown         ; $CF4D
  jsr Sub_CF88                 ; $CF4F
  bcs Loc_CF87                 ; $CF52
  ldy z:RiderLane,x            ; $CF54
  iny                          ; $CF56
  sty z:$02                    ; $CF57
  ldy #$00                     ; $CF59
  jsr AiLaneBlocked            ; $CF5B
  bcs Loc_CF87                 ; $CF5E
  lda #$01                     ; $CF60
  bne Loc_CF85                 ; $CF62
Loc_CF64:
  lda z:RiderTrackPiece,x      ; $CF64
  cmp #$E6                     ; $CF66
  beq AiLaneChangeUp           ; $CF68
AiLaneChangeDown:
  ldy RiderLaneRow,x           ; $CF6A
  iny                          ; $CF6D
  cpy #$05                     ; $CF6E
  bpl AiLaneChangeUp           ; $CF70
  jsr Sub_CF88                 ; $CF72
  bcs Loc_CF87                 ; $CF75
  ldy z:RiderLane,x            ; $CF77
  dey                          ; $CF79
  sty z:$02                    ; $CF7A
  ldy #$00                     ; $CF7C
  jsr AiLaneBlocked            ; $CF7E
  bcs Loc_CF87                 ; $CF81
  lda #$FF                     ; $CF83
Loc_CF85:
  sta z:RiderLaneStep,x        ; $CF85
Loc_CF87:
  rts                          ; $CF87
Sub_CF88:
  jsr TrackPieceAtRow          ; $CF88
Sub_CF8B:
  cmp #$3B                     ; $CF8B
  bcc Loc_CF94                 ; $CF8D
  cmp #$3E                     ; $CF8F
  bcs Loc_CF94                 ; $CF91
  rts                          ; $CF93
Loc_CF94:
  sec                          ; $CF94
  rts                          ; $CF95
AiLaneBlocked:
  lda z:RiderXLo,x             ; $CF96
  clc                          ; $CF98
  adc Data_C0D6,y              ; $CF99
  sta z:$00                    ; $CF9C
  sec                          ; $CF9E
  sbc Data_C0D7,y              ; $CF9F
  sta z:$01                    ; $CFA2
  ldy z:FirstAiRider           ; $CFA4
Loc_CFA6:
  cpy z:$0F                    ; $CFA6
  beq Loc_CFC4                 ; $CFA8
  lda a:RiderXHi,y             ; $CFAA
  lsr a                        ; $CFAD
  bcc Loc_CFC4                 ; $CFAE
  lda a:RiderLane,y            ; $CFB0
  beq Loc_CFC4                 ; $CFB3
  cmp z:$02                    ; $CFB5
  bne Loc_CFC4                 ; $CFB7
  lda a:RiderXLo,y             ; $CFB9
  cmp z:$00                    ; $CFBC
  bcs Loc_CFC4                 ; $CFBE
  cmp z:$01                    ; $CFC0
  bcs Loc_CFCA                 ; $CFC2
Loc_CFC4:
  iny                          ; $CFC4
  cpy #$04                     ; $CFC5
  bcc Loc_CFA6                 ; $CFC7
  clc                          ; $CFC9
Loc_CFCA:
  rts                          ; $CFCA
AiMatchTargetSpeed:
  ldy #$80                     ; $CFCB
  lda z:RiderSpeedHi,x         ; $CFCD
  cmp z:RiderTargetSpeedHi,x   ; $CFCF
  bcc Loc_CFFA                 ; $CFD1
  bne Sub_CFDB                 ; $CFD3
  lda z:RiderSpeedLo,x         ; $CFD5
  cmp z:RiderTargetSpeedLo,x   ; $CFD7
  bcc Loc_CFFA                 ; $CFD9
Sub_CFDB:
  lda z:RiderSpeedHi,x         ; $CFDB
  beq Loc_CFE9                 ; $CFDD
  lda #$0F                     ; $CFDF
  bne Loc_CFE5                 ; $CFE1
Sub_CFE3:
  lda #$F0                     ; $CFE3
Loc_CFE5:
  and z:RiderInput,x           ; $CFE5
  sta z:RiderInput,x           ; $CFE7
Loc_CFE9:
  rts                          ; $CFE9
AiSetPitchInput:
  jsr Sub_CFE3                 ; $CFEA
  ldy #$01                     ; $CFED
  lda z:RiderTargetPitch,x     ; $CFEF
  beq Loc_CFFF                 ; $CFF1
  cmp z:RiderPitch,x           ; $CFF3
  beq Loc_CFFF                 ; $CFF5
  bcc Loc_CFFA                 ; $CFF7
  iny                          ; $CFF9
Loc_CFFA:
  tya                          ; $CFFA
  ora z:RiderInput,x           ; $CFFB
  sta z:RiderInput,x           ; $CFFD
Loc_CFFF:
  rts                          ; $CFFF
AiJumpCheck:
  ldy #$00                     ; $D000
  cpx #$03                     ; $D002
  beq Loc_D015                 ; $D004
  lda z:RiderXLo,x             ; $D006
  and #$10                     ; $D008
  beq Loc_CFFF                 ; $D00A
  lda z:$1A,x                  ; $D00C
  cmp #$C0                     ; $D00E
  bcc Loc_CFFF                 ; $D010
  bne Loc_D015                 ; $D012
  iny                          ; $D014
Loc_D015:
  jmp SetRiderTargetSpeed      ; $D015
AiScanObstacles:
  lda #$00                     ; $D018
  sta z:$09                    ; $D01A
  sta z:$0D                    ; $D01C
  txa                          ; $D01E
  asl a                        ; $D01F
  asl a                        ; $D020
  sta z:$0A                    ; $D021
  ldy #$03                     ; $D023
Loc_D025:
  sty z:$0B                    ; $D025
  ldy z:$0A                    ; $D027
  lda $03C0,y                  ; $D029
  cmp #$C0                     ; $D02C
  beq Loc_D058                 ; $D02E
  cmp #$C1                     ; $D030
  beq Loc_D058                 ; $D032
  cmp #$70                     ; $D034
  bcc Loc_D03C                 ; $D036
  cmp #$74                     ; $D038
  bcc Loc_D058                 ; $D03A
Loc_D03C:
  cmp #$48                     ; $D03C
  bcc Loc_D044                 ; $D03E
  cmp #$4B                     ; $D040
  bcc Loc_D0A4                 ; $D042
Loc_D044:
  inc z:$0A                    ; $D044
  ldy z:$0B                    ; $D046
  dey                          ; $D048
  bpl Loc_D025                 ; $D049
Loc_D04B:
  ldy #$00                     ; $D04B
  lda z:RiderScriptId,x        ; $D04D
  bne Loc_D054                 ; $D04F
  ldy RiderPitchGoal,x         ; $D051
Loc_D054:
  tya                          ; $D054
  jmp Loc_D0A6                 ; $D055
Loc_D058:
  inc z:$0D                    ; $D058
  lda z:$0A                    ; $D05A
  and #$03                     ; $D05C
  tay                          ; $D05E
  iny                          ; $D05F
  tya                          ; $D060
  clc                          ; $D061
  adc z:RiderTrackPos,x        ; $D062
  and #$3F                     ; $D064
  sta z:$08                    ; $D066
  lda #$40                     ; $D068
  sta z:$09                    ; $D06A
  ldy RiderLaneRow,x           ; $D06C
Loc_D06F:
  dey                          ; $D06F
  cpy #$01                     ; $D070
  bmi Loc_D088                 ; $D072
  jsr TrackPieceAt             ; $D074
  ldy z:$07                    ; $D077
  cmp #$FA                     ; $D079
  beq Loc_D088                 ; $D07B
  jsr Sub_CF8B                 ; $D07D
  bcs Loc_D06F                 ; $D080
  jsr AiLaneChangeUp           ; $D082
  jmp Loc_D04B                 ; $D085
Loc_D088:
  ldy RiderLaneRow,x           ; $D088
Loc_D08B:
  iny                          ; $D08B
  cpy #$06                     ; $D08C
  bpl Loc_D04B                 ; $D08E
  jsr TrackPieceAt             ; $D090
  ldy z:$07                    ; $D093
  cmp #$E4                     ; $D095
  beq Loc_D04B                 ; $D097
  jsr Sub_CF8B                 ; $D099
  bcs Loc_D08B                 ; $D09C
  jsr AiLaneChangeDown         ; $D09E
  jmp Loc_D04B                 ; $D0A1
Loc_D0A4:
  lda #$09                     ; $D0A4
Loc_D0A6:
  sta z:RiderTargetPitch,x     ; $D0A6
  lda z:$0D                    ; $D0A8
  rts                          ; $D0AA
