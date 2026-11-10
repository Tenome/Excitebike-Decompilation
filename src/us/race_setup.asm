; Module race_setup: $C7DE-
.segment "PRG"


; Menu cursor handler: A = number of items; moves MenuCursor with up/down/select, Start confirms.
MenuHandleInput:
  sta z:$00                    ; $C7DE
  ldy z:MenuCursor             ; $C7E0
  ldx #$00                     ; $C7E2
  lda z:Joy1Trigger            ; $C7E4
  and #$3C                     ; $C7E6
  bne Loc_C7ED                 ; $C7E8
  sta z:InputLatch             ; $C7EA
Loc_C7EC:
  rts                          ; $C7EC
Loc_C7ED:
  lda #$5D                     ; $C7ED
  sta z:$31                    ; $C7EF
  lda z:InputLatch             ; $C7F1
  bne Loc_C7EC                 ; $C7F3
  lda z:Joy1Trigger            ; $C7F5
  bit Data_C0CE                ; $C7F7
  bne Loc_C80A                 ; $C7FA
  lsr a                        ; $C7FC
  lsr a                        ; $C7FD
  lsr a                        ; $C7FE
  bcs Loc_C80A                 ; $C7FF
  lsr a                        ; $C801
  bcs Loc_C811                 ; $C802
  ldx #$04                     ; $C804
  stx z:$30                    ; $C806
  bne Loc_C81B                 ; $C808
Loc_C80A:
  iny                          ; $C80A
  cpy z:$00                    ; $C80B
  bcc Loc_C817                 ; $C80D
  ldy #$01                     ; $C80F
Loc_C811:
  dey                          ; $C811
  bpl Loc_C817                 ; $C812
  ldy z:$00                    ; $C814
  dey                          ; $C816
Loc_C817:
  lda #$01                     ; $C817
  sta z:SfxPulse1Request       ; $C819
Loc_C81B:
  sty z:MenuCursor             ; $C81B
  inc z:InputLatch             ; $C81D
  rts                          ; $C81F
  jsr ClearRiderSprites        ; $C820
  lda #$03                     ; $C823
  sta z:$01                    ; $C825
  lsr a                        ; $C827
  sta z:PpuUpdateIndex         ; $C828
  lsr a                        ; $C82A
  sta z:$00                    ; $C82B
  sta z:ResultsFlag            ; $C82D
  ldy #$EF                     ; $C82F
Loc_C831:
  sta ($00),y                  ; $C831
  dey                          ; $C833
  cpy #$40                     ; $C834
  bcs Loc_C831                 ; $C836
  ldx #$7F                     ; $C838
Loc_C83A:
  lda #$3B                     ; $C83A
  sta $0400,x                  ; $C83C
  lda #$3D                     ; $C83F
  sta $0480,x                  ; $C841
  sta $0500,x                  ; $C844
  dex                          ; $C847
  bpl Loc_C83A                 ; $C848
  lda #$BF                     ; $C84A
  sta OamBuffer                ; $C84C
  lda #$F7                     ; $C84F
  sta $0203                    ; $C851
  lda #$FF                     ; $C854
  sta $0201                    ; $C856
  lda #$3F                     ; $C859
  sta z:$E8                    ; $C85B
  lsr a                        ; $C85D
  sta z:$E9                    ; $C85E
  lda #$0A                     ; $C860
  sta z:$EB                    ; $C862
  lda #$25                     ; $C864
  sta z:$EA                    ; $C866
  rts                          ; $C868
  lda #$00                     ; $C869
  ldx #$EF                     ; $C86B
Loc_C86D:
  sta z:$00,x                  ; $C86D
  dex                          ; $C86F
  cpx #$4C                     ; $C870
  bne Loc_C86D                 ; $C872
  rts                          ; $C874
  inc z:RaceActive             ; $C875
  inc z:GameStateActive        ; $C877
  lda z:MenuHintTimer          ; $C879
  bne Loc_C87F                 ; $C87B
  lda #$05                     ; $C87D
Loc_C87F:
  sta z:MenuHintTimer          ; $C87F
  lda #$34                     ; $C881
  sta z:$E8                    ; $C883
  lda #$14                     ; $C885
  sta z:$E9                    ; $C887
  lda #$A0                     ; $C889
  sta LandingBaseY             ; $C88B
  lda #$80                     ; $C88E
  sta $03B4                    ; $C890
  sta $03B0                    ; $C893
  lda #$FF                     ; $C896
  sta $03BD                    ; $C898
  ldx #$01                     ; $C89B
  stx RiderGateWait            ; $C89D
  inx                          ; $C8A0
  stx $03BE                    ; $C8A1
  inx                          ; $C8A4
  lda SelectionB               ; $C8A5
  bne Loc_C8AC                 ; $C8A8
  ldx #$00                     ; $C8AA
