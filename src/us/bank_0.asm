; PRG-ROM $C000-$FFFF
.segment "PRG"

Data_C000:
  .incbin "prg_bank_0.bin", $0000, $1C  ; $C000
Data_C01C:
  .incbin "prg_bank_0.bin", $001C, $E  ; $C01C
Data_C02A:
  .incbin "prg_bank_0.bin", $002A, $9  ; $C02A
Data_C033:
  .incbin "prg_bank_0.bin", $0033, $4D  ; $C033
Data_C080:
  .incbin "prg_bank_0.bin", $0080, $3  ; $C080
Data_C083:
  .incbin "prg_bank_0.bin", $0083, $5  ; $C083
Data_C088:
  .incbin "prg_bank_0.bin", $0088, $3  ; $C088
Data_C08B:
  .incbin "prg_bank_0.bin", $008B, $6  ; $C08B
Data_C091:
  .incbin "prg_bank_0.bin", $0091, $1  ; $C091
Data_C092:
  .incbin "prg_bank_0.bin", $0092, $1  ; $C092
Data_C093:
  .incbin "prg_bank_0.bin", $0093, $1D  ; $C093
Data_C0B0:
  .incbin "prg_bank_0.bin", $00B0, $4  ; $C0B0
Data_C0B4:
  .incbin "prg_bank_0.bin", $00B4, $4  ; $C0B4
Data_C0B8:
  .incbin "prg_bank_0.bin", $00B8, $4  ; $C0B8
Data_C0BC:
  .incbin "prg_bank_0.bin", $00BC, $5  ; $C0BC
Data_C0C1:
  .incbin "prg_bank_0.bin", $00C1, $7  ; $C0C1
Data_C0C8:
  .incbin "prg_bank_0.bin", $00C8, $2  ; $C0C8
Data_C0CA:
  .incbin "prg_bank_0.bin", $00CA, $2  ; $C0CA
Data_C0CC:
  .incbin "prg_bank_0.bin", $00CC, $2  ; $C0CC
Data_C0CE:
  .incbin "prg_bank_0.bin", $00CE, $3  ; $C0CE
Data_C0D1:
  .incbin "prg_bank_0.bin", $00D1, $3  ; $C0D1
Data_C0D4:
  .incbin "prg_bank_0.bin", $00D4, $2  ; $C0D4
Data_C0D6:
  .incbin "prg_bank_0.bin", $00D6, $1  ; $C0D6
Data_C0D7:
  .incbin "prg_bank_0.bin", $00D7, $3  ; $C0D7
Data_C0DA:
  .incbin "prg_bank_0.bin", $00DA, $4  ; $C0DA
Data_C0DE:
  .incbin "prg_bank_0.bin", $00DE, $4  ; $C0DE
Data_C0E2:
  .incbin "prg_bank_0.bin", $00E2, $3  ; $C0E2
Data_C0E5:
  .incbin "prg_bank_0.bin", $00E5, $3  ; $C0E5
Data_C0E8:
  .incbin "prg_bank_0.bin", $00E8, $4  ; $C0E8
Data_C0EC:
  .incbin "prg_bank_0.bin", $00EC, $1  ; $C0EC
Data_C0ED:
  .incbin "prg_bank_0.bin", $00ED, $9  ; $C0ED
Data_C0F6:
  .incbin "prg_bank_0.bin", $00F6, $1B  ; $C0F6
Data_C111:
  .incbin "prg_bank_0.bin", $0111, $1B  ; $C111
Data_C12C:
  .byte <(Sub_CB3B), <(Sub_CB77), <(Sub_CBA4), <(Sub_CC6B)  ; $C12C pointer table (low bytes)
Data_C130:
  .byte >(Sub_CB3B), >(Sub_CB77), >(Sub_CBA4), >(Sub_CC6B)  ; $C130 pointer table (high bytes)
Data_C134:
  .incbin "prg_bank_0.bin", $0134, $8  ; $C134
Data_C13C:
  .incbin "prg_bank_0.bin", $013C, $B  ; $C13C
Data_C147:
  .incbin "prg_bank_0.bin", $0147, $9  ; $C147
Data_C150:
  .incbin "prg_bank_0.bin", $0150, $8  ; $C150
Data_C158:
  .incbin "prg_bank_0.bin", $0158, $8  ; $C158
Data_C160:
  .incbin "prg_bank_0.bin", $0160, $6  ; $C160
Data_C166:
  .incbin "prg_bank_0.bin", $0166, $4  ; $C166
Data_C16A:
  .incbin "prg_bank_0.bin", $016A, $6  ; $C16A
Data_C170:
  .incbin "prg_bank_0.bin", $0170, $8  ; $C170
Data_C178:
  .incbin "prg_bank_0.bin", $0178, $7  ; $C178
Data_C17F:
  .incbin "prg_bank_0.bin", $017F, $5  ; $C17F
Reset:
  sei                          ; $C184
  cld                          ; $C185
  lda #$00                     ; $C186
  sta PPU_CTRL                 ; $C188
  ldx #$FF                     ; $C18B
  txs                          ; $C18D
Loc_C18E:
  lda PPU_STATUS               ; $C18E
  and #$80                     ; $C191
  beq Loc_C18E                 ; $C193
Loc_C195:
  lda PPU_STATUS               ; $C195
  and #$80                     ; $C198
  beq Loc_C195                 ; $C19A
  ldy #$07                     ; $C19C
  lda BackupRamSigA5           ; $C19E
  cmp #$A5                     ; $C1A1
  bne Loc_C1AE                 ; $C1A3
  lda BackupRamSig5A           ; $C1A5
  cmp #$5A                     ; $C1A8
  bne Loc_C1AE                 ; $C1AA
  ldy #$04                     ; $C1AC
Loc_C1AE:
  sty z:$01                    ; $C1AE
  ldy #$00                     ; $C1B0
  sty z:$00                    ; $C1B2
  tya                          ; $C1B4
Loc_C1B5:
  sta ($00),y                  ; $C1B5
  dey                          ; $C1B7
  bne Loc_C1B5                 ; $C1B8
  dec z:$01                    ; $C1BA
  bpl Loc_C1B5                 ; $C1BC
  lda BackupRamSigA5           ; $C1BE
  bne Loc_C1C6                 ; $C1C1
  jsr InitBackupRam            ; $C1C3
Loc_C1C6:
  sta APU_DMC_RAW              ; $C1C6
  lda #$06                     ; $C1C9
  sta PPU_MASK                 ; $C1CB
  sta z:RandomState            ; $C1CE
  jsr InitScreenState          ; $C1D0
  lda #$90                     ; $C1D3
  jsr SetPpuCtrl               ; $C1D5
Loc_C1D8:
  jsr UpdateRandom             ; $C1D8
  lda z:$48                    ; $C1DB
  bmi Loc_C1D8                 ; $C1DD
  beq Loc_C1D8                 ; $C1DF
  jsr DisableNmi               ; $C1E1
  lda z:$48                    ; $C1E4
  cmp #$01                     ; $C1E6
  bne Loc_C1F7                 ; $C1E8
  jsr Sub_C6C8                 ; $C1EA
Loc_C1ED:
  lda #$FF                     ; $C1ED
  sta z:$48                    ; $C1EF
  jsr WaitVblankEndEnableNmi   ; $C1F1
  jmp Loc_C1D8                 ; $C1F4
Loc_C1F7:
  jsr Sub_C739                 ; $C1F7
  jmp Loc_C1ED                 ; $C1FA
InitBackupRam:
  ldx #$1E                     ; $C1FD
Loc_C1FF:
  lda Data_C091,x              ; $C1FF
  sta $0580,x                  ; $C202
  sta $05A3,x                  ; $C205
  dex                          ; $C208
  bpl Loc_C1FF                 ; $C209
  ldx #$01                     ; $C20B
  stx $06E0                    ; $C20D
Loc_C210:
  lda #$40                     ; $C210
  sta $06E0,x                  ; $C212
  inx                          ; $C215
  cpx #$CF                     ; $C216
  bcc Loc_C210                 ; $C218
  lda #$09                     ; $C21A
  sta $06E0,x                  ; $C21C
  lda #$A5                     ; $C21F
  sta BackupRamSigA5           ; $C221
  lda #$5A                     ; $C224
  sta BackupRamSig5A           ; $C226
  ldx #$00                     ; $C229
  lda #$0A                     ; $C22B
Loc_C22D:
  sta $05A0,x                  ; $C22D
  sta $05C3,x                  ; $C230
  lda #$00                     ; $C233
  inx                          ; $C235
  cpx #$03                     ; $C236
  bcc Loc_C22D                 ; $C238
  rts                          ; $C23A
Nmi:
  jsr DisableNmi               ; $C23B
  lda z:PpuUpdateIndex         ; $C23E
  bne Loc_C24B                 ; $C240
  lda z:PpuMaskShadow          ; $C242
  ora #$1A                     ; $C244
  sta PPU_MASK                 ; $C246
  sta z:PpuMaskShadow          ; $C249
Loc_C24B:
  lda #$00                     ; $C24B
  sta OAM_ADDR                 ; $C24D
  lda #$02                     ; $C250
  sta OAM_DMA                  ; $C252
  jsr FlushPpuUpdate           ; $C255
  lda z:$47                    ; $C258
  beq Loc_C262                 ; $C25A
  jsr Sub_D0AB                 ; $C25C
  jsr Sub_D14E                 ; $C25F
Loc_C262:
  lda $03B1                    ; $C262
  ora $03B2                    ; $C265
  bne Loc_C26F                 ; $C268
  inc z:FrameCounter           ; $C26A
  jsr TickTimers               ; $C26C
Loc_C26F:
  jsr ReadJoypads              ; $C26F
  jsr Sub_F844                 ; $C272
  jsr GameStateDispatch        ; $C275
  lda PPU_STATUS               ; $C278
  jsr WaitVblankEndEnableNmi   ; $C27B
  rti                          ; $C27E
FlushPpuUpdate:
  ldx z:PpuUpdateIndex         ; $C27F
  lda Data_C0F6,x              ; $C281
  sta z:$00                    ; $C284
  lda Data_C111,x              ; $C286
Loc_C289:
  sta z:$01                    ; $C289
  jsr RunPpuWriteList          ; $C28B
  lda #$00                     ; $C28E
  sta $0300                    ; $C290
  sta $0301                    ; $C293
  sta z:PpuUpdateIndex         ; $C296
  lda #$3F                     ; $C298
  sta PPU_ADDR                 ; $C29A
  lda #$00                     ; $C29D
  sta PPU_ADDR                 ; $C29F
  sta PPU_ADDR                 ; $C2A2
  sta PPU_ADDR                 ; $C2A5
  rts                          ; $C2A8
GameStateDispatch:
  ldx z:GameStateActive        ; $C2A9
  beq Loc_C2ED                 ; $C2AB
  lda z:GameState              ; $C2AD
  asl a                        ; $C2AF
  tay                          ; $C2B0
  lda Data_C000,y              ; $C2B1
  sta z:$00                    ; $C2B4
  iny                          ; $C2B6
  lda Data_C000,y              ; $C2B7
  jmp Loc_CB36                 ; $C2BA
  lda #$04                     ; $C2BD
  sta $03F8                    ; $C2BF
  lsr a                        ; $C2C2
  sta z:PpuUpdateIndex         ; $C2C3
  ldy #$00                     ; $C2C5
  jsr Sub_C409                 ; $C2C7
  ldx $03F0                    ; $C2CA
  bne Loc_C2D3                 ; $C2CD
  lda #$01                     ; $C2CF
  sta z:$FB                    ; $C2D1
Loc_C2D3:
  cpx #$02                     ; $C2D3
  bmi Loc_C2D9                 ; $C2D5
  ldx #$FF                     ; $C2D7
Loc_C2D9:
  inx                          ; $C2D9
  stx $03F0                    ; $C2DA
  lda #$38                     ; $C2DD
  sta z:$31                    ; $C2DF
  lda #$0F                     ; $C2E1
  sta APU_SND_CHN              ; $C2E3
  lda Data_C080                ; $C2E6
  sta OamBuffer                ; $C2E9
Loc_C2EC:
  rts                          ; $C2EC
Loc_C2ED:
  jsr Sub_D24F                 ; $C2ED
  lda z:$30                    ; $C2F0
  bne Loc_C2EC                 ; $C2F2
  ldx z:GameState              ; $C2F4
  lda Data_C01C,x              ; $C2F6
  tax                          ; $C2F9
  lda Data_C02A,x              ; $C2FA
  sta z:$02                    ; $C2FD
  lda Data_C033,x              ; $C2FF
  sta z:$03                    ; $C302
  ldy z:$44                    ; $C304
  inc z:$44                    ; $C306
  dey                          ; $C308
  bmi InitScreenState          ; $C309
  tya                          ; $C30B
  asl a                        ; $C30C
  tay                          ; $C30D
  lda ($02),y                  ; $C30E
  sta z:$00                    ; $C310
  iny                          ; $C312
  lda ($02),y                  ; $C313
  jmp Loc_CB36                 ; $C315
InitScreenState:
  jsr ClearOam                 ; $C318
  jsr Sub_D23B                 ; $C31B
  jsr ResetPpuScroll           ; $C31E
  sta z:ScrollX                ; $C321
  sta z:SplitScrollX           ; $C323
  sta z:ScrollY                ; $C325
  sta z:SplitScrollY           ; $C327
  sta z:$FC                    ; $C329
  lda #$10                     ; $C32B
  bne SetPpuCtrl               ; $C32D
DisableNmi:
  lda z:PpuCtrlShadow          ; $C32F
  and #$7F                     ; $C331
SetPpuCtrl:
  sta PPU_CTRL                 ; $C333
  sta z:PpuCtrlShadow          ; $C336
  rts                          ; $C338
WaitVblankEndEnableNmi:
  lda PPU_STATUS               ; $C339
  and #$80                     ; $C33C
  bne WaitVblankEndEnableNmi   ; $C33E
  lda z:PpuCtrlShadow          ; $C340
  ora #$80                     ; $C342
  bne SetPpuCtrl               ; $C344
  lda z:$31                    ; $C346
  bne Loc_C359                 ; $C348
  sta z:$43                    ; $C34A
  sta z:$4A                    ; $C34C
  lda #$0F                     ; $C34E
  sta $03F7                    ; $C350
  lda #$02                     ; $C353
  sta z:GameState              ; $C355
  bne Loc_C389                 ; $C357
Loc_C359:
  lda #$03                     ; $C359
  jsr Sub_C7DE                 ; $C35B
  txa                          ; $C35E
  bne Loc_C36A                 ; $C35F
  sta $03F2                    ; $C361
  lda Data_C080,y              ; $C364
  jmp Loc_C3EF                 ; $C367
Loc_C36A:
  ldy z:$42                    ; $C36A
  ldx #$00                     ; $C36C
  stx $03F7                    ; $C36E
  stx z:$43                    ; $C371
  stx z:$42                    ; $C373
  inx                          ; $C375
  stx $03F3                    ; $C376
  stx z:$4A                    ; $C379
  stx $03F0                    ; $C37B
  cpy #$02                     ; $C37E
  bne Loc_C384                 ; $C380
  ldx #$08                     ; $C382
Loc_C384:
  stx z:GameState              ; $C384
  sty $03F2                    ; $C386
Loc_C389:
  jsr Sub_C3B1                 ; $C389
  lda $03F7                    ; $C38C
  eor #$0F                     ; $C38F
  sta APU_SND_CHN              ; $C391
  rts                          ; $C394
  lda z:Joy1Trigger            ; $C395
  and #$F3                     ; $C397
  sta z:Joy1Trigger            ; $C399
  and #$03                     ; $C39B
  asl a                        ; $C39D
  asl a                        ; $C39E
  ora z:Joy1Trigger            ; $C39F
  sta z:Joy1Trigger            ; $C3A1
  lda #$05                     ; $C3A3
  jsr Sub_C7DE                 ; $C3A5
  txa                          ; $C3A8
  beq Loc_C3B8                 ; $C3A9
  lda z:$42                    ; $C3AB
  sta z:$43                    ; $C3AD
Sub_C3AF:
  inc z:GameState              ; $C3AF
Sub_C3B1:
  lda #$00                     ; $C3B1
  sta z:GameStateActive        ; $C3B3
  sta z:$44                    ; $C3B5
  rts                          ; $C3B7
Loc_C3B8:
  lda Data_C083,y              ; $C3B8
  bne Loc_C411                 ; $C3BB
  lda #$06                     ; $C3BD
  jsr Sub_C7DE                 ; $C3BF
  txa                          ; $C3C2
  beq Loc_C3EA                 ; $C3C3
  lda z:$42                    ; $C3C5
  cmp #$02                     ; $C3C7
  beq Loc_C3D2                 ; $C3C9
  bcs Loc_C3D5                 ; $C3CB
  sta $03F2                    ; $C3CD
  inc z:GameState              ; $C3D0
Loc_C3D2:
  jmp Sub_C3AF                 ; $C3D2
Loc_C3D5:
  cmp #$05                     ; $C3D5
  beq Loc_C3E4                 ; $C3D7
  clc                          ; $C3D9
  adc #$09                     ; $C3DA
  sta z:GameState              ; $C3DC
  lda #$00                     ; $C3DE
  sta z:$42                    ; $C3E0
  beq Sub_C3B1                 ; $C3E2
Loc_C3E4:
  lsr a                        ; $C3E4
  sta z:$42                    ; $C3E5
  jmp Loc_CA85                 ; $C3E7
Loc_C3EA:
  ldy z:$42                    ; $C3EA
  lda Data_C08B,y              ; $C3EC
Loc_C3EF:
  sta OamBuffer                ; $C3EF
  rts                          ; $C3F2
  ldx #$04                     ; $C3F3
  stx z:$FB                    ; $C3F5
  dex                          ; $C3F7
  stx z:PpuUpdateIndex         ; $C3F8
  ldy #$01                     ; $C3FA
  jsr Sub_C409                 ; $C3FC
  sta z:$42                    ; $C3FF
  lda #$2D                     ; $C401
  sta z:$34                    ; $C403
  lda #$B0                     ; $C405
  bne Loc_C3EF                 ; $C407
Sub_C409:
  lda #$FA                     ; $C409
  sta $0201                    ; $C40B
  lda Data_C088,y              ; $C40E
Loc_C411:
  sta $0203                    ; $C411
  lda #$00                     ; $C414
  sta $0202                    ; $C416
  sta z:$46                    ; $C419
  rts                          ; $C41B
  lda #$02                     ; $C41C  [heuristic code]
  ldx z:$44                    ; $C41E
  beq Loc_C450                 ; $C420
  lda z:$48                    ; $C422
  cmp #$FF                     ; $C424
  bne Loc_C454                 ; $C426
  ldx #$02                     ; $C428
Loc_C42A:
  lda z:$65,x                  ; $C42A
  sta $05A0,x                  ; $C42C
  lda z:$68,x                  ; $C42F
  sta $05C3,x                  ; $C431
  dex                          ; $C434
  bpl Loc_C42A                 ; $C435
  jsr Sub_EC3B                 ; $C437
  jmp Loc_C447                 ; $C43A
  .incbin "prg_bank_0.bin", $043D, $A  ; $C43D
Loc_C447:
  lda #$40                     ; $C447
  sta z:$FB                    ; $C449
  jmp Sub_CC6B                 ; $C44B
  .incbin "prg_bank_0.bin", $044E, $2  ; $C44E
Loc_C450:
  sta z:$48                    ; $C450
  sta z:$44                    ; $C452
Loc_C454:
  rts                          ; $C454
  ldy #$08                     ; $C455
  lda z:GameState              ; $C457
  cmp #$08                     ; $C459
  bcs Loc_C462                 ; $C45B
  lda z:$46                    ; $C45D
  beq Loc_C464                 ; $C45F
  dey                          ; $C461
Loc_C462:
  sty z:PpuUpdateIndex         ; $C462
Loc_C464:
  rts                          ; $C464
  lda z:$34                    ; $C465  [heuristic code]
  beq Loc_C477                 ; $C467
  lda #$06                     ; $C469
  jsr Sub_C92C                 ; $C46B
  lda z:FrameCounter           ; $C46E
  and #$10                     ; $C470
  bne Loc_C464                 ; $C472
  jmp Loc_CAFA                 ; $C474
Loc_C477:
  jsr Sub_C3AF                 ; $C477
  lda z:GameState              ; $C47A
  cmp #$08                     ; $C47C
  bcc Loc_C482                 ; $C47E
  lda #$02                     ; $C480
Loc_C482:
  sta z:GameState              ; $C482
  rts                          ; $C484
  jsr Sub_C53A                 ; $C485
  lda z:$05                    ; $C488
  cmp z:$68                    ; $C48A
  bne Loc_C49A                 ; $C48C
  lda z:$06                    ; $C48E
  cmp z:$69                    ; $C490
  bne Loc_C49A                 ; $C492
  lda z:$07                    ; $C494
  cmp z:$6A                    ; $C496
  beq Loc_C4A9                 ; $C498
Loc_C49A:
  bcc Loc_C4AD                 ; $C49A
  ldx #$00                     ; $C49C
Loc_C49E:
  lda z:$68,x                  ; $C49E
  sta $0580,y                  ; $C4A0
  inx                          ; $C4A3
  iny                          ; $C4A4
  cpx #$03                     ; $C4A5
  bmi Loc_C49E                 ; $C4A7
Loc_C4A9:
  lda #$01                     ; $C4A9
  bne Loc_C512                 ; $C4AB
Loc_C4AD:
  lda z:GameState              ; $C4AD
  cmp #$08                     ; $C4AF
  bcs Loc_C4CC                 ; $C4B1
  jsr Sub_C522                 ; $C4B3
  lda z:$05                    ; $C4B6
  cmp z:$68                    ; $C4B8
  bne Loc_C4C6                 ; $C4BA
  lda z:$06                    ; $C4BC
  cmp z:$69                    ; $C4BE
  bne Loc_C4C6                 ; $C4C0
  lda z:$07                    ; $C4C2
  cmp z:$6A                    ; $C4C4
Loc_C4C6:
  bcc Loc_C4CC                 ; $C4C6
  lda #$02                     ; $C4C8
  bne Loc_C512                 ; $C4CA
Loc_C4CC:
  lda $03F8                    ; $C4CC
  sta z:$0A                    ; $C4CF
  asl a                        ; $C4D1
  sta z:$09                    ; $C4D2
  lda z:$68                    ; $C4D4
  sec                          ; $C4D6
  sbc z:$05                    ; $C4D7
  tay                          ; $C4D9
  lda #$00                     ; $C4DA
