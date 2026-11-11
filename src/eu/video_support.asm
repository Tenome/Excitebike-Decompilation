; Module video_support: $D0AB-
.segment "PRG"

ComputeRiderLanes:
  ldx #$03                     ; $D0AB
Loc_D0AD:
  ldy #$05                     ; $D0AD
  lda z:RiderY,x               ; $D0AF
  sec                          ; $D0B1
  sbc #$10                     ; $D0B2
  bmi Loc_D0BE                 ; $D0B4
Loc_D0B6:
  dey                          ; $D0B6
  beq Loc_D0BE                 ; $D0B7
  sec                          ; $D0B9
  sbc #$08                     ; $D0BA
  bpl Loc_D0B6                 ; $D0BC
Loc_D0BE:
  tya                          ; $D0BE
  sta RiderLaneRow,x           ; $D0BF
  dex                          ; $D0C2
  bpl Loc_D0AD                 ; $D0C3
  rts                          ; $D0C5
FetchTrackWindow:
  ldx #$03                     ; $D0C6
Loc_D0C8:
  txa                          ; $D0C8
  asl a                        ; $D0C9
  asl a                        ; $D0CA
  sta z:$0C                    ; $D0CB
  lda #$04                     ; $D0CD
  sta z:$0B                    ; $D0CF
  jsr TrackPieceAtRiderLane    ; $D0D1
  sta z:RiderTrackPiece,x      ; $D0D4
  jmp Loc_D0DD                 ; $D0D6
Loc_D0D9:
  ldy z:$08                    ; $D0D9
  lda ($03),y                  ; $D0DB
Loc_D0DD:
  pha                          ; $D0DD
  iny                          ; $D0DE
  tya                          ; $D0DF
  and #$3F                     ; $D0E0
  sta z:$08                    ; $D0E2
  ldy z:$0C                    ; $D0E4
  pla                          ; $D0E6
  sta $03C0,y                  ; $D0E7
  inc z:$0C                    ; $D0EA
  dec z:$0B                    ; $D0EC
  bne Loc_D0D9                 ; $D0EE
  dex                          ; $D0F0
  bpl Loc_D0C8                 ; $D0F1
  rts                          ; $D0F3
CopyTimeDigitsToHud:
  ldx #$06                     ; $D0F4
Loc_D0F6:
  lda $03D9,x                  ; $D0F6
  sta $03D1,x                  ; $D0F9
  dex                          ; $D0FC
  bpl Loc_D0F6                 ; $D0FD
  lda #$56                     ; $D0FF
  sta z:$00                    ; $D101
  lda #$23                     ; $D103
  sta z:$01                    ; $D105
  lda #$17                     ; $D107
  sta $03D0                    ; $D109
  lda #$D0                     ; $D10C
  sta z:$02                    ; $D10E
  lda #$03                     ; $D110
  sta z:$03                    ; $D112
  lda #$FB                     ; $D114
  sta $03D2                    ; $D116
  sta $03D5                    ; $D119
  jmp QueueNametableRect       ; $D11C
InitHudBuffer:
  lda #$11                     ; $D11F
  sta PpuBufferLen             ; $D121
  lda #$23                     ; $D124
  sta PpuBuffer                ; $D126
  lda #$A0                     ; $D129
  sta $0302                    ; $D12B
  ldx #$0E                     ; $D12E
  stx $0303                    ; $D130
  lda #$FE                     ; $D133
Loc_D135:
  sta $0303,x                  ; $D135
  dex                          ; $D138
  bne Loc_D135                 ; $D139
  stx $0312                    ; $D13B
  rts                          ; $D13E
ClearRiderSprites:
  ldx #$00                     ; $D13F
  jsr InitHudSprite            ; $D141
  ldx #$04                     ; $D144
  jsr InitHudSprite            ; $D146
  ldx #$08                     ; $D149
  jmp InitHudSprite            ; $D14B
