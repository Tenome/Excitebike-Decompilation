; Module riders: $D918-
.segment "PRG"

UpdateRiderStates:
  ldx #$03                     ; $D918
Loc_D91A:
  jsr RiderStateDispatch       ; $D91A
  jsr ComputeRiderShadowY      ; $D91D
  dex                          ; $D920
  bpl Loc_D91A                 ; $D921
RiderState0Racing:
  rts                          ; $D923
RiderStateDispatch:
  ldy z:RiderState,x           ; $D924
  lda Data_D8FF,y              ; $D926
  sta z:$00                    ; $D929
  lda Data_D905,y              ; $D92B
  sta z:$01                    ; $D92E
  jmp ($0000)                  ; $D930
RiderState1Gate:
  lda $0370,x                  ; $D933
  beq Loc_D94E                 ; $D936
  lda z:FrameCounter           ; $D938
  lsr a                        ; $D93A
  bcs Loc_D952                 ; $D93B
  inc $0390,x                  ; $D93D
  ldy $03E4,x                  ; $D940
  lda z:RiderXLo,x             ; $D943
  clc                          ; $D945
  adc Data_D90E,y              ; $D946
  cmp $0390,x                  ; $D949
  bcs Loc_D952                 ; $D94C
Loc_D94E:
  inc z:RiderState,x           ; $D94E
  bne Loc_D97E                 ; $D950
Loc_D952:
  rts                          ; $D952
RiderState2MoveToLane:
  txa                          ; $D953
  tay                          ; $D954
  beq Loc_D95D                 ; $D955
  lda z:RiderHeight,x          ; $D957
  beq Loc_D95D                 ; $D959
  ldy #$04                     ; $D95B
Loc_D95D:
  lda z:RiderY,x               ; $D95D
  cmp Data_D8C4,y              ; $D95F
  beq Loc_D96E                 ; $D962
  ldy #$01                     ; $D964
  bcc Loc_D96A                 ; $D966
  ldy #$FF                     ; $D968
Loc_D96A:
  tya                          ; $D96A
  sta z:RiderLaneStep,x        ; $D96B
  rts                          ; $D96D
Loc_D96E:
  lda #$00                     ; $D96E
  sta $0398,x                  ; $D970
  sta z:RiderLaneStep,x        ; $D973
  inc z:RiderState,x           ; $D975
  txa                          ; $D977
  bne Loc_D97E                 ; $D978
  lda #$02                     ; $D97A
  sta z:SfxNoiseRequest        ; $D97C
Loc_D97E:
  lda #$08                     ; $D97E
  sta z:$2A,x                  ; $D980
  rts                          ; $D982
RiderState3Wait:
  lda $0370,x                  ; $D983
  beq Loc_D9C0                 ; $D986
  lda z:$2A,x                  ; $D988
  bne Loc_D9D2                 ; $D98A
  txa                          ; $D98C
  ora $03F7                    ; $D98D
  bne Loc_D9A1                 ; $D990
  ldy z:InputLatch             ; $D992
  lda z:Joy1Held               ; $D994
  and #$C0                     ; $D996
  beq Loc_D99F                 ; $D998
  sta z:InputLatch             ; $D99A
  tya                          ; $D99C
  beq Loc_D9A7                 ; $D99D
Loc_D99F:
  sta z:InputLatch             ; $D99F
Loc_D9A1:
  lda z:FrameCounter           ; $D9A1
  and #$0F                     ; $D9A3
  bne Loc_D9AA                 ; $D9A5
Loc_D9A7:
  dec $0390,x                  ; $D9A7
Loc_D9AA:
  and #$07                     ; $D9AA
  bne Loc_D9B6                 ; $D9AC
  lda $0398,x                  ; $D9AE
  eor #$01                     ; $D9B1
  sta $0398,x                  ; $D9B3
Loc_D9B6:
  lda $0390,x                  ; $D9B6
  sec                          ; $D9B9
  sbc #$08                     ; $D9BA
  cmp z:RiderXLo,x             ; $D9BC
  bcs Loc_D9D2                 ; $D9BE
Loc_D9C0:
  lda #$03                     ; $D9C0
  sta z:$36,x                  ; $D9C2
  inc z:RiderState,x           ; $D9C4
  lda #$00                     ; $D9C6
  cpx #$03                     ; $D9C8
  bne Loc_D9D2                 ; $D9CA
  sta $03A8                    ; $D9CC
  sta $0373                    ; $D9CF
Loc_D9D2:
  rts                          ; $D9D2
RiderState4Release:
  lda z:$36,x                  ; $D9D3
  bne Loc_D9F5                 ; $D9D5
  txa                          ; $D9D7
  bne Loc_D9E7                 ; $D9D8
  lda $03E0                    ; $D9DA
  bne Loc_DA10                 ; $D9DD
  lda $03F7                    ; $D9DF
  beq Loc_D9F3                 ; $D9E2
  jmp ResetGameRam             ; $D9E4
Loc_D9E7:
  lda z:$22                    ; $D9E7
  bne Loc_D9F5                 ; $D9E9
  lda #$01                     ; $D9EB
  sta z:RiderLaneStep,x        ; $D9ED
  lda #$18                     ; $D9EF
  sta z:$22                    ; $D9F1
Loc_D9F3:
  inc z:RiderState,x           ; $D9F3
Loc_D9F5:
  rts                          ; $D9F5
RiderState5Finish:
  lda z:RiderSpeedHi,x         ; $D9F6
  ora z:RiderLaneStep,x        ; $D9F8
  bne Loc_DA03                 ; $D9FA
  lda z:RiderY,x               ; $D9FC
  cmp Data_D8C4,x              ; $D9FE
  beq Loc_DA14                 ; $DA01
Loc_DA03:
  lda #$01                     ; $DA03
  sta z:RiderLaneStep,x        ; $DA05
  txa                          ; $DA07
  beq Loc_DA10                 ; $DA08
  lda z:RiderY,x               ; $DA0A
  cmp #$08                     ; $DA0C
  bcc Loc_DA14                 ; $DA0E
Loc_DA10:
  lda #$00                     ; $DA10
  sta z:RiderState,x           ; $DA12
Loc_DA14:
  rts                          ; $DA14
ComputeRiderShadowY:
  lda $0390,x                  ; $DA15
  sec                          ; $DA18
  sbc z:RiderXLo,x             ; $DA19
  sbc #$08                     ; $DA1B
  asl a                        ; $DA1D
  clc                          ; $DA1E
  adc z:RiderY,x               ; $DA1F
  adc #$04                     ; $DA21
  sta z:RiderShadowY,x         ; $DA23
  rts                          ; $DA25

