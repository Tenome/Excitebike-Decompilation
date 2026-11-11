; Module sound: $F844-
.segment "PRG"


; Sound engine, called every NMI: pulse 1 SFX, pulse 2/triangle SFX, noise SFX, music; clears the request bytes.
SoundUpdate:
  lda #$C0                     ; $F844
  sta JOYPAD2                  ; $F846
  jsr SoundPulse1Sfx           ; $F849
  jsr SoundPulse2TriangleSfx   ; $F84C
  jsr SoundNoiseSfx            ; $F84F
  jsr SoundMusic               ; $F852
  lda #$00                     ; $F855
  sta z:SfxPulse1Request       ; $F857
  sta z:SfxPulse2Request       ; $F859
  sta z:SfxNoiseRequest        ; $F85B
  sta z:MusicRequest           ; $F85D
  lda $07FF                    ; $F85F
  beq Loc_F86A                 ; $F862
  sta APU_DMC_RAW              ; $F864
  dec $07FF                    ; $F867
Loc_F86A:
  rts                          ; $F86A
SetPulse1Regs:
  stx APU_PL1_VOL              ; $F86B
  sty APU_PL1_SWEEP            ; $F86E
PlayPulseNote:
  ldx #$00                     ; $F871
Loc_F873:
  tay                          ; $F873
  lda Data_FF01,y              ; $F874
  beq Loc_F884                 ; $F877
  sta APU_PL1_LO,x             ; $F879
  lda NoteTable,y              ; $F87C
  ora #$08                     ; $F87F
  sta APU_PL1_HI,x             ; $F881
Loc_F884:
  rts                          ; $F884
Sub_F885:
  ldx #$04                     ; $F885
  bne Loc_F873                 ; $F887
Sub_F889:
  ldx #$08                     ; $F889
  bne Loc_F873                 ; $F88B
Loc_F88D:
  sty z:$F0                    ; $F88D
  lda #$01                     ; $F88F
  sta z:$F5                    ; $F891
  ldx #$80                     ; $F893
  ldy #$9C                     ; $F895
  lda #$04                     ; $F897
  jmp SetPulse1Regs            ; $F899
Loc_F89C:
  sty z:$F0                    ; $F89C
  lda #$10                     ; $F89E
  sta z:$F5                    ; $F8A0
  ldx #$85                     ; $F8A2
  ldy #$85                     ; $F8A4
  lda #$30                     ; $F8A6
  jsr SetPulse1Regs            ; $F8A8
Loc_F8AB:
  jmp Loc_F93A                 ; $F8AB
Loc_F8AE:
  sty z:$F0                    ; $F8AE
  lda #$09                     ; $F8B0
  sta z:$F5                    ; $F8B2
  lda #$04                     ; $F8B4
  jsr PlayPulseNote            ; $F8B6
Loc_F8B9:
  lda z:$F5                    ; $F8B9
  cmp #$04                     ; $F8BB
  bne Loc_F8C2                 ; $F8BD
  jmp Loc_F93E                 ; $F8BF
Loc_F8C2:
  ldy #$84                     ; $F8C2
  cmp #$07                     ; $F8C4
  bcs Loc_F8CA                 ; $F8C6
  ldy #$8B                     ; $F8C8
Loc_F8CA:
  sty APU_PL1_SWEEP            ; $F8CA
  ora #$90                     ; $F8CD
  sta APU_PL1_VOL              ; $F8CF
  bne Loc_F93A                 ; $F8D2