Loc_C4DC:
  dey                          ; $C4DC
  bmi Loc_C4E8                 ; $C4DD
  clc                          ; $C4DF
  adc #$3C                     ; $C4E0
  bcc Loc_C4DC                 ; $C4E2
Loc_C4E4:
  lda #$FF                     ; $C4E4
  bne Loc_C50B                 ; $C4E6
Loc_C4E8:
  sta z:$08                    ; $C4E8
  lda z:$69                    ; $C4EA
  sec                          ; $C4EC
  sbc z:$06                    ; $C4ED
  bcs Loc_C4F7                 ; $C4EF
  clc                          ; $C4F1
  adc z:$08                    ; $C4F2
  jmp Loc_C4FC                 ; $C4F4
Loc_C4F7:
  clc                          ; $C4F7
  adc z:$08                    ; $C4F8
  bcs Loc_C4E4                 ; $C4FA
Loc_C4FC:
  cmp z:$09                    ; $C4FC
  bcs Loc_C50B                 ; $C4FE
  clc                          ; $C500
  adc z:$09                    ; $C501
Loc_C503:
  lsr z:$0A                    ; $C503
  beq Loc_C512                 ; $C505
  lsr a                        ; $C507
  jmp Loc_C503                 ; $C508
Loc_C50B:
  sec                          ; $C50B
  sbc z:$09                    ; $C50C
  lsr a                        ; $C50E
  clc                          ; $C50F
  adc #$04                     ; $C510
Loc_C512:
  sta z:$53                    ; $C512
  lda #$18                     ; $C514
  sta z:PpuUpdateIndex         ; $C516
  lda #$01                     ; $C518
  sta z:$49                    ; $C51A
  sta z:GameStateActive        ; $C51C
  lsr a                        ; $C51E
  sta z:$44                    ; $C51F
  rts                          ; $C521
Sub_C522:
  lda z:$43                    ; $C522
  sta z:$02                    ; $C524
  jsr Sub_CB13                 ; $C526
  tay                          ; $C529
  lda Data_C091,y              ; $C52A
  sta z:$05                    ; $C52D
  lda Data_C092,y              ; $C52F
  sta z:$06                    ; $C532
  lda Data_C093,y              ; $C534
  sta z:$07                    ; $C537
  rts                          ; $C539
Sub_C53A:
  lda z:$43                    ; $C53A
  sta z:$02                    ; $C53C
Sub_C53E:
  jsr Sub_CB06                 ; $C53E
  lda $0580,y                  ; $C541
  sta z:$05                    ; $C544
  lda $0581,y                  ; $C546
  sta z:$06                    ; $C549
  lda $0582,y                  ; $C54B
  sta z:$07                    ; $C54E
  rts                          ; $C550
  lda #$12                     ; $C551
  ldx z:GameState              ; $C553
  cpx #$08                     ; $C555
  bcs Loc_C56E                 ; $C557
  clc                          ; $C559
  adc z:$43                    ; $C55A
  bne Loc_C56E                 ; $C55C
  lda #$06                     ; $C55E
  bne Loc_C56E                 ; $C560
  lda #$05                     ; $C562
  bne Loc_C56E                 ; $C564
  lda #$0E                     ; $C566
  bne Loc_C56E                 ; $C568
  lda #$04                     ; $C56A
  sta z:$33                    ; $C56C
Loc_C56E:
  sta z:PpuUpdateIndex         ; $C56E
  rts                          ; $C570
  .incbin "prg_bank_0.bin", $0571, $32  ; $C571
  lda #$17                     ; $C5A3
  bne Loc_C56E                 ; $C5A5
  lda #$00                     ; $C5A7
  jmp Sub_C92C                 ; $C5A9
  lda #$12                     ; $C5AC  [heuristic code]
  sta z:$34                    ; $C5AE
  ldx #$05                     ; $C5B0
Loc_C5B2:
  lda Data_C13C,x              ; $C5B2
  sta $0300,x                  ; $C5B5
  dex                          ; $C5B8
  bpl Loc_C5B2                 ; $C5B9
  ldx z:$43                    ; $C5BB
  inx                          ; $C5BD
  stx $0304                    ; $C5BE
  rts                          ; $C5C1
  ldx #$01                     ; $C5C2  [heuristic code]
  stx z:$B7                    ; $C5C4
  jsr Sub_C621                 ; $C5C6
  stx z:$BD                    ; $C5C9
  stx z:$BE                    ; $C5CB
  stx z:$C4                    ; $C5CD
  stx z:$C0                    ; $C5CF
  stx z:$49                    ; $C5D1
  stx z:$C2                    ; $C5D3
  inx                          ; $C5D5
  stx $05E0                    ; $C5D6
  lda #$06                     ; $C5D9
  sta z:$AC                    ; $C5DB
  lda #$A0                     ; $C5DD
  sta z:$8C                    ; $C5DF
  lda #$10                     ; $C5E1
  sta z:$80                    ; $C5E3
  lda #$04                     ; $C5E5
  sta z:$04                    ; $C5E7
  ldx #$00                     ; $C5E9
  stx z:$0B                    ; $C5EB
  jsr Sub_E1A3                 ; $C5ED
  ldx #$07                     ; $C5F0
Loc_C5F2:
  lda Data_C178,x              ; $C5F2
  sta $0228,x                  ; $C5F5
  dex                          ; $C5F8
  bpl Loc_C5F2                 ; $C5F9
  lda #$05                     ; $C5FB
  sta z:$B1                    ; $C5FD
  sta z:$B2                    ; $C5FF
  lda #$21                     ; $C601
  sta z:$B0                    ; $C603
  lda #$03                     ; $C605
  sta z:$B3                    ; $C607
  lda #$08                     ; $C609
  sta z:$64                    ; $C60B
  sta z:$E0                    ; $C60D
  inc z:$E0                    ; $C60F
  lda #$7A                     ; $C611
  sta z:$B4                    ; $C613
  inc z:GameStateActive        ; $C615
  inc z:$47                    ; $C617
  lda #$D0                     ; $C619
  jsr Sub_EC25                 ; $C61B
  jmp Loc_EC47                 ; $C61E
Sub_C621:
  ldx #$00                     ; $C621
Loc_C623:
  lda $06E0,x                  ; $C623
  sta $05E0,x                  ; $C626
  dex                          ; $C629
  bne Loc_C623                 ; $C62A
  rts                          ; $C62C
Sub_C62D:
  lda #$05                     ; $C62D
  sta JOYPAD1                  ; $C62F
  pha                          ; $C632
  pla                          ; $C633
  pha                          ; $C634
  pla                          ; $C635
  pha                          ; $C636
  pla                          ; $C637
  rts                          ; $C638
Sub_C639:
  jsr Sub_C62D                 ; $C639
  lda JOYPAD1                  ; $C63C
  and #$02                     ; $C63F
  beq Sub_C639                 ; $C641
Loc_C643:
  jsr Sub_C62D                 ; $C643
  lda JOYPAD1                  ; $C646
  and #$02                     ; $C649
  bne Loc_C643                 ; $C64B
  rts                          ; $C64D
Sub_C64E:
  pha                          ; $C64E
  lda #$34                     ; $C64F
  bne Loc_C656                 ; $C651
Sub_C653:
  pha                          ; $C653
  lda #$6A                     ; $C654
Loc_C656:
  sta z:$07                    ; $C656
  sta z:$0C                    ; $C658
  lda #$04                     ; $C65A
  sta JOYPAD1                  ; $C65C
Loc_C65F:
  dec z:$07                    ; $C65F
  bne Loc_C65F                 ; $C661
  lda #$FF                     ; $C663
  sta JOYPAD1                  ; $C665
Loc_C668:
  dec z:$0C                    ; $C668
  bne Loc_C668                 ; $C66A
  pla                          ; $C66C
  rts                          ; $C66D
Sub_C66E:
  jsr Sub_C653                 ; $C66E
  ldx #$08                     ; $C671
Loc_C673:
  sta z:$00                    ; $C673
  clc                          ; $C675
  adc z:$00                    ; $C676
  bcs Loc_C681                 ; $C678
  jsr Sub_C64E                 ; $C67A
Loc_C67D:
  dex                          ; $C67D
  bne Loc_C673                 ; $C67E
  rts                          ; $C680
Loc_C681:
  jsr Sub_C653                 ; $C681
  jsr Sub_C68A                 ; $C684
  jmp Loc_C67D                 ; $C687
Sub_C68A:
  inc z:$08                    ; $C68A
  bne Loc_C690                 ; $C68C
  inc z:$09                    ; $C68E
Loc_C690:
  rts                          ; $C690
Sub_C691:
  jsr Sub_C639                 ; $C691
  lda #$4E                     ; $C694
  sta z:$01                    ; $C696
Loc_C698:
  dec z:$01                    ; $C698
  bne Loc_C698                 ; $C69A
  jsr Sub_C62D                 ; $C69C
  lda JOYPAD1                  ; $C69F
  and #$02                     ; $C6A2
  rts                          ; $C6A4
Sub_C6A5:
  lda #$08                     ; $C6A5
  sta z:$03                    ; $C6A7
  lda #$00                     ; $C6A9
  sta z:$04                    ; $C6AB
Loc_C6AD:
  lda z:$04                    ; $C6AD
  clc                          ; $C6AF
  adc z:$04                    ; $C6B0
  sta z:$04                    ; $C6B2
  jsr Sub_C691                 ; $C6B4
  bne Loc_C6BE                 ; $C6B7
  jsr Sub_C68A                 ; $C6B9
  inc z:$04                    ; $C6BC
Loc_C6BE:
  dec z:$03                    ; $C6BE
  bne Loc_C6AD                 ; $C6C0
  jsr Sub_C639                 ; $C6C2
  lda z:$04                    ; $C6C5
  rts                          ; $C6C7
Sub_C6C8:
  jsr Sub_C716                 ; $C6C8
  jsr Sub_C6D1                 ; $C6CB
  jsr Sub_C726                 ; $C6CE
Sub_C6D1:
  lda #$20                     ; $C6D1
  sta z:$0A                    ; $C6D3
  lda #$4E                     ; $C6D5
  sta z:$0B                    ; $C6D7
Loc_C6D9:
  jsr Sub_C64E                 ; $C6D9
  dec z:$0A                    ; $C6DC
  bne Loc_C6D9                 ; $C6DE
  dec z:$0B                    ; $C6E0
  bne Loc_C6D9                 ; $C6E2
Loc_C6E4:
  jsr Sub_C653                 ; $C6E4
  dec z:$05                    ; $C6E7
  bne Loc_C6E4                 ; $C6E9
Loc_C6EB:
  jsr Sub_C64E                 ; $C6EB
  dec z:$06                    ; $C6EE
  bne Loc_C6EB                 ; $C6F0
  jsr Sub_C653                 ; $C6F2
  lda #$00                     ; $C6F5
  sta z:$08                    ; $C6F7
  sta z:$09                    ; $C6F9
  ldy #$00                     ; $C6FB
Loc_C6FD:
  lda ($0E),y                  ; $C6FD
  jsr Sub_C66E                 ; $C6FF
  iny                          ; $C702
  cpy z:$0D                    ; $C703
  bne Loc_C6FD                 ; $C705
  lda z:$09                    ; $C707
  pha                          ; $C709
  lda z:$08                    ; $C70A
  jsr Sub_C66E                 ; $C70C
  pla                          ; $C70F
  jsr Sub_C66E                 ; $C710
  jmp Sub_C653                 ; $C713
Sub_C716:
  lda #$40                     ; $C716
  sta z:$0D                    ; $C718
  lda #$60                     ; $C71A
  sta z:$0E                    ; $C71C
  lda #$00                     ; $C71E
  sta z:$0F                    ; $C720
  lda #$28                     ; $C722
  bne Loc_C734                 ; $C724
Sub_C726:
  lda #$00                     ; $C726
  sta z:$0D                    ; $C728
  lda #$E0                     ; $C72A
  sta z:$0E                    ; $C72C
  lda #$05                     ; $C72E
  sta z:$0F                    ; $C730
  lda #$14                     ; $C732
Loc_C734:
  sta z:$05                    ; $C734
  sta z:$06                    ; $C736
  rts                          ; $C738
Sub_C739:
  jsr DisableNmi               ; $C739
  jsr Sub_C716                 ; $C73C
  jsr Sub_C792                 ; $C73F
  bcc Loc_C751                 ; $C742
Loc_C744:
  lda #$19                     ; $C744
  sta z:PpuUpdateIndex         ; $C746
Loc_C748:
  jsr WaitVblankEndEnableNmi   ; $C748
Loc_C74B:
  lda z:PpuUpdateIndex         ; $C74B
  bne Loc_C74B                 ; $C74D
  beq Sub_C739                 ; $C74F
Loc_C751:
  ldx #$00                     ; $C751
  stx z:$A8                    ; $C753
  ldy #$01                     ; $C755
Loc_C757:
  lda ($0E),y                  ; $C757
  sta a:$A3,y                  ; $C759
  cmp Data_C17F,y              ; $C75C
  beq Loc_C762                 ; $C75F
  inx                          ; $C761
Loc_C762:
  iny                          ; $C762
  cpy #$05                     ; $C763
  bne Loc_C757                 ; $C765
  lda #$07                     ; $C767
  sta z:$A0                    ; $C769
  lda #$22                     ; $C76B
  sta z:$A1                    ; $C76D
  lda #$4F                     ; $C76F
  sta z:$A2                    ; $C771
  lda #$04                     ; $C773
  sta z:$A3                    ; $C775
  lda #$1A                     ; $C777
  sta z:PpuUpdateIndex         ; $C779
  cpx #$00                     ; $C77B
  bne Loc_C748                 ; $C77D
  jsr WaitVblankEndEnableNmi   ; $C77F
Loc_C782:
  lda z:PpuUpdateIndex         ; $C782
  bne Loc_C782                 ; $C784
  jsr DisableNmi               ; $C786
  jsr Sub_C726                 ; $C789
  jsr Sub_C792                 ; $C78C
  bcs Loc_C744                 ; $C78F
  rts                          ; $C791
Sub_C792:
  lda z:$05                    ; $C792
  sta z:$00                    ; $C794
Loc_C796:
  jsr Sub_C691                 ; $C796
  bne Sub_C792                 ; $C799
  dec z:$00                    ; $C79B
  bne Loc_C796                 ; $C79D
  lda z:$06                    ; $C79F
  sta z:$00                    ; $C7A1
Loc_C7A3:
  jsr Sub_C691                 ; $C7A3
  beq Sub_C792                 ; $C7A6
  dec z:$00                    ; $C7A8
  bne Loc_C7A3                 ; $C7AA
  lda #$00                     ; $C7AC
  sta z:$08                    ; $C7AE
  sta z:$09                    ; $C7B0
  jsr Sub_C639                 ; $C7B2
  jsr Sub_C639                 ; $C7B5
  ldy #$00                     ; $C7B8
Loc_C7BA:
  jsr Sub_C6A5                 ; $C7BA
  sta ($0E),y                  ; $C7BD
  iny                          ; $C7BF
  cpy z:$0D                    ; $C7C0
  bne Loc_C7BA                 ; $C7C2
  lda z:$08                    ; $C7C4
  sta z:$0A                    ; $C7C6
  lda z:$09                    ; $C7C8
  sta z:$0B                    ; $C7CA
  jsr Sub_C6A5                 ; $C7CC
  cmp z:$0A                    ; $C7CF
  bne Loc_C7DA                 ; $C7D1
  jsr Sub_C6A5                 ; $C7D3
  cmp z:$0B                    ; $C7D6
  beq Loc_C7DC                 ; $C7D8
Loc_C7DA:
  sec                          ; $C7DA
  rts                          ; $C7DB
Loc_C7DC:
  clc                          ; $C7DC
  rts                          ; $C7DD
Sub_C7DE:
  sta z:$00                    ; $C7DE
  ldy z:$42                    ; $C7E0
  ldx #$00                     ; $C7E2
  lda z:Joy1Trigger            ; $C7E4
  and #$3C                     ; $C7E6
  bne Loc_C7ED                 ; $C7E8
  sta z:$49                    ; $C7EA
Loc_C7EC:
  rts                          ; $C7EC
Loc_C7ED:
  lda #$5D                     ; $C7ED
  sta z:$31                    ; $C7EF
  lda z:$49                    ; $C7F1
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
  sta z:$FF                    ; $C819
Loc_C81B:
  sty z:$42                    ; $C81B
  inc z:$49                    ; $C81D
  rts                          ; $C81F
  jsr Sub_D13F                 ; $C820
  lda #$03                     ; $C823
  sta z:$01                    ; $C825
  lsr a                        ; $C827
  sta z:PpuUpdateIndex         ; $C828
  lsr a                        ; $C82A
  sta z:$00                    ; $C82B
  sta z:$4B                    ; $C82D
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
  inc z:$47                    ; $C875
  inc z:GameStateActive        ; $C877
  lda z:$34                    ; $C879
  bne Loc_C87F                 ; $C87B
  lda #$05                     ; $C87D
Loc_C87F:
  sta z:$34                    ; $C87F
  lda #$34                     ; $C881
  sta z:$E8                    ; $C883
  lda #$14                     ; $C885
  sta z:$E9                    ; $C887
  lda #$A0                     ; $C889
  sta $03F1                    ; $C88B
  lda #$80                     ; $C88E
  sta $03B4                    ; $C890
  sta $03B0                    ; $C893
  lda #$FF                     ; $C896
  sta $03BD                    ; $C898
  ldx #$01                     ; $C89B
  stx $0370                    ; $C89D
  inx                          ; $C8A0
  stx $03BE                    ; $C8A1
  inx                          ; $C8A4
  lda $03F2                    ; $C8A5
  bne Loc_C8AC                 ; $C8A8
  ldx #$00                     ; $C8AA
Loc_C8AC:
  lda Data_C0B4,x              ; $C8AC
  sta z:$B8,x                  ; $C8AF
  lda #$08                     ; $C8B1
  sta z:$64,x                  ; $C8B3
  lda Data_C0B0,x              ; $C8B5
  sta z:$E0,x                  ; $C8B8
  lda Data_C0B8,x              ; $C8BA
  sta z:$80,x                  ; $C8BD
  lda #$06                     ; $C8BF
  sta z:$AC,x                  ; $C8C1
  sta z:$78,x                  ; $C8C3
  lda #$01                     ; $C8C5
  sta z:$84,x                  ; $C8C7
  sta z:$A8,x                  ; $C8C9
  lda z:$19,x                  ; $C8CB
  lsr a                        ; $C8CD
  sta z:$74,x                  ; $C8CE
  dex                          ; $C8D0
  bpl Loc_C8AC                 ; $C8D1
  lda z:$19,x                  ; $C8D3
  and #$03                     ; $C8D5
  bne Loc_C8DB                 ; $C8D7
  lda #$02                     ; $C8D9
Loc_C8DB:
  tax                          ; $C8DB
  lsr z:$78,x                  ; $C8DC
  lda z:$46                    ; $C8DE
  beq Loc_C902                 ; $C8E0
  lda z:$43                    ; $C8E2
  cmp #$04                     ; $C8E4
  bne Loc_C902                 ; $C8E6
  ldx #$07                     ; $C8E8
Loc_C8EA:
  lda Data_C158,x              ; $C8EA
  sta $0300,x                  ; $C8ED
  dex                          ; $C8F0
  bpl Loc_C8EA                 ; $C8F1
  lda $03F3                    ; $C8F3
  jsr DivMod10                 ; $C8F6
  sta $0307                    ; $C8F9
  txa                          ; $C8FC
  beq Loc_C902                 ; $C8FD
  sta $0306                    ; $C8FF
Loc_C902:
  jsr Sub_C522                 ; $C902
  lda z:GameState              ; $C905
  cmp #$08                     ; $C907
  bcc Loc_C90E                 ; $C909
  jsr Sub_C53A                 ; $C90B
Loc_C90E:
  lda $03F8                    ; $C90E
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
  jsr Sub_C935                 ; $C927
  lda #$08                     ; $C92A
Sub_C92C:
  ldy z:$43                    ; $C92C
  sty z:$02                    ; $C92E
  sta z:$03                    ; $C930
  jsr Sub_C53E                 ; $C932
Sub_C935:
  ldx #$05                     ; $C935
  jsr Sub_DF7F                 ; $C937
  ldx $0300                    ; $C93A
  ldy #$00                     ; $C93D
Loc_C93F:
  lda $03D1,y                  ; $C93F
  sta $0304,x                  ; $C942
  inx                          ; $C945
  iny                          ; $C946
  cpy #$07                     ; $C947
  bcc Loc_C93F                 ; $C949
Sub_C94B:
  lda #$0A                     ; $C94B
  jsr Sub_C971                 ; $C94D
  ldy z:$03                    ; $C950
  lda Data_C0EC,y              ; $C952
  sta $0301,x                  ; $C955
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
Sub_C971:
  ldx $0300                    ; $C971
  clc                          ; $C974
  adc $0300                    ; $C975
  sta $0300                    ; $C978
  rts                          ; $C97B
  .incbin "prg_bank_0.bin", $097C, $1B  ; $C97C
Loc_C997:
  jmp Sub_D19B                 ; $C997
  jsr Sub_CA08                 ; $C99A
  lda $03B1                    ; $C99D
  ora $03B2                    ; $C9A0
  bne Loc_C997                 ; $C9A3
  jsr Sub_D918                 ; $C9A5
  jsr Sub_DD8D                 ; $C9A8
  jsr Sub_E733                 ; $C9AB
  jsr Sub_E927                 ; $C9AE
  lda z:$52                    ; $C9B1
  beq Loc_C9BB                 ; $C9B3
  jsr Sub_CA9B                 ; $C9B5
  jmp Loc_C9D5                 ; $C9B8
Loc_C9BB:
  lda $03F2                    ; $C9BB
  beq Loc_C9C9                 ; $C9BE
  jsr Sub_DA9F                 ; $C9C0
  jsr Sub_DBC4                 ; $C9C3
  jsr Sub_DEBB                 ; $C9C6
Loc_C9C9:
  jsr Sub_DF30                 ; $C9C9
  jsr Sub_EAC5                 ; $C9CC
  jsr Sub_DFD5                 ; $C9CF
  jsr Sub_E09F                 ; $C9D2
