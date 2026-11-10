; Module rider_draw: $E17F-
.segment "PRG"

DrawRiders:
  jsr SortRidersByY            ; $E17F
  ldx #$03                     ; $E182
Loc_E184:
  stx z:$0D                    ; $E184
  lda Data_D8C0,x              ; $E186
  sta z:$04                    ; $E189
  lda z:RiderSortOrder,x       ; $E18B
  tax                          ; $E18D
  lda z:RiderActive,x          ; $E18E
  beq Loc_E19D                 ; $E190
  lda Data_D8C9,x              ; $E192
  sta z:$0B                    ; $E195
  jsr DrawRider                ; $E197
  jsr DrawRiderShadow          ; $E19A
Loc_E19D:
  ldx z:$0D                    ; $E19D
  dex                          ; $E19F
  bpl Loc_E184                 ; $E1A0
  rts                          ; $E1A2
DrawRider:
  lda z:RiderXLo,x             ; $E1A3
  sta z:$00                    ; $E1A5
  lda z:RiderScreenY,x         ; $E1A7
  sta z:$01                    ; $E1A9
  jsr RiderSpriteFrame         ; $E1AB
  tay                          ; $E1AE
  lda Data_D892,y              ; $E1AF
  sta z:$02                    ; $E1B2
  lda #$33                     ; $E1B4
  sta z:$03                    ; $E1B6
  cpy #$16                     ; $E1B8
  bne Loc_E1D1                 ; $E1BA
  lda z:$04                    ; $E1BC
  sta $039F                    ; $E1BE
  clc                          ; $E1C1
  adc #$0C                     ; $E1C2
  sta z:$04                    ; $E1C4
  lda z:$01                    ; $E1C6
  clc                          ; $E1C8
  adc #$08                     ; $E1C9
  sta z:$01                    ; $E1CB
  lda #$23                     ; $E1CD
  sta z:$03                    ; $E1CF
Loc_E1D1:
  lda Data_D8A9,y              ; $E1D1
  jsr DrawMetasprite           ; $E1D4
  lda z:$0E                    ; $E1D7
  beq Loc_E1F8                 ; $E1D9
  lsr a                        ; $E1DB
  bcs Loc_E1F2                 ; $E1DC
  ldy #$11                     ; $E1DE
  lda #$B2                     ; $E1E0
Loc_E1E2:
  cpy #$09                     ; $E1E2
  beq Loc_E1EB                 ; $E1E4
  sta ($04),y                  ; $E1E6
  sec                          ; $E1E8
  sbc #$01                     ; $E1E9
Loc_E1EB:
  dey                          ; $E1EB
  dey                          ; $E1EC
  dey                          ; $E1ED
  dey                          ; $E1EE
  bpl Loc_E1E2                 ; $E1EF
  rts                          ; $E1F1
Loc_E1F2:
  ldy #$15                     ; $E1F2
  lda #$AE                     ; $E1F4
  sta ($04),y                  ; $E1F6
Loc_E1F8:
  rts                          ; $E1F8
RiderSpriteFrame:
  lda #$00                     ; $E1F9
  sta z:$0E                    ; $E1FB
  sta $039F                    ; $E1FD
  lda z:RiderState,x           ; $E200
  beq Loc_E21F                 ; $E202
  cmp #$05                     ; $E204
  beq Loc_E21F                 ; $E206
  ldy #$06                     ; $E208
  lda z:RiderHeight,x          ; $E20A
  bne Loc_E213                 ; $E20C
  lda $0370,x                  ; $E20E
  bne Loc_E215                 ; $E211
Loc_E213:
  ldy #$02                     ; $E213
Loc_E215:
  tya                          ; $E215
  ldy z:$36,x                  ; $E216
  beq Loc_E21C                 ; $E218
  dey                          ; $E21A
  tya                          ; $E21B
Loc_E21C:
  ora #$10                     ; $E21C
  rts                          ; $E21E