Loc_C8AC:
  lda Data_C0B4,x              ; $C8AC
  sta z:RiderY,x               ; $C8AF
  lda #$08                     ; $C8B1
  sta z:RiderMoveFraction,x    ; $C8B3
  lda Data_C0B0,x              ; $C8B5
  sta z:RiderTrackPos,x        ; $C8B8
  lda Data_C0B8,x              ; $C8BA
  sta z:RiderXLo,x             ; $C8BD
  lda #$06                     ; $C8BF
  sta z:RiderPitch,x           ; $C8C1
  sta z:RiderTargetSpeedHi,x   ; $C8C3
  lda #$01                     ; $C8C5
  sta z:RiderXHi,x             ; $C8C7
  sta z:RiderActive,x          ; $C8C9
  lda z:$19,x                  ; $C8CB
  lsr a                        ; $C8CD
  sta z:RiderTargetSpeedLo,x   ; $C8CE
  dex                          ; $C8D0
  bpl Loc_C8AC                 ; $C8D1
  lda z:$19,x                  ; $C8D3
  and #$03                     ; $C8D5
  bne Loc_C8DB                 ; $C8D7
  lda #$02                     ; $C8D9
Loc_C8DB:
  tax                          ; $C8DB
  lsr z:RiderTargetSpeedHi,x   ; $C8DC
  lda z:ModeFlagB              ; $C8DE
  beq Loc_C902                 ; $C8E0
  lda z:TrackIndex             ; $C8E2
  cmp #$04                     ; $C8E4
  bne Loc_C902                 ; $C8E6
  ldx #$07                     ; $C8E8
Loc_C8EA:
  lda Data_C158,x              ; $C8EA
  sta PpuBufferLen,x           ; $C8ED
  dex                          ; $C8F0
  bpl Loc_C8EA                 ; $C8F1
  lda $03F3                    ; $C8F3
  jsr DivMod10                 ; $C8F6
  sta $0307                    ; $C8F9
  txa                          ; $C8FC
  beq Loc_C902                 ; $C8FD
  sta $0306                    ; $C8FF
Loc_C902:
  jsr LoadBestTime             ; $C902
  lda z:GameState              ; $C905
  cmp #$08                     ; $C907
  bcc Loc_C90E                 ; $C909
  jsr LoadSavedTime            ; $C90B
Loc_C90E:
  lda LapSpeedScale            ; $C90E
  asl a                        ; $C911
  clc                          ; $C912
  adc z:$06                    ; $C913
  cmp #$3C                     ; $C915
  bcc Loc_C91D                 ; $C917
  sbc #$3C                     ; $C919
  inc z:$05                    ; $C91B
Loc_C91D:
  sta z:$06                    ; $C91D
  lda #$00                     ; $C91F
  sta z:$07                    ; $C921
  lda #$02                     ; $C923
  sta z:$03                    ; $C925
  jsr WriteTimeDigitsToBuffer  ; $C927
  lda #$08                     ; $C92A
WriteTimeTextSaved:
  ldy z:TrackIndex             ; $C92C
  sty z:$02                    ; $C92E
  sta z:$03                    ; $C930
  jsr LoadSavedTimeForIndex    ; $C932
WriteTimeDigitsToBuffer:
  ldx #$05                     ; $C935
  jsr SplitDigits3             ; $C937
  ldx PpuBufferLen             ; $C93A
  ldy #$00                     ; $C93D
Loc_C93F:
  lda $03D1,y                  ; $C93F
  sta $0304,x                  ; $C942
  inx                          ; $C945
  iny                          ; $C946
  cpy #$07                     ; $C947
  bcc Loc_C93F                 ; $C949
WriteTimeTextHeader:
  lda #$0A                     ; $C94B
  jsr AdvanceBufferPos         ; $C94D
  ldy z:$03                    ; $C950
  lda Data_C0EC,y              ; $C952
  sta PpuBuffer,x              ; $C955
  lda Data_C0ED,y              ; $C958
  sta $0302,x                  ; $C95B
  lda #$FB                     ; $C95E
  sta $0305,x                  ; $C960
  sta $0308,x                  ; $C963
  lda #$07                     ; $C966
  sta $0303,x                  ; $C968
  lda #$00                     ; $C96B
  sta $030B,x                  ; $C96D
  rts                          ; $C970