SplitScreenScrollHandler:
  lda PPU_STATUS               ; $D14E
  and #$40                     ; $D151
  bne SplitScreenScrollHandler ; $D153
  jsr ApplySplitScroll         ; $D155
  lda z:FrameCounter           ; $D158
  and #$03                     ; $D15A
  sta z:FrameMod4              ; $D15C
  jsr InitHudBuffer            ; $D15E
  ldx #$43                     ; $D161
  lda z:GameState              ; $D163
  cmp #$09                     ; $D165
  beq Loc_D17E                 ; $D167
  lda #$F8                     ; $D169
  ldy #$EC                     ; $D16B
Loc_D16D:
  sta OamBuffer,y              ; $D16D
  dey                          ; $D170
  dey                          ; $D171
  dey                          ; $D172
  dey                          ; $D173
  bne Loc_D16D                 ; $D174
  jsr FetchTrackWindow         ; $D176
  jsr CopyTimeDigitsToHud      ; $D179
  ldx #$27                     ; $D17C
Loc_D17E:
  ldy #$12                     ; $D17E
Loc_D180:
  dey                          ; $D180
  bne Loc_D180                 ; $D181
  dex                          ; $D183
  bne Loc_D17E                 ; $D184
  lda z:PpuCtrlShadow          ; $D186
  ora z:PpuCtrlNametableBits   ; $D188
  sta PPU_CTRL                 ; $D18A
  lda PPU_STATUS               ; $D18D
  lda z:ScrollX                ; $D190
  sta PPU_SCROLL               ; $D192
  lda z:ScrollY                ; $D195
Loc_D197:
  sta PPU_SCROLL               ; $D197
  rts                          ; $D19A
WaitSprite0ThenResetScroll:
  lda PPU_STATUS               ; $D19B
  and #$40                     ; $D19E
  beq WaitSprite0ThenResetScroll ; $D1A0
  lda z:PpuCtrlShadow          ; $D1A2
  and #$F0                     ; $D1A4
  jsr SetPpuCtrl               ; $D1A6
ResetPpuScroll:
  lda PPU_STATUS               ; $D1A9
  lda #$00                     ; $D1AC
  sta PPU_SCROLL               ; $D1AE
  beq Loc_D197                 ; $D1B1
ApplySplitScroll:
  lda z:PpuCtrlShadow          ; $D1B3
  ora z:SplitNametableBits     ; $D1B5
  sta PPU_CTRL                 ; $D1B7
  lda PPU_STATUS               ; $D1BA
  lda z:SplitScrollX           ; $D1BD
  sta PPU_SCROLL               ; $D1BF
  lda z:SplitScrollY           ; $D1C2
  jmp Loc_D197                 ; $D1C4

; Draw a metasprite into OAM: $00 X, $01 Y, $02 first tile, $03 size nibbles (columns/rows), $04 OAM pointer low, $0B attributes.
DrawMetasprite:
  sta z:$0A                    ; $D1C7
  txa                          ; $D1C9
  pha                          ; $D1CA
  tya                          ; $D1CB
  pha                          ; $D1CC
  lda #$02                     ; $D1CD
  sta z:$05                    ; $D1CF
  lda #$0F                     ; $D1D1
  and z:$03                    ; $D1D3
  sta z:$07                    ; $D1D5
  lda z:$03                    ; $D1D7
  lsr a                        ; $D1D9
  lsr a                        ; $D1DA
  lsr a                        ; $D1DB
  lsr a                        ; $D1DC
  sta z:$06                    ; $D1DD
  tax                          ; $D1DF
  lda #$00                     ; $D1E0
  clc                          ; $D1E2
Loc_D1E3:
  adc z:$07                    ; $D1E3
  dex                          ; $D1E5
  bne Loc_D1E3                 ; $D1E6
  sta z:$08                    ; $D1E8
  lda z:$02                    ; $D1EA
  ldy #$01                     ; $D1EC