SoundPulse1Sfx:
  ldy z:$F4                    ; $F8D4
  bne Loc_F90D                 ; $F8D6
  ldy z:SfxPulse1Request       ; $F8D8
  lda z:$F0                    ; $F8DA
  lsr z:SfxPulse1Request       ; $F8DC
  bcs Loc_F88D                 ; $F8DE
  lsr a                        ; $F8E0
  bcs Loc_F93A                 ; $F8E1
  lsr z:SfxPulse1Request       ; $F8E3
  bcs Loc_F89C                 ; $F8E5
  lsr a                        ; $F8E7
  bcs Loc_F8AB                 ; $F8E8
  lsr a                        ; $F8EA
  bcs Loc_F8B9                 ; $F8EB
  lsr z:SfxPulse1Request       ; $F8ED
  bcs Loc_F8AE                 ; $F8EF
  lsr z:SfxPulse1Request       ; $F8F1
  bcs Loc_F90E                 ; $F8F3
  lsr a                        ; $F8F5
  bcs Loc_F921                 ; $F8F6
  lsr z:SfxPulse1Request       ; $F8F8
  bcs Loc_F948                 ; $F8FA
  lsr a                        ; $F8FC
  bcs Loc_F95B                 ; $F8FD
  lsr z:SfxPulse1Request       ; $F8FF
  bcs Loc_F96D                 ; $F901
  lsr a                        ; $F903
  bcs Loc_F975                 ; $F904
  lsr z:SfxPulse1Request       ; $F906
  bcs Loc_F97D                 ; $F908
  lsr a                        ; $F90A
  bcs Loc_F98A                 ; $F90B
Loc_F90D:
  rts                          ; $F90D
Loc_F90E:
  sty z:$F0                    ; $F90E
  lda #$06                     ; $F910
  sta z:$F5                    ; $F912
  ldx #$9C                     ; $F914
  lda #$3C                     ; $F916
  jsr SetPulse1Regs            ; $F918
  lda #$03                     ; $F91B
  sta z:$F6                    ; $F91D
  bne Loc_F92B                 ; $F91F
Loc_F921:
  dec z:$F6                    ; $F921
  beq Loc_F931                 ; $F923
  lda z:$F6                    ; $F925
  cmp #$03                     ; $F927
  bne Loc_F90D                 ; $F929
Loc_F92B:
  lda #$9A                     ; $F92B
Loc_F92D:
  sta APU_PL1_SWEEP            ; $F92D
  rts                          ; $F930
Loc_F931:
  lda #$93                     ; $F931
Loc_F933:
  sta APU_PL1_SWEEP            ; $F933
  lda #$06                     ; $F936
  sta z:$F6                    ; $F938
Loc_F93A:
  dec z:$F5                    ; $F93A
  bne Loc_F947                 ; $F93C
Loc_F93E:
  lda #$00                     ; $F93E
  sta z:$F0                    ; $F940
Loc_F942:
  lda #$90                     ; $F942
  sta APU_PL1_VOL              ; $F944
Loc_F947:
  rts                          ; $F947
Loc_F948:
  sty z:$F0                    ; $F948
  lda #$03                     ; $F94A
  sta z:$F5                    ; $F94C
Loc_F94E:
  ldx #$9C                     ; $F94E
  lda #$00                     ; $F950
  jsr SetPulse1Regs            ; $F952
  lda #$04                     ; $F955
  sta z:$F6                    ; $F957
  bne Loc_F965                 ; $F959
Loc_F95B:
  dec z:$F6                    ; $F95B
  beq Loc_F969                 ; $F95D
Loc_F95F:
  lda z:$F6                    ; $F95F
  cmp #$04                     ; $F961
  bne Loc_F90D                 ; $F963
Loc_F965:
  lda #$9A                     ; $F965
  bne Loc_F92D                 ; $F967
Loc_F969:
  lda #$93                     ; $F969
  bne Loc_F933                 ; $F96B
Loc_F96D:
  sty z:$F0                    ; $F96D
  lda #$02                     ; $F96F
  sta z:$F5                    ; $F971
  bne Loc_F94E                 ; $F973
Loc_F975:
  dec z:$F6                    ; $F975
  bne Loc_F95F                 ; $F977
  lda #$94                     ; $F979
  bne Loc_F933                 ; $F97B
Loc_F97D:
  sty z:$F0                    ; $F97D
  lda #$21                     ; $F97F
  sta z:$F5                    ; $F981
  ldy #$BC                     ; $F983
  lda #$30                     ; $F985
  jsr SetPulse1Regs            ; $F987
Loc_F98A:
  lda z:$F5                    ; $F98A
  cmp #$15                     ; $F98C
  bne Loc_F995                 ; $F98E
  ldy #$7F                     ; $F990
  sty APU_PL1_SWEEP            ; $F992