; Per-frame rider movement: accumulate each rider's speed into pixel moves, scroll the world by rider 0's move, shift the others.
MoveRiders:
  lda z:RaceStarted            ; $DA26
  beq Loc_DA69                 ; $DA28
  ldx #$03                     ; $DA2A
Loc_DA2C:
  jsr AccumulateRiderMove      ; $DA2C
  jsr RiderLandingCheck        ; $DA2F
  jsr RiderLaunchUpdate        ; $DA32
  jsr RiderPitchTimer          ; $DA35
  dex                          ; $DA38
  bpl Loc_DA2C                 ; $DA39
  jsr ScrollWorld              ; $DA3B
  jsr ShiftRidersByScroll      ; $DA3E
  jsr ScrollSplitLayer         ; $DA41
  lda z:$3C                    ; $DA44
  bne Loc_DA69                 ; $DA46
  ldy $03BC                    ; $DA48
  lda Data_D8EF,y              ; $DA4B
  sta z:$00                    ; $DA4E
  lda Data_D8F1,y              ; $DA50
  sta z:$01                    ; $DA53
  jmp ($0000)                  ; $DA55
AccumulateRiderMove:
  lda z:RiderSpeedHi,x         ; $DA58
  sta z:RiderMoveX,x           ; $DA5A
  lda z:RiderSpeedLo,x         ; $DA5C
  clc                          ; $DA5E
  adc $0394,x                  ; $DA5F
  sta $0394,x                  ; $DA62
  bcc Loc_DA69                 ; $DA65
  inc z:RiderMoveX,x           ; $DA67
Loc_DA69:
  rts                          ; $DA69
ScrollWorld:
  lda z:ScrollX                ; $DA6A
  clc                          ; $DA6C
  adc z:RiderMoveX             ; $DA6D
  sta z:ScrollX                ; $DA6F
  bcc Loc_DA79                 ; $DA71
  lda z:PpuCtrlNametableBits   ; $DA73
  eor #$01                     ; $DA75
  sta z:PpuCtrlNametableBits   ; $DA77
Loc_DA79:
  rts                          ; $DA79
ShiftRidersByScroll:
  ldx #$03                     ; $DA7A
Loc_DA7C:
  lda z:RiderActive,x          ; $DA7C
  beq Loc_DA9B                 ; $DA7E
  lda z:RiderMoveX,x           ; $DA80
  clc                          ; $DA82
  adc z:RiderXLo,x             ; $DA83
  bcc Loc_DA89                 ; $DA85
  inc z:RiderXHi,x             ; $DA87
Loc_DA89:
  sec                          ; $DA89
  sbc z:RiderMoveX             ; $DA8A
  sta z:RiderXLo,x             ; $DA8C
  bcs Loc_DA92                 ; $DA8E
  dec z:RiderXHi,x             ; $DA90
Loc_DA92:
  lda $0390,x                  ; $DA92
  sec                          ; $DA95
  sbc z:RiderMoveX             ; $DA96
  sta $0390,x                  ; $DA98
Loc_DA9B:
  dex                          ; $DA9B
  bne Loc_DA7C                 ; $DA9C
  rts                          ; $DA9E
SpawnCpuRiders:
  ldx #$03                     ; $DA9F
  lda z:$3B                    ; $DAA1
  bne Loc_DADF                 ; $DAA3
Loc_DAA5:
  txa                          ; $DAA5
  eor z:FrameMod4              ; $DAA6
  ora z:RiderActive,x          ; $DAA8
  ora z:$23                    ; $DAAA
  ora $0373                    ; $DAAC
  ora $03A8                    ; $DAAF
  bne Loc_DADF                 ; $DAB2
  lda z:RandomState,x          ; $DAB4
  cmp #$A0                     ; $DAB6
  bcc Loc_DADF                 ; $DAB8
  stx z:$00                    ; $DABA
  and #$03                     ; $DABC
  tay                          ; $DABE
  iny                          ; $DABF
  lda z:RiderSpeedHi           ; $DAC0
  and #$02                     ; $DAC2
  sta z:RiderXHi,x             ; $DAC4
  ldx #$03                     ; $DAC6
Loc_DAC8:
  sty z:$01                    ; $DAC8
  lda z:RiderLane,x            ; $DACA
  cmp z:$01                    ; $DACC
  bne Loc_DAD7                 ; $DACE
  iny                          ; $DAD0
  cpy #$05                     ; $DAD1
  bcc Loc_DAD7                 ; $DAD3
  ldy #$01                     ; $DAD5
Loc_DAD7:
  dex                          ; $DAD7
  bne Loc_DAC8                 ; $DAD8
  ldx z:$00                    ; $DADA
  jsr SpawnRider               ; $DADC
Loc_DADF:
  dex                          ; $DADF
  bne Loc_DAA5                 ; $DAE0
  rts                          ; $DAE2
SpawnRider:
  jsr ClearRider               ; $DAE3
  dey                          ; $DAE6
  lda Data_D8D8,y              ; $DAE7
  sta z:RiderY,x               ; $DAEA
  ldy z:RiderXHi,x             ; $DAEC
  lda Data_D8DF,y              ; $DAEE
  sta z:RiderXLo,x             ; $DAF1
  lda #$06                     ; $DAF3
  sta z:RiderPitch,x           ; $DAF5
  lda z:RiderTrackPos          ; $DAF7
  clc                          ; $DAF9
  adc Data_D8E2,y              ; $DAFA
  and #$3F                     ; $DAFD
  sta z:RiderTrackPos,x        ; $DAFF
  lda z:RiderMoveFraction      ; $DB01
  sta z:RiderMoveFraction,x    ; $DB03
  tya                          ; $DB05
  beq Loc_DB34                 ; $DB06
  ldy #$05                     ; $DB08
  jsr TrackPieceAtRow          ; $DB0A
  cmp #$E4                     ; $DB0D
  beq Loc_DB34                 ; $DB0F
  cmp #$3B                     ; $DB11
  bcc Loc_DB4D                 ; $DB13
  cmp #$93                     ; $DB15
  bcs Loc_DB4D                 ; $DB17
  ldy #$02                     ; $DB19
  jsr TrackPieceAtRow          ; $DB1B
  cmp #$E6                     ; $DB1E
  bne Loc_DB34                 ; $DB20
  lda z:RiderY,x               ; $DB22
  cmp #$20                     ; $DB24
  bcc Loc_DB30                 ; $DB26
  lda #$30                     ; $DB28
  sta z:RiderHeight,x          ; $DB2A
  lda #$01                     ; $DB2C
  bne Loc_DB32                 ; $DB2E
