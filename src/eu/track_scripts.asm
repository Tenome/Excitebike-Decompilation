; Module track_scripts: $E70B-
.segment "PRG"


; Advance each rider's position in the 64-entry track ring by the pixels it moved.
AdvanceTrackPositions:
  ldx #$03                     ; $E70B
Loc_E70D:
  lda z:RiderMoveX,x           ; $E70D
  beq Loc_E72B                 ; $E70F
  lda z:RiderMoveFraction,x    ; $E711
  sec                          ; $E713
  sbc z:RiderMoveX,x           ; $E714
  beq Loc_E71E                 ; $E716
  bmi Loc_E71E                 ; $E718
  sta z:RiderMoveFraction,x    ; $E71A
  bne Loc_E72B                 ; $E71C
Loc_E71E:
  clc                          ; $E71E
  adc #$08                     ; $E71F
  sta z:RiderMoveFraction,x    ; $E721
  inc z:RiderTrackPos,x        ; $E723
  lda z:RiderTrackPos,x        ; $E725
  and #$3F                     ; $E727
  sta z:RiderTrackPos,x        ; $E729
Loc_E72B:
  lda #$00                     ; $E72B
  sta z:RiderTrackFlags,x      ; $E72D
  dex                          ; $E72F
  bpl Loc_E70D                 ; $E730
  rts                          ; $E732
RunTrackScripts:
  ldx #$03                     ; $E733
Loc_E735:
  jsr RunTrackScriptRider      ; $E735
  dex                          ; $E738
  bne Loc_E735                 ; $E739
RunTrackScriptRider:
  lda z:RiderMoveX,x           ; $E73B
  clc                          ; $E73D
  adc z:$C8,x                  ; $E73E
  sta z:$C8,x                  ; $E740
  lda z:$58,x                  ; $E742
  bne Loc_E762                 ; $E744
  lda z:RiderTrackPiece,x      ; $E746
  sec                          ; $E748
  sbc #$40                     ; $E749
  bmi Loc_E753                 ; $E74B
  lsr a                        ; $E74D
  lsr a                        ; $E74E
  cmp #$16                     ; $E74F
  bcc Loc_E754                 ; $E751
Loc_E753:
  rts                          ; $E753
Loc_E754:
  sta z:$58,x                  ; $E754
  inc z:$58,x                  ; $E756
  lda #$00                     ; $E758
  sta z:$C4,x                  ; $E75A
  lda z:RiderMoveFraction,x    ; $E75C
  sta z:$C8,x                  ; $E75E
  dec z:$C8,x                  ; $E760
Loc_E762:
  ldy z:$58,x                  ; $E762
  lda Data_E559,y              ; $E764
  sta z:$0A                    ; $E767
  lda Data_E56E,y              ; $E769
  sta z:$0B                    ; $E76C
  ldy z:$C4,x                  ; $E76E
  lda ($0A),y                  ; $E770
  cmp #$FF                     ; $E772
  beq Loc_E7D0                 ; $E774
  sta z:$0F                    ; $E776
  cmp z:$C8,x                  ; $E778
  beq Loc_E77E                 ; $E77A
  bcs Loc_E753                 ; $E77C
Loc_E77E:
  iny                          ; $E77E
  lda ($0A),y                  ; $E77F
  bit Data_E703                ; $E781
  bne Loc_E7A3                 ; $E784
  bit Data_E6FB                ; $E786
  bne Loc_E7F2                 ; $E789
  jsr TrackScriptOpcode        ; $E78B
  inc z:$C4,x                  ; $E78E
  inc z:$C4,x                  ; $E790
  bne Loc_E762                 ; $E792
TrackScriptOpcode:
  asl a                        ; $E794
  tay                          ; $E795
  lda Data_E6B7,y              ; $E796
  sta z:$00                    ; $E799
  lda Data_E6B8,y              ; $E79B
  sta z:$01                    ; $E79E
  jmp ($0000)                  ; $E7A0