Loc_C9D5:
  jsr Sub_DDD1                 ; $C9D5
  jsr Sub_CD1F                 ; $C9D8
  jsr Sub_E96C                 ; $C9DB
  jsr Sub_DE31                 ; $C9DE
  jsr Sub_E836                 ; $C9E1
  jsr Sub_EA44                 ; $C9E4
  jsr Sub_F4FF                 ; $C9E7
  jsr Sub_E4C8                 ; $C9EA
  jsr Sub_DEE2                 ; $C9ED
  jsr Sub_E359                 ; $C9F0
  jsr Sub_E17F                 ; $C9F3
  jsr Sub_E456                 ; $C9F6
  jsr Sub_DA26                 ; $C9F9
  jsr Sub_E70B                 ; $C9FC
  jsr Sub_D19B                 ; $C9FF
  jsr Sub_CED0                 ; $CA02
  jmp Loc_E42B                 ; $CA05
Sub_CA08:
  ldx #$03                     ; $CA08
Loc_CA0A:
  jsr Sub_DCA0                 ; $CA0A
  jsr Sub_DFB2                 ; $CA0D
  dex                          ; $CA10
  bpl Loc_CA0A                 ; $CA11
  lda $03F7                    ; $CA13
  bne Loc_CA20                 ; $CA16
  jsr Sub_CA38                 ; $CA18
  lda z:Joy1Held               ; $CA1B
  sta z:$5C                    ; $CA1D
  rts                          ; $CA1F
Loc_CA20:
  lda $03F7                    ; $CA20
  beq Loc_CA84                 ; $CA23
  lda z:Joy1Trigger            ; $CA25
  asl a                        ; $CA27
  asl a                        ; $CA28
  asl a                        ; $CA29
  bcs Loc_CA85                 ; $CA2A
  asl a                        ; $CA2C
  bcc Loc_CA84                 ; $CA2D
  lda #$00                     ; $CA2F
  sta z:$42                    ; $CA31
  sta z:$47                    ; $CA33
  jmp Loc_C36A                 ; $CA35
Sub_CA38:
  lda $03B2                    ; $CA38
  bne Loc_CA63                 ; $CA3B
  lda z:Joy1Trigger            ; $CA3D
  and #$10                     ; $CA3F
  beq Loc_CA67                 ; $CA41
  lda $03B0                    ; $CA43
  bne Loc_CA67                 ; $CA46
  lda #$80                     ; $CA48
  sta z:$FB                    ; $CA4A
  sta $03B0                    ; $CA4C
  asl a                        ; $CA4F
  sta z:$FC                    ; $CA50
  lda $03B1                    ; $CA52
  eor #$01                     ; $CA55
  sta $03B1                    ; $CA57
  bne Loc_CA7F                 ; $CA5A
  lda #$0F                     ; $CA5C
  sta APU_SND_CHN              ; $CA5E
  bne Loc_CA7F                 ; $CA61
Loc_CA63:
  dec $03B2                    ; $CA63
  rts                          ; $CA66
Loc_CA67:
  sta $03B0                    ; $CA67
  lda $03B1                    ; $CA6A
  beq Loc_CA84                 ; $CA6D
  lda #$00                     ; $CA6F
  sta APU_SND_CHN              ; $CA71
  lda z:Joy1Trigger            ; $CA74
  and #$0F                     ; $CA76
  beq Loc_CA84                 ; $CA78
  lda $03B2                    ; $CA7A
  bne Loc_CA84                 ; $CA7D
Loc_CA7F:
  lda #$28                     ; $CA7F
  sta $03B2                    ; $CA81
Loc_CA84:
  rts                          ; $CA84
Loc_CA85:
  lda z:$42                    ; $CA85
  pha                          ; $CA87
  ldx #$FF                     ; $CA88
  lda #$00                     ; $CA8A
Loc_CA8C:
  sta z:$00,x                  ; $CA8C
  dex                          ; $CA8E
  cpx #$20                     ; $CA8F
  bne Loc_CA8C                 ; $CA91
  sta z:$FC                    ; $CA93
  inc z:$49                    ; $CA95
  pla                          ; $CA97
  sta z:$42                    ; $CA98
  rts                          ; $CA9A
Sub_CA9B:
  lda z:$32                    ; $CA9B
  bne Loc_CAAA                 ; $CA9D
  jsr Sub_C3AF                 ; $CA9F
  lda $03F7                    ; $CAA2
  bne Loc_CA85                 ; $CAA5
  sta z:$47                    ; $CAA7
Loc_CAA9:
  rts                          ; $CAA9
Loc_CAAA:
  lda #$00                     ; $CAAA
  sta z:$FC                    ; $CAAC
  sta $03A9                    ; $CAAE
  sta $03E0                    ; $CAB1
  sta z:$3C                    ; $CAB4
  ldx z:$52                    ; $CAB6
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
  ldy z:$43                    ; $CAE4
  lda Data_C160,y              ; $CAE6
  sta $0315                    ; $CAE9
  lda Data_C16A,y              ; $CAEC
  sta $0317                    ; $CAEF
  rts                          ; $CAF2
Loc_CAF3:
  ldx #$11                     ; $CAF3
  lda z:$32                    ; $CAF5
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
Sub_CB06:
  jsr Sub_CB13                 ; $CB06
  ldy $03F2                    ; $CB09
  beq Loc_CB11                 ; $CB0C
  clc                          ; $CB0E
  adc #$23                     ; $CB0F
Loc_CB11:
  tay                          ; $CB11
  rts                          ; $CB12
Sub_CB13:
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
  ldy z:$46                    ; $CB25
  beq Loc_CB2B                 ; $CB27
  ora #$10                     ; $CB29
Loc_CB2B:
  rts                          ; $CB2B
  ldy z:$44                    ; $CB2C
  lda Data_C12C,y              ; $CB2E
  sta z:$00                    ; $CB31
  lda Data_C130,y              ; $CB33
Loc_CB36:
  sta z:$01                    ; $CB36
  jmp ($0000)                  ; $CB38
Sub_CB3B:
  lda z:GameState              ; $CB3B
  cmp #$08                     ; $CB3D
  bcs Loc_CB73                 ; $CB3F
  lda $03F2                    ; $CB41
  sta z:$42                    ; $CB44
  lda z:$53                    ; $CB46
  cmp #$04                     ; $CB48
  bcs Loc_CB73                 ; $CB4A
  lda z:$46                    ; $CB4C
  beq Loc_CB6D                 ; $CB4E
  lda z:$43                    ; $CB50
  cmp #$04                     ; $CB52
  bne Loc_CB69                 ; $CB54
  inc $03F3                    ; $CB56
  lda $03F3                    ; $CB59
  lsr a                        ; $CB5C
  bcs Loc_CB6D                 ; $CB5D
  lda $03F8                    ; $CB5F
  lsr a                        ; $CB62
  beq Loc_CB6D                 ; $CB63
  sta $03F8                    ; $CB65
  sec                          ; $CB68
Loc_CB69:
  bcs Loc_CB6D                 ; $CB69
  inc z:$43                    ; $CB6B
Loc_CB6D:
  lda #$01                     ; $CB6D
  sta z:$46                    ; $CB6F
  sta z:$4B                    ; $CB71
Loc_CB73:
  lda #$04                     ; $CB73
  bne Loc_CB9F                 ; $CB75
Sub_CB77:
  ldy z:$33                    ; $CB77
  bne Loc_CBA3                 ; $CB79
  lda #$04                     ; $CB7B
  sta z:$03                    ; $CB7D
  ldx $0300                    ; $CB7F
Loc_CB82:
  lda $03D9,y                  ; $CB82
  sta $0304,x                  ; $CB85
  inx                          ; $CB88
  iny                          ; $CB89
  cpy #$07                     ; $CB8A
  bne Loc_CB82                 ; $CB8C
  jsr Sub_C94B                 ; $CB8E
  lda #$20                     ; $CB91
  ldx z:$4B                    ; $CB93
  bne Loc_CB99                 ; $CB95
  lda #$31                     ; $CB97
Loc_CB99:
  sta $03AD                    ; $CB99
  clc                          ; $CB9C
  adc #$03                     ; $CB9D
Loc_CB9F:
  sta z:$33                    ; $CB9F
  inc z:$44                    ; $CBA1
Loc_CBA3:
  rts                          ; $CBA3
Sub_CBA4:
  lda z:$33                    ; $CBA4
  beq Loc_CB9F                 ; $CBA6
  cmp $03AD                    ; $CBA8
  beq Loc_CBC9                 ; $CBAB
  bcs Loc_CBA3                 ; $CBAD
  lda z:$4B                    ; $CBAF
  bne Loc_CBB9                 ; $CBB1
  lda z:Joy1Held               ; $CBB3
  and #$F0                     ; $CBB5
  bne Loc_CBBF                 ; $CBB7
Loc_CBB9:
  jsr Sub_CC15                 ; $CBB9
  jmp Loc_CC7D                 ; $CBBC
Loc_CBBF:
  jsr Sub_CC6B                 ; $CBBF
  lda z:GameState              ; $CBC2
  bne Loc_CBA3                 ; $CBC4
  jmp Sub_C3AF                 ; $CBC6
Loc_CBC9:
  lda z:$20                    ; $CBC9
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
  jsr Sub_CCCA                 ; $CBE3
  dex                          ; $CBE6
  bpl Loc_CBD4                 ; $CBE7
  lda #$01                     ; $CBE9
  ldx z:$53                    ; $CBEB
  dex                          ; $CBED
  stx z:$00                    ; $CBEE
  cpx #$03                     ; $CBF0
  bcs Loc_CBF8                 ; $CBF2
  stx z:$0D                    ; $CBF4
  lda #$02                     ; $CBF6
Loc_CBF8:
  sta z:$FB                    ; $CBF8
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
Sub_CC15:
  lda $03AD                    ; $CC15
  sec                          ; $CC18
  sbc #$10                     ; $CC19
  cmp z:$33                    ; $CC1B
  bne Loc_CC32                 ; $CC1D
  lda z:$20                    ; $CC1F
  bne Loc_CC32                 ; $CC21
  lda #$0D                     ; $CC23
  ldy z:$52                    ; $CC25
  dey                          ; $CC27
  bne Loc_CC2F                 ; $CC28
  lda z:$4B                    ; $CC2A
  clc                          ; $CC2C
  adc #$0B                     ; $CC2D
Loc_CC2F:
  sta z:PpuUpdateIndex         ; $CC2F
  rts                          ; $CC31
Loc_CC32:
  lda #$07                     ; $CC32
  tay                          ; $CC34
  jsr Sub_C971                 ; $CC35
  stx z:$05                    ; $CC38
Loc_CC3A:
  lda Data_C134,y              ; $CC3A
  sta $0301,x                  ; $CC3D
  inx                          ; $CC40
  dey                          ; $CC41
  bpl Loc_CC3A                 ; $CC42
  lda z:FrameCounter           ; $CC44
  and #$10                     ; $CC46
  bne Loc_CC6A                 ; $CC48
  ldy z:$05                    ; $CC4A
  lda z:$53                    ; $CC4C
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
Sub_CC6B:
  jsr Sub_C3AF                 ; $CC6B
  lda z:$4B                    ; $CC6E
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
  jsr Sub_DD6F                 ; $CCA5
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
  ldx z:$53                    ; $CCBD
  dex                          ; $CCBF
  cpx #$03                     ; $CCC0
  bcc Loc_CCC6                 ; $CCC2
  ldx #$03                     ; $CCC4
Loc_CCC6:
  lda #$02                     ; $CCC6
  sta z:$0B                    ; $CCC8
Sub_CCCA:
  lda Data_C0DA,x              ; $CCCA
  sta z:$00                    ; $CCCD
  lda #$21                     ; $CCCF
  sta z:$03                    ; $CCD1
  lda Data_C0E8,x              ; $CCD3
  sta z:$04                    ; $CCD6
  lda #$00                     ; $CCD8
  jmp Sub_D1C7                 ; $CCDA
Loc_CCDD:
  lda z:$3C                    ; $CCDD
  lsr a                        ; $CCDF
  bcc Loc_CD12                 ; $CCE0
  lda #$40                     ; $CCE2
  sta z:$FB                    ; $CCE4
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
Sub_CD1F:
  lda z:$4F                    ; $CD1F
  beq Loc_CD40                 ; $CD21
  ldx #$03                     ; $CD23
Loc_CD25:
  lda z:$A8,x                  ; $CD25
  beq Loc_CD3D                 ; $CD27
  lda z:$9C,x                  ; $CD29
  cmp #$05                     ; $CD2B
  beq Loc_CD3A                 ; $CD2D
  ora z:$98,x                  ; $CD2F
  ora $03E0,x                  ; $CD31
  beq Loc_CD3A                 ; $CD34
  lda #$00                     ; $CD36
  sta z:$5C,x                  ; $CD38
Loc_CD3A:
  jsr Sub_CD59                 ; $CD3A
Loc_CD3D:
  dex                          ; $CD3D
  bpl Loc_CD25                 ; $CD3E
Loc_CD40:
  lda z:$34                    ; $CD40
  bne Loc_CD58                 ; $CD42
  lda z:$5C                    ; $CD44
  and #$C0                     ; $CD46
  beq Loc_CD58                 ; $CD48
  lda $03A9                    ; $CD4A
  ora z:$52                    ; $CD4D
  bne Loc_CD58                 ; $CD4F
  lda #$01                     ; $CD51
  sta $03A9                    ; $CD53
  sta z:$FE                    ; $CD56
Loc_CD58:
  rts                          ; $CD58
Sub_CD59:
  lda z:$5C,x                  ; $CD59
  and #$03                     ; $CD5B
  sta z:$0A                    ; $CD5D
  ldy #$00                     ; $CD5F
  lda $0374,x                  ; $CD61
  ora z:$98,x                  ; $CD64
  bne Loc_CDBA                 ; $CD66
  lda z:$9C,x                  ; $CD68
  beq Loc_CD70                 ; $CD6A
  cmp #$05                     ; $CD6C
  bne Loc_CDBA                 ; $CD6E
Loc_CD70:
  txa                          ; $CD70
  bne Loc_CD7B                 ; $CD71
  ldy #$02                     ; $CD73
  lda z:$52                    ; $CD75
  bne Loc_CD9A                 ; $CD77
  ldy #$00                     ; $CD79
Loc_CD7B:
  lda z:$B0,x                  ; $CD7B
  bne Loc_CDB2                 ; $CD7D
  lda z:$5C,x                  ; $CD7F
  and #$C0                     ; $CD81
  beq Loc_CDBA                 ; $CD83
  stx z:$00                    ; $CD85
  asl a                        ; $CD87
  bcs Loc_CD8C                 ; $CD88
  inc z:$00                    ; $CD8A
Loc_CD8C:
  jsr Sub_CDEE                 ; $CD8C
  beq Loc_CD95                 ; $CD8F
  lda z:$94,x                  ; $CD91
  bne Loc_CDBA                 ; $CD93
Loc_CD95:
  ldy z:$00                    ; $CD95
  txa                          ; $CD97
  bne Loc_CDAC                 ; $CD98
Loc_CD9A:
  lda z:$94,x                  ; $CD9A
  cmp Data_C0D1,y              ; $CD9C
  bcc Loc_CDAC                 ; $CD9F
  bne Loc_CDB9                 ; $CDA1
  lda z:$90,x                  ; $CDA3
  cmp Data_C0CE,y              ; $CDA5
  beq Loc_CDBD                 ; $CDA8
  bcs Loc_CDB9                 ; $CDAA
Loc_CDAC:
  jsr Sub_CE29                 ; $CDAC
  jmp Loc_CDBD                 ; $CDAF
Loc_CDB2:
  ldy #$04                     ; $CDB2
  lda z:$0A                    ; $CDB4
  beq Loc_CDBA                 ; $CDB6
  tay                          ; $CDB8
Loc_CDB9:
  iny                          ; $CDB9
Loc_CDBA:
  jsr Sub_CE58                 ; $CDBA
Loc_CDBD:
  lda z:$98,x                  ; $CDBD
  bne Loc_CE1C                 ; $CDBF
  lda z:$B0,x                  ; $CDC1
  bne Loc_CDD5                 ; $CDC3
  lda z:$58,x                  ; $CDC5
  ora z:$52                    ; $CDC7
  bne Loc_CDDE                 ; $CDC9
  lda z:$94,x                  ; $CDCB
  bne Loc_CDD5                 ; $CDCD
  lda z:$90,x                  ; $CDCF
  cmp #$A0                     ; $CDD1
  bcc Loc_CDDE                 ; $CDD3
Loc_CDD5:
  lda z:$0A                    ; $CDD5
  beq Loc_CDDE                 ; $CDD7
  sta z:$00                    ; $CDD9
  jmp Loc_CE83                 ; $CDDB
Loc_CDDE:
  lda z:$B0,x                  ; $CDDE
  bne Loc_CE1C                 ; $CDE0
  lda $0368,x                  ; $CDE2
  cmp z:$AC,x                  ; $CDE5
  beq Loc_CE1C                 ; $CDE7
  ldy #$05                     ; $CDE9
  jmp Loc_DCC7                 ; $CDEB
Sub_CDEE:
  lda z:$C0,x                  ; $CDEE
  cmp #$E4                     ; $CDF0
  beq Loc_CE0A                 ; $CDF2
  lda #$03                     ; $CDF4
  cmp z:$A4,x                  ; $CDF6
  bne Loc_CE00                 ; $CDF8
  lda z:$70,x                  ; $CDFA
  cmp #$03                     ; $CDFC
  bcs Loc_CE0A                 ; $CDFE
Loc_CE00:
  lda z:$B8,x                  ; $CE00
  cmp #$38                     ; $CE02
  bcs Loc_CE0A                 ; $CE04
  cmp #$08                     ; $CE06
  bcs Loc_CE1D                 ; $CE08
Loc_CE0A:
  lda #$01                     ; $CE0A
  cmp $036C,x                  ; $CE0C
  beq Loc_CE15                 ; $CE0F
  asl a                        ; $CE11
  sta $036C,x                  ; $CE12
Loc_CE15:
  txa                          ; $CE15
  bne Loc_CE28                 ; $CE16
  lda #$04                     ; $CE18
  sta z:$FD                    ; $CE1A
Loc_CE1C:
  rts                          ; $CE1C
Loc_CE1D:
  lda #$01                     ; $CE1D
  cmp $036C,x                  ; $CE1F
  beq Loc_CE28                 ; $CE22
  lsr a                        ; $CE24
  sta $036C,x                  ; $CE25
Loc_CE28:
  rts                          ; $CE28
Sub_CE29:
  cpx z:$4C                    ; $CE29
  bne Loc_CE45                 ; $CE2B
  lda Data_C0BC,y              ; $CE2D
  clc                          ; $CE30
  adc z:$90,x                  ; $CE31
  sta z:$90,x                  ; $CE33
  bcc Loc_CE39                 ; $CE35
  inc z:$94,x                  ; $CE37
Loc_CE39:
  txa                          ; $CE39
  bne Loc_CE45                 ; $CE3A
  lda z:$94,x                  ; $CE3C
  cmp Data_C0D1,y              ; $CE3E
  beq Loc_CE46                 ; $CE41
  bcs Loc_CE4D                 ; $CE43
Loc_CE45:
  rts                          ; $CE45
Loc_CE46:
  lda z:$90,x                  ; $CE46
  cmp Data_C0CE,y              ; $CE48
  bcc Loc_CE45                 ; $CE4B
Loc_CE4D:
  lda Data_C0CE,y              ; $CE4D
  sta z:$90,x                  ; $CE50
  lda Data_C0D1,y              ; $CE52
  sta z:$94,x                  ; $CE55
  rts                          ; $CE57
Sub_CE58:
  cpx z:$4C                    ; $CE58
  bne Loc_CE82                 ; $CE5A
Sub_CE5C:
  sty z:$00                    ; $CE5C
  lda z:$94,x                  ; $CE5E
  bne Loc_CE6D                 ; $CE60
  lda z:$B0,x                  ; $CE62
  lsr a                        ; $CE64
  tay                          ; $CE65
  lda z:$90,x                  ; $CE66
  cmp Data_C0CC,y              ; $CE68
  bcc Loc_CE82                 ; $CE6B
Loc_CE6D:
  ldy z:$00                    ; $CE6D
  lda z:$90,x                  ; $CE6F
  sec                          ; $CE71
  sbc Data_C0C1,y              ; $CE72
  sta z:$90,x                  ; $CE75
  bcs Loc_CE82                 ; $CE77
  lda z:$94,x                  ; $CE79
  beq Loc_CE80                 ; $CE7B
  dec z:$94,x                  ; $CE7D
  rts                          ; $CE7F
Loc_CE80:
  sta z:$90,x                  ; $CE80
Loc_CE82:
  rts                          ; $CE82
Loc_CE83:
  lda z:$26,x                  ; $CE83
  bne Loc_CE9F                 ; $CE85
  lda z:$B0,x                  ; $CE87
  lsr a                        ; $CE89
  tay                          ; $CE8A
  lda Data_C0D4,y              ; $CE8B
  sta z:$26,x                  ; $CE8E
  lsr z:$00                    ; $CE90
  bcc Loc_CEA0                 ; $CE92
  lda z:$AC,x                  ; $CE94
  cmp Data_C0C8,y              ; $CE96
  beq Loc_CE9F                 ; $CE99
  bcc Loc_CEAF                 ; $CE9B
  dec z:$AC,x                  ; $CE9D
Loc_CE9F:
  rts                          ; $CE9F
Loc_CEA0:
  lda $0388,x                  ; $CEA0
  and #$02                     ; $CEA3
  sta $0388,x                  ; $CEA5
  lda z:$AC,x                  ; $CEA8
  cmp Data_C0CA,y              ; $CEAA
  bcs Loc_CEB2                 ; $CEAD
Loc_CEAF:
  inc z:$AC,x                  ; $CEAF
  rts                          ; $CEB1
Loc_CEB2:
  lda z:$5C,x                  ; $CEB2
  and #$C0                     ; $CEB4
  beq Loc_CECF                 ; $CEB6
  lda z:$B0,x                  ; $CEB8
  bne Loc_CECF                 ; $CEBA
  inc z:$AC,x                  ; $CEBC
  lda #$0D                     ; $CEBE
  sta z:$26,x                  ; $CEC0
  lda z:$AC,x                  ; $CEC2
  cmp #$0D                     ; $CEC4
  bcc Loc_CECF                 ; $CEC6
  lda #$01                     ; $CEC8
  sta z:$98,x                  ; $CECA
  asl a                        ; $CECC
  sta z:$26,x                  ; $CECD