Loc_DB30:
  lda #$03                     ; $DB30
Loc_DB32:
  sta z:RiderTerrainState,x    ; $DB32
Loc_DB34:
  ldy z:RiderXHi,x             ; $DB34
  jsr SetRiderTargetSpeed      ; $DB36
  lda z:RiderXHi,x             ; $DB39
  eor #$02                     ; $DB3B
  asl a                        ; $DB3D
  sta z:RiderSpeedHi,x         ; $DB3E
  lda #$20                     ; $DB40
  sta $039B,x                  ; $DB42
  lsr a                        ; $DB45
  sta z:$23                    ; $DB46
  lda #$01                     ; $DB48
  sta z:RiderActive,x          ; $DB4A
  rts                          ; $DB4C
Loc_DB4D:
  lda #$00                     ; $DB4D
  rts                          ; $DB4F
SetRiderTargetSpeed:
  lda z:RaceEndState           ; $DB50
  beq Loc_DB58                 ; $DB52
  lda #$03                     ; $DB54
  bne Loc_DB5F                 ; $DB56
Loc_DB58:
  cpx #$03                     ; $DB58
  beq Loc_DB6C                 ; $DB5A
Loc_DB5C:
  lda Data_D8D5,y              ; $DB5C
Loc_DB5F:
  sta z:RiderTargetSpeedHi,x   ; $DB5F
  lda z:$1B,x                  ; $DB61
  and #$0F                     ; $DB63
  tay                          ; $DB65
  lda Data_D8CD,y              ; $DB66
  sta z:RiderTargetSpeedLo,x   ; $DB69
  rts                          ; $DB6B
Loc_DB6C:
  lda z:RiderXHi,x             ; $DB6C
  lsr a                        ; $DB6E
  lsr a                        ; $DB6F
  bcs Loc_DB5C                 ; $DB70
  lda z:RiderSpeedHi           ; $DB72
  beq Loc_DB5C                 ; $DB74
  sta z:RiderTargetSpeedHi,x   ; $DB76
  lda z:RiderSpeedLo           ; $DB78
  sta z:RiderTargetSpeedLo,x   ; $DB7A
  lda z:RiderXHi,x             ; $DB7C
  beq Loc_DB8C                 ; $DB7E
  lda z:RiderXLo,x             ; $DB80
  cmp #$40                     ; $DB82
  bcs Loc_DB5C                 ; $DB84
  lda z:RiderLane              ; $DB86
  cmp z:$73                    ; $DB88
  beq Loc_DB94                 ; $DB8A
Loc_DB8C:
  lda z:RiderTargetSpeedHi,x   ; $DB8C
  cmp #$04                     ; $DB8E
  bcs Loc_DB94                 ; $DB90
  inc z:RiderTargetSpeedHi,x   ; $DB92
Loc_DB94:
  rts                          ; $DB94
ClearRider:
  lda #$00                     ; $DB95
  sta z:RiderActive,x          ; $DB97
  sta z:RiderY,x               ; $DB99
  sta z:RiderHeight,x          ; $DB9B
  sta z:RiderBumpState,x       ; $DB9D
  sta z:RiderTerrainState,x    ; $DB9F
  sta z:$58,x                  ; $DBA1
  sta z:$CC,x                  ; $DBA3
  sta $036C,x                  ; $DBA5
  sta z:RiderSpeedLo,x         ; $DBA8
  sta z:RiderSpeedHi,x         ; $DBAA
  sta z:RiderCrash,x           ; $DBAC
  sta z:RiderState,x           ; $DBAE
  sta z:RiderAirborne,x        ; $DBB0
  sta z:$D4,x                  ; $DBB2
  sta $0388,x                  ; $DBB4
  sta z:RiderTrackPiece,x      ; $DBB7
  sta $039C,x                  ; $DBB9
  sta z:RiderLaneStep,x        ; $DBBC
  sta z:RiderLane,x            ; $DBBE
  sta $0370,x                  ; $DBC0
Loc_DBC3:
  rts                          ; $DBC3
HandleLostRider:
  lda $03A8                    ; $DBC4
  beq Loc_DBC3                 ; $DBC7
  lda z:$AB                    ; $DBC9
  beq Loc_DBE0                 ; $DBCB
  ldx #$03                     ; $DBCD
  lda z:RiderXHi,x             ; $DBCF
  lsr a                        ; $DBD1
  bcs Loc_DBC3                 ; $DBD2
  lsr a                        ; $DBD4
  bcs Loc_DBDD                 ; $DBD5
  lda z:RiderXLo,x             ; $DBD7
  cmp #$EA                     ; $DBD9
  bcs Loc_DBC3                 ; $DBDB
Loc_DBDD:
  jmp ClearRider               ; $DBDD
Loc_DBE0:
  ldy #$00                     ; $DBE0
  sty $03A8                    ; $DBE2
  iny                          ; $DBE5
  ldx #$02                     ; $DBE6
  stx z:$87                    ; $DBE8
  inx                          ; $DBEA
  jsr SpawnRider               ; $DBEB
  beq Loc_DBC3                 ; $DBEE
  lda #$00                     ; $DBF0
  sta z:$97                    ; $DBF2
  lda #$92                     ; $DBF4
  sta z:$8F                    ; $DBF6
  sta $0373                    ; $DBF8
  jmp Loc_DC69                 ; $DBFB
ScrollSplitLayer:
  lda z:RiderMoveX             ; $DBFE
  lsr a                        ; $DC00
  ror a                        ; $DC01
  ror a                        ; $DC02
  ror a                        ; $DC03
  clc                          ; $DC04
  adc $03BF                    ; $DC05
  sta $03BF                    ; $DC08
  lda z:RiderMoveX             ; $DC0B
  adc z:SplitScrollX           ; $DC0D
  sta z:SplitScrollX           ; $DC0F
  bcc Loc_DC19                 ; $DC11
  lda z:SplitNametableBits     ; $DC13
  eor #$01                     ; $DC15
  sta z:SplitNametableBits     ; $DC17
Loc_DC19:
  rts                          ; $DC19