Loc_E7A3:
  lda z:RiderAirborne,x        ; $E7A3
  ora z:RiderCrash,x           ; $E7A5
  bne Loc_E7CA                 ; $E7A7
  lda ($0A),y                  ; $E7A9
  and #$0F                     ; $E7AB
  sta z:$00                    ; $E7AD
  lda z:RiderTerrainState,x    ; $E7AF
  cmp #$01                     ; $E7B1
  beq Loc_E7CA                 ; $E7B3
  lda z:$00                    ; $E7B5
  sta z:RiderPitch,x           ; $E7B7
  lda z:$58,x                  ; $E7B9
  cmp #$03                     ; $E7BB
  beq Loc_E7CA                 ; $E7BD
  lda z:RiderPitch,x           ; $E7BF
  sec                          ; $E7C1
  sbc #$02                     ; $E7C2
  tay                          ; $E7C4
  lda Data_E6AD,y              ; $E7C5
  sta z:$D4,x                  ; $E7C8
Loc_E7CA:
  inc z:$C4,x                  ; $E7CA
  inc z:$C4,x                  ; $E7CC
  bne Loc_E762                 ; $E7CE
Loc_E7D0:
  lda #$00                     ; $E7D0
  sta z:$58,x                  ; $E7D2
  sta z:$D4,x                  ; $E7D4
  lda z:RiderBumpState,x       ; $E7D6
  bne Loc_E7EC                 ; $E7D8
  lda z:RiderTerrainState,x    ; $E7DA
  cmp #$01                     ; $E7DC
  beq Loc_E7EC                 ; $E7DE
  lda #$00                     ; $E7E0
  sta z:RiderHeight,x          ; $E7E2
  lda z:RiderTerrainState,x    ; $E7E4
  cmp #$02                     ; $E7E6
  bne Loc_E7EC                 ; $E7E8
  inc z:RiderTerrainState,x    ; $E7EA
Loc_E7EC:
  lda #$00                     ; $E7EC
  sta $036C,x                  ; $E7EE
  rts                          ; $E7F1
Loc_E7F2:
  and #$0F                     ; $E7F2
  sta z:$CC,x                  ; $E7F4
  lda z:$0F                    ; $E7F6
  sta z:$D0,x                  ; $E7F8
  bpl Loc_E7CA                 ; $E7FA
TrackPieceAtRiderLane:
  ldy $0360,x                  ; $E7FC
TrackPieceAtRow:
  lda z:RiderTrackPos,x        ; $E7FF
  sta z:$08                    ; $E801
TrackPieceAt:
  jsr SetTrackRowPointer       ; $E803
  sty z:$07                    ; $E806
  ldy z:$08                    ; $E808
  lda ($03),y                  ; $E80A
  rts                          ; $E80C
SetTrackRowPointer:
  lda Data_E54E,y              ; $E80D
  sta z:$03                    ; $E810
  lda Data_E554,y              ; $E812
  sta z:$04                    ; $E815
  rts                          ; $E817
Sub_E818:
  lda z:RiderAirborne,x        ; $E818
  bne Loc_E835                 ; $E81A
  lda z:RiderPitch,x           ; $E81C
  cmp #$07                     ; $E81E
  bpl Loc_E835                 ; $E820
  lda z:RiderSpeedHi,x         ; $E822
  cmp #$03                     ; $E824
  bcs Loc_E831                 ; $E826
  cmp #$02                     ; $E828
  bne Loc_E835                 ; $E82A
  lda z:RiderSpeedLo,x         ; $E82C
  asl a                        ; $E82E
  bcc Loc_E835                 ; $E82F
Loc_E831:
  lda #$FF                     ; $E831
  sta z:RiderCrash,x           ; $E833
Loc_E835:
  rts                          ; $E835
UpdateRiderGroundDistance:
  ldx #$03                     ; $E836
Loc_E838:
  lda z:RiderAirborne,x        ; $E838
  bne Loc_E841                 ; $E83A
  jsr RiderBaseY               ; $E83C
  sta z:RiderScreenY,x         ; $E83F
Loc_E841:
  dex                          ; $E841
  bpl Loc_E838                 ; $E842
  rts                          ; $E844