Loc_E21F:
  ldy z:RaceEndState           ; $E21F
  dey                          ; $E221
  bne Loc_E22F                 ; $E222
  lda z:RiderPitch,x           ; $E224
  cmp #$0A                     ; $E226
  bne Loc_E22F                 ; $E228
  ldy #$02                     ; $E22A
  sty z:$0E                    ; $E22C
  rts                          ; $E22E
Loc_E22F:
  lda z:RiderCrash,x           ; $E22F
  ora z:RiderAirborne,x        ; $E231
  bne Loc_E267                 ; $E233
  lda z:$58,x                  ; $E235
  beq Loc_E243                 ; $E237
  cmp #$0D                     ; $E239
  bne Loc_E267                 ; $E23B
  lda z:RiderY,x               ; $E23D
  cmp #$20                     ; $E23F
  bcc Loc_E267                 ; $E241
Loc_E243:
  lda z:RiderSpeedLo,x         ; $E243
  ora z:RiderSpeedHi,x         ; $E245
  bne Loc_E24D                 ; $E247
  inc z:$0E                    ; $E249
  bne Loc_E267                 ; $E24B
Loc_E24D:
  lda z:RiderPitch,x           ; $E24D
  cmp #$06                     ; $E24F
  bne Loc_E267                 ; $E251
  ldy #$14                     ; $E253
  lda z:RiderLaneStep,x        ; $E255
  beq Loc_E25E                 ; $E257
  bpl Loc_E25C                 ; $E259
  iny                          ; $E25B
Loc_E25C:
  tya                          ; $E25C
  rts                          ; $E25D
Loc_E25E:
  lda z:FrameCounter           ; $E25E
  and #$02                     ; $E260
  beq Loc_E267                 ; $E262
  lda #$13                     ; $E264
  rts                          ; $E266
Loc_E267:
  lda z:RiderPitch,x           ; $E267
Loc_E269:
  rts                          ; $E269
DrawRiderShadow:
  lda $039F                    ; $E26A
  beq Loc_E269                 ; $E26D
  lda z:RiderXHi,x             ; $E26F
  cmp #$02                     ; $E271
  beq Loc_E269                 ; $E273
  lda $0390,x                  ; $E275
  cmp #$F8                     ; $E278
  bcs Loc_E269                 ; $E27A
  cmp z:RiderXLo,x             ; $E27C
  bcc Loc_E269                 ; $E27E
  lda $0390,x                  ; $E280
  sta z:$00                    ; $E283
  lda #$A8                     ; $E285
  sec                          ; $E287
  sbc z:RiderShadowY,x         ; $E288
  sta z:$01                    ; $E28A
  lda #$22                     ; $E28C
  sta z:$03                    ; $E28E
  lda $039F                    ; $E290
  sta z:$04                    ; $E293
  lda z:RiderTerrainState,x    ; $E295
  beq Loc_E29B                 ; $E297
  lda #$20                     ; $E299
Loc_E29B:
  ora z:$0B                    ; $E29B
  sta z:$0B                    ; $E29D
  ldy $0398,x                  ; $E29F
  lda Data_D90B,y              ; $E2A2
  sta z:$02                    ; $E2A5
  tya                          ; $E2A7
  beq Loc_E2AC                 ; $E2A8
  eor #$03                     ; $E2AA
Loc_E2AC:
  jmp DrawMetasprite           ; $E2AC
  lda $03BD                    ; $E2AF
  sec                          ; $E2B2
  sbc z:RiderMoveX             ; $E2B3
  sta $03BD                    ; $E2B5
  bcs Loc_E2BD                 ; $E2B8
  dec $03BE                    ; $E2BA
