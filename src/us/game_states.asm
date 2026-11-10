; Module game_states: $C346-
.segment "PRG"

StateTitleMenu:
  lda z:$31                    ; $C346
  bne Loc_C359                 ; $C348
  sta z:TrackIndex             ; $C34A
  sta z:FirstAiRider           ; $C34C
  lda #$0F                     ; $C34E
  sta $03F7                    ; $C350
  lda #$02                     ; $C353
  sta z:GameState              ; $C355
  bne Loc_C389                 ; $C357
Loc_C359:
  lda #$03                     ; $C359
  jsr MenuHandleInput          ; $C35B
  txa                          ; $C35E
  bne Loc_C36A                 ; $C35F
  sta SelectionB               ; $C361
  lda Data_C080,y              ; $C364
  jmp Loc_C3EF                 ; $C367
Loc_C36A:
  ldy z:MenuCursor             ; $C36A
  ldx #$00                     ; $C36C
  stx $03F7                    ; $C36E
  stx z:TrackIndex             ; $C371
  stx z:MenuCursor             ; $C373
  inx                          ; $C375
  stx $03F3                    ; $C376
  stx z:FirstAiRider           ; $C379
  stx $03F0                    ; $C37B
  cpy #$02                     ; $C37E
  bne Loc_C384                 ; $C380
  ldx #$08                     ; $C382
Loc_C384:
  stx z:GameState              ; $C384
  sty SelectionB               ; $C386
Loc_C389:
  jsr Sub_C3B1                 ; $C389
  lda $03F7                    ; $C38C
  eor #$0F                     ; $C38F
  sta APU_SND_CHN              ; $C391
  rts                          ; $C394
StateMenuChoice5:
  lda z:Joy1Trigger            ; $C395
  and #$F3                     ; $C397
  sta z:Joy1Trigger            ; $C399
  and #$03                     ; $C39B
  asl a                        ; $C39D
  asl a                        ; $C39E
  ora z:Joy1Trigger            ; $C39F
  sta z:Joy1Trigger            ; $C3A1
  lda #$05                     ; $C3A3
  jsr MenuHandleInput          ; $C3A5
  txa                          ; $C3A8
  beq Loc_C3B8                 ; $C3A9
  lda z:MenuCursor             ; $C3AB
  sta z:TrackIndex             ; $C3AD
Sub_C3AF:
  inc z:GameState              ; $C3AF
Sub_C3B1:
  lda #$00                     ; $C3B1
  sta z:GameStateActive        ; $C3B3
  sta z:GameSubStep            ; $C3B5
  rts                          ; $C3B7
Loc_C3B8:
  lda Data_C083,y              ; $C3B8
  bne Loc_C411                 ; $C3BB
StateMenuChoice6:
  lda #$06                     ; $C3BD
  jsr MenuHandleInput          ; $C3BF
  txa                          ; $C3C2
  beq Loc_C3EA                 ; $C3C3
  lda z:MenuCursor             ; $C3C5
  cmp #$02                     ; $C3C7
  beq Loc_C3D2                 ; $C3C9
  bcs Loc_C3D5                 ; $C3CB
  sta SelectionB               ; $C3CD
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
  sta z:MenuCursor             ; $C3E0
  beq Sub_C3B1                 ; $C3E2
Loc_C3E4:
  lsr a                        ; $C3E4
  sta z:MenuCursor             ; $C3E5
  jmp ResetGameRam             ; $C3E7
Loc_C3EA:
  ldy z:MenuCursor             ; $C3EA
  lda Data_C08B,y              ; $C3EC
Loc_C3EF:
  sta OamBuffer                ; $C3EF
  rts                          ; $C3F2
  ldx #$04                     ; $C3F3
  stx z:MusicRequest           ; $C3F5
  dex                          ; $C3F7
  stx z:PpuUpdateIndex         ; $C3F8
  ldy #$01                     ; $C3FA
  jsr SetMenuCursorSprite      ; $C3FC
  sta z:MenuCursor             ; $C3FF
  lda #$2D                     ; $C401
  sta z:$34                    ; $C403
  lda #$B0                     ; $C405
  bne Loc_C3EF                 ; $C407
SetMenuCursorSprite:
  lda #$FA                     ; $C409
  sta $0201                    ; $C40B
  lda Data_C088,y              ; $C40E
Loc_C411:
  sta $0203                    ; $C411
  lda #$00                     ; $C414
  sta $0202                    ; $C416
  sta z:ModeFlagB              ; $C419
  rts                          ; $C41B
StateDesignSaveCheck:
  lda #$02                     ; $C41C  [heuristic code]
  ldx z:GameSubStep            ; $C41E
  beq Loc_C450                 ; $C420
  lda z:ResetState             ; $C422
  cmp #$FF                     ; $C424
  bne Loc_C454                 ; $C426
  ldx #$02                     ; $C428
Loc_C42A:
  lda z:$65,x                  ; $C42A
  sta SavedTimes,x             ; $C42C
  lda z:$68,x                  ; $C42F
  sta $05C3,x                  ; $C431
  dex                          ; $C434
  bpl Loc_C42A                 ; $C435
  jsr CopyBackupToDesign       ; $C437
  jmp Loc_C447                 ; $C43A