Loc_F995:
  lsr a                        ; $F995
  tay                          ; $F996
  lda Data_F9A2,y              ; $F997
  bcs Loc_F99E                 ; $F99A
  lda #$13                     ; $F99C
Loc_F99E:
  sta APU_PL1_VOL              ; $F99E
  bne Loc_F93A                 ; $F9A1
  sta ($92),y                  ; $F9A3
  .incbin "prg_bank_0.bin", $39A5, $E  ; $F9A5
Data_F9B3:
  .incbin "prg_bank_0.bin", $39B3, $6  ; $F9B3
Data_F9B9:
  .incbin "prg_bank_0.bin", $39B9, $6  ; $F9B9
Data_F9BF:
  .incbin "prg_bank_0.bin", $39BF, $5  ; $F9BF
Data_F9C4:
  .incbin "prg_bank_0.bin", $39C4, $30  ; $F9C4
Data_F9F4:
  .incbin "prg_bank_0.bin", $39F4, $30  ; $F9F4
Data_FA24:
  .incbin "prg_bank_0.bin", $3A24, $15  ; $FA24
Data_FA39:
  .incbin "prg_bank_0.bin", $3A39, $16  ; $FA39
Loc_FA4F:
  ldy #$15                     ; $FA4F
  sty z:$F1                    ; $FA51
  bne Loc_FA5E                 ; $FA53
Loc_FA55:
  dec $07F3                    ; $FA55
  bne Loc_FA8F                 ; $FA58
  dec z:$F1                    ; $FA5A
  beq Loc_FA8F                 ; $FA5C
Loc_FA5E:
  ldx Data_FA24,y              ; $FA5E
  lda #$01                     ; $FA61
  cpx #$80                     ; $FA63
  bne Loc_FA69                 ; $FA65
  lda #$02                     ; $FA67
Loc_FA69:
  sta $07F3                    ; $FA69
  lda Data_FA39,y              ; $FA6C
  ldy #$7F                     ; $FA6F
  jmp Loc_FAF7                 ; $FA71
SoundPulse2TriangleSfx:
  ldy z:SfxPulse2Request       ; $FA74
  bne Loc_FA4F                 ; $FA76
  ldy z:$F1                    ; $FA78
  bne Loc_FA55                 ; $FA7A
  lda z:EngineSoundRequest     ; $FA7C
  and #$7F                     ; $FA7E
  bne Loc_FA95                 ; $FA80
  lda z:$F3                    ; $FA82
  beq Loc_FA94                 ; $FA84
  lda #$00                     ; $FA86
  sta z:$F3                    ; $FA88
  sta z:$F7                    ; $FA8A
  sta $07F8                    ; $FA8C
Loc_FA8F:
  lda #$90                     ; $FA8F
  sta APU_PL2_VOL              ; $FA91
Loc_FA94:
  rts                          ; $FA94
Loc_FA95:
  ldy z:$F7                    ; $FA95
  inc z:$F7                    ; $FA97
  cpy $07F8                    ; $FA99
  bne Loc_FACF                 ; $FA9C
  cmp #$30                     ; $FA9E
  bcs Loc_FABF                 ; $FAA0
  sec                          ; $FAA2
  sbc z:$F3                    ; $FAA3
  beq Loc_FAC3                 ; $FAA5
  bcs Loc_FAB3                 ; $FAA7
  dec z:$F3                    ; $FAA9
  cmp #$F8                     ; $FAAB
  bcs Loc_FABB                 ; $FAAD
  dec z:$F3                    ; $FAAF
  bne Loc_FABB                 ; $FAB1
Loc_FAB3:
  inc z:$F3                    ; $FAB3
  cmp #$08                     ; $FAB5
  bcc Loc_FABB                 ; $FAB7
  inc z:$F3                    ; $FAB9
Loc_FABB:
  lda #$01                     ; $FABB
  bne Loc_FAC8                 ; $FABD
Loc_FABF:
  lda #$30                     ; $FABF
  sta z:$F3                    ; $FAC1