RiderLandingCheck:
  lda z:RiderAirborne,x        ; $DC1A
  beq Loc_DC19                 ; $DC1C
  jsr RiderBaseY               ; $DC1E
  sta z:$01                    ; $DC21
  cmp z:RiderScreenY,x         ; $DC23
  bcs Loc_DC19                 ; $DC25
  lda z:RiderScreenY,x         ; $DC27
  cmp #$A8                     ; $DC29
  bcs Loc_DC19                 ; $DC2B
  lda $0364,x                  ; $DC2D
  beq Loc_DC19                 ; $DC30
  txa                          ; $DC32
  bne Loc_DC39                 ; $DC33
  lda #$02                     ; $DC35
  sta z:SfxPulse1Request       ; $DC37
Loc_DC39:
  lda #$00                     ; $DC39
  sta z:RiderAirborne,x        ; $DC3B
  sta $0364,x                  ; $DC3D
  lda z:RiderCrash,x           ; $DC40
  bne Loc_DC87                 ; $DC42
  lda z:RaceEndState           ; $DC44
  bne Loc_DC8E                 ; $DC46
  ldy $0388,x                  ; $DC48
  sta $0388,x                  ; $DC4B
  tya                          ; $DC4E
  bne Loc_DC87                 ; $DC4F
  lda z:$D4,x                  ; $DC51
  ldy z:RiderSpeedHi,x         ; $DC53
  cpy #$02                     ; $DC55
  bpl Loc_DC5C                 ; $DC57
  clc                          ; $DC59
  adc #$08                     ; $DC5A
Loc_DC5C:
  tay                          ; $DC5C
  lda z:RiderPitch,x           ; $DC5D
  cmp Data_D86C,y              ; $DC5F
  bcc Loc_DC69                 ; $DC62
  cmp Data_D87C,y              ; $DC64
  bcc Loc_DC6E                 ; $DC67
Loc_DC69:
  lda #$FF                     ; $DC69
  sta z:RiderCrash,x           ; $DC6B
  rts                          ; $DC6D
Loc_DC6E:
  lda $0368,x                  ; $DC6E
  cmp z:RiderPitch,x           ; $DC71
  beq Loc_DC87                 ; $DC73
  lda z:$D4,x                  ; $DC75
  ora z:$CC,x                  ; $DC77
  bne Loc_DC87                 ; $DC79
  lda #$04                     ; $DC7B
  sta $0374,x                  ; $DC7D
  lsr a                        ; $DC80
  sta $0388,x                  ; $DC81
  lsr a                        ; $DC84
  sta z:RiderAirborne,x        ; $DC85
Loc_DC87:
  dec z:$01                    ; $DC87
  lda z:$01                    ; $DC89
  sta z:RiderScreenY,x         ; $DC8B
Loc_DC8D:
  rts                          ; $DC8D
Loc_DC8E:
  lda z:$D4,x                  ; $DC8E
  bne Loc_DC8D                 ; $DC90
  lda #$06                     ; $DC92
  sta z:RiderPitch,x           ; $DC94
  rts                          ; $DC96
RiderBaseY:
  lda $03F1                    ; $DC97
RiderBaseYFrom:
  sec                          ; $DC9A
  sbc z:RiderHeight,x          ; $DC9B
  sbc z:RiderY,x               ; $DC9D
  rts                          ; $DC9F
SetRiderTargetPitch:
  ldy z:$D4,x                  ; $DCA0
  lda z:RaceEndState           ; $DCA2
  cmp #$01                     ; $DCA4
  bne Loc_DCB5                 ; $DCA6
  txa                          ; $DCA8
  ora z:RiderCrash             ; $DCA9
  ora z:RiderState             ; $DCAB
  ora z:$58                    ; $DCAD
  bne Loc_DCB5                 ; $DCAF
  lda #$0A                     ; $DCB1
  bne Loc_DCB8                 ; $DCB3
Loc_DCB5:
  lda Data_D88B,y              ; $DCB5
Loc_DCB8:
  sta $0368,x                  ; $DCB8
  lda z:RiderTerrainState,x    ; $DCBB
  cmp #$01                     ; $DCBD
  bne Loc_DCC6                 ; $DCBF
  lda #$06                     ; $DCC1
  sta $0368,x                  ; $DCC3
Loc_DCC6:
  rts                          ; $DCC6
Loc_DCC7:
  sta z:$00                    ; $DCC7
  lda z:$2A,x                  ; $DCC9
  bne Loc_DCDD                 ; $DCCB
  sty z:$2A,x                  ; $DCCD
  lda z:RiderPitch,x           ; $DCCF
  cmp z:$00                    ; $DCD1
  beq Loc_DCDD                 ; $DCD3
  bcc Loc_DCDB                 ; $DCD5
  dec z:RiderPitch,x           ; $DCD7
  dec z:RiderPitch,x           ; $DCD9
Loc_DCDB:
  inc z:RiderPitch,x           ; $DCDB
Loc_DCDD:
  rts                          ; $DCDD
RiderPitchTimer:
  lda $0374,x                  ; $DCDE
  beq Loc_DCF1                 ; $DCE1
  dec $0374,x                  ; $DCE3
  lda z:RiderInput,x           ; $DCE6
  and #$C0                     ; $DCE8
  beq Loc_DCF1                 ; $DCEA
  lda #$00                     ; $DCEC
  sta $0374,x                  ; $DCEE
Loc_DCF1:
  rts                          ; $DCF1
RiderLaunchUpdate:
  lda z:RiderAirborne,x        ; $DCF2
  beq Loc_DD37                 ; $DCF4
  cmp #$02                     ; $DCF6
  beq Loc_DD11                 ; $DCF8
Loc_DCFA:
  lda #$00                     ; $DCFA
  beq Loc_DD08                 ; $DCFC
Loc_DCFE:
  lda z:RiderCrash,x           ; $DCFE
  bne Loc_DCFA                 ; $DD00
  inc z:RiderSpeedHi,x         ; $DD02
  bne Loc_DCFA                 ; $DD04
RiderStartJump:
  lda z:RiderSpeedHi,x         ; $DD06
Loc_DD08:
  sta $0384,x                  ; $DD08
  jsr RiderJumpSetup           ; $DD0B
  jmp Loc_DD1A                 ; $DD0E
Loc_DD11:
  lda z:RiderInput,x           ; $DD11
  lsr a                        ; $DD13
  bcc Loc_DD1A                 ; $DD14
  lda z:FrameMod4              ; $DD16
  beq Loc_DD37                 ; $DD18
Loc_DD1A:
  lda z:RiderInput,x           ; $DD1A
  and #$03                     ; $DD1C
  tay                          ; $DD1E
  lda Data_D868,y              ; $DD1F
  sta $038C,x                  ; $DD22
  lda z:RiderScreenY,x         ; $DD25
  sta z:$01                    ; $DD27
  jsr JumpArcStep              ; $DD29
  sta z:RiderScreenY,x         ; $DD2C
  lda z:$CC,x                  ; $DD2E
  bne Loc_DD37                 ; $DD30
  lda #$01                     ; $DD32
  sta $0364,x                  ; $DD34