Loc_CECF:
  rts                          ; $CECF
Sub_CED0:
  ldx z:$4A                    ; $CED0
Loc_CED2:
  stx z:$0F                    ; $CED2
  lda z:$A8,x                  ; $CED4
  beq Loc_CF04                 ; $CED6
  lda z:$98,x                  ; $CED8
  ora z:$9C,x                  ; $CEDA
  bne Loc_CF04                 ; $CEDC
  jsr Sub_CFEA                 ; $CEDE
  lda z:$B0,x                  ; $CEE1
  bne Loc_CEFF                 ; $CEE3
  jsr Sub_CFCB                 ; $CEE5
  jsr Sub_D018                 ; $CEE8
  bne Loc_CF04                 ; $CEEB
  lda $03A6                    ; $CEED
  beq Loc_CF04                 ; $CEF0
  jsr Sub_D000                 ; $CEF2
  lda z:$52                    ; $CEF5
  bne Loc_CF04                 ; $CEF7
  jsr Sub_CF0C                 ; $CEF9
  jmp Loc_CF04                 ; $CEFC
Loc_CEFF:
  lda $0368,x                  ; $CEFF
  sta z:$7C,x                  ; $CF02
Loc_CF04:
  ldx z:$0F                    ; $CF04
  inx                          ; $CF06
  cpx #$04                     ; $CF07
  bcc Loc_CED2                 ; $CF09
Loc_CF0B:
  rts                          ; $CF0B
Sub_CF0C:
  lda z:$84,x                  ; $CF0C
  lsr a                        ; $CF0E
  bcc Loc_CF0B                 ; $CF0F
  lda z:$70,x                  ; $CF11
  sta z:$02                    ; $CF13
  ldy #$02                     ; $CF15
  jsr Sub_CF96                 ; $CF17
  bcc Loc_CF2B                 ; $CF1A
  jsr Sub_CFDB                 ; $CF1C
  lda z:$80,x                  ; $CF1F
  asl a                        ; $CF21
  bcc Loc_CF0B                 ; $CF22
  lda z:RandomState,x          ; $CF24
  lsr a                        ; $CF26
  bcs Loc_CF64                 ; $CF27
  bcc Sub_CF47                 ; $CF29
Loc_CF2B:
  lda z:$DC,x                  ; $CF2B
  bne Loc_CF87                 ; $CF2D
  lda z:$84,x                  ; $CF2F
  lsr a                        ; $CF31
  bcc Loc_CF87                 ; $CF32
  lda z:$80,x                  ; $CF34
  cmp #$F0                     ; $CF36
  bcs Loc_CF87                 ; $CF38
  asl a                        ; $CF3A
  bcc Loc_CF87                 ; $CF3B
  lda z:$19,x                  ; $CF3D
  cmp #$E0                     ; $CF3F
  bcc Loc_CF87                 ; $CF41
  cmp #$F8                     ; $CF43
  bcc Loc_CF64                 ; $CF45
Sub_CF47:
  ldy $0360,x                  ; $CF47
  dey                          ; $CF4A
  cpy #$01                     ; $CF4B
  bmi Sub_CF6A                 ; $CF4D
  jsr Sub_CF88                 ; $CF4F
  bcs Loc_CF87                 ; $CF52
  ldy z:$70,x                  ; $CF54
  iny                          ; $CF56
  sty z:$02                    ; $CF57
  ldy #$00                     ; $CF59
  jsr Sub_CF96                 ; $CF5B
  bcs Loc_CF87                 ; $CF5E
  lda #$01                     ; $CF60
  bne Loc_CF85                 ; $CF62
Loc_CF64:
  lda z:$C0,x                  ; $CF64
  cmp #$E6                     ; $CF66
  beq Sub_CF47                 ; $CF68
Sub_CF6A:
  ldy $0360,x                  ; $CF6A
  iny                          ; $CF6D
  cpy #$05                     ; $CF6E
  bpl Sub_CF47                 ; $CF70
  jsr Sub_CF88                 ; $CF72
  bcs Loc_CF87                 ; $CF75
  ldy z:$70,x                  ; $CF77
  dey                          ; $CF79
  sty z:$02                    ; $CF7A
  ldy #$00                     ; $CF7C
  jsr Sub_CF96                 ; $CF7E
  bcs Loc_CF87                 ; $CF81
  lda #$FF                     ; $CF83
Loc_CF85:
  sta z:$DC,x                  ; $CF85
Loc_CF87:
  rts                          ; $CF87
Sub_CF88:
  jsr Sub_E7FF                 ; $CF88
Sub_CF8B:
  cmp #$3B                     ; $CF8B
  bcc Loc_CF94                 ; $CF8D
  cmp #$3E                     ; $CF8F
  bcs Loc_CF94                 ; $CF91
  rts                          ; $CF93
Loc_CF94:
  sec                          ; $CF94
  rts                          ; $CF95
Sub_CF96:
  lda z:$80,x                  ; $CF96
  clc                          ; $CF98
  adc Data_C0D6,y              ; $CF99
  sta z:$00                    ; $CF9C
  sec                          ; $CF9E
  sbc Data_C0D7,y              ; $CF9F
  sta z:$01                    ; $CFA2
  ldy z:$4A                    ; $CFA4
Loc_CFA6:
  cpy z:$0F                    ; $CFA6
  beq Loc_CFC4                 ; $CFA8
  lda a:$84,y                  ; $CFAA
  lsr a                        ; $CFAD
  bcc Loc_CFC4                 ; $CFAE
  lda a:$70,y                  ; $CFB0
  beq Loc_CFC4                 ; $CFB3
  cmp z:$02                    ; $CFB5
  bne Loc_CFC4                 ; $CFB7
  lda a:$80,y                  ; $CFB9
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
Sub_CFCB:
  ldy #$80                     ; $CFCB
  lda z:$94,x                  ; $CFCD
  cmp z:$78,x                  ; $CFCF
  bcc Loc_CFFA                 ; $CFD1
  bne Sub_CFDB                 ; $CFD3
  lda z:$90,x                  ; $CFD5
  cmp z:$74,x                  ; $CFD7
  bcc Loc_CFFA                 ; $CFD9
Sub_CFDB:
  lda z:$94,x                  ; $CFDB
  beq Loc_CFE9                 ; $CFDD
  lda #$0F                     ; $CFDF
  bne Loc_CFE5                 ; $CFE1
Sub_CFE3:
  lda #$F0                     ; $CFE3
Loc_CFE5:
  and z:$5C,x                  ; $CFE5
  sta z:$5C,x                  ; $CFE7
Loc_CFE9:
  rts                          ; $CFE9
Sub_CFEA:
  jsr Sub_CFE3                 ; $CFEA
  ldy #$01                     ; $CFED
  lda z:$7C,x                  ; $CFEF
  beq Loc_CFFF                 ; $CFF1
  cmp z:$AC,x                  ; $CFF3
  beq Loc_CFFF                 ; $CFF5
  bcc Loc_CFFA                 ; $CFF7
  iny                          ; $CFF9
Loc_CFFA:
  tya                          ; $CFFA
  ora z:$5C,x                  ; $CFFB
  sta z:$5C,x                  ; $CFFD
Loc_CFFF:
  rts                          ; $CFFF
Sub_D000:
  ldy #$00                     ; $D000
  cpx #$03                     ; $D002
  beq Loc_D015                 ; $D004
  lda z:$80,x                  ; $D006
  and #$10                     ; $D008
  beq Loc_CFFF                 ; $D00A
  lda z:$1A,x                  ; $D00C
  cmp #$C0                     ; $D00E
  bcc Loc_CFFF                 ; $D010
  bne Loc_D015                 ; $D012
  iny                          ; $D014
Loc_D015:
  jmp Sub_DB50                 ; $D015
Sub_D018:
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
  lda z:$58,x                  ; $D04D
  bne Loc_D054                 ; $D04F
  ldy $0368,x                  ; $D051
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
  adc z:$E0,x                  ; $D062
  and #$3F                     ; $D064
  sta z:$08                    ; $D066
  lda #$40                     ; $D068
  sta z:$09                    ; $D06A
  ldy $0360,x                  ; $D06C
Loc_D06F:
  dey                          ; $D06F
  cpy #$01                     ; $D070
  bmi Loc_D088                 ; $D072
  jsr Sub_E803                 ; $D074
  ldy z:$07                    ; $D077
  cmp #$FA                     ; $D079
  beq Loc_D088                 ; $D07B
  jsr Sub_CF8B                 ; $D07D
  bcs Loc_D06F                 ; $D080
  jsr Sub_CF47                 ; $D082
  jmp Loc_D04B                 ; $D085
Loc_D088:
  ldy $0360,x                  ; $D088
Loc_D08B:
  iny                          ; $D08B
  cpy #$06                     ; $D08C
  bpl Loc_D04B                 ; $D08E
  jsr Sub_E803                 ; $D090
  ldy z:$07                    ; $D093
  cmp #$E4                     ; $D095
  beq Loc_D04B                 ; $D097
  jsr Sub_CF8B                 ; $D099
  bcs Loc_D08B                 ; $D09C
  jsr Sub_CF6A                 ; $D09E
  jmp Loc_D04B                 ; $D0A1
Loc_D0A4:
  lda #$09                     ; $D0A4
Loc_D0A6:
  sta z:$7C,x                  ; $D0A6
  lda z:$0D                    ; $D0A8
  rts                          ; $D0AA
Sub_D0AB:
  ldx #$03                     ; $D0AB
Loc_D0AD:
  ldy #$05                     ; $D0AD
  lda z:$B8,x                  ; $D0AF
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
  sta $0360,x                  ; $D0BF
  dex                          ; $D0C2
  bpl Loc_D0AD                 ; $D0C3
  rts                          ; $D0C5
Sub_D0C6:
  ldx #$03                     ; $D0C6
Loc_D0C8:
  txa                          ; $D0C8
  asl a                        ; $D0C9
  asl a                        ; $D0CA
  sta z:$0C                    ; $D0CB
  lda #$04                     ; $D0CD
  sta z:$0B                    ; $D0CF
  jsr Sub_E7FC                 ; $D0D1
  sta z:$C0,x                  ; $D0D4
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
Sub_D0F4:
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
  jmp Loc_D2A3                 ; $D11C
Sub_D11F:
  lda #$11                     ; $D11F
  sta $0300                    ; $D121
  lda #$23                     ; $D124
  sta $0301                    ; $D126
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
Sub_D13F:
  ldx #$00                     ; $D13F
  jsr Sub_ECE4                 ; $D141
  ldx #$04                     ; $D144
  jsr Sub_ECE4                 ; $D146
  ldx #$08                     ; $D149
  jmp Sub_ECE4                 ; $D14B
Sub_D14E:
  lda PPU_STATUS               ; $D14E
  and #$40                     ; $D151
  bne Sub_D14E                 ; $D153
  jsr Sub_D1B3                 ; $D155
  lda z:FrameCounter           ; $D158
  and #$03                     ; $D15A
  sta z:$4C                    ; $D15C
  jsr Sub_D11F                 ; $D15E
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
  jsr Sub_D0C6                 ; $D176
  jsr Sub_D0F4                 ; $D179
  ldx #$28                     ; $D17C
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
Sub_D19B:
  lda PPU_STATUS               ; $D19B
  and #$40                     ; $D19E
  beq Sub_D19B                 ; $D1A0
  lda z:PpuCtrlShadow          ; $D1A2
  and #$F0                     ; $D1A4
  jsr SetPpuCtrl               ; $D1A6
ResetPpuScroll:
  lda PPU_STATUS               ; $D1A9
  lda #$00                     ; $D1AC
  sta PPU_SCROLL               ; $D1AE
  beq Loc_D197                 ; $D1B1
Sub_D1B3:
  lda z:PpuCtrlShadow          ; $D1B3
  ora z:$4E                    ; $D1B5
  sta PPU_CTRL                 ; $D1B7
  lda PPU_STATUS               ; $D1BA
  lda z:SplitScrollX           ; $D1BD
  sta PPU_SCROLL               ; $D1BF
  lda z:SplitScrollY           ; $D1C2
  jmp Loc_D197                 ; $D1C4
Sub_D1C7:
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
Sub_D23B:
  ldx #$01                     ; $D23B
Loc_D23D:
  txa                          ; $D23D
  pha                          ; $D23E
  sta z:$01                    ; $D23F
  jsr Sub_D24F                 ; $D241
  jsr Sub_D260                 ; $D244
  pla                          ; $D247
  tax                          ; $D248
  inx                          ; $D249
  cpx #$03                     ; $D24A
  bcc Loc_D23D                 ; $D24C
  rts                          ; $D24E
Sub_D24F:
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
Sub_D260:
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
Loc_D2A3:
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
  ldx $0300                    ; $D2B7
Loc_D2BA:
  lda z:$01                    ; $D2BA
  sta $0301,x                  ; $D2BC
  jsr Sub_D2FF                 ; $D2BF
  lda z:$00                    ; $D2C2
  sta $0301,x                  ; $D2C4
  jsr Sub_D2FF                 ; $D2C7
  lda z:$05                    ; $D2CA
  sta z:$06                    ; $D2CC
  sta $0301,x                  ; $D2CE
Loc_D2D1:
  jsr Sub_D2FF                 ; $D2D1
  iny                          ; $D2D4
  lda ($02),y                  ; $D2D5
  sta $0301,x                  ; $D2D7
  dec z:$06                    ; $D2DA
  bne Loc_D2D1                 ; $D2DC
  jsr Sub_D2FF                 ; $D2DE
  stx $0300                    ; $D2E1
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
  sta $0301,x                  ; $D2F7
  pla                          ; $D2FA
  tay                          ; $D2FB
  pla                          ; $D2FC
  tax                          ; $D2FD
  rts                          ; $D2FE
Sub_D2FF:
  inx                          ; $D2FF
  txa                          ; $D300
  cmp #$3F                     ; $D301
  bcc Loc_D30F                 ; $D303
  ldx $0300                    ; $D305
  lda #$00                     ; $D308
  sta $0301,x                  ; $D30A
  pla                          ; $D30D
  pla                          ; $D30E
Loc_D30F:
  rts                          ; $D30F
TickTimers:
  ldx #$0E                     ; $D310
  dec z:$20                    ; $D312
  bpl Loc_D31C                 ; $D314
  lda #$0A                     ; $D316
  sta z:$20                    ; $D318
  ldx #$1C                     ; $D31A
Loc_D31C:
  lda z:$21,x                  ; $D31C
  beq Loc_D322                 ; $D31E
  dec z:$21,x                  ; $D320
Loc_D322:
  dex                          ; $D322
  bpl Loc_D31C                 ; $D323
  rts                          ; $D325
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
  .incbin "prg_bank_0.bin", $13D6, $400  ; $D3D6
  .incbin "prg_bank_0.bin", $17D6, $92  ; $D7D6
Data_D868:
  .incbin "prg_bank_0.bin", $1868, $4  ; $D868
Data_D86C:
  .incbin "prg_bank_0.bin", $186C, $10  ; $D86C
Data_D87C:
  .incbin "prg_bank_0.bin", $187C, $F  ; $D87C
Data_D88B:
  .incbin "prg_bank_0.bin", $188B, $7  ; $D88B
Data_D892:
  .incbin "prg_bank_0.bin", $1892, $17  ; $D892
Data_D8A9:
  .incbin "prg_bank_0.bin", $18A9, $17  ; $D8A9
Data_D8C0:
  .incbin "prg_bank_0.bin", $18C0, $4  ; $D8C0
Data_D8C4:
  .incbin "prg_bank_0.bin", $18C4, $5  ; $D8C4
Data_D8C9:
  .incbin "prg_bank_0.bin", $18C9, $4  ; $D8C9
Data_D8CD:
  .incbin "prg_bank_0.bin", $18CD, $8  ; $D8CD
Data_D8D5:
  .incbin "prg_bank_0.bin", $18D5, $3  ; $D8D5
Data_D8D8:
  .incbin "prg_bank_0.bin", $18D8, $4  ; $D8D8
Data_D8DC:
  .incbin "prg_bank_0.bin", $18DC, $3  ; $D8DC
Data_D8DF:
  .incbin "prg_bank_0.bin", $18DF, $3  ; $D8DF
Data_D8E2:
  .incbin "prg_bank_0.bin", $18E2, $3  ; $D8E2
Data_D8E5:
  .incbin "prg_bank_0.bin", $18E5, $2  ; $D8E5
Data_D8E7:
  .incbin "prg_bank_0.bin", $18E7, $8  ; $D8E7
Data_D8EF:
  .incbin "prg_bank_0.bin", $18EF, $2  ; $D8EF
Data_D8F1:
  .incbin "prg_bank_0.bin", $18F1, $2  ; $D8F1
Data_D8F3:
  .incbin "prg_bank_0.bin", $18F3, $4  ; $D8F3
Data_D8F7:
  .incbin "prg_bank_0.bin", $18F7, $4  ; $D8F7
Data_D8FB:
  .incbin "prg_bank_0.bin", $18FB, $4  ; $D8FB
Data_D8FF:
  .incbin "prg_bank_0.bin", $18FF, $6  ; $D8FF
Data_D905:
  .incbin "prg_bank_0.bin", $1905, $6  ; $D905
Data_D90B:
  .incbin "prg_bank_0.bin", $190B, $3  ; $D90B
Data_D90E:
  .incbin "prg_bank_0.bin", $190E, $5  ; $D90E
Data_D913:
  .incbin "prg_bank_0.bin", $1913, $5  ; $D913
Sub_D918:
  ldx #$03                     ; $D918
Loc_D91A:
  jsr Sub_D924                 ; $D91A
  jsr Sub_DA15                 ; $D91D
  dex                          ; $D920
  bpl Loc_D91A                 ; $D921
  rts                          ; $D923
Sub_D924:
  ldy z:$9C,x                  ; $D924
  lda Data_D8FF,y              ; $D926
  sta z:$00                    ; $D929
  lda Data_D905,y              ; $D92B
  sta z:$01                    ; $D92E
  jmp ($0000)                  ; $D930
  lda $0370,x                  ; $D933
  beq Loc_D94E                 ; $D936
  lda z:FrameCounter           ; $D938
  lsr a                        ; $D93A
  bcs Loc_D952                 ; $D93B
  inc $0390,x                  ; $D93D
  ldy $03E4,x                  ; $D940
  lda z:$80,x                  ; $D943
  clc                          ; $D945
  adc Data_D90E,y              ; $D946
  cmp $0390,x                  ; $D949
  bcs Loc_D952                 ; $D94C
Loc_D94E:
  inc z:$9C,x                  ; $D94E
  bne Loc_D97E                 ; $D950
Loc_D952:
  rts                          ; $D952
  txa                          ; $D953
  tay                          ; $D954
  beq Loc_D95D                 ; $D955
  lda z:$BC,x                  ; $D957
  beq Loc_D95D                 ; $D959
  ldy #$04                     ; $D95B
Loc_D95D:
  lda z:$B8,x                  ; $D95D
  cmp Data_D8C4,y              ; $D95F
  beq Loc_D96E                 ; $D962
  ldy #$01                     ; $D964
  bcc Loc_D96A                 ; $D966
  ldy #$FF                     ; $D968
Loc_D96A:
  tya                          ; $D96A
  sta z:$DC,x                  ; $D96B
  rts                          ; $D96D
Loc_D96E:
  lda #$00                     ; $D96E
  sta $0398,x                  ; $D970
  sta z:$DC,x                  ; $D973
  inc z:$9C,x                  ; $D975
  txa                          ; $D977
  bne Loc_D97E                 ; $D978
  lda #$02                     ; $D97A
  sta z:$FD                    ; $D97C
Loc_D97E:
  lda #$08                     ; $D97E
  sta z:$2A,x                  ; $D980
  rts                          ; $D982
  lda $0370,x                  ; $D983
  beq Loc_D9C0                 ; $D986
  lda z:$2A,x                  ; $D988
  bne Loc_D9D2                 ; $D98A
  txa                          ; $D98C
  ora $03F7                    ; $D98D
  bne Loc_D9A1                 ; $D990
  ldy z:$49                    ; $D992
  lda z:Joy1Held               ; $D994
  and #$C0                     ; $D996
  beq Loc_D99F                 ; $D998
  sta z:$49                    ; $D99A
  tya                          ; $D99C
  beq Loc_D9A7                 ; $D99D
Loc_D99F:
  sta z:$49                    ; $D99F
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
  cmp z:$80,x                  ; $D9BC
  bcs Loc_D9D2                 ; $D9BE
Loc_D9C0:
  lda #$03                     ; $D9C0
  sta z:$36,x                  ; $D9C2
  inc z:$9C,x                  ; $D9C4
  lda #$00                     ; $D9C6
  cpx #$03                     ; $D9C8
  bne Loc_D9D2                 ; $D9CA
  sta $03A8                    ; $D9CC
  sta $0373                    ; $D9CF
Loc_D9D2:
  rts                          ; $D9D2
  lda z:$36,x                  ; $D9D3
  bne Loc_D9F5                 ; $D9D5
  txa                          ; $D9D7
  bne Loc_D9E7                 ; $D9D8
  lda $03E0                    ; $D9DA
  bne Loc_DA10                 ; $D9DD
  lda $03F7                    ; $D9DF
  beq Loc_D9F3                 ; $D9E2
  jmp Loc_CA85                 ; $D9E4
Loc_D9E7:
  lda z:$22                    ; $D9E7
  bne Loc_D9F5                 ; $D9E9
  lda #$01                     ; $D9EB
  sta z:$DC,x                  ; $D9ED
  lda #$18                     ; $D9EF
  sta z:$22                    ; $D9F1
Loc_D9F3:
  inc z:$9C,x                  ; $D9F3
Loc_D9F5:
  rts                          ; $D9F5
  lda z:$94,x                  ; $D9F6
  ora z:$DC,x                  ; $D9F8
  bne Loc_DA03                 ; $D9FA
  lda z:$B8,x                  ; $D9FC
  cmp Data_D8C4,x              ; $D9FE
  beq Loc_DA14                 ; $DA01
Loc_DA03:
  lda #$01                     ; $DA03
  sta z:$DC,x                  ; $DA05
  txa                          ; $DA07
  beq Loc_DA10                 ; $DA08
  lda z:$B8,x                  ; $DA0A
  cmp #$08                     ; $DA0C
  bcc Loc_DA14                 ; $DA0E