Loc_FAC3:
  ldy z:$F3                    ; $FAC3
  lda Data_F9F4,y              ; $FAC5
Loc_FAC8:
  sta $07F8                    ; $FAC8
  lda #$00                     ; $FACB
  sta z:$F7                    ; $FACD
Loc_FACF:
  lda $07FF                    ; $FACF
  clc                          ; $FAD2
  adc #$04                     ; $FAD3
  cmp #$40                     ; $FAD5
  bcs Loc_FADC                 ; $FAD7
  sta $07FF                    ; $FAD9
Loc_FADC:
  ldy z:$F3                    ; $FADC
  lda Data_F9C4,y              ; $FADE
  ldy z:$F7                    ; $FAE1
  clc                          ; $FAE3
  adc Data_F9B3,y              ; $FAE4
  ldx z:EngineSoundRequest     ; $FAE7
  bpl Loc_FAF2                 ; $FAE9
  ldx Data_F9BF,y              ; $FAEB
  ldy #$89                     ; $FAEE
  bne Loc_FAF7                 ; $FAF0
Loc_FAF2:
  ldx Data_F9B9,y              ; $FAF2
  ldy #$7F                     ; $FAF5
Loc_FAF7:
  stx APU_PL2_VOL              ; $FAF7
  sty APU_PL2_SWEEP            ; $FAFA
  sta $07F9                    ; $FAFD
  ldy #$07                     ; $FB00
  sty z:$00                    ; $FB02
  ldy #$FF                     ; $FB04
  sty z:$01                    ; $FB06
  lsr a                        ; $FB08
  lsr a                        ; $FB09
  lsr a                        ; $FB0A
  lsr a                        ; $FB0B
  lsr a                        ; $FB0C
  tay                          ; $FB0D
  beq Loc_FB17                 ; $FB0E
Loc_FB10:
  lsr z:$00                    ; $FB10
  ror z:$01                    ; $FB12
  dey                          ; $FB14
  bne Loc_FB10                 ; $FB15
Loc_FB17:
  lda z:$00                    ; $FB17
  lsr a                        ; $FB19
  tax                          ; $FB1A
  lda z:$01                    ; $FB1B
  ror a                        ; $FB1D
  tay                          ; $FB1E
  asl $07F9                    ; $FB1F
  asl $07F9                    ; $FB22
  asl $07F9                    ; $FB25
Loc_FB28:
  txa                          ; $FB28
  lsr a                        ; $FB29
  tax                          ; $FB2A
  tya                          ; $FB2B
  ror a                        ; $FB2C
  tay                          ; $FB2D
  asl $07F9                    ; $FB2E
  bcc Loc_FB41                 ; $FB31
  sec                          ; $FB33
  eor #$FF                     ; $FB34
  adc z:$01                    ; $FB36
  sta z:$01                    ; $FB38
  txa                          ; $FB3A
  eor #$FF                     ; $FB3B
  adc z:$00                    ; $FB3D
  sta z:$00                    ; $FB3F
Loc_FB41:
  lda $07F9                    ; $FB41
  bne Loc_FB28                 ; $FB44
  lda z:$01                    ; $FB46
  sta APU_PL2_LO               ; $FB48
  lda z:$00                    ; $FB4B
  sta APU_PL2_HI               ; $FB4D
  lda z:$F1                    ; $FB50
  bne Loc_FB5A                 ; $FB52
  lda z:$F7                    ; $FB54
  ora z:$FA                    ; $FB56
  bne Loc_FB76                 ; $FB58
Loc_FB5A:
  lsr z:$00                    ; $FB5A
  ror z:$01                    ; $FB5C
  lda z:$00                    ; $FB5E
  lsr a                        ; $FB60
  tay                          ; $FB61
  lda z:$01                    ; $FB62
  ror a                        ; $FB64
  clc                          ; $FB65
  adc z:$01                    ; $FB66
  sta APU_TRI_LO               ; $FB68
  tya                          ; $FB6B
  adc z:$00                    ; $FB6C
  sta APU_TRI_HI               ; $FB6E
  lda #$04                     ; $FB71
  sta APU_TRI_LINEAR           ; $FB73