Loc_DD37:
  rts                          ; $DD37
RiderJumpSetup:
  lda #$02                     ; $DD38
  sta z:RiderAirborne,x        ; $DD3A
  lda #$0F                     ; $DD3C
  sta $0380,x                  ; $DD3E
  lda z:RiderSpeedLo,x         ; $DD41
  clc                          ; $DD43
  adc #$AF                     ; $DD44
  sta $0378,x                  ; $DD46
  lda z:RiderSpeedHi,x         ; $DD49
  adc #$00                     ; $DD4B
  sta $037C,x                  ; $DD4D
  lda $0388,x                  ; $DD50
  cmp #$02                     ; $DD53
  bne Loc_DD5D                 ; $DD55
  lsr $037C,x                  ; $DD57
  ror $0378,x                  ; $DD5A
Loc_DD5D:
  txa                          ; $DD5D
  bne Loc_DD6E                 ; $DD5E
  lda z:RiderSpeedHi,x         ; $DD60
  asl a                        ; $DD62
  asl a                        ; $DD63
  asl a                        ; $DD64
  asl a                        ; $DD65
  eor #$30                     ; $DD66
  bne Loc_DD6C                 ; $DD68
  lda #$08                     ; $DD6A
Loc_DD6C:
  sta z:SfxPulse1Request       ; $DD6C
Loc_DD6E:
  rts                          ; $DD6E
JumpArcStep:
  lda $0380,x                  ; $DD6F
  adc $038C,x                  ; $DD72
  sta $0380,x                  ; $DD75
  lda $0384,x                  ; $DD78
  adc #$00                     ; $DD7B
  sta $0384,x                  ; $DD7D
  lda z:$01                    ; $DD80
  sbc $037C,x                  ; $DD82
  sta z:$01                    ; $DD85
  lda z:$01                    ; $DD87
  adc $0384,x                  ; $DD89
Loc_DD8C:
  rts                          ; $DD8C
OverheatUpdate:
  lda z:$3C                    ; $DD8D
  ora $03E0                    ; $DD8F
  beq Loc_DD8C                 ; $DD92
  lda z:$3C                    ; $DD94
  cmp #$08                     ; $DD96
  beq Loc_DDBF                 ; $DD98
  bcc Loc_DDCE                 ; $DD9A
  lda z:RiderSpeedHi           ; $DD9C
  ora z:RiderCrash             ; $DD9E
  ora z:RiderState             ; $DDA0
  bne Loc_DDBC                 ; $DDA2
  lda z:$58                    ; $DDA4
  beq Loc_DDAE                 ; $DDA6
  lda #$C0                     ; $DDA8
  sta z:RiderSpeedLo           ; $DDAA
  bne Loc_DDBC                 ; $DDAC
Loc_DDAE:
  sta z:RiderSpeedLo           ; $DDAE
  ldx #$01                     ; $DDB0
  lda z:RiderY                 ; $DDB2
  cmp Data_D8C4                ; $DDB4
  bne Loc_DDBA                 ; $DDB7
  dex                          ; $DDB9
Loc_DDBA:
  stx z:RiderLaneStep          ; $DDBA
Loc_DDBC:
  jmp Loc_CCDD                 ; $DDBC
Loc_DDBF:
  lda #$00                     ; $DDBF
  sta $03E0                    ; $DDC1
  lda #$05                     ; $DDC4
  sta $03B6                    ; $DDC6
  sta z:RiderState             ; $DDC9
  sta $0374                    ; $DDCB
Loc_DDCE:
  jmp Loc_CD13                 ; $DDCE
RiderCrashUpdate:
  ldx #$03                     ; $DDD1
Loc_DDD3:
  lda z:RiderCrash,x           ; $DDD3
  beq Loc_DE2D                 ; $DDD5
  ldy #$04                     ; $DDD7
  txa                          ; $DDD9
  bne Loc_DDEE                 ; $DDDA
  sta $03A9                    ; $DDDC
  sta z:EngineSoundRequest     ; $DDDF
  lda z:FrameMod4              ; $DDE1
  bne Loc_DDE9                 ; $DDE3
  lda #$01                     ; $DDE5
  sta z:SfxNoiseRequest        ; $DDE7
Loc_DDE9:
  lda z:$1B                    ; $DDE9
  and #$03                     ; $DDEB
  tay                          ; $DDED
Loc_DDEE:
  tya                          ; $DDEE
  sta $03E4,x                  ; $DDEF
  lda z:FrameMod4              ; $DDF2
  lsr a                        ; $DDF4
  bcs Loc_DE2D                 ; $DDF5
  lda z:RiderSpeedHi,x         ; $DDF7
  bne Loc_DE24                 ; $DDF9
  lda z:RiderAirborne,x        ; $DDFB
  ora z:$58,x                  ; $DDFD
  bne Loc_DE20                 ; $DDFF
  sta z:RiderSpeedLo,x         ; $DE01
  sta z:RiderMoveX,x           ; $DE03
  sta z:RiderCrash,x           ; $DE05
  lda #$06                     ; $DE07
  sta z:RiderPitch,x           ; $DE09
  lda z:RiderXLo,x             ; $DE0B
  clc                          ; $DE0D
  adc #$08                     ; $DE0E
  sta $0390,x                  ; $DE10
  jsr ComputeRiderShadowY      ; $DE13
  lda #$02                     ; $DE16
  sta $0398,x                  ; $DE18
  lsr a                        ; $DE1B
  sta z:RiderState,x           ; $DE1C
  bne Loc_DE2D                 ; $DE1E
Loc_DE20:
  lda #$88                     ; $DE20
  sta z:RiderSpeedLo,x         ; $DE22
Loc_DE24:
  lda z:RiderPitch,x           ; $DE24
  clc                          ; $DE26
  adc z:RiderCrash,x           ; $DE27
  and #$0F                     ; $DE29
  sta z:RiderPitch,x           ; $DE2B
Loc_DE2D:
  dex                          ; $DE2D
  bpl Loc_DDD3                 ; $DE2E
  rts                          ; $DE30