Sub_E845:
  lda #$80                     ; $E845
  sta z:RiderTrackFlags,x      ; $E847
  lda #$05                     ; $E849
  jsr TrackScriptSetHeight     ; $E84B
  lsr a                        ; $E84E
Sub_E84F:
  sta z:RiderHeight,x          ; $E84F
  sta z:$E4,x                  ; $E851
  rts                          ; $E853
Sub_E854:
  lda #$02                     ; $E854
  jsr TrackScriptSetHeight     ; $E856
  lsr a                        ; $E859
  jmp Sub_E86F                 ; $E85A
Sub_E85D:
  lda #$06                     ; $E85D
  jsr TrackScriptSetHeight     ; $E85F
  jsr Sub_E84F                 ; $E862
  lda #$60                     ; $E865
  sta z:RiderTrackFlags,x      ; $E867
  rts                          ; $E869
Sub_E86A:
  lda #$01                     ; $E86A
  jsr TrackScriptSetHeight     ; $E86C
Sub_E86F:
  sta z:$00                    ; $E86F
  lda z:$E4,x                  ; $E871
  sec                          ; $E873
  sbc z:$00                    ; $E874
  sta z:RiderHeight,x          ; $E876
  rts                          ; $E878
Sub_E879:
  lda #$04                     ; $E879
  jsr TrackScriptSetHeight     ; $E87B
  asl a                        ; $E87E
  jsr Sub_E84F                 ; $E87F
  lda z:RiderBumpState,x       ; $E882
  beq Loc_E88E                 ; $E884
  lda z:RiderHeight,x          ; $E886
  clc                          ; $E888
  adc #$10                     ; $E889
  jsr Sub_E84F                 ; $E88B
Loc_E88E:
  lda #$40                     ; $E88E
  sta z:RiderTrackFlags,x      ; $E890
  rts                          ; $E892
TrackScriptSetHeight:
  sta z:$D4,x                  ; $E893
  sta z:$B4,x                  ; $E895
  lda z:$C8,x                  ; $E897
  sec                          ; $E899
  sbc z:$D0,x                  ; $E89A
  rts                          ; $E89C
Sub_E89D:
  lda z:RiderTerrainState,x    ; $E89D
  beq Loc_E8A5                 ; $E89F
  cmp #$01                     ; $E8A1
  beq Loc_E8BE                 ; $E8A3
Loc_E8A5:
  lda #$03                     ; $E8A5
  jsr TrackScriptSetHeight     ; $E8A7
  asl a                        ; $E8AA
  jsr Sub_E86F                 ; $E8AB
  lda z:RiderTerrainState,x    ; $E8AE
  cmp #$04                     ; $E8B0
  bne Loc_E8BE                 ; $E8B2
  jsr RiderStartJump           ; $E8B4
  lda #$02                     ; $E8B7
  sta z:RiderTerrainState,x    ; $E8B9
  sta $0364,x                  ; $E8BB
Loc_E8BE:
  rts                          ; $E8BE
Sub_E8BF:
  lda #$00                     ; $E8BF
  sta z:RiderTerrainState,x    ; $E8C1
Loc_E8C3:
  sta z:RiderBumpState,x       ; $E8C3
  rts                          ; $E8C5
Sub_E8C6:
  lda #$01                     ; $E8C6
  sta z:RiderTerrainState,x    ; $E8C8
  lda z:RiderY,x               ; $E8CA
  cmp #$20                     ; $E8CC
  bcs Loc_E8D2                 ; $E8CE
  inc z:RiderTerrainState,x    ; $E8D0
Loc_E8D2:
  rts                          ; $E8D2
  txa                          ; $E8D3
  ora z:RiderAirborne,x        ; $E8D4
  ora $03E0                    ; $E8D6
  ora z:$3C                    ; $E8D9
  bne Loc_E8E2                 ; $E8DB
  lda #$08                     ; $E8DD
  sta $03B6                    ; $E8DF
Loc_E8E2:
  rts                          ; $E8E2