Loc_FB76:
  rts                          ; $FB76
  .incbin "prg_bank_0.bin", $3B77, $2D  ; $FB77
Data_FBA4:
  .incbin "prg_bank_0.bin", $3BA4, $2F  ; $FBA4
Data_FBD3:
  .incbin "prg_bank_0.bin", $3BD3, $1F  ; $FBD3
Data_FBF2:
  .incbin "prg_bank_0.bin", $3BF2, $D  ; $FBF2
Loc_FBFF:
  sty z:$F2                    ; $FBFF
  lda #$2E                     ; $FC01
  sta $07F6                    ; $FC03
Loc_FC06:
  tya                          ; $FC06
  beq Loc_FC0E                 ; $FC07
  and #$02                     ; $FC09
  sta $07F7                    ; $FC0B
Loc_FC0E:
  ldy $07F6                    ; $FC0E
  lda Loc_FB76,y               ; $FC11
  sta APU_NOISE_VOL            ; $FC14
  lda Data_FBA4,y              ; $FC17
  sta APU_NOISE_LO             ; $FC1A
  bne Loc_FC75                 ; $FC1D
Loc_FC1F:
  sty z:$F2                    ; $FC1F
  lda #$00                     ; $FC21
  sta $07F6                    ; $FC23
  sta $07F7                    ; $FC26
  lda #$0E                     ; $FC29
  sta APU_NOISE_LO             ; $FC2B
Loc_FC2E:
  lda $07F6                    ; $FC2E
  lsr a                        ; $FC31
  lsr a                        ; $FC32
  lsr a                        ; $FC33
  tay                          ; $FC34
  lda Data_FBD3,y              ; $FC35
  sta APU_NOISE_VOL            ; $FC38
  bne Loc_FC75                 ; $FC3B
SoundNoiseSfx:
  ldy z:SfxNoiseRequest        ; $FC3D
  lda z:$F2                    ; $FC3F
  lsr z:SfxNoiseRequest        ; $FC41
  bcs Loc_FBFF                 ; $FC43
  lsr a                        ; $FC45
  bcs Loc_FC06                 ; $FC46
  lsr z:SfxNoiseRequest        ; $FC48
  bcs Loc_FC1F                 ; $FC4A
  lsr a                        ; $FC4C
  bcs Loc_FC2E                 ; $FC4D
  lsr a                        ; $FC4F
  bcs Loc_FC63                 ; $FC50
  lsr z:SfxNoiseRequest        ; $FC52
  bcs Loc_FC57                 ; $FC54
Loc_FC56:
  rts                          ; $FC56
Loc_FC57:
  sty z:$F2                    ; $FC57
  lda #$0C                     ; $FC59
  sta $07F6                    ; $FC5B
  lda #$0D                     ; $FC5E
  sta APU_NOISE_LO             ; $FC60
Loc_FC63:
  ldy $07F6                    ; $FC63
  lda Data_FBF2,y              ; $FC66
  sta APU_NOISE_VOL            ; $FC69
  cpy #$08                     ; $FC6C
  bne Loc_FC75                 ; $FC6E
  lda #$0E                     ; $FC70
  sta APU_NOISE_LO             ; $FC72
Loc_FC75:
  lda #$08                     ; $FC75
  sta APU_NOISE_HI             ; $FC77
  dec $07F6                    ; $FC7A
  bne Loc_FC56                 ; $FC7D
  ldy $07F7                    ; $FC7F
  bne Loc_FC1F                 ; $FC82
  lda #$00                     ; $FC84
  sta z:$F2                    ; $FC86
  rts                          ; $FC88
Data_FC89:
  .incbin "prg_bank_0.bin", $3C89, $4  ; $FC89
SoundMusic:
  lda z:MusicRequest           ; $FC8D
  bne Loc_FC96                 ; $FC8F
  lda z:$F4                    ; $FC91
  bne Loc_FCD9                 ; $FC93
  rts                          ; $FC95
Loc_FC96:
  sta z:$F4                    ; $FC96
  ldy #$00                     ; $FC98