UpdateExhaustSprites:
  lda z:$24                    ; $DE31
  cmp #$01                     ; $DE33
  beq Loc_DEA6                 ; $DE35
  ldy z:RaceStarted            ; $DE37
  bne Loc_DEA5                 ; $DE39
  cmp #$60                     ; $DE3B
  bcs Loc_DE4E                 ; $DE3D
  lda $03A9                    ; $DE3F
  beq Loc_DE4E                 ; $DE42
  lda z:RiderInput             ; $DE44
  and #$C0                     ; $DE46
  beq Loc_DE4E                 ; $DE48
  lda #$01                     ; $DE4A
  sta z:SfxPulse2Request       ; $DE4C
Loc_DE4E:
  ldy #$F0                     ; $DE4E
  lda z:$24                    ; $DE50
  cmp #$10                     ; $DE52
  bcs Loc_DE5E                 ; $DE54
  ldy #$F2                     ; $DE56
  cmp #$08                     ; $DE58
  bcs Loc_DE5E                 ; $DE5A
  ldy #$F4                     ; $DE5C
Loc_DE5E:
  cmp #$72                     ; $DE5E
  bne Loc_DE66                 ; $DE60
  lda #$20                     ; $DE62
  sta z:MusicRequest           ; $DE64
Loc_DE66:
  sty z:$00                    ; $DE66
  lda $03B4                    ; $DE68
  sta z:$01                    ; $DE6B
  ldy #$07                     ; $DE6D
Loc_DE6F:
  tya                          ; $DE6F
  asl a                        ; $DE70
  asl a                        ; $DE71
  tax                          ; $DE72
  lda Data_D8E7,y              ; $DE73
  sta $02C0,x                  ; $DE76
  lda z:$00                    ; $DE79
  sta $02C1,x                  ; $DE7B
  lda #$00                     ; $DE7E
  sta $02C2,x                  ; $DE80
  lda z:$01                    ; $DE83
  sta $02C3,x                  ; $DE85
  tya                          ; $DE88
  lsr a                        ; $DE89
  bcc Loc_DE91                 ; $DE8A
  inc $02C1,x                  ; $DE8C
  bne Loc_DE9A                 ; $DE8F
Loc_DE91:
  lda z:$01                    ; $DE91
  sec                          ; $DE93
  sbc #$10                     ; $DE94
  sta z:$01                    ; $DE96
  bcc Loc_DE9D                 ; $DE98
Loc_DE9A:
  dey                          ; $DE9A
  bpl Loc_DE6F                 ; $DE9B
Loc_DE9D:
  lda z:$34                    ; $DE9D
  beq Loc_DEA5                 ; $DE9F
  lda #$88                     ; $DEA1
  sta z:$24                    ; $DEA3
Loc_DEA5:
  rts                          ; $DEA5
Loc_DEA6:
  lda #$01                     ; $DEA6
  sta z:RaceStarted            ; $DEA8
  lda $03B4                    ; $DEAA
  sec                          ; $DEAD
  sbc z:RiderMoveX             ; $DEAE
  sta $03B4                    ; $DEB0
  bcc Loc_DEA5                 ; $DEB3
  lda #$02                     ; $DEB5
  sta z:$24                    ; $DEB7
  bne Loc_DE4E                 ; $DEB9
CheckTrackEdge:
  ldx #$03                     ; $DEBB
Loc_DEBD:
  lda z:RiderXHi,x             ; $DEBD
  lsr a                        ; $DEBF
  bcc Loc_DEDE                 ; $DEC0
  lda z:RiderXLo,x             ; $DEC2
  cmp #$30                     ; $DEC4
  bcc Loc_DECC                 ; $DEC6
  cmp #$40                     ; $DEC8
  bcc Loc_DED9                 ; $DECA
Loc_DECC:
  lda $03A9,x                  ; $DECC
  beq Loc_DEDE                 ; $DECF
  lda #$40                     ; $DED1
  sta z:SfxPulse1Request       ; $DED3
  lda #$00                     ; $DED5
  beq Loc_DEDB                 ; $DED7
Loc_DED9:
  lda #$01                     ; $DED9
Loc_DEDB:
  sta $03A9,x                  ; $DEDB
Loc_DEDE:
  dex                          ; $DEDE
  bne Loc_DEBD                 ; $DEDF
  rts                          ; $DEE1
UpdateEngineSound:
  ldx #$00                     ; $DEE2
  lda $03A9                    ; $DEE4
  beq Loc_DF2D                 ; $DEE7
  lda z:FrameMod4              ; $DEE9
  lsr a                        ; $DEEB
  bcs Loc_DEA5                 ; $DEEC
  ldx #$02                     ; $DEEE
  lda z:RiderSpeedHi           ; $DEF0
  sta z:$00                    ; $DEF2
  lda z:RiderSpeedLo           ; $DEF4
  sta z:$01                    ; $DEF6
Loc_DEF8:
  lsr z:$00                    ; $DEF8
  ror z:$01                    ; $DEFA
  dex                          ; $DEFC
  bpl Loc_DEF8                 ; $DEFD
  lda #$02                     ; $DEFF
  ldy z:RiderAirborne          ; $DF01
  beq Loc_DF07                 ; $DF03
  lda #$04                     ; $DF05
Loc_DF07:
  tax                          ; $DF07
  lda z:$01                    ; $DF08
  sec                          ; $DF0A
  sbc #$02                     ; $DF0B
  bmi Loc_DF15                 ; $DF0D
  jsr DivModByX                ; $DF0F
  txa                          ; $DF12
  bne Loc_DF17                 ; $DF13
Loc_DF15:
  ldx #$01                     ; $DF15
Loc_DF17:
  cpx #$2F                     ; $DF17
  bcc Loc_DF24                 ; $DF19
  ldx #$2F                     ; $DF1B
  lda z:FrameCounter           ; $DF1D
  and #$08                     ; $DF1F
  bne Loc_DF24                 ; $DF21
  dex                          ; $DF23
Loc_DF24:
  lda z:RiderInput             ; $DF24
  asl a                        ; $DF26
  bcs Loc_DF2D                 ; $DF27
  txa                          ; $DF29
  ora #$80                     ; $DF2A
  tax                          ; $DF2C
Loc_DF2D:
  stx z:EngineSoundRequest     ; $DF2D
  rts                          ; $DF2F
UpdateRaceClock:
  lda z:RaceStarted            ; $DF30
  beq Loc_DF51                 ; $DF32
  lda z:$6B                    ; $DF34
  clc                          ; $DF36
  adc #$10                     ; $DF37
  sta z:$6B                    ; $DF39
Loc_DF3B:
  lda z:$6B                    ; $DF3B
  cmp #$0A                     ; $DF3D
  bcs Loc_DF52                 ; $DF3F