Sub_E8E3:
  lda #$01                     ; $E8E3
  bne Loc_E8C3                 ; $E8E5
  lda z:RiderAirborne,x        ; $E8E7
  bne Loc_E8E2                 ; $E8E9
  jmp Loc_DCFE                 ; $E8EB
Sub_E8EE:
  lda #$02                     ; $E8EE
  sta z:RiderBumpState,x       ; $E8F0
  lsr a                        ; $E8F2
  sta z:RiderTrackFlags,x      ; $E8F3
  lda #$30                     ; $E8F5
  jmp Sub_E84F                 ; $E8F7
Sub_E8FA:
  lda #$10                     ; $E8FA
  jmp Sub_E84F                 ; $E8FC
Sub_E8FF:
  lda z:RiderAirborne,x        ; $E8FF
  bne Loc_E926                 ; $E901
  lda z:RiderTerrainState,x    ; $E903
  beq Loc_E90B                 ; $E905
  lsr a                        ; $E907
  lsr a                        ; $E908
  bcc Loc_E926                 ; $E909
Loc_E90B:
  sty z:$01                    ; $E90B
  lda z:RiderSpeedHi,x         ; $E90D
  beq Loc_E924                 ; $E90F
  ldy #$04                     ; $E911
  lda z:RiderInput,x           ; $E913
  asl a                        ; $E915
  asl a                        ; $E916
  bcc Loc_E91A                 ; $E917
  dey                          ; $E919
Loc_E91A:
  lda #$01                     ; $E91A
  sta $036C,x                  ; $E91C
  iny                          ; $E91F
  iny                          ; $E920
  jsr RiderDecelerateBy        ; $E921
Loc_E924:
  ldy z:$01                    ; $E924
Loc_E926:
  rts                          ; $E926
RunPendingTrackScripts:
  ldx #$03                     ; $E927
Loc_E929:
  lda z:$CC,x                  ; $E929
  beq Loc_E930                 ; $E92B
  jsr TrackScriptOpcode        ; $E92D
Loc_E930:
  dex                          ; $E930
  bpl Loc_E929                 ; $E931
Loc_E933:
  rts                          ; $E933
Sub_E934:
  lda z:RiderAirborne,x        ; $E934
  bne Loc_E933                 ; $E936
  ldy #$00                     ; $E938
  lda z:RiderSpeedHi,x         ; $E93A
  beq Loc_E933                 ; $E93C
  cmp #$02                     ; $E93E
  bcs Loc_E949                 ; $E940
  lda z:RiderSpeedLo,x         ; $E942
  cmp z:RiderTrackFlags,x      ; $E944
  bcs Loc_E949                 ; $E946
  iny                          ; $E948
Loc_E949:
  tya                          ; $E949
  sta $0388,x                  ; $E94A
  lda z:RiderBumpState,x       ; $E94D
  cmp #$02                     ; $E94F
  beq Loc_E960                 ; $E951
  jmp Loc_DCFA                 ; $E953
Sub_E956:
  lda z:RiderTerrainState,x    ; $E956
  cmp #$01                     ; $E958
  bne Loc_E933                 ; $E95A
  lda #$00                     ; $E95C
  sta z:RiderHeight,x          ; $E95E
Loc_E960:
  jmp RiderStartJump           ; $E960
Sub_E963:
  lda #$00                     ; $E963
  sta z:$CC,x                  ; $E965
  sta z:$D4,x                  ; $E967
  sta z:$B4,x                  ; $E969
  rts                          ; $E96B
UpdateRiderY:
  ldx #$03                     ; $E96C
Loc_E96E:
  lda z:$58,x                  ; $E96E
  cmp #$15                     ; $E970
  beq Loc_E97F                 ; $E972
  cmp #$14                     ; $E974
  beq Loc_E97F                 ; $E976
  lda z:RiderY,x               ; $E978
  clc                          ; $E97A
  adc z:RiderLaneStep,x        ; $E97B
  sta z:RiderY,x               ; $E97D
Loc_E97F:
  ldy #$03                     ; $E97F