Loc_FC9A:
  iny                          ; $FC9A
  lsr a                        ; $FC9B
  bcc Loc_FC9A                 ; $FC9C
  lda Loc_FDD2,y               ; $FC9E
  tay                          ; $FCA1
  lda Data_FDD3,y              ; $FCA2
  sta $07F0                    ; $FCA5
  lda Data_FDD4,y              ; $FCA8
  sta z:$F8                    ; $FCAB
  lda Data_FDD5,y              ; $FCAD
  sta z:$F9                    ; $FCB0
  lda Data_FDD6,y              ; $FCB2
  sta $07E0                    ; $FCB5
  lda Data_FDD7,y              ; $FCB8
  sta z:$FA                    ; $FCBB
  lda Data_FDD8,y              ; $FCBD
  sta $07EC                    ; $FCC0
  lda #$01                     ; $FCC3
  sta $07E5                    ; $FCC5
  sta $07E1                    ; $FCC8
  sta $07E9                    ; $FCCB
  sta $07ED                    ; $FCCE
  ldy #$00                     ; $FCD1
  sty $07E4                    ; $FCD3
  inc $07FB                    ; $FCD6
Loc_FCD9:
  ldy $07E0                    ; $FCD9
  beq Loc_FD1A                 ; $FCDC
  dec $07E1                    ; $FCDE
  bne Loc_FD1A                 ; $FCE1
  inc $07E0                    ; $FCE3
  lda ($F8),y                  ; $FCE6
  jsr Sub_FF53                 ; $FCE8
  sta $07E1                    ; $FCEB
  txa                          ; $FCEE
  and #$3E                     ; $FCEF
  jsr PlayPulseNote            ; $FCF1
  bne Loc_FCFA                 ; $FCF4
  ldx #$10                     ; $FCF6
  bne Loc_FD04                 ; $FCF8
Loc_FCFA:
  ldx #$4F                     ; $FCFA
  lda z:$F4                    ; $FCFC
  and #$60                     ; $FCFE
  bne Loc_FD04                 ; $FD00
  ldx #$05                     ; $FD02
Loc_FD04:
  stx APU_PL1_VOL              ; $FD04
  ldy #$7F                     ; $FD07
  lda z:$F4                    ; $FD09
  lsr a                        ; $FD0B
  bcc Loc_FD17                 ; $FD0C
  lda $07FB                    ; $FD0E
  and #$03                     ; $FD11
  tax                          ; $FD13
  ldy Data_FC89,x              ; $FD14
Loc_FD17:
  sty APU_PL1_SWEEP            ; $FD17
Loc_FD1A:
  dec $07E5                    ; $FD1A
  bne Loc_FD63                 ; $FD1D
  ldy $07E4                    ; $FD1F
  inc $07E4                    ; $FD22
  lda ($F8),y                  ; $FD25
  bne Loc_FD32                 ; $FD27
  lda #$00                     ; $FD29
  sta z:$FA                    ; $FD2B
  sta z:$F4                    ; $FD2D
  jmp Loc_F942                 ; $FD2F
Loc_FD32:
  jsr Sub_FF53                 ; $FD32
  sta $07E5                    ; $FD35
  lda z:$F4                    ; $FD38
  and #$60                     ; $FD3A
  bne Loc_FD63                 ; $FD3C
  txa                          ; $FD3E
  and #$3E                     ; $FD3F
  jsr Sub_F885                 ; $FD41
  bne Loc_FD4A                 ; $FD44
  ldx #$10                     ; $FD46
  bne Loc_FD5B                 ; $FD48
Loc_FD4A:
  ldx #$87                     ; $FD4A
  lda $07E5                    ; $FD4C
  cmp #$10                     ; $FD4F
  bcs Loc_FD5B                 ; $FD51
  ldx #$84                     ; $FD53
  cmp #$08                     ; $FD55
  bcs Loc_FD5B                 ; $FD57
  ldx #$82                     ; $FD59
Loc_FD5B:
  stx APU_PL2_VOL              ; $FD5B
  lda #$7F                     ; $FD5E
  sta APU_PL2_SWEEP            ; $FD60