Loc_DF41:
  ldx #$68                     ; $DF41
  jsr SplitDigits3             ; $DF43
  ldx #$06                     ; $DF46
Loc_DF48:
  lda $03D1,x                  ; $DF48
  sta $03D9,x                  ; $DF4B
  dex                          ; $DF4E
  bpl Loc_DF48                 ; $DF4F
Loc_DF51:
  rts                          ; $DF51
Loc_DF52:
  lda z:$6B                    ; $DF52
  sec                          ; $DF54
  sbc #$0A                     ; $DF55
  sta z:$6B                    ; $DF57
  inc z:$6A                    ; $DF59
  lda z:$6A                    ; $DF5B
  cmp #$64                     ; $DF5D
  bcc Loc_DF3B                 ; $DF5F
  lda #$00                     ; $DF61
  sta z:$6A                    ; $DF63
  inc z:$69                    ; $DF65
  lda z:$69                    ; $DF67
  cmp #$3C                     ; $DF69
  bcc Loc_DF3B                 ; $DF6B
  lda #$00                     ; $DF6D
  sta z:$69                    ; $DF6F
  inc z:$68                    ; $DF71
  lda z:$68                    ; $DF73
  cmp #$09                     ; $DF75
  bcc Loc_DF3B                 ; $DF77
  lda #$02                     ; $DF79
  sta z:RaceEndState           ; $DF7B
  bne Loc_DF41                 ; $DF7D
SplitDigits3:
  lda z:$00,x                  ; $DF7F
  pha                          ; $DF81
  lda z:$01,x                  ; $DF82
  pha                          ; $DF84
  lda z:$02,x                  ; $DF85
  jsr DivMod10                 ; $DF87
  stx $03D6                    ; $DF8A
  sta $03D7                    ; $DF8D
  pla                          ; $DF90
  jsr DivMod10                 ; $DF91
  stx $03D3                    ; $DF94
  sta $03D4                    ; $DF97
  pla                          ; $DF9A
  jsr DivMod10                 ; $DF9B
  sta $03D1                    ; $DF9E
  rts                          ; $DFA1
DivMod10:
  ldx #$0A                     ; $DFA2
DivModByX:
  stx z:$0F                    ; $DFA4
  ldx #$00                     ; $DFA6
Loc_DFA8:
  inx                          ; $DFA8
  sec                          ; $DFA9
  sbc z:$0F                    ; $DFAA
  bpl Loc_DFA8                 ; $DFAC
  dex                          ; $DFAE
  adc z:$0F                    ; $DFAF
  rts                          ; $DFB1
RiderLaneFromY:
  ldy #$00                     ; $DFB2
  lda z:RiderState,x           ; $DFB4
  bne Loc_DFD1                 ; $DFB6
  lda z:RiderY,x               ; $DFB8
Loc_DFBA:
  cmp Data_D913,y              ; $DFBA
  bmi Loc_DFC6                 ; $DFBD
  iny                          ; $DFBF
  cpy #$05                     ; $DFC0
  bmi Loc_DFBA                 ; $DFC2
  ldy #$00                     ; $DFC4
Loc_DFC6:
  tya                          ; $DFC6
  beq Loc_DFD1                 ; $DFC7
  lda #$01                     ; $DFC9
  cmp z:RiderTerrainState,x    ; $DFCB
  bne Loc_DFD1                 ; $DFCD
  iny                          ; $DFCF
  iny                          ; $DFD0
Loc_DFD1:
  tya                          ; $DFD1
  sta z:RiderLane,x            ; $DFD2
  rts                          ; $DFD4
RiderCollisions:
  ldx #$00                     ; $DFD5
  ldy #$01                     ; $DFD7
Loc_DFD9:
  lda z:RiderActive,x          ; $DFD9
  bne Loc_DFE0                 ; $DFDB
Loc_DFDD:
  jmp Loc_E086                 ; $DFDD
Loc_DFE0:
  lda a:RiderActive,y          ; $DFE0
  beq Loc_E01D                 ; $DFE3
  lda z:RiderXHi,x             ; $DFE5
  lsr a                        ; $DFE7
  bcc Loc_DFDD                 ; $DFE8
  lda a:RiderXHi,y             ; $DFEA
  lsr a                        ; $DFED
  bcc Loc_E01D                 ; $DFEE
  lda z:RiderLane,x            ; $DFF0
  beq Loc_DFDD                 ; $DFF2
  cmp a:RiderLane,y            ; $DFF4
  bne Loc_E01D                 ; $DFF7
  lda z:RiderCrash,x           ; $DFF9
  ora $03E0,x                  ; $DFFB
  bne Loc_DFDD                 ; $DFFE
  lda a:RiderCrash,y           ; $E000
  bne Loc_E07E                 ; $E003
  lda z:RiderAirborne,x        ; $E005
  bne Loc_E00E                 ; $E007
  lda a:RiderAirborne,y        ; $E009
  beq Loc_E02A                 ; $E00C
Loc_E00E:
  lda z:RiderScreenY,x         ; $E00E
  cmp a:RiderScreenY,y         ; $E010
  bcs Loc_E020                 ; $E013
  jsr AddCollisionHeight       ; $E015
  cmp a:RiderScreenY,y         ; $E018
  bcs Loc_E02A                 ; $E01B
Loc_E01D:
  jmp Loc_E07E                 ; $E01D
Loc_E020:
  lda a:RiderScreenY,y         ; $E020
  jsr AddCollisionHeight       ; $E023
  cmp z:RiderScreenY,x         ; $E026
  bcc Loc_E07E                 ; $E028
Loc_E02A:
  lda z:RiderXLo,x             ; $E02A
  cmp a:RiderXLo,y             ; $E02C
  bcs Loc_E045                 ; $E02F
  jsr AddCollisionWidth        ; $E031
  cmp a:RiderXLo,y             ; $E034
  bcs Loc_E061                 ; $E037
  lda z:RiderXLo,x             ; $E039
  jsr AddCollisionHeight       ; $E03B
  cmp a:RiderXLo,y             ; $E03E
  bcs Loc_E05B                 ; $E041
  bcc Loc_E07E                 ; $E043
Loc_E045:
  lda a:RiderXLo,y             ; $E045
  jsr AddCollisionWidth        ; $E048
  cmp z:RiderXLo,x             ; $E04B
  bcs Loc_E061                 ; $E04D
  lda a:RiderXLo,y             ; $E04F
  jsr AddCollisionHeight       ; $E052
  cmp z:RiderXLo,x             ; $E055
  bcs Loc_E065                 ; $E057
  bcc Loc_E07E                 ; $E059