Loc_DA10:
  lda #$00                     ; $DA10
  sta z:$9C,x                  ; $DA12
Loc_DA14:
  rts                          ; $DA14
Sub_DA15:
  lda $0390,x                  ; $DA15
  sec                          ; $DA18
  sbc z:$80,x                  ; $DA19
  sbc #$08                     ; $DA1B
  asl a                        ; $DA1D
  clc                          ; $DA1E
  adc z:$B8,x                  ; $DA1F
  adc #$04                     ; $DA21
  sta z:$6C,x                  ; $DA23
  rts                          ; $DA25
Sub_DA26:
  lda z:$4F                    ; $DA26
  beq Loc_DA69                 ; $DA28
  ldx #$03                     ; $DA2A
Loc_DA2C:
  jsr Sub_DA58                 ; $DA2C
  jsr Sub_DC1A                 ; $DA2F
  jsr Sub_DCF2                 ; $DA32
  jsr Sub_DCDE                 ; $DA35
  dex                          ; $DA38
  bpl Loc_DA2C                 ; $DA39
  jsr Sub_DA6A                 ; $DA3B
  jsr Sub_DA7A                 ; $DA3E
  jsr Sub_DBFE                 ; $DA41
  lda z:$3C                    ; $DA44
  bne Loc_DA69                 ; $DA46
  ldy $03BC                    ; $DA48
  lda Data_D8EF,y              ; $DA4B
  sta z:$00                    ; $DA4E
  lda Data_D8F1,y              ; $DA50
  sta z:$01                    ; $DA53
  jmp ($0000)                  ; $DA55
Sub_DA58:
  lda z:$94,x                  ; $DA58
  sta z:$60,x                  ; $DA5A
  lda z:$90,x                  ; $DA5C
  clc                          ; $DA5E
  adc $0394,x                  ; $DA5F
  sta $0394,x                  ; $DA62
  bcc Loc_DA69                 ; $DA65
  inc z:$60,x                  ; $DA67
Loc_DA69:
  rts                          ; $DA69
Sub_DA6A:
  lda z:ScrollX                ; $DA6A
  clc                          ; $DA6C
  adc z:$60                    ; $DA6D
  sta z:ScrollX                ; $DA6F
  bcc Loc_DA79                 ; $DA71
  lda z:PpuCtrlNametableBits   ; $DA73
  eor #$01                     ; $DA75
  sta z:PpuCtrlNametableBits   ; $DA77
Loc_DA79:
  rts                          ; $DA79
Sub_DA7A:
  ldx #$03                     ; $DA7A
Loc_DA7C:
  lda z:$A8,x                  ; $DA7C
  beq Loc_DA9B                 ; $DA7E
  lda z:$60,x                  ; $DA80
  clc                          ; $DA82
  adc z:$80,x                  ; $DA83
  bcc Loc_DA89                 ; $DA85
  inc z:$84,x                  ; $DA87
Loc_DA89:
  sec                          ; $DA89
  sbc z:$60                    ; $DA8A
  sta z:$80,x                  ; $DA8C
  bcs Loc_DA92                 ; $DA8E
  dec z:$84,x                  ; $DA90
Loc_DA92:
  lda $0390,x                  ; $DA92
  sec                          ; $DA95
  sbc z:$60                    ; $DA96
  sta $0390,x                  ; $DA98
Loc_DA9B:
  dex                          ; $DA9B
  bne Loc_DA7C                 ; $DA9C
  rts                          ; $DA9E
Sub_DA9F:
  ldx #$03                     ; $DA9F
  lda z:$3B                    ; $DAA1
  bne Loc_DADF                 ; $DAA3
Loc_DAA5:
  txa                          ; $DAA5
  eor z:$4C                    ; $DAA6
  ora z:$A8,x                  ; $DAA8
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
  lda z:$94                    ; $DAC0
  and #$02                     ; $DAC2
  sta z:$84,x                  ; $DAC4
  ldx #$03                     ; $DAC6
Loc_DAC8:
  sty z:$01                    ; $DAC8
  lda z:$70,x                  ; $DACA
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
  jsr Sub_DAE3                 ; $DADC
Loc_DADF:
  dex                          ; $DADF
  bne Loc_DAA5                 ; $DAE0
  rts                          ; $DAE2
Sub_DAE3:
  jsr Sub_DB95                 ; $DAE3
  dey                          ; $DAE6
  lda Data_D8D8,y              ; $DAE7
  sta z:$B8,x                  ; $DAEA
  ldy z:$84,x                  ; $DAEC
  lda Data_D8DF,y              ; $DAEE
  sta z:$80,x                  ; $DAF1
  lda #$06                     ; $DAF3
  sta z:$AC,x                  ; $DAF5
  lda z:$E0                    ; $DAF7
  clc                          ; $DAF9
  adc Data_D8E2,y              ; $DAFA
  and #$3F                     ; $DAFD
  sta z:$E0,x                  ; $DAFF
  lda z:$64                    ; $DB01
  sta z:$64,x                  ; $DB03
  tya                          ; $DB05
  beq Loc_DB34                 ; $DB06
  ldy #$05                     ; $DB08
  jsr Sub_E7FF                 ; $DB0A
  cmp #$E4                     ; $DB0D
  beq Loc_DB34                 ; $DB0F
  cmp #$3B                     ; $DB11
  bcc Loc_DB4D                 ; $DB13
  cmp #$93                     ; $DB15
  bcs Loc_DB4D                 ; $DB17
  ldy #$02                     ; $DB19
  jsr Sub_E7FF                 ; $DB1B
  cmp #$E6                     ; $DB1E
  bne Loc_DB34                 ; $DB20
  lda z:$B8,x                  ; $DB22
  cmp #$20                     ; $DB24
  bcc Loc_DB30                 ; $DB26
  lda #$30                     ; $DB28
  sta z:$BC,x                  ; $DB2A
  lda #$01                     ; $DB2C
  bne Loc_DB32                 ; $DB2E
Loc_DB30:
  lda #$03                     ; $DB30
Loc_DB32:
  sta z:$A4,x                  ; $DB32
Loc_DB34:
  ldy z:$84,x                  ; $DB34
  jsr Sub_DB50                 ; $DB36
  lda z:$84,x                  ; $DB39
  eor #$02                     ; $DB3B
  asl a                        ; $DB3D
  sta z:$94,x                  ; $DB3E
  lda #$20                     ; $DB40
  sta $039B,x                  ; $DB42
  lsr a                        ; $DB45
  sta z:$23                    ; $DB46
  lda #$01                     ; $DB48
  sta z:$A8,x                  ; $DB4A
  rts                          ; $DB4C
Loc_DB4D:
  lda #$00                     ; $DB4D
  rts                          ; $DB4F
Sub_DB50:
  lda z:$52                    ; $DB50
  beq Loc_DB58                 ; $DB52
  lda #$03                     ; $DB54
  bne Loc_DB5F                 ; $DB56
Loc_DB58:
  cpx #$03                     ; $DB58
  beq Loc_DB6C                 ; $DB5A
Loc_DB5C:
  lda Data_D8D5,y              ; $DB5C
Loc_DB5F:
  sta z:$78,x                  ; $DB5F
  lda z:$1B,x                  ; $DB61
  and #$0F                     ; $DB63
  tay                          ; $DB65
  lda Data_D8CD,y              ; $DB66
  sta z:$74,x                  ; $DB69
  rts                          ; $DB6B
Loc_DB6C:
  lda z:$84,x                  ; $DB6C
  lsr a                        ; $DB6E
  lsr a                        ; $DB6F
  bcs Loc_DB5C                 ; $DB70
  lda z:$94                    ; $DB72
  beq Loc_DB5C                 ; $DB74
  sta z:$78,x                  ; $DB76
  lda z:$90                    ; $DB78
  sta z:$74,x                  ; $DB7A
  lda z:$84,x                  ; $DB7C
  beq Loc_DB8C                 ; $DB7E
  lda z:$80,x                  ; $DB80
  cmp #$40                     ; $DB82
  bcs Loc_DB5C                 ; $DB84
  lda z:$70                    ; $DB86
  cmp z:$73                    ; $DB88
  beq Loc_DB94                 ; $DB8A
Loc_DB8C:
  lda z:$78,x                  ; $DB8C
  cmp #$04                     ; $DB8E
  bcs Loc_DB94                 ; $DB90
  inc z:$78,x                  ; $DB92
Loc_DB94:
  rts                          ; $DB94
Sub_DB95:
  lda #$00                     ; $DB95
  sta z:$A8,x                  ; $DB97
  sta z:$B8,x                  ; $DB99
  sta z:$BC,x                  ; $DB9B
  sta z:$A0,x                  ; $DB9D
  sta z:$A4,x                  ; $DB9F
  sta z:$58,x                  ; $DBA1
  sta z:$CC,x                  ; $DBA3
  sta $036C,x                  ; $DBA5
  sta z:$90,x                  ; $DBA8
  sta z:$94,x                  ; $DBAA
  sta z:$98,x                  ; $DBAC
  sta z:$9C,x                  ; $DBAE
  sta z:$B0,x                  ; $DBB0
  sta z:$D4,x                  ; $DBB2
  sta $0388,x                  ; $DBB4
  sta z:$C0,x                  ; $DBB7
  sta $039C,x                  ; $DBB9
  sta z:$DC,x                  ; $DBBC
  sta z:$70,x                  ; $DBBE
  sta $0370,x                  ; $DBC0
Loc_DBC3:
  rts                          ; $DBC3
Sub_DBC4:
  lda $03A8                    ; $DBC4
  beq Loc_DBC3                 ; $DBC7
  lda z:$AB                    ; $DBC9
  beq Loc_DBE0                 ; $DBCB
  ldx #$03                     ; $DBCD
  lda z:$84,x                  ; $DBCF
  lsr a                        ; $DBD1
  bcs Loc_DBC3                 ; $DBD2
  lsr a                        ; $DBD4
  bcs Loc_DBDD                 ; $DBD5
  lda z:$80,x                  ; $DBD7
  cmp #$EA                     ; $DBD9
  bcs Loc_DBC3                 ; $DBDB
Loc_DBDD:
  jmp Sub_DB95                 ; $DBDD
Loc_DBE0:
  ldy #$00                     ; $DBE0
  sty $03A8                    ; $DBE2
  iny                          ; $DBE5
  ldx #$02                     ; $DBE6
  stx z:$87                    ; $DBE8
  inx                          ; $DBEA
  jsr Sub_DAE3                 ; $DBEB
  beq Loc_DBC3                 ; $DBEE
  lda #$00                     ; $DBF0
  sta z:$97                    ; $DBF2
  lda #$92                     ; $DBF4
  sta z:$8F                    ; $DBF6
  sta $0373                    ; $DBF8
  jmp Loc_DC69                 ; $DBFB
Sub_DBFE:
  lda z:$60                    ; $DBFE
  lsr a                        ; $DC00
  ror a                        ; $DC01
  ror a                        ; $DC02
  ror a                        ; $DC03
  clc                          ; $DC04
  adc $03BF                    ; $DC05
  sta $03BF                    ; $DC08
  lda z:$60                    ; $DC0B
  adc z:SplitScrollX           ; $DC0D
  sta z:SplitScrollX           ; $DC0F
  bcc Loc_DC19                 ; $DC11
  lda z:$4E                    ; $DC13
  eor #$01                     ; $DC15
  sta z:$4E                    ; $DC17
Loc_DC19:
  rts                          ; $DC19
Sub_DC1A:
  lda z:$B0,x                  ; $DC1A
  beq Loc_DC19                 ; $DC1C
  jsr Sub_DC97                 ; $DC1E
  sta z:$01                    ; $DC21
  cmp z:$8C,x                  ; $DC23
  bcs Loc_DC19                 ; $DC25
  lda z:$8C,x                  ; $DC27
  cmp #$A8                     ; $DC29
  bcs Loc_DC19                 ; $DC2B
  lda $0364,x                  ; $DC2D
  beq Loc_DC19                 ; $DC30
  txa                          ; $DC32
  bne Loc_DC39                 ; $DC33
  lda #$02                     ; $DC35
  sta z:$FF                    ; $DC37
Loc_DC39:
  lda #$00                     ; $DC39
  sta z:$B0,x                  ; $DC3B
  sta $0364,x                  ; $DC3D
  lda z:$98,x                  ; $DC40
  bne Loc_DC87                 ; $DC42
  lda z:$52                    ; $DC44
  bne Loc_DC8E                 ; $DC46
  ldy $0388,x                  ; $DC48
  sta $0388,x                  ; $DC4B
  tya                          ; $DC4E
  bne Loc_DC87                 ; $DC4F
  lda z:$D4,x                  ; $DC51
  ldy z:$94,x                  ; $DC53
  cpy #$02                     ; $DC55
  bpl Loc_DC5C                 ; $DC57
  clc                          ; $DC59
  adc #$08                     ; $DC5A
Loc_DC5C:
  tay                          ; $DC5C
  lda z:$AC,x                  ; $DC5D
  cmp Data_D86C,y              ; $DC5F
  bcc Loc_DC69                 ; $DC62
  cmp Data_D87C,y              ; $DC64
  bcc Loc_DC6E                 ; $DC67
Loc_DC69:
  lda #$FF                     ; $DC69
  sta z:$98,x                  ; $DC6B
  rts                          ; $DC6D
Loc_DC6E:
  lda $0368,x                  ; $DC6E
  cmp z:$AC,x                  ; $DC71
  beq Loc_DC87                 ; $DC73
  lda z:$D4,x                  ; $DC75
  ora z:$CC,x                  ; $DC77
  bne Loc_DC87                 ; $DC79
  lda #$04                     ; $DC7B
  sta $0374,x                  ; $DC7D
  lsr a                        ; $DC80
  sta $0388,x                  ; $DC81
  lsr a                        ; $DC84
  sta z:$B0,x                  ; $DC85
Loc_DC87:
  dec z:$01                    ; $DC87
  lda z:$01                    ; $DC89
  sta z:$8C,x                  ; $DC8B
Loc_DC8D:
  rts                          ; $DC8D
Loc_DC8E:
  lda z:$D4,x                  ; $DC8E
  bne Loc_DC8D                 ; $DC90
  lda #$06                     ; $DC92
  sta z:$AC,x                  ; $DC94
  rts                          ; $DC96
Sub_DC97:
  lda $03F1                    ; $DC97
Sub_DC9A:
  sec                          ; $DC9A
  sbc z:$BC,x                  ; $DC9B
  sbc z:$B8,x                  ; $DC9D
  rts                          ; $DC9F
Sub_DCA0:
  ldy z:$D4,x                  ; $DCA0
  lda z:$52                    ; $DCA2
  cmp #$01                     ; $DCA4
  bne Loc_DCB5                 ; $DCA6
  txa                          ; $DCA8
  ora z:$98                    ; $DCA9
  ora z:$9C                    ; $DCAB
  ora z:$58                    ; $DCAD
  bne Loc_DCB5                 ; $DCAF
  lda #$0A                     ; $DCB1
  bne Loc_DCB8                 ; $DCB3
Loc_DCB5:
  lda Data_D88B,y              ; $DCB5
Loc_DCB8:
  sta $0368,x                  ; $DCB8
  lda z:$A4,x                  ; $DCBB
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
  lda z:$AC,x                  ; $DCCF
  cmp z:$00                    ; $DCD1
  beq Loc_DCDD                 ; $DCD3
  bcc Loc_DCDB                 ; $DCD5
  dec z:$AC,x                  ; $DCD7
  dec z:$AC,x                  ; $DCD9
Loc_DCDB:
  inc z:$AC,x                  ; $DCDB
Loc_DCDD:
  rts                          ; $DCDD
Sub_DCDE:
  lda $0374,x                  ; $DCDE
  beq Loc_DCF1                 ; $DCE1
  dec $0374,x                  ; $DCE3
  lda z:$5C,x                  ; $DCE6
  and #$C0                     ; $DCE8
  beq Loc_DCF1                 ; $DCEA
  lda #$00                     ; $DCEC
  sta $0374,x                  ; $DCEE
Loc_DCF1:
  rts                          ; $DCF1
Sub_DCF2:
  lda z:$B0,x                  ; $DCF2
  beq Loc_DD37                 ; $DCF4
  cmp #$02                     ; $DCF6
  beq Loc_DD11                 ; $DCF8
Loc_DCFA:
  lda #$00                     ; $DCFA
  beq Loc_DD08                 ; $DCFC
Loc_DCFE:
  lda z:$98,x                  ; $DCFE
  bne Loc_DCFA                 ; $DD00
  inc z:$94,x                  ; $DD02
  bne Loc_DCFA                 ; $DD04
Sub_DD06:
  lda z:$94,x                  ; $DD06
Loc_DD08:
  sta $0384,x                  ; $DD08
  jsr Sub_DD38                 ; $DD0B
  jmp Loc_DD1A                 ; $DD0E
Loc_DD11:
  lda z:$5C,x                  ; $DD11
  lsr a                        ; $DD13
  bcc Loc_DD1A                 ; $DD14
  lda z:$4C                    ; $DD16
  beq Loc_DD37                 ; $DD18
Loc_DD1A:
  lda z:$5C,x                  ; $DD1A
  and #$03                     ; $DD1C
  tay                          ; $DD1E
  lda Data_D868,y              ; $DD1F
  sta $038C,x                  ; $DD22
  lda z:$8C,x                  ; $DD25
  sta z:$01                    ; $DD27
  jsr Sub_DD6F                 ; $DD29
  sta z:$8C,x                  ; $DD2C
  lda z:$CC,x                  ; $DD2E
  bne Loc_DD37                 ; $DD30
  lda #$01                     ; $DD32
  sta $0364,x                  ; $DD34
Loc_DD37:
  rts                          ; $DD37
Sub_DD38:
  lda #$02                     ; $DD38
  sta z:$B0,x                  ; $DD3A
  lda #$0F                     ; $DD3C
  sta $0380,x                  ; $DD3E
  lda z:$90,x                  ; $DD41
  clc                          ; $DD43
  adc #$AF                     ; $DD44
  sta $0378,x                  ; $DD46
  lda z:$94,x                  ; $DD49
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
  lda z:$94,x                  ; $DD60
  asl a                        ; $DD62
  asl a                        ; $DD63
  asl a                        ; $DD64
  asl a                        ; $DD65
  eor #$30                     ; $DD66
  bne Loc_DD6C                 ; $DD68
  lda #$08                     ; $DD6A
Loc_DD6C:
  sta z:$FF                    ; $DD6C
Loc_DD6E:
  rts                          ; $DD6E
Sub_DD6F:
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
Sub_DD8D:
  lda z:$3C                    ; $DD8D
  ora $03E0                    ; $DD8F
  beq Loc_DD8C                 ; $DD92
  lda z:$3C                    ; $DD94
  cmp #$08                     ; $DD96
  beq Loc_DDBF                 ; $DD98
  bcc Loc_DDCE                 ; $DD9A
  lda z:$94                    ; $DD9C
  ora z:$98                    ; $DD9E
  ora z:$9C                    ; $DDA0
  bne Loc_DDBC                 ; $DDA2
  lda z:$58                    ; $DDA4
  beq Loc_DDAE                 ; $DDA6
  lda #$C0                     ; $DDA8
  sta z:$90                    ; $DDAA
  bne Loc_DDBC                 ; $DDAC
Loc_DDAE:
  sta z:$90                    ; $DDAE
  ldx #$01                     ; $DDB0
  lda z:$B8                    ; $DDB2
  cmp Data_D8C4                ; $DDB4
  bne Loc_DDBA                 ; $DDB7
  dex                          ; $DDB9
Loc_DDBA:
  stx z:$DC                    ; $DDBA
Loc_DDBC:
  jmp Loc_CCDD                 ; $DDBC
Loc_DDBF:
  lda #$00                     ; $DDBF
  sta $03E0                    ; $DDC1
  lda #$05                     ; $DDC4
  sta $03B6                    ; $DDC6
  sta z:$9C                    ; $DDC9
  sta $0374                    ; $DDCB
Loc_DDCE:
  jmp Loc_CD13                 ; $DDCE
Sub_DDD1:
  ldx #$03                     ; $DDD1
Loc_DDD3:
  lda z:$98,x                  ; $DDD3
  beq Loc_DE2D                 ; $DDD5
  ldy #$04                     ; $DDD7
  txa                          ; $DDD9
  bne Loc_DDEE                 ; $DDDA
  sta $03A9                    ; $DDDC
  sta z:$FC                    ; $DDDF
  lda z:$4C                    ; $DDE1
  bne Loc_DDE9                 ; $DDE3
  lda #$01                     ; $DDE5
  sta z:$FD                    ; $DDE7
Loc_DDE9:
  lda z:$1B                    ; $DDE9
  and #$03                     ; $DDEB
  tay                          ; $DDED
Loc_DDEE:
  tya                          ; $DDEE
  sta $03E4,x                  ; $DDEF
  lda z:$4C                    ; $DDF2
  lsr a                        ; $DDF4
  bcs Loc_DE2D                 ; $DDF5
  lda z:$94,x                  ; $DDF7
  bne Loc_DE24                 ; $DDF9
  lda z:$B0,x                  ; $DDFB
  ora z:$58,x                  ; $DDFD
  bne Loc_DE20                 ; $DDFF
  sta z:$90,x                  ; $DE01
  sta z:$60,x                  ; $DE03
  sta z:$98,x                  ; $DE05
  lda #$06                     ; $DE07
  sta z:$AC,x                  ; $DE09
  lda z:$80,x                  ; $DE0B
  clc                          ; $DE0D
  adc #$08                     ; $DE0E
  sta $0390,x                  ; $DE10
  jsr Sub_DA15                 ; $DE13
  lda #$02                     ; $DE16
  sta $0398,x                  ; $DE18
  lsr a                        ; $DE1B
  sta z:$9C,x                  ; $DE1C
  bne Loc_DE2D                 ; $DE1E
Loc_DE20:
  lda #$88                     ; $DE20
  sta z:$90,x                  ; $DE22
Loc_DE24:
  lda z:$AC,x                  ; $DE24
  clc                          ; $DE26
  adc z:$98,x                  ; $DE27
  and #$0F                     ; $DE29
  sta z:$AC,x                  ; $DE2B
Loc_DE2D:
  dex                          ; $DE2D
  bpl Loc_DDD3                 ; $DE2E
  rts                          ; $DE30