Loc_D1EE:
  txa                          ; $D1EE
  lsr a                        ; $D1EF
  bcs Loc_D1FC                 ; $D1F0
  lsr z:$0A                    ; $D1F2
  bcc Loc_D1FC                 ; $D1F4
  lda #$FC                     ; $D1F6
  sta ($04),y                  ; $D1F8
  bne Loc_D202                 ; $D1FA
Loc_D1FC:
  lda z:$02                    ; $D1FC
  sta ($04),y                  ; $D1FE
  inc z:$02                    ; $D200
Loc_D202:
  iny                          ; $D202
  lda z:$0B                    ; $D203
  sta ($04),y                  ; $D205
  iny                          ; $D207
  iny                          ; $D208
  iny                          ; $D209
  inx                          ; $D20A
  cpx z:$08                    ; $D20B
  bne Loc_D1EE                 ; $D20D
  ldy #$00                     ; $D20F
Loc_D211:
  ldx z:$06                    ; $D211
  lda z:$01                    ; $D213
  sta z:$09                    ; $D215
Loc_D217:
  lda z:$09                    ; $D217
  sta ($04),y                  ; $D219
  clc                          ; $D21B
  adc #$08                     ; $D21C
  sta z:$09                    ; $D21E
  iny                          ; $D220
  iny                          ; $D221
  iny                          ; $D222
  lda z:$00                    ; $D223
  sta ($04),y                  ; $D225
  iny                          ; $D227
  dex                          ; $D228
  bne Loc_D217                 ; $D229
  lda z:$00                    ; $D22B
  clc                          ; $D22D
  adc #$08                     ; $D22E
  sta z:$00                    ; $D230
  dec z:$07                    ; $D232
  bne Loc_D211                 ; $D234
  pla                          ; $D236
  tay                          ; $D237
  pla                          ; $D238
  tax                          ; $D239
  rts                          ; $D23A
ClearNametables:
  ldx #$01                     ; $D23B
Loc_D23D:
  txa                          ; $D23D
  pha                          ; $D23E
  sta z:$01                    ; $D23F
  jsr DisableRendering         ; $D241
  jsr ClearNametable           ; $D244
  pla                          ; $D247
  tax                          ; $D248
  inx                          ; $D249
  cpx #$03                     ; $D24A
  bcc Loc_D23D                 ; $D24C
  rts                          ; $D24E
DisableRendering:
  lda #$00                     ; $D24F
  sta PPU_MASK                 ; $D251
  rts                          ; $D254
ClearOam:
  lda #$F8                     ; $D255
  ldy #$00                     ; $D257
Loc_D259:
  sta OamBuffer,y              ; $D259
  dey                          ; $D25C
  bne Loc_D259                 ; $D25D
  rts                          ; $D25F
ClearNametable:
  lda PPU_STATUS               ; $D260
  lda z:PpuCtrlShadow          ; $D263
  and #$FB                     ; $D265
  jsr SetPpuCtrl               ; $D267
  lda #$1C                     ; $D26A
  clc                          ; $D26C
Loc_D26D:
  adc #$04                     ; $D26D
  dec z:$01                    ; $D26F
  bne Loc_D26D                 ; $D271
  sta z:$02                    ; $D273
  sta PPU_ADDR                 ; $D275
  lda #$00                     ; $D278
  sta PPU_ADDR                 ; $D27A
  ldx #$04                     ; $D27D
  ldy #$00                     ; $D27F
  lda #$FC                     ; $D281
Loc_D283:
  sta PPU_DATA                 ; $D283
  dey                          ; $D286
  bne Loc_D283                 ; $D287
  dex                          ; $D289
  bne Loc_D283                 ; $D28A
  lda z:$02                    ; $D28C
  adc #$03                     ; $D28E
  sta PPU_ADDR                 ; $D290
  lda #$C0                     ; $D293
  sta PPU_ADDR                 ; $D295
  ldy #$40                     ; $D298
  lda #$00                     ; $D29A