Loc_E05B:
  lda #$FF                     ; $E05B
  sta z:RiderCrash,x           ; $E05D
  bne Loc_E076                 ; $E05F
Loc_E061:
  lda #$FF                     ; $E061
  sta z:RiderCrash,x           ; $E063
Loc_E065:
  cpx #$00                     ; $E065
  bne Loc_E071                 ; $E067
  cpy #$03                     ; $E069
  bne Loc_E071                 ; $E06B
  lda #$10                     ; $E06D
  sta z:$3B                    ; $E06F
Loc_E071:
  lda #$FF                     ; $E071
  sta a:RiderCrash,y           ; $E073
Loc_E076:
  cpx #$00                     ; $E076
  bne Loc_E07E                 ; $E078
  lda #$01                     ; $E07A
  sta z:SfxNoiseRequest        ; $E07C
Loc_E07E:
  iny                          ; $E07E
  cpy #$04                     ; $E07F
  beq Loc_E086                 ; $E081
  jmp Loc_DFE0                 ; $E083
Loc_E086:
  inx                          ; $E086
  txa                          ; $E087
  tay                          ; $E088
  iny                          ; $E089
  cpx #$03                     ; $E08A
  beq Loc_E097                 ; $E08C
  jmp Loc_DFD9                 ; $E08E
AddCollisionHeight:
  cmp #$E7                     ; $E091
  bcs Loc_E097                 ; $E093
  adc #$0C                     ; $E095
Loc_E097:
  rts                          ; $E097
AddCollisionWidth:
  cmp #$E7                     ; $E098
  bcs Loc_E09E                 ; $E09A
  adc #$02                     ; $E09C
Loc_E09E:
  rts                          ; $E09E
BikeVsObstacleCheck:
  lda z:RiderState             ; $E09F
  bne Loc_E0E5                 ; $E0A1
  tax                          ; $E0A3
  lda z:$87                    ; $E0A4
  lsr a                        ; $E0A6
  bcc Loc_E0E5                 ; $E0A7
  lda $0373                    ; $E0A9
  beq Loc_E0E5                 ; $E0AC
  lda z:RiderY                 ; $E0AE
  sec                          ; $E0B0
  sbc #$03                     ; $E0B1
  cmp z:$6F                    ; $E0B3
  bcs Loc_E0E5                 ; $E0B5
  adc #$07                     ; $E0B7
  cmp z:$6F                    ; $E0B9
  bcc Loc_E0E5                 ; $E0BB
  lda z:RiderXLo               ; $E0BD
  cmp $0393                    ; $E0BF
  bcs Loc_E0E5                 ; $E0C2
  adc #$12                     ; $E0C4
  cmp $0393                    ; $E0C6
  bcc Loc_E0E5                 ; $E0C9
  jsr RiderBaseY               ; $E0CB
  sec                          ; $E0CE
  sbc #$08                     ; $E0CF
  cmp z:RiderScreenY           ; $E0D1
  bcs Loc_E0E5                 ; $E0D3
  ldy #$FF                     ; $E0D5
  sty z:RiderCrash             ; $E0D7
  iny                          ; $E0D9
  sty z:$DF                    ; $E0DA
  iny                          ; $E0DC
  sty z:$9F                    ; $E0DD
  sty z:SfxNoiseRequest        ; $E0DF
  iny                          ; $E0E1
  sty $039B                    ; $E0E2
Loc_E0E5:
  rts                          ; $E0E5
  lda z:$3A                    ; $E0E6
  ora z:RaceEndState           ; $E0E8
  ora z:$24                    ; $E0EA
  bne Loc_E09E                 ; $E0EC
  lda $03A0                    ; $E0EE
  bne Loc_E10A                 ; $E0F1
  lda z:$2E                    ; $E0F3
  bne Loc_E09E                 ; $E0F5
  lda z:RandomState            ; $E0F7
  and #$03                     ; $E0F9
  tax                          ; $E0FB
  lda Data_D8F3,x              ; $E0FC
  sta $03A1                    ; $E0FF
  lda #$F8                     ; $E102
  sta $03B9                    ; $E104
  sta $03A0                    ; $E107
Loc_E10A:
  lda #$50                     ; $E10A
  sta z:$01                    ; $E10C
  lda $03B9                    ; $E10E
  sec                          ; $E111
  sbc z:RiderMoveX             ; $E112
  sta $03B9                    ; $E114
  lda z:RiderMoveX             ; $E117
  beq Loc_E124                 ; $E119
  lda z:FrameCounter           ; $E11B
  and #$0F                     ; $E11D
  bne Loc_E124                 ; $E11F
  dec $03B9                    ; $E121
Loc_E124:
  lda $03B9                    ; $E124
  sta z:$00                    ; $E127
  cmp #$FC                     ; $E129
  bcc Loc_E139                 ; $E12B
  lda z:RandomState            ; $E12D
  and #$A0                     ; $E12F
  sta z:$2E                    ; $E131
  lda #$00                     ; $E133
  sta $03A0                    ; $E135
  rts                          ; $E138
Loc_E139:
  lda $03A1                    ; $E139
  sta z:$02                    ; $E13C
  lda #$22                     ; $E13E
  sta z:$03                    ; $E140
  lda #$C0                     ; $E142
  sta z:$04                    ; $E144
  lda #$20                     ; $E146
  sta z:$0B                    ; $E148
  jsr DrawMetasprite           ; $E14A
  lda $03B9                    ; $E14D
  cmp #$60                     ; $E150
  bcs Loc_E17E                 ; $E152
  ldx $03A1                    ; $E154
  inx                          ; $E157
  inx                          ; $E158
  inx                          ; $E159
  stx z:$00                    ; $E15A
  jsr Sub_E16C                 ; $E15C
  ldx $03A1                    ; $E15F
  inx                          ; $E162
  stx z:$00                    ; $E163
  lda z:$04                    ; $E165
  clc                          ; $E167
  adc #$08                     ; $E168
  sta z:$04                    ; $E16A
Sub_E16C:
  ldy #$06                     ; $E16C
Loc_E16E:
  lda #$60                     ; $E16E
  sta ($04),y                  ; $E170
  dey                          ; $E172
  lda z:$00                    ; $E173
  sta ($04),y                  ; $E175
  dec z:$00                    ; $E177
  dey                          ; $E179
  dey                          ; $E17A
  dey                          ; $E17B
  bpl Loc_E16E                 ; $E17C
Loc_E17E:
  rts                          ; $E17E