AdvanceBufferPos:
  ldx PpuBufferLen             ; $C971
  clc                          ; $C974
  adc PpuBufferLen             ; $C975
  sta PpuBufferLen             ; $C978
  rts                          ; $C97B
StateDesignFrame:
  jsr SaveInputToRider0        ; $C97C
  jsr DesignModeUpdate         ; $C97F
  jsr ScrollWorld              ; $C982
  jsr ScrollSplitLayer         ; $C985
  jsr AdvanceTrackPositions    ; $C988
  jsr TrackRenderUpdate        ; $C98B
  jsr Sub_F68D                 ; $C98E
  jsr Sub_F755                 ; $C991
  jsr Sub_C229                 ; $C994
Loc_C997:
  jmp WaitSprite0ThenResetScroll ; $C997
StateRaceFrame:
  jsr RacePreUpdate            ; $C99A
  lda PauseFlag                ; $C99D
  ora PauseDebounce            ; $C9A0
  bne Loc_C997                 ; $C9A3
  jsr UpdateRiderStates        ; $C9A5
  jsr OverheatUpdate           ; $C9A8
  jsr RunTrackScripts          ; $C9AB
  jsr RunPendingTrackScripts   ; $C9AE
  lda z:RaceEndState           ; $C9B1
  beq Loc_C9BB                 ; $C9B3
  jsr RaceEndSequence          ; $C9B5
  jmp Loc_C9D5                 ; $C9B8
Loc_C9BB:
  lda SelectionB               ; $C9BB
  beq Loc_C9C9                 ; $C9BE
  jsr SpawnCpuRiders           ; $C9C0
  jsr HandleLostRider          ; $C9C3
  jsr CheckTrackEdge           ; $C9C6
Loc_C9C9:
  jsr UpdateRaceClock          ; $C9C9
  jsr DrawFinishGate           ; $C9CC
  jsr RiderCollisions          ; $C9CF
  jsr BikeVsObstacleCheck      ; $C9D2
Loc_C9D5:
  jsr RiderCrashUpdate         ; $C9D5
  jsr UpdateRiderControls      ; $C9D8
  jsr UpdateRiderY             ; $C9DB
  jsr UpdateExhaustSprites     ; $C9DE
  jsr UpdateRiderGroundDistance ; $C9E1
  jsr DrawJumpShadows          ; $C9E4
  jsr TrackRenderUpdate        ; $C9E7
  jsr DetectRiderOverlap       ; $C9EA
  jsr UpdateEngineSound        ; $C9ED
  jsr UpdateTempGauge          ; $C9F0
  jsr DrawRiders               ; $C9F3
  jsr ErasePassedRiderSprites  ; $C9F6
  jsr MoveRiders               ; $C9F9
  jsr AdvanceTrackPositions    ; $C9FC
  jsr WaitSprite0ThenResetScroll ; $C9FF
  jsr UpdateAiRiders           ; $CA02
  jmp Loc_E42B                 ; $CA05
RacePreUpdate:
  ldx #$03                     ; $CA08
Loc_CA0A:
  jsr SetRiderTargetPitch      ; $CA0A
  jsr RiderLaneFromY           ; $CA0D
  dex                          ; $CA10
  bpl Loc_CA0A                 ; $CA11
  lda DemoMode                 ; $CA13
  bne Loc_CA20                 ; $CA16
  jsr HandlePause              ; $CA18
SaveInputToRider0:
  lda z:Joy1Held               ; $CA1B
  sta z:RiderInput             ; $CA1D
  rts                          ; $CA1F
Loc_CA20:
  lda DemoMode                 ; $CA20
  beq Loc_CA84                 ; $CA23
  lda z:Joy1Trigger            ; $CA25
  asl a                        ; $CA27
  asl a                        ; $CA28
  asl a                        ; $CA29
  bcs ResetGameRam             ; $CA2A
  asl a                        ; $CA2C
  bcc Loc_CA84                 ; $CA2D
  lda #$00                     ; $CA2F
  sta z:MenuCursor             ; $CA31
  sta z:RaceActive             ; $CA33
  jmp Loc_C36A                 ; $CA35