Loc_D29C:
  sta PPU_DATA                 ; $D29C
  dey                          ; $D29F
  bne Loc_D29C                 ; $D2A0
  rts                          ; $D2A2
QueueNametableRect:
  txa                          ; $D2A3
  pha                          ; $D2A4
  tya                          ; $D2A5
  pha                          ; $D2A6
  ldy #$00                     ; $D2A7
  lda ($02),y                  ; $D2A9
  and #$0F                     ; $D2AB
  sta z:$05                    ; $D2AD
  lda ($02),y                  ; $D2AF
  lsr a                        ; $D2B1
  lsr a                        ; $D2B2
  lsr a                        ; $D2B3
  lsr a                        ; $D2B4
  sta z:$04                    ; $D2B5
  ldx PpuBufferLen             ; $D2B7
Loc_D2BA:
  lda z:$01                    ; $D2BA
  sta PpuBuffer,x              ; $D2BC
  jsr PpuBufferAdvance         ; $D2BF
  lda z:$00                    ; $D2C2
  sta PpuBuffer,x              ; $D2C4
  jsr PpuBufferAdvance         ; $D2C7
  lda z:$05                    ; $D2CA
  sta z:$06                    ; $D2CC
  sta PpuBuffer,x              ; $D2CE
Loc_D2D1:
  jsr PpuBufferAdvance         ; $D2D1
  iny                          ; $D2D4
  lda ($02),y                  ; $D2D5
  sta PpuBuffer,x              ; $D2D7
  dec z:$06                    ; $D2DA
  bne Loc_D2D1                 ; $D2DC
  jsr PpuBufferAdvance         ; $D2DE
  stx PpuBufferLen             ; $D2E1
  clc                          ; $D2E4
  lda #$20                     ; $D2E5
  adc z:$00                    ; $D2E7
  sta z:$00                    ; $D2E9
  lda #$00                     ; $D2EB
  adc z:$01                    ; $D2ED
  sta z:$01                    ; $D2EF
  dec z:$04                    ; $D2F1
  bne Loc_D2BA                 ; $D2F3
  lda #$00                     ; $D2F5
  sta PpuBuffer,x              ; $D2F7
  pla                          ; $D2FA
  tay                          ; $D2FB
  pla                          ; $D2FC
  tax                          ; $D2FD
  rts                          ; $D2FE
PpuBufferAdvance:
  inx                          ; $D2FF
  txa                          ; $D300
  cmp #$3F                     ; $D301
  bcc Loc_D30F                 ; $D303
  ldx PpuBufferLen             ; $D305
  lda #$00                     ; $D308
  sta PpuBuffer,x              ; $D30A
  pla                          ; $D30D
  pla                          ; $D30E
Loc_D30F:
  rts                          ; $D30F
TickTimers:
  ldx #$0E                     ; $D310
  dec z:TimerPrescaler         ; $D312
  bpl Loc_D31C                 ; $D314
  lda #$0A                     ; $D316
  sta z:TimerPrescaler         ; $D318
  ldx #$1C                     ; $D31A
Loc_D31C:
  lda z:Timers,x               ; $D31C
  beq Loc_D322                 ; $D31E
  dec z:Timers,x               ; $D320
Loc_D322:
  dex                          ; $D322
  bpl Loc_D31C                 ; $D323
  rts                          ; $D325

; 64-bit shift-register random number generator (RandomState $18-$1F).
UpdateRandom:
  lda z:RandomState            ; $D326
  and #$02                     ; $D328
  sta z:$00                    ; $D32A
  lda z:$19                    ; $D32C
  and #$02                     ; $D32E
  eor z:$00                    ; $D330
  clc                          ; $D332
  beq Loc_D336                 ; $D333
  sec                          ; $D335