Sub_DE31:
  lda z:$24                    ; $DE31
  cmp #$01                     ; $DE33
  beq Loc_DEA6                 ; $DE35
  ldy z:$4F                    ; $DE37
  bne Loc_DEA5                 ; $DE39
  cmp #$60                     ; $DE3B
  bcs Loc_DE4E                 ; $DE3D
  lda $03A9                    ; $DE3F
  beq Loc_DE4E                 ; $DE42
  lda z:$5C                    ; $DE44
  and #$C0                     ; $DE46
  beq Loc_DE4E                 ; $DE48
  lda #$01                     ; $DE4A
  sta z:$FE                    ; $DE4C
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
  sta z:$FB                    ; $DE64
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
  sta z:$4F                    ; $DEA8
  lda $03B4                    ; $DEAA
  sec                          ; $DEAD
  sbc z:$60                    ; $DEAE
  sta $03B4                    ; $DEB0
  bcc Loc_DEA5                 ; $DEB3
  lda #$02                     ; $DEB5
  sta z:$24                    ; $DEB7
  bne Loc_DE4E                 ; $DEB9
Sub_DEBB:
  ldx #$03                     ; $DEBB
Loc_DEBD:
  lda z:$84,x                  ; $DEBD
  lsr a                        ; $DEBF
  bcc Loc_DEDE                 ; $DEC0
  lda z:$80,x                  ; $DEC2
  cmp #$30                     ; $DEC4
  bcc Loc_DECC                 ; $DEC6
  cmp #$40                     ; $DEC8
  bcc Loc_DED9                 ; $DECA
Loc_DECC:
  lda $03A9,x                  ; $DECC
  beq Loc_DEDE                 ; $DECF
  lda #$40                     ; $DED1
  sta z:$FF                    ; $DED3
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
Sub_DEE2:
  ldx #$00                     ; $DEE2
  lda $03A9                    ; $DEE4
  beq Loc_DF2D                 ; $DEE7
  lda z:$4C                    ; $DEE9
  lsr a                        ; $DEEB
  bcs Loc_DEA5                 ; $DEEC
  ldx #$02                     ; $DEEE
  lda z:$94                    ; $DEF0
  sta z:$00                    ; $DEF2
  lda z:$90                    ; $DEF4
  sta z:$01                    ; $DEF6
Loc_DEF8:
  lsr z:$00                    ; $DEF8
  ror z:$01                    ; $DEFA
  dex                          ; $DEFC
  bpl Loc_DEF8                 ; $DEFD
  lda #$02                     ; $DEFF
  ldy z:$B0                    ; $DF01
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
  lda z:$5C                    ; $DF24
  asl a                        ; $DF26
  bcs Loc_DF2D                 ; $DF27
  txa                          ; $DF29
  ora #$80                     ; $DF2A
  tax                          ; $DF2C
Loc_DF2D:
  stx z:$FC                    ; $DF2D
  rts                          ; $DF2F
Sub_DF30:
  lda z:$4F                    ; $DF30
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
  jsr Sub_DF7F                 ; $DF43
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
  sta z:$52                    ; $DF7B
  bne Loc_DF41                 ; $DF7D
Sub_DF7F:
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
Sub_DFB2:
  ldy #$00                     ; $DFB2
  lda z:$9C,x                  ; $DFB4
  bne Loc_DFD1                 ; $DFB6
  lda z:$B8,x                  ; $DFB8
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
  cmp z:$A4,x                  ; $DFCB
  bne Loc_DFD1                 ; $DFCD
  iny                          ; $DFCF
  iny                          ; $DFD0
Loc_DFD1:
  tya                          ; $DFD1
  sta z:$70,x                  ; $DFD2
  rts                          ; $DFD4
Sub_DFD5:
  ldx #$00                     ; $DFD5
  ldy #$01                     ; $DFD7
Loc_DFD9:
  lda z:$A8,x                  ; $DFD9
  bne Loc_DFE0                 ; $DFDB
Loc_DFDD:
  jmp Loc_E086                 ; $DFDD
Loc_DFE0:
  lda a:$A8,y                  ; $DFE0
  beq Loc_E01D                 ; $DFE3
  lda z:$84,x                  ; $DFE5
  lsr a                        ; $DFE7
  bcc Loc_DFDD                 ; $DFE8
  lda a:$84,y                  ; $DFEA
  lsr a                        ; $DFED
  bcc Loc_E01D                 ; $DFEE
  lda z:$70,x                  ; $DFF0
  beq Loc_DFDD                 ; $DFF2
  cmp a:$70,y                  ; $DFF4
  bne Loc_E01D                 ; $DFF7
  lda z:$98,x                  ; $DFF9
  ora $03E0,x                  ; $DFFB
  bne Loc_DFDD                 ; $DFFE
  lda a:$98,y                  ; $E000
  bne Loc_E07E                 ; $E003
  lda z:$B0,x                  ; $E005
  bne Loc_E00E                 ; $E007
  lda a:$B0,y                  ; $E009
  beq Loc_E02A                 ; $E00C
Loc_E00E:
  lda z:$8C,x                  ; $E00E
  cmp a:$8C,y                  ; $E010
  bcs Loc_E020                 ; $E013
  jsr Sub_E091                 ; $E015
  cmp a:$8C,y                  ; $E018
  bcs Loc_E02A                 ; $E01B
Loc_E01D:
  jmp Loc_E07E                 ; $E01D
Loc_E020:
  lda a:$8C,y                  ; $E020
  jsr Sub_E091                 ; $E023
  cmp z:$8C,x                  ; $E026
  bcc Loc_E07E                 ; $E028
Loc_E02A:
  lda z:$80,x                  ; $E02A
  cmp a:$80,y                  ; $E02C
  bcs Loc_E045                 ; $E02F
  jsr Sub_E098                 ; $E031
  cmp a:$80,y                  ; $E034
  bcs Loc_E061                 ; $E037
  lda z:$80,x                  ; $E039
  jsr Sub_E091                 ; $E03B
  cmp a:$80,y                  ; $E03E
  bcs Loc_E05B                 ; $E041
  bcc Loc_E07E                 ; $E043
Loc_E045:
  lda a:$80,y                  ; $E045
  jsr Sub_E098                 ; $E048
  cmp z:$80,x                  ; $E04B
  bcs Loc_E061                 ; $E04D
  lda a:$80,y                  ; $E04F
  jsr Sub_E091                 ; $E052
  cmp z:$80,x                  ; $E055
  bcs Loc_E065                 ; $E057
  bcc Loc_E07E                 ; $E059
Loc_E05B:
  lda #$FF                     ; $E05B
  sta z:$98,x                  ; $E05D
  bne Loc_E076                 ; $E05F
Loc_E061:
  lda #$FF                     ; $E061
  sta z:$98,x                  ; $E063
Loc_E065:
  cpx #$00                     ; $E065
  bne Loc_E071                 ; $E067
  cpy #$03                     ; $E069
  bne Loc_E071                 ; $E06B
  lda #$10                     ; $E06D
  sta z:$3B                    ; $E06F
Loc_E071:
  lda #$FF                     ; $E071
  sta a:$98,y                  ; $E073
Loc_E076:
  cpx #$00                     ; $E076
  bne Loc_E07E                 ; $E078
  lda #$01                     ; $E07A
  sta z:$FD                    ; $E07C
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
Sub_E091:
  cmp #$E7                     ; $E091
  bcs Loc_E097                 ; $E093
  adc #$0C                     ; $E095
Loc_E097:
  rts                          ; $E097
Sub_E098:
  cmp #$E7                     ; $E098
  bcs Loc_E09E                 ; $E09A
  adc #$02                     ; $E09C
Loc_E09E:
  rts                          ; $E09E
Sub_E09F:
  lda z:$9C                    ; $E09F
  bne Loc_E0E5                 ; $E0A1
  tax                          ; $E0A3
  lda z:$87                    ; $E0A4
  lsr a                        ; $E0A6
  bcc Loc_E0E5                 ; $E0A7
  lda $0373                    ; $E0A9
  beq Loc_E0E5                 ; $E0AC
  lda z:$B8                    ; $E0AE
  sec                          ; $E0B0
  sbc #$03                     ; $E0B1
  cmp z:$6F                    ; $E0B3
  bcs Loc_E0E5                 ; $E0B5
  adc #$07                     ; $E0B7
  cmp z:$6F                    ; $E0B9
  bcc Loc_E0E5                 ; $E0BB
  lda z:$80                    ; $E0BD
  cmp $0393                    ; $E0BF
  bcs Loc_E0E5                 ; $E0C2
  adc #$12                     ; $E0C4
  cmp $0393                    ; $E0C6
  bcc Loc_E0E5                 ; $E0C9
  jsr Sub_DC97                 ; $E0CB
  sec                          ; $E0CE
  sbc #$08                     ; $E0CF
  cmp z:$8C                    ; $E0D1
  bcs Loc_E0E5                 ; $E0D3
  ldy #$FF                     ; $E0D5
  sty z:$98                    ; $E0D7
  iny                          ; $E0D9
  sty z:$DF                    ; $E0DA
  iny                          ; $E0DC
  sty z:$9F                    ; $E0DD
  sty z:$FD                    ; $E0DF
  iny                          ; $E0E1
  sty $039B                    ; $E0E2
Loc_E0E5:
  rts                          ; $E0E5
  lda z:$3A                    ; $E0E6
  ora z:$52                    ; $E0E8
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
  sbc z:$60                    ; $E112
  sta $03B9                    ; $E114
  lda z:$60                    ; $E117
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
  jsr Sub_D1C7                 ; $E14A
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
Sub_E17F:
  jsr Sub_E3F4                 ; $E17F
  ldx #$03                     ; $E182
Loc_E184:
  stx z:$0D                    ; $E184
  lda Data_D8C0,x              ; $E186
  sta z:$04                    ; $E189
  lda z:$88,x                  ; $E18B
  tax                          ; $E18D
  lda z:$A8,x                  ; $E18E
  beq Loc_E19D                 ; $E190
  lda Data_D8C9,x              ; $E192
  sta z:$0B                    ; $E195
  jsr Sub_E1A3                 ; $E197
  jsr Sub_E26A                 ; $E19A
Loc_E19D:
  ldx z:$0D                    ; $E19D
  dex                          ; $E19F
  bpl Loc_E184                 ; $E1A0
  rts                          ; $E1A2
Sub_E1A3:
  lda z:$80,x                  ; $E1A3
  sta z:$00                    ; $E1A5
  lda z:$8C,x                  ; $E1A7
  sta z:$01                    ; $E1A9
  jsr Sub_E1F9                 ; $E1AB
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
  jsr Sub_D1C7                 ; $E1D4
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
Sub_E1F9:
  lda #$00                     ; $E1F9
  sta z:$0E                    ; $E1FB
  sta $039F                    ; $E1FD
  lda z:$9C,x                  ; $E200
  beq Loc_E21F                 ; $E202
  cmp #$05                     ; $E204
  beq Loc_E21F                 ; $E206
  ldy #$06                     ; $E208
  lda z:$BC,x                  ; $E20A
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
  ldy z:$52                    ; $E21F
  dey                          ; $E221
  bne Loc_E22F                 ; $E222
  lda z:$AC,x                  ; $E224
  cmp #$0A                     ; $E226
  bne Loc_E22F                 ; $E228
  ldy #$02                     ; $E22A
  sty z:$0E                    ; $E22C
  rts                          ; $E22E
Loc_E22F:
  lda z:$98,x                  ; $E22F
  ora z:$B0,x                  ; $E231
  bne Loc_E267                 ; $E233
  lda z:$58,x                  ; $E235
  beq Loc_E243                 ; $E237
  cmp #$0D                     ; $E239
  bne Loc_E267                 ; $E23B
  lda z:$B8,x                  ; $E23D
  cmp #$20                     ; $E23F
  bcc Loc_E267                 ; $E241
Loc_E243:
  lda z:$90,x                  ; $E243
  ora z:$94,x                  ; $E245
  bne Loc_E24D                 ; $E247
  inc z:$0E                    ; $E249
  bne Loc_E267                 ; $E24B
Loc_E24D:
  lda z:$AC,x                  ; $E24D
  cmp #$06                     ; $E24F
  bne Loc_E267                 ; $E251
  ldy #$14                     ; $E253
  lda z:$DC,x                  ; $E255
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
  lda z:$AC,x                  ; $E267
Loc_E269:
  rts                          ; $E269
Sub_E26A:
  lda $039F                    ; $E26A
  beq Loc_E269                 ; $E26D
  lda z:$84,x                  ; $E26F
  cmp #$02                     ; $E271
  beq Loc_E269                 ; $E273
  lda $0390,x                  ; $E275
  cmp #$F8                     ; $E278
  bcs Loc_E269                 ; $E27A
  cmp z:$80,x                  ; $E27C
  bcc Loc_E269                 ; $E27E
  lda $0390,x                  ; $E280
  sta z:$00                    ; $E283
  lda #$A8                     ; $E285
  sec                          ; $E287
  sbc z:$6C,x                  ; $E288
  sta z:$01                    ; $E28A
  lda #$22                     ; $E28C
  sta z:$03                    ; $E28E
  lda $039F                    ; $E290
  sta z:$04                    ; $E293
  lda z:$A4,x                  ; $E295
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
  jmp Sub_D1C7                 ; $E2AC
  lda $03BD                    ; $E2AF
  sec                          ; $E2B2
  sbc z:$60                    ; $E2B3
  sta $03BD                    ; $E2B5
  bcs Loc_E2BD                 ; $E2B8
  dec $03BE                    ; $E2BA
Loc_E2BD:
  ldy z:$52                    ; $E2BD
  beq Loc_E2D0                 ; $E2BF
  dey                          ; $E2C1
  bne Loc_E269                 ; $E2C2
  lda z:$20                    ; $E2C4
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
  jmp Sub_D1C7                 ; $E2F3
Sub_E2F6:
  lda $036C,x                  ; $E2F6
  beq Loc_E358                 ; $E2F9
  lda z:$94,x                  ; $E2FB
  ora z:$90,x                  ; $E2FD
  beq Loc_E358                 ; $E2FF
  lda z:$BC,x                  ; $E301
Loc_E303:
  bne Loc_E358                 ; $E303
  lda z:$84,x                  ; $E305
  lsr a                        ; $E307
  bcc Loc_E358                 ; $E308
  lda z:$80,x                  ; $E30A
  cmp #$10                     ; $E30C
  bcc Loc_E358                 ; $E30E
  clc                          ; $E310
  adc #$F9                     ; $E311
  sta $0297,y                  ; $E313
  clc                          ; $E316
  adc #$F8                     ; $E317
  sta $029B,y                  ; $E319
  lda z:$8C,x                  ; $E31C
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
  lda z:$94,x                  ; $E34F
  bne Loc_E358                 ; $E351
  lda #$F8                     ; $E353
  sta $0298,y                  ; $E355
Loc_E358:
  rts                          ; $E358
Sub_E359:
  lda z:$52                    ; $E359
  bne Loc_E3C6                 ; $E35B
  lda $03E0                    ; $E35D
  beq Loc_E36B                 ; $E360
  lda z:$3C                    ; $E362
  lsr a                        ; $E364
  bcs Loc_E3C6                 ; $E365
  lda #$FC                     ; $E367
  bne Loc_E3C8                 ; $E369
Loc_E36B:
  lda z:$5C                    ; $E36B
  and #$C0                     ; $E36D
  beq Loc_E37A                 ; $E36F
  ldy z:$4F                    ; $E371
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
  ora z:$FC                    ; $E3C2
  sta z:$FC                    ; $E3C4
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
Sub_E3F4:
  ldx #$03                     ; $E3F4
Loc_E3F6:
  txa                          ; $E3F6
  sta z:$88,x                  ; $E3F7
  lda z:$B8,x                  ; $E3F9
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
  ldx z:$88,y                  ; $E40F
  lda z:$00,x                  ; $E411
  ldx z:$89,y                  ; $E413
  cmp z:$00,x                  ; $E415
  bcc Loc_E421                 ; $E417
  lda a:$88,y                  ; $E419
  sta a:$89,y                  ; $E41C
  stx z:$88,y                  ; $E41F
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
  lda z:$88,x                  ; $E432
  beq Loc_E44A                 ; $E434
  cmp #$03                     ; $E436
  bne Loc_E43F                 ; $E438
  lda $0373                    ; $E43A
  bne Loc_E44A                 ; $E43D
Loc_E43F:
  lda Data_D8C0,x              ; $E43F
  sta z:$07                    ; $E442
  ldy $03B3                    ; $E444
  jsr Sub_E4AD                 ; $E447
Loc_E44A:
  dex                          ; $E44A
  bpl Loc_E432                 ; $E44B
  lda $03B3                    ; $E44D
  eor #$02                     ; $E450
  sta $03B3                    ; $E452
Loc_E455:
  rts                          ; $E455
Sub_E456:
  ldy #$03                     ; $E456
Loc_E458:
  sty z:$05                    ; $E458
  lda Data_D8C0,y              ; $E45A
  sta z:$07                    ; $E45D
  lda a:$88,y                  ; $E45F
  beq Loc_E495                 ; $E462
  tax                          ; $E464
  lda z:$84,x                  ; $E465
  sta z:$02                    ; $E467
  sta z:$03                    ; $E469
  sta z:$04                    ; $E46B
  lsr a                        ; $E46D
  bcs Loc_E484                 ; $E46E
  lda z:$80,x                  ; $E470
  cmp #$70                     ; $E472
  bcc Loc_E484                 ; $E474
  cmp #$90                     ; $E476
  bcs Loc_E484                 ; $E478
  jsr Sub_DB95                 ; $E47A
  lda #$01                     ; $E47D
  sta $03A6                    ; $E47F
  bne Loc_E492                 ; $E482
Loc_E484:
  lda z:$80,x                  ; $E484
  cmp #$F8                     ; $E486
  bcc Loc_E48C                 ; $E488
  inc z:$03                    ; $E48A
Loc_E48C:
  cmp #$F0                     ; $E48C
  bcc Loc_E492                 ; $E48E
  inc z:$04                    ; $E490
Loc_E492:
  jsr Sub_E49B                 ; $E492
Loc_E495:
  ldy z:$05                    ; $E495
  dey                          ; $E497
  bpl Loc_E458                 ; $E498
  rts                          ; $E49A
Sub_E49B:
  ldx #$00                     ; $E49B
Loc_E49D:
  lda z:$02,x                  ; $E49D
  lsr a                        ; $E49F
  bcs Loc_E4A7                 ; $E4A0
  txa                          ; $E4A2
  tay                          ; $E4A3
  jsr Sub_E4AD                 ; $E4A4
Loc_E4A7:
  inx                          ; $E4A7
  cpx #$03                     ; $E4A8
  bcc Loc_E49D                 ; $E4AA
  rts                          ; $E4AC
Sub_E4AD:
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
Sub_E4C8:
  ldx #$01                     ; $E4C8
Loc_E4CA:
  stx z:$0C                    ; $E4CA
  lda z:$84,x                  ; $E4CC
  lsr a                        ; $E4CE
  bcs Loc_E4D9                 ; $E4CF
  bne Loc_E50A                 ; $E4D1
  lda z:$80,x                  ; $E4D3
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
  lda a:$84,y                  ; $E4E2
  lsr a                        ; $E4E5
  bcs Loc_E4F0                 ; $E4E6
  bne Loc_E4FF                 ; $E4E8
  lda z:$80,x                  ; $E4EA
  cmp #$F8                     ; $E4EC
  bcc Loc_E4FF                 ; $E4EE
Loc_E4F0:
  jsr Sub_E52C                 ; $E4F0
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
  jsr Sub_E52C                 ; $E521
  beq Loc_E50A                 ; $E524
Loc_E526:
  lda #$01                     ; $E526
Loc_E528:
  sta $03A3                    ; $E528
  rts                          ; $E52B
Sub_E52C:
  lda z:$8C,x                  ; $E52C
  sec                          ; $E52E
  sbc a:$8C,y                  ; $E52F
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
  .addr Sub_E963, Sub_E8E3, Sub_E85D, Sub_E86A, Sub_E845, Sub_E854, Sub_E934, Sub_E818, Sub_EA8F, Sub_E879, Sub_E89D, Sub_E8EE, Sub_E8FF, Sub_E956, Sub_E8BF, Sub_E8C6, Sub_E8FA  ; $E6B7 pointer table
  .incbin "prg_bank_0.bin", $26D9, $8  ; $E6D9
Data_E6E1:
  .incbin "prg_bank_0.bin", $26E1, $15  ; $E6E1
Data_E6F6:
  .incbin "prg_bank_0.bin", $26F6, $5  ; $E6F6
Data_E6FB:
  .incbin "prg_bank_0.bin", $26FB, $8  ; $E6FB
Data_E703:
  .incbin "prg_bank_0.bin", $2703, $8  ; $E703
Sub_E70B:
  ldx #$03                     ; $E70B
Loc_E70D:
  lda z:$60,x                  ; $E70D
  beq Loc_E72B                 ; $E70F
  lda z:$64,x                  ; $E711
  sec                          ; $E713
  sbc z:$60,x                  ; $E714
  beq Loc_E71E                 ; $E716
  bmi Loc_E71E                 ; $E718
  sta z:$64,x                  ; $E71A
  bne Loc_E72B                 ; $E71C
Loc_E71E:
  clc                          ; $E71E
  adc #$08                     ; $E71F
  sta z:$64,x                  ; $E721
  inc z:$E0,x                  ; $E723
  lda z:$E0,x                  ; $E725
  and #$3F                     ; $E727
  sta z:$E0,x                  ; $E729
Loc_E72B:
  lda #$00                     ; $E72B
  sta z:$D8,x                  ; $E72D
  dex                          ; $E72F
  bpl Loc_E70D                 ; $E730
  rts                          ; $E732
Sub_E733:
  ldx #$03                     ; $E733
Loc_E735:
  jsr Sub_E73B                 ; $E735
  dex                          ; $E738
  bne Loc_E735                 ; $E739
Sub_E73B:
  lda z:$60,x                  ; $E73B
  clc                          ; $E73D
  adc z:$C8,x                  ; $E73E
  sta z:$C8,x                  ; $E740
  lda z:$58,x                  ; $E742
  bne Loc_E762                 ; $E744
  lda z:$C0,x                  ; $E746
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
  lda z:$64,x                  ; $E75C
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
  jsr Sub_E794                 ; $E78B
  inc z:$C4,x                  ; $E78E
  inc z:$C4,x                  ; $E790
  bne Loc_E762                 ; $E792