Loc_E2BD:
  ldy z:RaceEndState           ; $E2BD
  beq Loc_E2D0                 ; $E2BF
  dey                          ; $E2C1
  bne Loc_E269                 ; $E2C2
  lda z:TimerPrescaler         ; $E2C4
  bne Loc_E2D0                 ; $E2C6
  lda $03BB                    ; $E2C8
  eor #$01                     ; $E2CB
  sta $03BB                    ; $E2CD
Loc_E2D0:
  ldy $03BE                    ; $E2D0
  dey                          ; $E2D3
  bne Loc_E303                 ; $E2D4
  lda $03BD                    ; $E2D6
  sta z:$00                    ; $E2D9
  lda #$50                     ; $E2DB
  sta z:$01                    ; $E2DD
  ldy $03BB                    ; $E2DF
  lda Data_D8E5,y              ; $E2E2
  sta z:$02                    ; $E2E5
  lda #$32                     ; $E2E7
  sta z:$03                    ; $E2E9
  lda #$C0                     ; $E2EB
  sta z:$04                    ; $E2ED
  lda #$00                     ; $E2EF
  sta z:$0B                    ; $E2F1
  jmp DrawMetasprite           ; $E2F3
DrawSkidSmoke:
  lda $036C,x                  ; $E2F6
  beq Loc_E358                 ; $E2F9
  lda z:RiderSpeedHi,x         ; $E2FB
  ora z:RiderSpeedLo,x         ; $E2FD
  beq Loc_E358                 ; $E2FF
  lda z:RiderHeight,x          ; $E301
Loc_E303:
  bne Loc_E358                 ; $E303
  lda z:RiderXHi,x             ; $E305
  lsr a                        ; $E307
  bcc Loc_E358                 ; $E308
  lda z:RiderXLo,x             ; $E30A
  cmp #$10                     ; $E30C
  bcc Loc_E358                 ; $E30E
  clc                          ; $E310
  adc #$F9                     ; $E311
  sta $0297,y                  ; $E313
  clc                          ; $E316
  adc #$F8                     ; $E317
  sta $029B,y                  ; $E319
  lda z:RiderScreenY,x         ; $E31C
  clc                          ; $E31E
  adc #$08                     ; $E31F
  sta $0298,y                  ; $E321
  clc                          ; $E324
  adc #$08                     ; $E325
  sta $0294,y                  ; $E327
  lda #$F6                     ; $E32A
  sta $0295,y                  ; $E32C
  lda #$F7                     ; $E32F
  sta $0299,y                  ; $E331
  lda z:FrameCounter           ; $E334
  and #$04                     ; $E336
  beq Loc_E344                 ; $E338
  lda #$F7                     ; $E33A
  sta $0295,y                  ; $E33C
  lda #$F6                     ; $E33F
  sta $0299,y                  ; $E341
Loc_E344:
  lda $036C,x                  ; $E344
  and #$02                     ; $E347
  sta $0296,y                  ; $E349
  sta $029A,y                  ; $E34C
  lda z:RiderSpeedHi,x         ; $E34F
  bne Loc_E358                 ; $E351
  lda #$F8                     ; $E353
  sta $0298,y                  ; $E355
Loc_E358:
  rts                          ; $E358
UpdateTempGauge:
  lda z:RaceEndState           ; $E359
  bne Loc_E3C6                 ; $E35B
  lda $03E0                    ; $E35D
  beq Loc_E36B                 ; $E360
  lda z:$3C                    ; $E362
  lsr a                        ; $E364
  bcs Loc_E3C6                 ; $E365
  lda #$FC                     ; $E367
  bne Loc_E3C8                 ; $E369
Loc_E36B:
  lda z:RiderInput             ; $E36B
  and #$C0                     ; $E36D
  beq Loc_E37A                 ; $E36F
  ldy z:RaceStarted            ; $E371
  bne Loc_E377                 ; $E373
  lda #$80                     ; $E375
Loc_E377:
  asl a                        ; $E377
  rol a                        ; $E378
  rol a                        ; $E379
