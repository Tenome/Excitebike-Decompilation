; Module boot: $C184-
.segment "PRG"


; Power-on/reset: wait two vblanks; clear RAM (only $0000-$04FF when the backup-RAM signature $A5/$5A is present, so saved designs survive);
; then loop reading the next game state request from $48.
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
  lda z:ResetState             ; $C1DB
  bmi Loc_C1D8                 ; $C1DD
  beq Loc_C1D8                 ; $C1DF
  jsr DisableNmi               ; $C1E1
  lda z:ResetState             ; $C1E4
  cmp #$01                     ; $C1E6
  bne Loc_C1F7                 ; $C1E8
  jsr TapeSaveDesigns          ; $C1EA
Loc_C1ED:
  lda #$FF                     ; $C1ED
  sta z:ResetState             ; $C1EF
  jsr WaitVblankEndEnableNmi   ; $C1F1
  jmp Loc_C1D8                 ; $C1F4
Loc_C1F7:
  jsr TapeLoadDesigns          ; $C1F7
  jmp Loc_C1ED                 ; $C1FA
InitBackupRam:
  ldx #$1E                     ; $C1FD
Loc_C1FF:
  lda Data_C091,x              ; $C1FF
  sta BestTimes,x              ; $C202
  sta $05A3,x                  ; $C205
  dex                          ; $C208
  bpl Loc_C1FF                 ; $C209
  ldx #$01                     ; $C20B
  stx TrackDesignWork          ; $C20D
Loc_C210:
  lda #$40                     ; $C210
  sta TrackDesignWork,x        ; $C212
  inx                          ; $C215
  cpx #$CF                     ; $C216
  bcc Loc_C210                 ; $C218
  lda #$09                     ; $C21A
  sta TrackDesignWork,x        ; $C21C
  lda #$A5                     ; $C21F
  sta BackupRamSigA5           ; $C221
  lda #$5A                     ; $C224
  sta BackupRamSig5A           ; $C226
Sub_C229:
  ldx #$00                     ; $C229
  lda #$0A                     ; $C22B
Loc_C22D:
  sta SavedTimes,x             ; $C22D
  sta $05C3,x                  ; $C230
  lda #$00                     ; $C233
  inx                          ; $C235
  cpx #$03                     ; $C236
  bcc Loc_C22D                 ; $C238
  rts                          ; $C23A

; NMI: sprite DMA, PPU buffer flush, split-screen scroll, timers, joypads, sound, then the per-state game logic.
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
  lda z:RaceActive             ; $C258
  beq Loc_C262                 ; $C25A
  jsr ComputeRiderLanes        ; $C25C
  jsr SplitScreenScrollHandler ; $C25F
Loc_C262:
  lda PauseFlag                ; $C262
  ora PauseDebounce            ; $C265
  bne Loc_C26F                 ; $C268
  inc z:FrameCounter           ; $C26A
  jsr TickTimers               ; $C26C
Loc_C26F:
  jsr ReadJoypads              ; $C26F
  jsr SoundUpdate              ; $C272
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
  sta PpuBufferLen             ; $C290
  sta PpuBuffer                ; $C293
  sta z:PpuUpdateIndex         ; $C296
  lda #$3F                     ; $C298
  sta PPU_ADDR                 ; $C29A
  lda #$00                     ; $C29D
  sta PPU_ADDR                 ; $C29F
  sta PPU_ADDR                 ; $C2A2
  sta PPU_ADDR                 ; $C2A5
  rts                          ; $C2A8

; Dispatch to the current game state's handler through the word table at $C000 (when GameStateActive is set),
; otherwise run the state's setup list (tables at $C01C/$C02A/$C033).
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
  sta LapSpeedScale            ; $C2BF
  lsr a                        ; $C2C2
  sta z:PpuUpdateIndex         ; $C2C3
  ldy #$00                     ; $C2C5
  jsr SetMenuCursorSprite      ; $C2C7
  ldx $03F0                    ; $C2CA
  bne Loc_C2D3                 ; $C2CD
  lda #$01                     ; $C2CF
  sta z:MusicRequest           ; $C2D1
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
  jsr DisableRendering         ; $C2ED
  lda z:$30                    ; $C2F0
  bne Loc_C2EC                 ; $C2F2
  ldx z:GameState              ; $C2F4
  lda Data_C01C,x              ; $C2F6
  tax                          ; $C2F9
  lda Data_C02A,x              ; $C2FA
  sta z:$02                    ; $C2FD
  lda Data_C033,x              ; $C2FF
  sta z:$03                    ; $C302
  ldy z:GameSubStep            ; $C304
  inc z:GameSubStep            ; $C306
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
  jsr ClearNametables          ; $C31B
  jsr ResetPpuScroll           ; $C31E
  sta z:ScrollX                ; $C321
  sta z:SplitScrollX           ; $C323
  sta z:ScrollY                ; $C325
  sta z:SplitScrollY           ; $C327
  sta z:EngineSoundRequest     ; $C329
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