Sub_E794:
  asl a                        ; $E794
  tay                          ; $E795
  lda Data_E6B7,y              ; $E796
  sta z:$00                    ; $E799
  lda Data_E6B8,y              ; $E79B
  sta z:$01                    ; $E79E
  jmp ($0000)                  ; $E7A0
Loc_E7A3:
  lda z:$B0,x                  ; $E7A3
  ora z:$98,x                  ; $E7A5
  bne Loc_E7CA                 ; $E7A7
  lda ($0A),y                  ; $E7A9
  and #$0F                     ; $E7AB
  sta z:$00                    ; $E7AD
  lda z:$A4,x                  ; $E7AF
  cmp #$01                     ; $E7B1
  beq Loc_E7CA                 ; $E7B3
  lda z:$00                    ; $E7B5
  sta z:$AC,x                  ; $E7B7
  lda z:$58,x                  ; $E7B9
  cmp #$03                     ; $E7BB
  beq Loc_E7CA                 ; $E7BD
  lda z:$AC,x                  ; $E7BF
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
  lda z:$A0,x                  ; $E7D6
  bne Loc_E7EC                 ; $E7D8
  lda z:$A4,x                  ; $E7DA
  cmp #$01                     ; $E7DC
  beq Loc_E7EC                 ; $E7DE
  lda #$00                     ; $E7E0
  sta z:$BC,x                  ; $E7E2
  lda z:$A4,x                  ; $E7E4
  cmp #$02                     ; $E7E6
  bne Loc_E7EC                 ; $E7E8
  inc z:$A4,x                  ; $E7EA
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
Sub_E7FC:
  ldy $0360,x                  ; $E7FC
Sub_E7FF:
  lda z:$E0,x                  ; $E7FF
  sta z:$08                    ; $E801
Sub_E803:
  jsr Sub_E80D                 ; $E803
  sty z:$07                    ; $E806
  ldy z:$08                    ; $E808
  lda ($03),y                  ; $E80A
  rts                          ; $E80C
Sub_E80D:
  lda Data_E54E,y              ; $E80D
  sta z:$03                    ; $E810
  lda Data_E554,y              ; $E812
  sta z:$04                    ; $E815
  rts                          ; $E817
Sub_E818:
  lda z:$B0,x                  ; $E818
  bne Loc_E835                 ; $E81A
  lda z:$AC,x                  ; $E81C
  cmp #$07                     ; $E81E
  bpl Loc_E835                 ; $E820
  lda z:$94,x                  ; $E822
  cmp #$03                     ; $E824
  bcs Loc_E831                 ; $E826
  cmp #$02                     ; $E828
  bne Loc_E835                 ; $E82A
  lda z:$90,x                  ; $E82C
  asl a                        ; $E82E
  bcc Loc_E835                 ; $E82F
Loc_E831:
  lda #$FF                     ; $E831
  sta z:$98,x                  ; $E833
Loc_E835:
  rts                          ; $E835
Sub_E836:
  ldx #$03                     ; $E836
Loc_E838:
  lda z:$B0,x                  ; $E838
  bne Loc_E841                 ; $E83A
  jsr Sub_DC97                 ; $E83C
  sta z:$8C,x                  ; $E83F
Loc_E841:
  dex                          ; $E841
  bpl Loc_E838                 ; $E842
  rts                          ; $E844
Sub_E845:
  lda #$80                     ; $E845
  sta z:$D8,x                  ; $E847
  lda #$05                     ; $E849
  jsr Sub_E893                 ; $E84B
  lsr a                        ; $E84E
Sub_E84F:
  sta z:$BC,x                  ; $E84F
  sta z:$E4,x                  ; $E851
  rts                          ; $E853
Sub_E854:
  lda #$02                     ; $E854
  jsr Sub_E893                 ; $E856
  lsr a                        ; $E859
  jmp Sub_E86F                 ; $E85A
Sub_E85D:
  lda #$06                     ; $E85D
  jsr Sub_E893                 ; $E85F
  jsr Sub_E84F                 ; $E862
  lda #$60                     ; $E865
  sta z:$D8,x                  ; $E867
  rts                          ; $E869
Sub_E86A:
  lda #$01                     ; $E86A
  jsr Sub_E893                 ; $E86C
Sub_E86F:
  sta z:$00                    ; $E86F
  lda z:$E4,x                  ; $E871
  sec                          ; $E873
  sbc z:$00                    ; $E874
  sta z:$BC,x                  ; $E876
  rts                          ; $E878
Sub_E879:
  lda #$04                     ; $E879
  jsr Sub_E893                 ; $E87B
  asl a                        ; $E87E
  jsr Sub_E84F                 ; $E87F
  lda z:$A0,x                  ; $E882
  beq Loc_E88E                 ; $E884
  lda z:$BC,x                  ; $E886
  clc                          ; $E888
  adc #$10                     ; $E889
  jsr Sub_E84F                 ; $E88B
Loc_E88E:
  lda #$40                     ; $E88E
  sta z:$D8,x                  ; $E890
  rts                          ; $E892
Sub_E893:
  sta z:$D4,x                  ; $E893
  sta z:$B4,x                  ; $E895
  lda z:$C8,x                  ; $E897
  sec                          ; $E899
  sbc z:$D0,x                  ; $E89A
  rts                          ; $E89C
Sub_E89D:
  lda z:$A4,x                  ; $E89D
  beq Loc_E8A5                 ; $E89F
  cmp #$01                     ; $E8A1
  beq Loc_E8BE                 ; $E8A3
Loc_E8A5:
  lda #$03                     ; $E8A5
  jsr Sub_E893                 ; $E8A7
  asl a                        ; $E8AA
  jsr Sub_E86F                 ; $E8AB
  lda z:$A4,x                  ; $E8AE
  cmp #$04                     ; $E8B0
  bne Loc_E8BE                 ; $E8B2
  jsr Sub_DD06                 ; $E8B4
  lda #$02                     ; $E8B7
  sta z:$A4,x                  ; $E8B9
  sta $0364,x                  ; $E8BB
Loc_E8BE:
  rts                          ; $E8BE
Sub_E8BF:
  lda #$00                     ; $E8BF
  sta z:$A4,x                  ; $E8C1
Loc_E8C3:
  sta z:$A0,x                  ; $E8C3
  rts                          ; $E8C5
Sub_E8C6:
  lda #$01                     ; $E8C6
  sta z:$A4,x                  ; $E8C8
  lda z:$B8,x                  ; $E8CA
  cmp #$20                     ; $E8CC
  bcs Loc_E8D2                 ; $E8CE
  inc z:$A4,x                  ; $E8D0
Loc_E8D2:
  rts                          ; $E8D2
  txa                          ; $E8D3
  ora z:$B0,x                  ; $E8D4
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
  lda z:$B0,x                  ; $E8E7
  bne Loc_E8E2                 ; $E8E9
  jmp Loc_DCFE                 ; $E8EB
Sub_E8EE:
  lda #$02                     ; $E8EE
  sta z:$A0,x                  ; $E8F0
  lsr a                        ; $E8F2
  sta z:$D8,x                  ; $E8F3
  lda #$30                     ; $E8F5
  jmp Sub_E84F                 ; $E8F7
Sub_E8FA:
  lda #$10                     ; $E8FA
  jmp Sub_E84F                 ; $E8FC
Sub_E8FF:
  lda z:$B0,x                  ; $E8FF
  bne Loc_E926                 ; $E901
  lda z:$A4,x                  ; $E903
  beq Loc_E90B                 ; $E905
  lsr a                        ; $E907
  lsr a                        ; $E908
  bcc Loc_E926                 ; $E909
Loc_E90B:
  sty z:$01                    ; $E90B
  lda z:$94,x                  ; $E90D
  beq Loc_E924                 ; $E90F
  ldy #$04                     ; $E911
  lda z:$5C,x                  ; $E913
  asl a                        ; $E915
  asl a                        ; $E916
  bcc Loc_E91A                 ; $E917
  dey                          ; $E919
Loc_E91A:
  lda #$01                     ; $E91A
  sta $036C,x                  ; $E91C
  iny                          ; $E91F
  iny                          ; $E920
  jsr Sub_CE5C                 ; $E921
Loc_E924:
  ldy z:$01                    ; $E924
Loc_E926:
  rts                          ; $E926
Sub_E927:
  ldx #$03                     ; $E927
Loc_E929:
  lda z:$CC,x                  ; $E929
  beq Loc_E930                 ; $E92B
  jsr Sub_E794                 ; $E92D
Loc_E930:
  dex                          ; $E930
  bpl Loc_E929                 ; $E931
Loc_E933:
  rts                          ; $E933
Sub_E934:
  lda z:$B0,x                  ; $E934
  bne Loc_E933                 ; $E936
  ldy #$00                     ; $E938
  lda z:$94,x                  ; $E93A
  beq Loc_E933                 ; $E93C
  cmp #$02                     ; $E93E
  bcs Loc_E949                 ; $E940
  lda z:$90,x                  ; $E942
  cmp z:$D8,x                  ; $E944
  bcs Loc_E949                 ; $E946
  iny                          ; $E948
Loc_E949:
  tya                          ; $E949
  sta $0388,x                  ; $E94A
  lda z:$A0,x                  ; $E94D
  cmp #$02                     ; $E94F
  beq Loc_E960                 ; $E951
  jmp Loc_DCFA                 ; $E953
Sub_E956:
  lda z:$A4,x                  ; $E956
  cmp #$01                     ; $E958
  bne Loc_E933                 ; $E95A
  lda #$00                     ; $E95C
  sta z:$BC,x                  ; $E95E
Loc_E960:
  jmp Sub_DD06                 ; $E960
Sub_E963:
  lda #$00                     ; $E963
  sta z:$CC,x                  ; $E965
  sta z:$D4,x                  ; $E967
  sta z:$B4,x                  ; $E969
  rts                          ; $E96B
Sub_E96C:
  ldx #$03                     ; $E96C
Loc_E96E:
  lda z:$58,x                  ; $E96E
  cmp #$15                     ; $E970
  beq Loc_E97F                 ; $E972
  cmp #$14                     ; $E974
  beq Loc_E97F                 ; $E976
  lda z:$B8,x                  ; $E978
  clc                          ; $E97A
  adc z:$DC,x                  ; $E97B
  sta z:$B8,x                  ; $E97D
Loc_E97F:
  ldy #$03                     ; $E97F
Loc_E981:
  lda z:$B8,x                  ; $E981
  cmp Data_E53D,y              ; $E983
  beq Loc_EA01                 ; $E986
  dey                          ; $E988
  bpl Loc_E981                 ; $E989
  lda z:$A4,x                  ; $E98B
  beq Loc_E9C4                 ; $E98D
  cmp #$01                     ; $E98F
  bne Loc_E9B8                 ; $E991
  lda z:$B8,x                  ; $E993
  cmp #$20                     ; $E995
  bcs Loc_E9C4                 ; $E997
  lda #$04                     ; $E999
  sta z:$A4,x                  ; $E99B
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
  sta z:$BC,x                  ; $E9AF
  jsr Sub_DD06                 ; $E9B1
  dec z:$A4,x                  ; $E9B4
  bne Loc_E9E3                 ; $E9B6
Loc_E9B8:
  cmp #$03                     ; $E9B8
  beq Loc_E9C4                 ; $E9BA
  lda z:$B8,x                  ; $E9BC
  cmp #$20                     ; $E9BE
  bcc Loc_E9C4                 ; $E9C0
  dec z:$B8,x                  ; $E9C2
Loc_E9C4:
  lda z:$B8,x                  ; $E9C4
  cmp #$08                     ; $E9C6
  bcc Loc_E9E9                 ; $E9C8
  cmp #$3A                     ; $E9CA
  bcc Loc_E9E3                 ; $E9CC
  lda #$39                     ; $E9CE
  sta z:$B8,x                  ; $E9D0
Loc_E9D2:
  lda z:$9C,x                  ; $E9D2
  ora $03E0,x                  ; $E9D4
  bne Loc_E9E3                 ; $E9D7
Loc_E9D9:
  lda z:$DC,x                  ; $E9D9
  bne Loc_E9DF                 ; $E9DB
  lda #$FF                     ; $E9DD
Loc_E9DF:
  eor #$FE                     ; $E9DF
  sta z:$DC,x                  ; $E9E1
Loc_E9E3:
  dex                          ; $E9E3
  bmi Loc_EA07                 ; $E9E4
  jmp Loc_E96E                 ; $E9E6
Loc_E9E9:
  lda z:$9C,x                  ; $E9E9
  bne Loc_E9F1                 ; $E9EB
  lda #$07                     ; $E9ED
  bne Loc_E9F9                 ; $E9EF
Loc_E9F1:
  lda z:$B8,x                  ; $E9F1
  cmp #$02                     ; $E9F3
  bcs Loc_E9F9                 ; $E9F5
  lda #$01                     ; $E9F7
Loc_E9F9:
  sta z:$B8,x                  ; $E9F9
  cpx #$00                     ; $E9FB
  beq Loc_E9D9                 ; $E9FD
  bne Loc_E9D2                 ; $E9FF
Loc_EA01:
  lda #$00                     ; $EA01
  sta z:$DC,x                  ; $EA03
  beq Loc_E9E3                 ; $EA05
Loc_EA07:
  lda z:$4F                    ; $EA07
  beq Loc_EA43                 ; $EA09
  lda z:$98                    ; $EA0B
  ora $03E0                    ; $EA0D
  ora $03F7                    ; $EA10
  bne Loc_EA43                 ; $EA13
  lda z:$B0                    ; $EA15
  beq Loc_EA23                 ; $EA17
  lda $0388                    ; $EA19
  cmp #$02                     ; $EA1C
  bne Loc_EA43                 ; $EA1E
  inc $0388                    ; $EA20
Loc_EA23:
  lda z:$9C                    ; $EA23
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
  sta z:$DC                    ; $EA3B
  lda #$04                     ; $EA3D
  ora z:$FD                    ; $EA3F
  sta z:$FD                    ; $EA41
Loc_EA43:
  rts                          ; $EA43
Sub_EA44:
  ldx #$03                     ; $EA44
Loc_EA46:
  txa                          ; $EA46
  asl a                        ; $EA47
  asl a                        ; $EA48
  asl a                        ; $EA49
  tay                          ; $EA4A
  lda z:$84,x                  ; $EA4B
  lsr a                        ; $EA4D
  bcc Loc_EA58                 ; $EA4E
  lda z:$80,x                  ; $EA50
  cmp #$F4                     ; $EA52
  bcc Loc_EA61                 ; $EA54
  bcs Loc_EA88                 ; $EA56
Loc_EA58:
  lsr a                        ; $EA58
  bcs Loc_EA88                 ; $EA59
  lda z:$80,x                  ; $EA5B
  cmp #$F6                     ; $EA5D
  bcc Loc_EA88                 ; $EA5F
Loc_EA61:
  lda z:$B0,x                  ; $EA61
  beq Loc_EA88                 ; $EA63
  lda #$B6                     ; $EA65
  jsr Sub_DC9A                 ; $EA67
  sta $0294,y                  ; $EA6A
  lda z:$80,x                  ; $EA6D
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
  jsr Sub_E2F6                 ; $EA88
Loc_EA8B:
  dex                          ; $EA8B
  bpl Loc_EA46                 ; $EA8C
  rts                          ; $EA8E
Sub_EA8F:
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
  sta z:$FD                    ; $EABB
  lsr a                        ; $EABD
  sta z:$52                    ; $EABE
Loc_EAC0:
  lda #$00                     ; $EAC0
  sta z:$3A                    ; $EAC2
Loc_EAC4:
  rts                          ; $EAC4
Sub_EAC5:
  lda z:$52                    ; $EAC5
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
  sta z:$FB                    ; $EADE
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
  sta z:$60                    ; $EB29
  sta z:$C0                    ; $EB2B
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
  sta z:$B8                    ; $EB41
Loc_EB43:
  lda #$02                     ; $EB43
  sta z:$C1                    ; $EB45
  bne Loc_EB93                 ; $EB47
Loc_EB49:
  lda z:$BF                    ; $EB49
  bne Loc_EB5E                 ; $EB4B
  lda z:$5C                    ; $EB4D
  asl a                        ; $EB4F
  bcc Loc_EB7F                 ; $EB50
  lda #$00                     ; $EB52
  sta z:$49                    ; $EB54
  lda z:$2B                    ; $EB56
  bne Loc_EB9D                 ; $EB58
  lda #$05                     ; $EB5A
  sta z:$2B                    ; $EB5C
Loc_EB5E:
  lda #$04                     ; $EB5E
  sta z:$60                    ; $EB60
  jsr Sub_EC99                 ; $EB62
  ldy z:$B3                    ; $EB65
  lda #$00                     ; $EB67
  sta z:$BD                    ; $EB69
  jsr Sub_ECC9                 ; $EB6B
  bne Loc_EB7C                 ; $EB6E
  iny                          ; $EB70
  cpy #$40                     ; $EB71
  bne Loc_EB77                 ; $EB73
  ldy #$00                     ; $EB75
Loc_EB77:
  jsr Sub_ECC9                 ; $EB77
  beq Loc_EB9D                 ; $EB7A
Loc_EB7C:
  inc z:$BD                    ; $EB7C
Loc_EB7E:
  rts                          ; $EB7E
Loc_EB7F:
  asl a                        ; $EB7F
  bcc Loc_EBF6                 ; $EB80
  lda z:$49                    ; $EB82
  bne Loc_EB9D                 ; $EB84
  jsr Sub_EC75                 ; $EB86
  lda z:$B8                    ; $EB89
  cmp #$FF                     ; $EB8B
  beq Loc_EB9D                 ; $EB8D
  cmp #$09                     ; $EB8F
  beq Loc_EB43                 ; $EB91
Loc_EB93:
  lda #$01                     ; $EB93
  sta z:$BE                    ; $EB95
  sta z:$49                    ; $EB97
  lda #$40                     ; $EB99
  sta z:$FB                    ; $EB9B
Loc_EB9D:
  rts                          ; $EB9D
Loc_EB9E:
  lda z:$49                    ; $EB9E
  bne Loc_EBB6                 ; $EBA0
  lda z:$5C                    ; $EBA2
  asl a                        ; $EBA4
  asl a                        ; $EBA5
  bcc Loc_EBBD                 ; $EBA6
  jsr Sub_C3B1                 ; $EBA8
  jsr Sub_EC3B                 ; $EBAB
  stx z:$47                    ; $EBAE
  stx z:$42                    ; $EBB0
  lda #$08                     ; $EBB2
  sta z:GameState              ; $EBB4
Loc_EBB6:
  lda z:$5C                    ; $EBB6
  bne Loc_EBBC                 ; $EBB8
  sta z:$49                    ; $EBBA
Loc_EBBC:
  rts                          ; $EBBC
Loc_EBBD:
  jsr Sub_EC5D                 ; $EBBD
  lda z:$3A                    ; $EBC0
  bne Loc_EBBC                 ; $EBC2
  inc z:$3A                    ; $EBC4
  lda z:$5C                    ; $EBC6
  cmp #$80                     ; $EBC8
  beq Loc_EBD0                 ; $EBCA
  cmp #$08                     ; $EBCC
  bne Loc_EBE9                 ; $EBCE
Loc_EBD0:
  inc $05E0                    ; $EBD0
  lda $05E0                    ; $EBD3
  cmp #$0A                     ; $EBD6
  bmi Loc_EBDF                 ; $EBD8
  lda #$01                     ; $EBDA
Loc_EBDC:
  sta $05E0                    ; $EBDC
Loc_EBDF:
  lda #$01                     ; $EBDF
  sta z:$FF                    ; $EBE1
  lsr a                        ; $EBE3
  sta z:$49                    ; $EBE4
  jmp Loc_EC47                 ; $EBE6
Loc_EBE9:
  cmp #$04                     ; $EBE9
  bne Loc_EBB6                 ; $EBEB
  dec $05E0                    ; $EBED
  bne Loc_EBDF                 ; $EBF0
  lda #$09                     ; $EBF2
  bne Loc_EBDC                 ; $EBF4
Loc_EBF6:
  lda z:$2C                    ; $EBF6
  bne Loc_EC3A                 ; $EBF8
  lda #$08                     ; $EBFA
  sta z:$2C                    ; $EBFC
  lda z:$5C                    ; $EBFE
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
  sta z:$FF                    ; $EC1E
  lsr a                        ; $EC20
  sta z:$49                    ; $EC21
  lda #$D0                     ; $EC23
Sub_EC25:
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
Sub_EC3B:
  ldx #$00                     ; $EC3B
Loc_EC3D:
  lda $05E0,x                  ; $EC3D
  sta $06E0,x                  ; $EC40
  dex                          ; $EC43
  bne Loc_EC3D                 ; $EC44
  rts                          ; $EC46
Loc_EC47:
  lda #$CF                     ; $EC47
  sta $0234                    ; $EC49
  lda $05E0                    ; $EC4C
  sta $0235                    ; $EC4F
  lda #$00                     ; $EC52
  sta $0236                    ; $EC54
  lda #$E4                     ; $EC57
  sta $0237                    ; $EC59
  rts                          ; $EC5C
Sub_EC5D:
  lda #$F8                     ; $EC5D
  jsr Sub_EC25                 ; $EC5F
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
Sub_EC75:
  lda #$00                     ; $EC75
  sta z:$CA                    ; $EC77
  sta z:$C8                    ; $EC79
  sta z:$C9                    ; $EC7B
  lda z:$B2                    ; $EC7D
  sta z:$BA                    ; $EC7F
  lda z:$B0                    ; $EC81
  sta z:$BB                    ; $EC83
  lda z:$B1                    ; $EC85
  sta z:$BC                    ; $EC87
  ldy z:$C2                    ; $EC89
  lda Data_E6E1,y              ; $EC8B
  sta z:$B8                    ; $EC8E
  cmp #$11                     ; $EC90
  bcc Loc_EC98                 ; $EC92
  and #$0F                     ; $EC94
  sta z:$C8                    ; $EC96
Loc_EC98:
  rts                          ; $EC98
Sub_EC99:
  lda z:$60                    ; $EC99
  beq Loc_EC98                 ; $EC9B
  clc                          ; $EC9D
  adc z:$B9                    ; $EC9E
  sta z:$B9                    ; $ECA0
  cmp #$08                     ; $ECA2
  bne Loc_EC98                 ; $ECA4
  lda #$01                     ; $ECA6
  sta z:$C0                    ; $ECA8
  lsr a                        ; $ECAA
  sta z:$B9                    ; $ECAB
  jsr Sub_F6FB                 ; $ECAD
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
Sub_ECC9:
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
Sub_ECE4:
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
  .incbin "prg_bank_0.bin", $3063, $24  ; $F063