Loc_E37A:
  tay                          ; $E37A
  lda $03B6                    ; $E37B
  cmp Data_D8FB,y              ; $E37E
  bcc Loc_E39B                 ; $E381
  beq Loc_E3AA                 ; $E383
  lda $03B5                    ; $E385
  sec                          ; $E388
  sbc #$0B                     ; $E389
  sta $03B5                    ; $E38B
  bcs Loc_E3AA                 ; $E38E
  lda $03B6                    ; $E390
  beq Loc_E3AA                 ; $E393
  dec $03B6                    ; $E395
  jmp Loc_E3AA                 ; $E398
Loc_E39B:
  lda $03B5                    ; $E39B
  clc                          ; $E39E
  adc Data_D8F7,y              ; $E39F
  sta $03B5                    ; $E3A2
  bcc Loc_E3AA                 ; $E3A5
  inc $03B6                    ; $E3A7
Loc_E3AA:
  ldx #$00                     ; $E3AA
  lda $03B6                    ; $E3AC
  cmp #$20                     ; $E3AF
  bcc Loc_E3B8                 ; $E3B1
  sta z:$3C                    ; $E3B3
  sta $03E0                    ; $E3B5
Loc_E3B8:
  cmp #$1A                     ; $E3B8
  bcc Loc_E3C1                 ; $E3BA
  dey                          ; $E3BC
  bne Loc_E3C1                 ; $E3BD
  ldx #$B0                     ; $E3BF
Loc_E3C1:
  txa                          ; $E3C1
  ora z:EngineSoundRequest     ; $E3C2
  sta z:EngineSoundRequest     ; $E3C4
Loc_E3C6:
  lda #$FE                     ; $E3C6
Loc_E3C8:
  sta z:$01                    ; $E3C8
  lda $03B6                    ; $E3CA
  clc                          ; $E3CD
  adc #$50                     ; $E3CE
  sta z:$00                    ; $E3D0
  ldx #$0C                     ; $E3D2
Loc_E3D4:
  lda #$CF                     ; $E3D4
  sta $02F0,x                  ; $E3D6
  lda z:$01                    ; $E3D9
  sta $02F1,x                  ; $E3DB
  lda #$20                     ; $E3DE
  sta $02F2,x                  ; $E3E0
  lda z:$00                    ; $E3E3
  sta $02F3,x                  ; $E3E5
  clc                          ; $E3E8
  adc #$08                     ; $E3E9
  sta z:$00                    ; $E3EB
  dex                          ; $E3ED
  dex                          ; $E3EE
  dex                          ; $E3EF
  dex                          ; $E3F0
  bpl Loc_E3D4                 ; $E3F1
  rts                          ; $E3F3
SortRidersByY:
  ldx #$03                     ; $E3F4
Loc_E3F6:
  txa                          ; $E3F6
  sta z:RiderSortOrder,x       ; $E3F7
  lda z:RiderY,x               ; $E3F9
  sta z:$00,x                  ; $E3FB
  dex                          ; $E3FD
  bpl Loc_E3F6                 ; $E3FE
  lda $0373                    ; $E400
  beq Loc_E409                 ; $E403
  lda z:$6F                    ; $E405
  sta z:$03                    ; $E407
Loc_E409:
  ldx #$03                     ; $E409
  stx z:$0D                    ; $E40B
Loc_E40D:
  ldy #$00                     ; $E40D
Loc_E40F:
  ldx z:RiderSortOrder,y       ; $E40F
  lda z:$00,x                  ; $E411
  ldx z:$89,y                  ; $E413
  cmp z:$00,x                  ; $E415
  bcc Loc_E421                 ; $E417
  lda a:RiderSortOrder,y       ; $E419
  sta a:$89,y                  ; $E41C
  stx z:RiderSortOrder,y       ; $E41F