HandlePause:
  lda PauseDebounce            ; $CA38
  bne Loc_CA63                 ; $CA3B
  lda z:Joy1Trigger            ; $CA3D
  and #$10                     ; $CA3F
  beq Loc_CA67                 ; $CA41
  lda $03B0                    ; $CA43
  bne Loc_CA67                 ; $CA46
  lda #$80                     ; $CA48
  sta z:MusicRequest           ; $CA4A
  sta $03B0                    ; $CA4C
  asl a                        ; $CA4F
  sta z:EngineSoundRequest     ; $CA50
  lda PauseFlag                ; $CA52
  eor #$01                     ; $CA55
  sta PauseFlag                ; $CA57
  bne Loc_CA7F                 ; $CA5A
  lda #$0F                     ; $CA5C
  sta APU_SND_CHN              ; $CA5E
  bne Loc_CA7F                 ; $CA61
Loc_CA63:
  dec PauseDebounce            ; $CA63
  rts                          ; $CA66
Loc_CA67:
  sta $03B0                    ; $CA67
  lda PauseFlag                ; $CA6A
  beq Loc_CA84                 ; $CA6D
  lda #$00                     ; $CA6F
  sta APU_SND_CHN              ; $CA71
  lda z:Joy1Trigger            ; $CA74
  and #$0F                     ; $CA76
  beq Loc_CA84                 ; $CA78
  lda PauseDebounce            ; $CA7A
  bne Loc_CA84                 ; $CA7D
Loc_CA7F:
  lda #$28                     ; $CA7F
  sta PauseDebounce            ; $CA81
Loc_CA84:
  rts                          ; $CA84
ResetGameRam:
  lda z:MenuCursor             ; $CA85
  pha                          ; $CA87
  ldx #$FF                     ; $CA88
  lda #$00                     ; $CA8A
Loc_CA8C:
  sta z:$00,x                  ; $CA8C
  dex                          ; $CA8E
  cpx #$20                     ; $CA8F
  bne Loc_CA8C                 ; $CA91
  sta z:EngineSoundRequest     ; $CA93
  inc z:InputLatch             ; $CA95
  pla                          ; $CA97
  sta z:MenuCursor             ; $CA98
  rts                          ; $CA9A
RaceEndSequence:
  lda z:RaceEndTimer           ; $CA9B
  bne Loc_CAAA                 ; $CA9D
  jsr Sub_C3AF                 ; $CA9F
  lda DemoMode                 ; $CAA2
  bne ResetGameRam             ; $CAA5
  sta z:RaceActive             ; $CAA7
Loc_CAA9:
  rts                          ; $CAA9
Loc_CAAA:
  lda #$00                     ; $CAAA
  sta z:EngineSoundRequest     ; $CAAC
  sta EngineRunning            ; $CAAE
  sta RiderOverheated          ; $CAB1
  sta z:OverheatTimer          ; $CAB4
  ldx z:RaceEndState           ; $CAB6
  dex                          ; $CAB8
  bne Loc_CAA9                 ; $CAB9
  lda z:FrameCounter           ; $CABB
  lsr a                        ; $CABD
  bcs Loc_CAF3                 ; $CABE
  lsr a                        ; $CAC0
  bcs Loc_CAF3                 ; $CAC1
  and #$03                     ; $CAC3
  tay                          ; $CAC5
  lda #$3F                     ; $CAC6
  sta $0312                    ; $CAC8
  lda #$00                     ; $CACB
  sta $0313                    ; $CACD
  sta $0319                    ; $CAD0
  lda #$04                     ; $CAD3
  sta $0314                    ; $CAD5
  lda Data_C166,y              ; $CAD8
  sta $0316                    ; $CADB
  lda Data_C170,y              ; $CADE
  sta $0318                    ; $CAE1
  ldy z:TrackIndex             ; $CAE4
  lda Data_C160,y              ; $CAE6
  sta $0315                    ; $CAE9
  lda Data_C16A,y              ; $CAEC
  sta $0317                    ; $CAEF
  rts                          ; $CAF2
Loc_CAF3:
  ldx #$11                     ; $CAF3
  lda z:RaceEndTimer           ; $CAF5
  lsr a                        ; $CAF7
  bcs Loc_CB05                 ; $CAF8
Loc_CAFA:
  ldy #$06                     ; $CAFA
  lda #$FE                     ; $CAFC
Loc_CAFE:
  sta $0304,x                  ; $CAFE
  inx                          ; $CB01
  dey                          ; $CB02
  bpl Loc_CAFE                 ; $CB03
Loc_CB05:
  rts                          ; $CB05