Loc_E981:
  lda z:RiderY,x               ; $E981
  cmp Data_E53D,y              ; $E983
  beq Loc_EA01                 ; $E986
  dey                          ; $E988
  bpl Loc_E981                 ; $E989
  lda z:RiderTerrainState,x    ; $E98B
  beq Loc_E9C4                 ; $E98D
  cmp #$01                     ; $E98F
  bne Loc_E9B8                 ; $E991
  lda z:RiderY,x               ; $E993
  cmp #$20                     ; $E995
  bcs Loc_E9C4                 ; $E997
  lda #$04                     ; $E999
  sta z:RiderTerrainState,x    ; $E99B
  lda z:$58,x                  ; $E99D
  beq Loc_E9AD                 ; $E99F
  cmp #$12                     ; $E9A1
  beq Loc_E9AD                 ; $E9A3
  cmp #$10                     ; $E9A5
  beq Loc_E9AD                 ; $E9A7
  cmp #$0D                     ; $E9A9
  bne Loc_E9E3                 ; $E9AB
Loc_E9AD:
  lda #$00                     ; $E9AD
  sta z:RiderHeight,x          ; $E9AF
  jsr RiderStartJump           ; $E9B1
  dec z:RiderTerrainState,x    ; $E9B4
  bne Loc_E9E3                 ; $E9B6
Loc_E9B8:
  cmp #$03                     ; $E9B8
  beq Loc_E9C4                 ; $E9BA
  lda z:RiderY,x               ; $E9BC
  cmp #$20                     ; $E9BE
  bcc Loc_E9C4                 ; $E9C0
  dec z:RiderY,x               ; $E9C2
Loc_E9C4:
  lda z:RiderY,x               ; $E9C4
  cmp #$08                     ; $E9C6
  bcc Loc_E9E9                 ; $E9C8
  cmp #$3A                     ; $E9CA
  bcc Loc_E9E3                 ; $E9CC
  lda #$39                     ; $E9CE
  sta z:RiderY,x               ; $E9D0
Loc_E9D2:
  lda z:RiderState,x           ; $E9D2
  ora $03E0,x                  ; $E9D4
  bne Loc_E9E3                 ; $E9D7
Loc_E9D9:
  lda z:RiderLaneStep,x        ; $E9D9
  bne Loc_E9DF                 ; $E9DB
  lda #$FF                     ; $E9DD
Loc_E9DF:
  eor #$FE                     ; $E9DF
  sta z:RiderLaneStep,x        ; $E9E1
Loc_E9E3:
  dex                          ; $E9E3
  bmi Loc_EA07                 ; $E9E4
  jmp Loc_E96E                 ; $E9E6
Loc_E9E9:
  lda z:RiderState,x           ; $E9E9
  bne Loc_E9F1                 ; $E9EB
  lda #$07                     ; $E9ED
  bne Loc_E9F9                 ; $E9EF
Loc_E9F1:
  lda z:RiderY,x               ; $E9F1
  cmp #$02                     ; $E9F3
  bcs Loc_E9F9                 ; $E9F5
  lda #$01                     ; $E9F7
Loc_E9F9:
  sta z:RiderY,x               ; $E9F9
  cpx #$00                     ; $E9FB
  beq Loc_E9D9                 ; $E9FD
  bne Loc_E9D2                 ; $E9FF
Loc_EA01:
  lda #$00                     ; $EA01
  sta z:RiderLaneStep,x        ; $EA03
  beq Loc_E9E3                 ; $EA05
Loc_EA07:
  lda z:RaceStarted            ; $EA07
  beq Loc_EA43                 ; $EA09
  lda z:RiderCrash             ; $EA0B
  ora $03E0                    ; $EA0D
  ora $03F7                    ; $EA10
  bne Loc_EA43                 ; $EA13
  lda z:RiderAirborne          ; $EA15
  beq Loc_EA23                 ; $EA17
  lda $0388                    ; $EA19
  cmp #$02                     ; $EA1C
  bne Loc_EA43                 ; $EA1E
  inc $0388                    ; $EA20
Loc_EA23:
  lda z:RiderState             ; $EA23
  beq Loc_EA2B                 ; $EA25
  cmp #$05                     ; $EA27
  bne Loc_EA43                 ; $EA29