Loc_E421:
  iny                          ; $E421
  cpy z:$0D                    ; $E422
  bne Loc_E40F                 ; $E424
  dec z:$0D                    ; $E426
  bne Loc_E40D                 ; $E428
  rts                          ; $E42A
Loc_E42B:
  lda $03A3                    ; $E42B
  beq Loc_E455                 ; $E42E
  ldx #$03                     ; $E430
Loc_E432:
  lda z:RiderSortOrder,x       ; $E432
  beq Loc_E44A                 ; $E434
  cmp #$03                     ; $E436
  bne Loc_E43F                 ; $E438
  lda $0373                    ; $E43A
  bne Loc_E44A                 ; $E43D
Loc_E43F:
  lda Data_D8C0,x              ; $E43F
  sta z:$07                    ; $E442
  ldy $03B3                    ; $E444
  jsr ClearSpriteBlock         ; $E447
Loc_E44A:
  dex                          ; $E44A
  bpl Loc_E432                 ; $E44B
  lda $03B3                    ; $E44D
  eor #$02                     ; $E450
  sta $03B3                    ; $E452
Loc_E455:
  rts                          ; $E455
ErasePassedRiderSprites:
  ldy #$03                     ; $E456
Loc_E458:
  sty z:$05                    ; $E458
  lda Data_D8C0,y              ; $E45A
  sta z:$07                    ; $E45D
  lda a:RiderSortOrder,y       ; $E45F
  beq Loc_E495                 ; $E462
  tax                          ; $E464
  lda z:RiderXHi,x             ; $E465
  sta z:$02                    ; $E467
  sta z:$03                    ; $E469
  sta z:$04                    ; $E46B
  lsr a                        ; $E46D
  bcs Loc_E484                 ; $E46E
  lda z:RiderXLo,x             ; $E470
  cmp #$70                     ; $E472
  bcc Loc_E484                 ; $E474
  cmp #$90                     ; $E476
  bcs Loc_E484                 ; $E478
  jsr ClearRider               ; $E47A
  lda #$01                     ; $E47D
  sta $03A6                    ; $E47F
  bne Loc_E492                 ; $E482
Loc_E484:
  lda z:RiderXLo,x             ; $E484
  cmp #$F8                     ; $E486
  bcc Loc_E48C                 ; $E488
  inc z:$03                    ; $E48A
Loc_E48C:
  cmp #$F0                     ; $E48C
  bcc Loc_E492                 ; $E48E
  inc z:$04                    ; $E490
Loc_E492:
  jsr EraseRiderSpriteRange    ; $E492
Loc_E495:
  ldy z:$05                    ; $E495
  dey                          ; $E497
  bpl Loc_E458                 ; $E498
  rts                          ; $E49A
EraseRiderSpriteRange:
  ldx #$00                     ; $E49B
Loc_E49D:
  lda z:$02,x                  ; $E49D
  lsr a                        ; $E49F
  bcs Loc_E4A7                 ; $E4A0
  txa                          ; $E4A2
  tay                          ; $E4A3
  jsr ClearSpriteBlock         ; $E4A4
Loc_E4A7:
  inx                          ; $E4A7
  cpx #$03                     ; $E4A8
  bcc Loc_E49D                 ; $E4AA
  rts                          ; $E4AC
ClearSpriteBlock:
  lda #$02                     ; $E4AD
  sta z:$01                    ; $E4AF
  lda z:$07                    ; $E4B1
  clc                          ; $E4B3
  adc Data_D8DC,y              ; $E4B4
  sta z:$00                    ; $E4B7
  ldy #$00                     ; $E4B9
  lda #$F8                     ; $E4BB
Loc_E4BD:
  sta ($00),y                  ; $E4BD
  iny                          ; $E4BF
  iny                          ; $E4C0
  iny                          ; $E4C1
  iny                          ; $E4C2
  cpy #$0C                     ; $E4C3
  bcc Loc_E4BD                 ; $E4C5
  rts                          ; $E4C7