Loc_D336:
  ror z:RandomState            ; $D336
  ror z:$19                    ; $D338
  ror z:$1A                    ; $D33A
  ror z:$1B                    ; $D33C
  ror z:$1C                    ; $D33E
  ror z:$1D                    ; $D340
  ror z:$1E                    ; $D342
  ror z:$1F                    ; $D344
  rts                          ; $D346
ReadJoypads:
  lda #$01                     ; $D347
  sta JOYPAD1                  ; $D349
  ldx #$00                     ; $D34C
  lda #$00                     ; $D34E
  sta JOYPAD1                  ; $D350
  jsr ReadJoypadPort           ; $D353
  inx                          ; $D356
  jsr ReadJoypadPort           ; $D357
  rts                          ; $D35A
ReadJoypadPort:
  ldy #$08                     ; $D35B
Loc_D35D:
  pha                          ; $D35D
  lda JOYPAD1,x                ; $D35E
  sta z:$00                    ; $D361
  lsr a                        ; $D363
  ora z:$00                    ; $D364
  lsr a                        ; $D366
  pla                          ; $D367
  rol a                        ; $D368
  dey                          ; $D369
  bne Loc_D35D                 ; $D36A
  stx z:$00                    ; $D36C
  asl z:$00                    ; $D36E
  ldx z:$00                    ; $D370
  ldy z:Joy1Held,x             ; $D372
  sty z:$00                    ; $D374
  sta z:Joy1Held,x             ; $D376
  sta z:Joy1Trigger,x          ; $D378
  and #$FF                     ; $D37A
  bpl Loc_D386                 ; $D37C
  bit z:$00                    ; $D37E
  bpl Loc_D386                 ; $D380
  and #$7F                     ; $D382
  sta z:Joy1Trigger,x          ; $D384
Loc_D386:
  rts                          ; $D386
Loc_D387:
  sta PPU_ADDR                 ; $D387
  iny                          ; $D38A
  lda ($00),y                  ; $D38B
  sta PPU_ADDR                 ; $D38D
  iny                          ; $D390
  lda ($00),y                  ; $D391
  asl a                        ; $D393
  pha                          ; $D394
  lda z:PpuCtrlShadow          ; $D395
  ora #$04                     ; $D397
  bcs Loc_D39D                 ; $D399
  and #$FB                     ; $D39B
Loc_D39D:
  jsr SetPpuCtrl               ; $D39D
  pla                          ; $D3A0
  asl a                        ; $D3A1
  bcc Loc_D3A7                 ; $D3A2
  ora #$02                     ; $D3A4
  iny                          ; $D3A6
Loc_D3A7:
  lsr a                        ; $D3A7
  lsr a                        ; $D3A8
  tax                          ; $D3A9
Loc_D3AA:
  bcs Loc_D3AD                 ; $D3AA
  iny                          ; $D3AC
Loc_D3AD:
  lda ($00),y                  ; $D3AD
  sta PPU_DATA                 ; $D3AF
  dex                          ; $D3B2
  bne Loc_D3AA                 ; $D3B3
  sec                          ; $D3B5
  tya                          ; $D3B6
  adc z:$00                    ; $D3B7
  sta z:$00                    ; $D3B9
  lda #$00                     ; $D3BB
  adc z:$01                    ; $D3BD
  sta z:$01                    ; $D3BF

; Run a PPU write list at ($00): {addr hi, addr lo, count/flags, data...} records ended by a zero byte.
RunPpuWriteList:
  ldx PPU_STATUS               ; $D3C1
  ldy #$00                     ; $D3C4
  lda ($00),y                  ; $D3C6
  bne Loc_D387                 ; $D3C8
  lda PPU_STATUS               ; $D3CA
  lda #$00                     ; $D3CD
  sta PPU_SCROLL               ; $D3CF
  sta PPU_SCROLL               ; $D3D2
  rts                          ; $D3D5