Data_F087:
  .incbin "prg_bank_0.bin", $3087, $2E  ; $F087
Data_F0B5:
  .incbin "prg_bank_0.bin", $30B5, $323  ; $F0B5
Data_F3D8:
  .incbin "prg_bank_0.bin", $33D8, $EE  ; $F3D8
Data_F4C6:
  .incbin "prg_bank_0.bin", $34C6, $7  ; $F4C6
Data_F4CD:
  .incbin "prg_bank_0.bin", $34CD, $28  ; $F4CD
Data_F4F5:
  .incbin "prg_bank_0.bin", $34F5, $5  ; $F4F5
Data_F4FA:
  .incbin "prg_bank_0.bin", $34FA, $5  ; $F4FA
Sub_F4FF:
  ldx z:$43                    ; $F4FF
  lda Data_ED3A,x              ; $F501
  sta z:$07                    ; $F504
  lda Data_ED40,x              ; $F506
  sta z:$08                    ; $F509
  lda z:$EB                    ; $F50B
  cmp z:$E0                    ; $F50D
  beq Loc_F512                 ; $F50F
Loc_F511:
  rts                          ; $F511
Loc_F512:
  lda z:$EC                    ; $F512
  bne Loc_F591                 ; $F514
  lda z:$EF                    ; $F516
  bne Loc_F597                 ; $F518
Loc_F51A:
  ldy z:$ED                    ; $F51A
  bne Loc_F525                 ; $F51C
  lda ($07),y                  ; $F51E
  sta z:$57                    ; $F520
  inc $03A4                    ; $F522
Loc_F525:
  lda z:GameState              ; $F525
  cmp #$09                     ; $F527
  bne Loc_F53A                 ; $F529
  lda $03BC                    ; $F52B
  beq Loc_F53A                 ; $F52E
  lda #$00                     ; $F530
  sta z:$EE                    ; $F532
  sta z:$ED                    ; $F534
  lda #$7F                     ; $F536
  bne Loc_F58D                 ; $F538
Loc_F53A:
  inc z:$ED                    ; $F53A
  ldy z:$ED                    ; $F53C
  lda ($07),y                  ; $F53E
  beq Loc_F511                 ; $F540
  bit Data_F3D8                ; $F542
  beq Loc_F54B                 ; $F545
  lda z:$46                    ; $F547
  beq Loc_F51A                 ; $F549
Loc_F54B:
  lda ($07),y                  ; $F54B
  bit Data_F0B5                ; $F54D
  beq Loc_F576                 ; $F550
  and #$0F                     ; $F552
  tax                          ; $F554
  lda Data_F4C6,x              ; $F555
  sta z:$EE                    ; $F558
  inc z:$ED                    ; $F55A
  iny                          ; $F55C
  lda z:GameState              ; $F55D
  cmp #$09                     ; $F55F
  bne Loc_F572                 ; $F561
  cpy #$02                     ; $F563
  bne Loc_F572                 ; $F565
  lda #$01                     ; $F567
  sta z:$57                    ; $F569
  lda ($07),y                  ; $F56B
  sec                          ; $F56D
  sbc #$3D                     ; $F56E
  bne Loc_F58D                 ; $F570
Loc_F572:
  lda ($07),y                  ; $F572
  bne Loc_F58D                 ; $F574
Loc_F576:
  ldx #$01                     ; $F576
  and #$3F                     ; $F578
  sta z:$EE                    ; $F57A
  cmp #$30                     ; $F57C
  bcc Loc_F597                 ; $F57E
  bne Loc_F587                 ; $F580
  lda $03BC                    ; $F582
  beq Loc_F588                 ; $F585
Loc_F587:
  dex                          ; $F587
Loc_F588:
  stx $03A8                    ; $F588
  bpl Loc_F51A                 ; $F58B
Loc_F58D:
  and #$7F                     ; $F58D
  sta z:$EC                    ; $F58F
Loc_F591:
  lda #$00                     ; $F591
  sta z:$EF                    ; $F593
  dec z:$EC                    ; $F595
Loc_F597:
  ldx z:$EE                    ; $F597
  jsr Sub_F82E                 ; $F599
  ldy z:$EF                    ; $F59C
  lda ($05),y                  ; $F59E
  bne Loc_F5A5                 ; $F5A0
  jmp Loc_F62D                 ; $F5A2
Loc_F5A5:
  jsr Sub_F676                 ; $F5A5
  lda ($05),y                  ; $F5A8
  tax                          ; $F5AA
  jsr Sub_F681                 ; $F5AB
  lda z:$EE                    ; $F5AE
  beq Loc_F5BA                 ; $F5B0
  cmp #$18                     ; $F5B2
  beq Loc_F5BA                 ; $F5B4
  cmp #$1A                     ; $F5B6
  bne Loc_F5C9                 ; $F5B8
Loc_F5BA:
  lda $03A2                    ; $F5BA
  eor #$01                     ; $F5BD
  sta $03A2                    ; $F5BF
  bne Loc_F5C9                 ; $F5C2
  lda #$83                     ; $F5C4
  sta $030A                    ; $F5C6
Loc_F5C9:
  iny                          ; $F5C9
  sty z:$EF                    ; $F5CA
  lda z:$EE                    ; $F5CC
  cmp #$09                     ; $F5CE
  bne Loc_F5F6                 ; $F5D0
  lda z:$57                    ; $F5D2
  cmp #$01                     ; $F5D4
  beq Loc_F5F6                 ; $F5D6
  cpy #$25                     ; $F5D8
  bcc Loc_F5F6                 ; $F5DA
  cpy #$58                     ; $F5DC
  bcs Loc_F5F6                 ; $F5DE
  ldx $03A5                    ; $F5E0
  lda Data_F4CD,x              ; $F5E3
  sta $0310                    ; $F5E6
  inc $03A5                    ; $F5E9
  cpx #$05                     ; $F5EC
  bne Loc_F5F6                 ; $F5EE
  lda $03A4                    ; $F5F0
  sta $0310                    ; $F5F3
Loc_F5F6:
  lda #$8E                     ; $F5F6
  sta $0303                    ; $F5F8
  lda z:$EA                    ; $F5FB
  sta $0301                    ; $F5FD
  lda z:$E9                    ; $F600
  sta $0302                    ; $F602
  lda z:$E8                    ; $F605
  sta z:$0F                    ; $F607
  jsr Sub_F64E                 ; $F609
  lda z:$E8                    ; $F60C
  jsr IncMod64                 ; $F60E
  sta z:$E8                    ; $F611
  inc z:$E9                    ; $F613
  lda z:$E9                    ; $F615
  cmp #$20                     ; $F617
  bne Loc_F625                 ; $F619
  lda #$00                     ; $F61B
  sta z:$E9                    ; $F61D
  lda z:$EA                    ; $F61F
  eor #$04                     ; $F621
  sta z:$EA                    ; $F623
Loc_F625:
  lda z:$E0                    ; $F625
  jsr IncMod64                 ; $F627
  sta z:$EB                    ; $F62A
  rts                          ; $F62C
Loc_F62D:
  sta z:$EF                    ; $F62D
  lda z:$EE                    ; $F62F
  cmp #$09                     ; $F631
  beq Loc_F638                 ; $F633
  jmp Loc_F51A                 ; $F635
Loc_F638:
  inc $03A4                    ; $F638
  dec z:$57                    ; $F63B
  bne Loc_F644                 ; $F63D
  lda #$01                     ; $F63F
  sta $03BC                    ; $F641
Loc_F644:
  lda #$00                     ; $F644
  sta z:$ED                    ; $F646
  sta $03A5                    ; $F648
  jmp Loc_F525                 ; $F64B
Sub_F64E:
  ldx #$05                     ; $F64E
  lda #$0D                     ; $F650
  sta z:$0C                    ; $F652
Loc_F654:
  txa                          ; $F654
  tay                          ; $F655
  jsr Sub_E80D                 ; $F656
  stx z:$0A                    ; $F659
Loc_F65B:
  ldx z:$0C                    ; $F65B
  lda $0304,x                  ; $F65D
  cmp #$FC                     ; $F660
  bne Loc_F66A                 ; $F662
  dec z:$0C                    ; $F664
  lda z:$0C                    ; $F666
  bpl Loc_F65B                 ; $F668
Loc_F66A:
  ldy z:$0F                    ; $F66A
  sta ($03),y                  ; $F66C
  dec z:$0C                    ; $F66E
  ldx z:$0A                    ; $F670
  dex                          ; $F672
  bpl Loc_F654                 ; $F673
  rts                          ; $F675
Sub_F676:
  ldx #$0A                     ; $F676
  lda #$FC                     ; $F678
Loc_F67A:
  sta $0303,x                  ; $F67A
  dex                          ; $F67D
  bne Loc_F67A                 ; $F67E
  rts                          ; $F680
Sub_F681:
  iny                          ; $F681
  lda ($05),y                  ; $F682
  sta $0303,x                  ; $F684
  inx                          ; $F687
  cpx #$0F                     ; $F688
  bne Sub_F681                 ; $F68A
Loc_F68C:
  rts                          ; $F68C
  lda z:$BE                    ; $F68D  [heuristic code]
  beq Loc_F68C                 ; $F68F
  lda z:$CA                    ; $F691
  bne Loc_F6C7                 ; $F693
  lda z:$C3                    ; $F695
  bne Loc_F6C7                 ; $F697
  ldx z:$C8                    ; $F699
  txa                          ; $F69B
  beq Loc_F6C7                 ; $F69C
  dex                          ; $F69E
  jsr Sub_F839                 ; $F69F
  ldy z:$C9                    ; $F6A2
  lda ($07),y                  ; $F6A4
  bne Loc_F6AB                 ; $F6A6
  jmp Loc_F71E                 ; $F6A8
Loc_F6AB:
  bit Data_F0B5                ; $F6AB
  beq Loc_F6C2                 ; $F6AE
  and #$0F                     ; $F6B0
  tax                          ; $F6B2
  lda Data_F4C6,x              ; $F6B3
  sta z:$B8                    ; $F6B6
  iny                          ; $F6B8
  lda ($07),y                  ; $F6B9
  sta z:$CA                    ; $F6BB
  iny                          ; $F6BD
  sty z:$C9                    ; $F6BE
  bne Loc_F6C7                 ; $F6C0
Loc_F6C2:
  sta z:$B8                    ; $F6C2
  iny                          ; $F6C4
  sty z:$C9                    ; $F6C5
Loc_F6C7:
  ldx z:$B8                    ; $F6C7
  jsr Sub_F82E                 ; $F6C9
  ldy z:$C3                    ; $F6CC
  lda ($05),y                  ; $F6CE
  beq Loc_F70E                 ; $F6D0
  jsr Sub_F676                 ; $F6D2
  lda ($05),y                  ; $F6D5
  tax                          ; $F6D7
  jsr Sub_F681                 ; $F6D8
  iny                          ; $F6DB
  sty z:$C3                    ; $F6DC
  lda #$8E                     ; $F6DE
  sta $0303                    ; $F6E0
  lda z:$B0                    ; $F6E3
  sta $0301                    ; $F6E5
  lda z:$B1                    ; $F6E8
  sta $0302                    ; $F6EA
  lda z:$B2                    ; $F6ED
  sta z:$0F                    ; $F6EF
  jsr Sub_F64E                 ; $F6F1
  lda z:$B2                    ; $F6F4
  jsr IncMod64                 ; $F6F6
  sta z:$B2                    ; $F6F9
Sub_F6FB:
  inc z:$B1                    ; $F6FB
  lda z:$B1                    ; $F6FD
  cmp #$20                     ; $F6FF
  bne Loc_F70D                 ; $F701
  lda #$00                     ; $F703
  sta z:$B1                    ; $F705
  lda z:$B0                    ; $F707
  eor #$04                     ; $F709
  sta z:$B0                    ; $F70B
Loc_F70D:
  rts                          ; $F70D
Loc_F70E:
  lda z:$C8                    ; $F70E
  beq Loc_F71E                 ; $F710
  lda #$00                     ; $F712
  sta z:$C3                    ; $F714
  lda z:$CA                    ; $F716
  beq Loc_F739                 ; $F718
  dec z:$CA                    ; $F71A
  bpl Loc_F739                 ; $F71C
Loc_F71E:
  ldy z:$B2                    ; $F71E
  jsr Sub_ECC9                 ; $F720
  bne Loc_F731                 ; $F723
  iny                          ; $F725
  cpy #$40                     ; $F726
  bne Loc_F72C                 ; $F728
  ldy #$00                     ; $F72A
Loc_F72C:
  jsr Sub_ECC9                 ; $F72C
  beq Loc_F73E                 ; $F72F
Loc_F731:
  lda #$00                     ; $F731
  sta z:$B8                    ; $F733
  sta z:$C3                    ; $F735
  sta z:$C8                    ; $F737
Loc_F739:
  lda #$01                     ; $F739
  sta z:$BE                    ; $F73B
  rts                          ; $F73D
Loc_F73E:
  lda #$00                     ; $F73E
  sta z:$C3                    ; $F740
  sta z:$BE                    ; $F742
  sta z:$BD                    ; $F744
  sta z:$C8                    ; $F746
  lda z:$BA                    ; $F748
  sta z:$B2                    ; $F74A
  lda z:$BB                    ; $F74C
  sta z:$B0                    ; $F74E
  lda z:$BC                    ; $F750
  sta z:$B1                    ; $F752
  rts                          ; $F754
  lda z:$B4                    ; $F755  [heuristic code]
  bne Loc_F798                 ; $F757
  lda z:$C0                    ; $F759
  beq Loc_F798                 ; $F75B
  ldx #$15                     ; $F75D
Loc_F75F:
  jsr Sub_F82E                 ; $F75F
  ldy #$00                     ; $F762
  lda ($05),y                  ; $F764
  sta z:$03                    ; $F766
  lda #$0F                     ; $F768
  sec                          ; $F76A
  sbc z:$03                    ; $F76B
  tay                          ; $F76D
  stx z:$04                    ; $F76E
  ldx z:$B3                    ; $F770
  lda ($05),y                  ; $F772
  cmp $0540,x                  ; $F774
  bne Loc_F792                 ; $F777
  dey                          ; $F779
  dey                          ; $F77A
  dey                          ; $F77B
  lda ($05),y                  ; $F77C
  cmp $0480,x                  ; $F77E
  bne Loc_F792                 ; $F781
  dey                          ; $F783
  dey                          ; $F784
  lda ($05),y                  ; $F785
  cmp $0400,x                  ; $F787
  bne Loc_F792                 ; $F78A
  lda z:$04                    ; $F78C
  sta z:$C7                    ; $F78E
  bpl Loc_F799                 ; $F790
Loc_F792:
  dec z:$04                    ; $F792
  ldx z:$04                    ; $F794
  bpl Loc_F75F                 ; $F796
Loc_F798:
  rts                          ; $F798
Loc_F799:
  lda z:$C4                    ; $F799
  bne Loc_F7AC                 ; $F79B
  lda z:$C7                    ; $F79D
  sta z:$C6                    ; $F79F
  ldx z:$B7                    ; $F7A1
  jsr Sub_F821                 ; $F7A3
  lda #$3D                     ; $F7A6
  sta z:$C5                    ; $F7A8
  inc z:$C4                    ; $F7AA
Loc_F7AC:
  lda z:$C7                    ; $F7AC
  cmp z:$C6                    ; $F7AE
  bne Loc_F7C9                 ; $F7B0
  lda z:$C6                    ; $F7B2
  bne Loc_F798                 ; $F7B4
  inc z:$C5                    ; $F7B6
  lda z:$C5                    ; $F7B8
  cmp #$7F                     ; $F7BA
  bcc Loc_F7FA                 ; $F7BC
  ldx z:$B7                    ; $F7BE
  sta $05E0,x                  ; $F7C0
  inx                          ; $F7C3
  jsr Sub_F821                 ; $F7C4
  beq Loc_F7FA                 ; $F7C7
Loc_F7C9:
  lda z:$C6                    ; $F7C9
  bne Loc_F7E7                 ; $F7CB
  ldx z:$B7                    ; $F7CD
  lda z:$C5                    ; $F7CF
  sta $05E0,x                  ; $F7D1
  inx                          ; $F7D4
  stx z:$B7                    ; $F7D5
  lda z:$C7                    ; $F7D7
  cmp #$11                     ; $F7D9
  bcs Loc_F809                 ; $F7DB
  lda z:$C7                    ; $F7DD
  sta $05E0,x                  ; $F7DF
  jsr Sub_F826                 ; $F7E2
  beq Loc_F7EC                 ; $F7E5
Loc_F7E7:
  ldx z:$B7                    ; $F7E7
  jsr Sub_F821                 ; $F7E9
Loc_F7EC:
  lda z:$C7                    ; $F7EC
  sta z:$C6                    ; $F7EE
  cmp #$09                     ; $F7F0
  bne Loc_F7FA                 ; $F7F2
  lda #$02                     ; $F7F4
  sta z:$BF                    ; $F7F6
  sta z:$49                    ; $F7F8
Loc_F7FA:
  lda z:$B7                    ; $F7FA
  cmp #$ED                     ; $F7FC
  bcc Loc_F808                 ; $F7FE
  lda z:$C1                    ; $F800
  bne Loc_F808                 ; $F802
  lda #$01                     ; $F804
  sta z:$C1                    ; $F806
Loc_F808:
  rts                          ; $F808
Loc_F809:
  and #$0F                     ; $F809
  tax                          ; $F80B
  dex                          ; $F80C
  jsr Sub_F839                 ; $F80D
  ldy #$00                     ; $F810
Loc_F812:
  ldx z:$B7                    ; $F812
  lda ($07),y                  ; $F814
  beq Loc_F7EC                 ; $F816
  sta $05E0,x                  ; $F818
  inx                          ; $F81B
  stx z:$B7                    ; $F81C
  iny                          ; $F81E
  bne Loc_F812                 ; $F81F
Sub_F821:
  lda #$40                     ; $F821
  sta $05E0,x                  ; $F823
Sub_F826:
  inx                          ; $F826
  stx z:$B7                    ; $F827
  lda #$00                     ; $F829
  sta z:$C5                    ; $F82B
  rts                          ; $F82D
Sub_F82E:
  lda Data_F063,x              ; $F82E
  sta z:$05                    ; $F831
  lda Data_F087,x              ; $F833
  sta z:$06                    ; $F836
  rts                          ; $F838
Sub_F839:
  lda Data_F4F5,x              ; $F839
  sta z:$07                    ; $F83C
  lda Data_F4FA,x              ; $F83E
  sta z:$08                    ; $F841
  rts                          ; $F843
Sub_F844:
  lda #$C0                     ; $F844
  sta JOYPAD2                  ; $F846
  jsr Sub_F8D4                 ; $F849
  jsr Sub_FA74                 ; $F84C
  jsr Sub_FC3D                 ; $F84F
  jsr Sub_FC8D                 ; $F852
  lda #$00                     ; $F855
  sta z:$FF                    ; $F857
  sta z:$FE                    ; $F859
  sta z:$FD                    ; $F85B
  sta z:$FB                    ; $F85D
  lda $07FF                    ; $F85F
  beq Loc_F86A                 ; $F862
  sta APU_DMC_RAW              ; $F864
  dec $07FF                    ; $F867
Loc_F86A:
  rts                          ; $F86A
Sub_F86B:
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
  jmp Sub_F86B                 ; $F899
Loc_F89C:
  sty z:$F0                    ; $F89C
  lda #$10                     ; $F89E
  sta z:$F5                    ; $F8A0
  ldx #$85                     ; $F8A2
  ldy #$85                     ; $F8A4
  lda #$30                     ; $F8A6
  jsr Sub_F86B                 ; $F8A8
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
Sub_F8D4:
  ldy z:$F4                    ; $F8D4
  bne Loc_F90D                 ; $F8D6
  ldy z:$FF                    ; $F8D8
  lda z:$F0                    ; $F8DA
  lsr z:$FF                    ; $F8DC
  bcs Loc_F88D                 ; $F8DE
  lsr a                        ; $F8E0
  bcs Loc_F93A                 ; $F8E1
  lsr z:$FF                    ; $F8E3
  bcs Loc_F89C                 ; $F8E5
  lsr a                        ; $F8E7
  bcs Loc_F8AB                 ; $F8E8
  lsr a                        ; $F8EA
  bcs Loc_F8B9                 ; $F8EB
  lsr z:$FF                    ; $F8ED
  bcs Loc_F8AE                 ; $F8EF
  lsr z:$FF                    ; $F8F1
  bcs Loc_F90E                 ; $F8F3
  lsr a                        ; $F8F5
  bcs Loc_F921                 ; $F8F6
  lsr z:$FF                    ; $F8F8
  bcs Loc_F948                 ; $F8FA
  lsr a                        ; $F8FC
  bcs Loc_F95B                 ; $F8FD
  lsr z:$FF                    ; $F8FF
  bcs Loc_F96D                 ; $F901
  lsr a                        ; $F903
  bcs Loc_F975                 ; $F904
  lsr z:$FF                    ; $F906
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
  jsr Sub_F86B                 ; $F918
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
  jsr Sub_F86B                 ; $F952
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
  jsr Sub_F86B                 ; $F987
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
Sub_FA74:
  ldy z:$FE                    ; $FA74
  bne Loc_FA4F                 ; $FA76
  ldy z:$F1                    ; $FA78
  bne Loc_FA55                 ; $FA7A
  lda z:$FC                    ; $FA7C
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
  ldx z:$FC                    ; $FAE7
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
Sub_FC3D:
  ldy z:$FD                    ; $FC3D
  lda z:$F2                    ; $FC3F
  lsr z:$FD                    ; $FC41
  bcs Loc_FBFF                 ; $FC43
  lsr a                        ; $FC45
  bcs Loc_FC06                 ; $FC46
  lsr z:$FD                    ; $FC48
  bcs Loc_FC1F                 ; $FC4A
  lsr a                        ; $FC4C
  bcs Loc_FC2E                 ; $FC4D
  lsr a                        ; $FC4F
  bcs Loc_FC63                 ; $FC50
  lsr z:$FD                    ; $FC52
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
Sub_FC8D:
  lda z:$FB                    ; $FC8D
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