Loc_EA2B:
  lda z:Joy1Held               ; $EA2B
  and #$0C                     ; $EA2D
  beq Loc_EA43                 ; $EA2F
  and #$04                     ; $EA31
  bne Loc_EA39                 ; $EA33
  lda #$01                     ; $EA35
  bne Loc_EA3B                 ; $EA37
Loc_EA39:
  lda #$FF                     ; $EA39
Loc_EA3B:
  sta z:RiderLaneStep          ; $EA3B
  lda #$04                     ; $EA3D
  ora z:SfxNoiseRequest        ; $EA3F
  sta z:SfxNoiseRequest        ; $EA41
Loc_EA43:
  rts                          ; $EA43
DrawJumpShadows:
  ldx #$03                     ; $EA44
Loc_EA46:
  txa                          ; $EA46
  asl a                        ; $EA47
  asl a                        ; $EA48
  asl a                        ; $EA49
  tay                          ; $EA4A
  lda z:RiderXHi,x             ; $EA4B
  lsr a                        ; $EA4D
  bcc Loc_EA58                 ; $EA4E
  lda z:RiderXLo,x             ; $EA50
  cmp #$F4                     ; $EA52
  bcc Loc_EA61                 ; $EA54
  bcs Loc_EA88                 ; $EA56
Loc_EA58:
  lsr a                        ; $EA58
  bcs Loc_EA88                 ; $EA59
  lda z:RiderXLo,x             ; $EA5B
  cmp #$F6                     ; $EA5D
  bcc Loc_EA88                 ; $EA5F
Loc_EA61:
  lda z:RiderAirborne,x        ; $EA61
  beq Loc_EA88                 ; $EA63
  lda #$B6                     ; $EA65
  jsr RiderBaseYFrom           ; $EA67
  sta $0294,y                  ; $EA6A
  lda z:RiderXLo,x             ; $EA6D
  clc                          ; $EA6F
  adc #$0A                     ; $EA70
  sta $0297,y                  ; $EA72
  sty z:$01                    ; $EA75
  ldy z:$B4,x                  ; $EA77
  lda Data_E69A,y              ; $EA79
  ldy z:$01                    ; $EA7C
  sta $0295,y                  ; $EA7E
  lda #$00                     ; $EA81
  sta $0296,y                  ; $EA83
  beq Loc_EA8B                 ; $EA86
Loc_EA88:
  jsr DrawSkidSmoke            ; $EA88
Loc_EA8B:
  dex                          ; $EA8B
  bpl Loc_EA46                 ; $EA8C
  rts                          ; $EA8E
TrackScriptFinishLine:
  cpx #$00                     ; $EA8F
  bne Loc_EAC4                 ; $EA91
  lda #$1D                     ; $EA93
  sta z:$3A                    ; $EA95
  lda z:$57                    ; $EA97
  beq Loc_EAB5                 ; $EA99
  lda z:$3C                    ; $EA9B
  bne Loc_EAC0                 ; $EA9D
  stx z:$0D                    ; $EA9F
  ldx #$06                     ; $EAA1
  ldy #$19                     ; $EAA3
Loc_EAA5:
  lda $03D9,x                  ; $EAA5
  sta $02C0,y                  ; $EAA8
  dey                          ; $EAAB
  dey                          ; $EAAC
  dey                          ; $EAAD
  dey                          ; $EAAE
  dex                          ; $EAAF
  bpl Loc_EAA5                 ; $EAB0
  ldx z:$0D                    ; $EAB2
  rts                          ; $EAB4
Loc_EAB5:
  lda #$10                     ; $EAB5
  sta z:$32                    ; $EAB7
  lda #$02                     ; $EAB9
  sta z:SfxNoiseRequest        ; $EABB
  lsr a                        ; $EABD
  sta z:RaceEndState           ; $EABE
Loc_EAC0:
  lda #$00                     ; $EAC0
  sta z:$3A                    ; $EAC2
Loc_EAC4:
  rts                          ; $EAC4