StateDesignEnd:
  lda z:GameSubStep            ; $C43D
  beq Loc_C44E                 ; $C43F
  lda z:ResetState             ; $C441
  cmp #$FF                     ; $C443
  bne Loc_C454                 ; $C445
Loc_C447:
  lda #$40                     ; $C447
  sta z:MusicRequest           ; $C449
  jmp ResultsStepFinish        ; $C44B
Loc_C44E:
  lda #$01                     ; $C44E
Loc_C450:
  sta z:ResetState             ; $C450
  sta z:GameSubStep            ; $C452
Loc_C454:
  rts                          ; $C454
  ldy #$08                     ; $C455
  lda z:GameState              ; $C457
  cmp #$08                     ; $C459
  bcs Loc_C462                 ; $C45B
  lda z:ModeFlagB              ; $C45D
  beq Loc_C464                 ; $C45F
  dey                          ; $C461
Loc_C462:
  sty z:PpuUpdateIndex         ; $C462
Loc_C464:
  rts                          ; $C464
StateRaceEndWait:
  lda z:$34                    ; $C465  [heuristic code]
  beq Loc_C477                 ; $C467
  lda #$06                     ; $C469
  jsr WriteTimeTextSaved       ; $C46B
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
  jsr LoadSavedTime            ; $C485
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
  sta BestTimes,y              ; $C4A0
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
  jsr LoadBestTime             ; $C4B3
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
  lda LapSpeedScale            ; $C4CC
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
  sta z:PlaceResult            ; $C512
  lda #$18                     ; $C514
  sta z:PpuUpdateIndex         ; $C516
  lda #$01                     ; $C518
  sta z:InputLatch             ; $C51A
  sta z:GameStateActive        ; $C51C
  lsr a                        ; $C51E
  sta z:GameSubStep            ; $C51F
  rts                          ; $C521
LoadBestTime:
  lda z:TrackIndex             ; $C522
  sta z:$02                    ; $C524
  jsr TimeTableIndexForTrack   ; $C526
  tay                          ; $C529
  lda Data_C091,y              ; $C52A
  sta z:$05                    ; $C52D
  lda Data_C092,y              ; $C52F
  sta z:$06                    ; $C532
  lda Data_C093,y              ; $C534
  sta z:$07                    ; $C537
  rts                          ; $C539
LoadSavedTime:
  lda z:TrackIndex             ; $C53A
  sta z:$02                    ; $C53C
LoadSavedTimeForIndex:
  jsr TimeTableIndexForSelection ; $C53E
  lda BestTimes,y              ; $C541
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
  adc z:TrackIndex             ; $C55A
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
  jmp WriteTimeTextSaved       ; $C5A9
  lda #$12                     ; $C5AC  [heuristic code]
  sta z:$34                    ; $C5AE
  ldx #$05                     ; $C5B0
Loc_C5B2:
  lda Data_C13C,x              ; $C5B2
  sta PpuBufferLen,x           ; $C5B5
  dex                          ; $C5B8
  bpl Loc_C5B2                 ; $C5B9
  ldx z:TrackIndex             ; $C5BB
  inx                          ; $C5BD
  stx $0304                    ; $C5BE
  rts                          ; $C5C1
  ldx #$01                     ; $C5C2  [heuristic code]
  stx z:$B7                    ; $C5C4
  jsr CopyTrackDesignToBackup  ; $C5C6
  stx z:$BD                    ; $C5C9
  stx z:$BE                    ; $C5CB
  stx z:$C4                    ; $C5CD
  stx z:RiderTrackPiece        ; $C5CF
  stx z:InputLatch             ; $C5D1
  stx z:$C2                    ; $C5D3
  inx                          ; $C5D5
  stx TrackDesign              ; $C5D6
  lda #$06                     ; $C5D9
  sta z:RiderPitch             ; $C5DB
  lda #$A0                     ; $C5DD
  sta z:RiderScreenY           ; $C5DF
  lda #$10                     ; $C5E1
  sta z:RiderXLo               ; $C5E3
  lda #$04                     ; $C5E5
  sta z:$04                    ; $C5E7
  ldx #$00                     ; $C5E9
  stx z:$0B                    ; $C5EB
  jsr DrawRider                ; $C5ED
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
  sta z:RiderAirborne          ; $C603
  lda #$03                     ; $C605
  sta z:$B3                    ; $C607
  lda #$08                     ; $C609
  sta z:RiderMoveFraction      ; $C60B
  sta z:RiderTrackPos          ; $C60D
  inc z:RiderTrackPos          ; $C60F
  lda #$7A                     ; $C611
  sta z:$B4                    ; $C613
  inc z:GameStateActive        ; $C615
  inc z:RaceActive             ; $C617
  lda #$D0                     ; $C619
  jsr DrawDesignCursorSprite   ; $C61B
  jmp Loc_EC47                 ; $C61E