Loc_FD63:
  ldy z:$FA                    ; $FD63
  beq Loc_FD99                 ; $FD65
  dec $07E9                    ; $FD67
  bne Loc_FD99                 ; $FD6A
  inc z:$FA                    ; $FD6C
  lda ($F8),y                  ; $FD6E
  jsr Sub_FF53                 ; $FD70
  sta $07E9                    ; $FD73
  clc                          ; $FD76
  adc #$FF                     ; $FD77
  cmp #$0C                     ; $FD79
  bcc Loc_FD7F                 ; $FD7B
  lda #$0C                     ; $FD7D
Loc_FD7F:
  asl a                        ; $FD7F
  asl a                        ; $FD80
  ldy z:$F4                    ; $FD81
  cpy #$20                     ; $FD83
  bne Loc_FD89                 ; $FD85
  lda #$81                     ; $FD87
Loc_FD89:
  sta APU_TRI_LINEAR           ; $FD89
  txa                          ; $FD8C
  and #$3E                     ; $FD8D
  jsr Sub_F889                 ; $FD8F
  bne Loc_FD99                 ; $FD92
  lda #$00                     ; $FD94
  sta APU_TRI_LINEAR           ; $FD96
Loc_FD99:
  lda z:$F4                    ; $FD99
  and #$1B                     ; $FD9B
  beq Loc_FDD2                 ; $FD9D
  dec $07ED                    ; $FD9F
  bne Loc_FDD2                 ; $FDA2
  ldy $07EC                    ; $FDA4
  inc $07EC                    ; $FDA7
  lda ($F8),y                  ; $FDAA
  jsr Sub_FF53                 ; $FDAC
  sta $07ED                    ; $FDAF
  txa                          ; $FDB2
  and #$3E                     ; $FDB3
  beq Loc_FDD2                 ; $FDB5
  cmp #$20                     ; $FDB7
  beq Loc_FDC3                 ; $FDB9
  lda #$00                     ; $FDBB
  ldx #$00                     ; $FDBD
  ldy #$08                     ; $FDBF
  bne Loc_FDC9                 ; $FDC1
Loc_FDC3:
  lda #$00                     ; $FDC3
  ldx #$02                     ; $FDC5
  ldy #$08                     ; $FDC7
Loc_FDC9:
  sta APU_NOISE_VOL            ; $FDC9
  stx APU_NOISE_LO             ; $FDCC
  sty APU_NOISE_HI             ; $FDCF
Loc_FDD2:
  rts                          ; $FDD2
Data_FDD3:
  .incbin "prg_bank_0.bin", $3DD3, $1  ; $FDD3
Data_FDD4:
  .incbin "prg_bank_0.bin", $3DD4, $1  ; $FDD4
Data_FDD5:
  .incbin "prg_bank_0.bin", $3DD5, $1  ; $FDD5
Data_FDD6:
  .incbin "prg_bank_0.bin", $3DD6, $1  ; $FDD6
Data_FDD7:
  .incbin "prg_bank_0.bin", $3DD7, $1  ; $FDD7
Data_FDD8:
  .incbin "prg_bank_0.bin", $3DD8, $128  ; $FDD8
NoteTable:
  .incbin "prg_bank_0.bin", $3F00, $1  ; $FF00
Data_FF01:
  .incbin "prg_bank_0.bin", $3F01, $3D  ; $FF01
Data_FF3E:
  .incbin "prg_bank_0.bin", $3F3E, $15  ; $FF3E
Sub_FF53:
  tax                          ; $FF53
  ror a                        ; $FF54
  txa                          ; $FF55
  rol a                        ; $FF56
  rol a                        ; $FF57
  rol a                        ; $FF58
  and #$07                     ; $FF59
  clc                          ; $FF5B
  adc $07F0                    ; $FF5C
  tay                          ; $FF5F
  lda Data_FF3E,y              ; $FF60
  rts                          ; $FF63
  .incbin "prg_bank_0.bin", $3F64, $8C  ; $FF64
Irq:
  .incbin "prg_bank_0.bin", $3FF0, $A  ; $FFF0

.segment "PRG"
; hardware vectors
  .addr Nmi, Reset, Irq
