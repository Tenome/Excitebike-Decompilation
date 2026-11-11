; Module track_render: $F4FF-
.segment "PRG"

TrackRenderUpdate:
  ldx z:TrackIndex             ; $F4FF
  lda Data_ED3A,x              ; $F501
  sta z:$07                    ; $F504
  lda Data_ED40,x              ; $F506
  sta z:$08                    ; $F509
  lda z:$EB                    ; $F50B
  cmp z:RiderTrackPos          ; $F50D
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
  lda SceneObjectKind          ; $F52B
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
  lda z:ModeFlagB              ; $F547
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
  lda SceneObjectKind          ; $F582
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
  sta PpuBuffer                ; $F5FD
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
  lda z:RiderTrackPos          ; $F625
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
  sta SceneObjectKind          ; $F641
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
  jsr SetTrackRowPointer       ; $F656
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
Sub_F68D:
  lda z:$BE                    ; $F68D  [heuristic code]
  beq Loc_F68C                 ; $F68F
  lda z:$CA                    ; $F691
  bne Loc_F6C7                 ; $F693
  lda z:$C3                    ; $F695
  bne Loc_F6C7                 ; $F697
  ldx z:RiderScriptClock       ; $F699
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
  sta z:RiderY                 ; $F6B6
  iny                          ; $F6B8
  lda ($07),y                  ; $F6B9
  sta z:$CA                    ; $F6BB
  iny                          ; $F6BD
  sty z:$C9                    ; $F6BE
  bne Loc_F6C7                 ; $F6C0
Loc_F6C2:
  sta z:RiderY                 ; $F6C2
  iny                          ; $F6C4
  sty z:$C9                    ; $F6C5
Loc_F6C7:
  ldx z:RiderY                 ; $F6C7
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
  lda z:RiderAirborne          ; $F6E3
  sta PpuBuffer                ; $F6E5
  lda z:$B1                    ; $F6E8
  sta $0302                    ; $F6EA
  lda z:$B2                    ; $F6ED
  sta z:$0F                    ; $F6EF
  jsr Sub_F64E                 ; $F6F1
  lda z:$B2                    ; $F6F4
  jsr IncMod64                 ; $F6F6
  sta z:$B2                    ; $F6F9
DrawTrackColumn:
  inc z:$B1                    ; $F6FB
  lda z:$B1                    ; $F6FD
  cmp #$20                     ; $F6FF
  bne Loc_F70D                 ; $F701
  lda #$00                     ; $F703
  sta z:$B1                    ; $F705
  lda z:RiderAirborne          ; $F707
  eor #$04                     ; $F709
  sta z:RiderAirborne          ; $F70B
Loc_F70D:
  rts                          ; $F70D
Loc_F70E:
  lda z:RiderScriptClock       ; $F70E
  beq Loc_F71E                 ; $F710
  lda #$00                     ; $F712
  sta z:$C3                    ; $F714
  lda z:$CA                    ; $F716
  beq Loc_F739                 ; $F718
  dec z:$CA                    ; $F71A
  bpl Loc_F739                 ; $F71C
Loc_F71E:
  ldy z:$B2                    ; $F71E
  jsr DesignCheckSlotFree      ; $F720
  bne Loc_F731                 ; $F723
  iny                          ; $F725
  cpy #$40                     ; $F726
  bne Loc_F72C                 ; $F728
  ldy #$00                     ; $F72A
Loc_F72C:
  jsr DesignCheckSlotFree      ; $F72C
  beq Loc_F73E                 ; $F72F
Loc_F731:
  lda #$00                     ; $F731
  sta z:RiderY                 ; $F733
  sta z:$C3                    ; $F735
  sta z:RiderScriptClock       ; $F737
Loc_F739:
  lda #$01                     ; $F739
  sta z:$BE                    ; $F73B
  rts                          ; $F73D
Loc_F73E:
  lda #$00                     ; $F73E
  sta z:$C3                    ; $F740
  sta z:$BE                    ; $F742
  sta z:$BD                    ; $F744
  sta z:RiderScriptClock       ; $F746
  lda z:$BA                    ; $F748
  sta z:$B2                    ; $F74A
  lda z:$BB                    ; $F74C
  sta z:RiderAirborne          ; $F74E
  lda z:RiderHeight            ; $F750
  sta z:$B1                    ; $F752
  rts                          ; $F754
Sub_F755:
  lda z:RiderScriptShapeB      ; $F755
  bne Loc_F798                 ; $F757
  lda z:RiderTrackPiece        ; $F759
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
  lda z:RiderScriptPos         ; $F799
  bne Loc_F7AC                 ; $F79B
  lda z:$C7                    ; $F79D
  sta z:$C6                    ; $F79F
  ldx z:$B7                    ; $F7A1
  jsr Sub_F821                 ; $F7A3
  lda #$3D                     ; $F7A6
  sta z:$C5                    ; $F7A8
  inc z:RiderScriptPos         ; $F7AA
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
  sta TrackDesign,x            ; $F7C0
  inx                          ; $F7C3
  jsr Sub_F821                 ; $F7C4
  beq Loc_F7FA                 ; $F7C7
Loc_F7C9:
  lda z:$C6                    ; $F7C9
  bne Loc_F7E7                 ; $F7CB
  ldx z:$B7                    ; $F7CD
  lda z:$C5                    ; $F7CF
  sta TrackDesign,x            ; $F7D1
  inx                          ; $F7D4
  stx z:$B7                    ; $F7D5
  lda z:$C7                    ; $F7D7
  cmp #$11                     ; $F7D9
  bcs Loc_F809                 ; $F7DB
  lda z:$C7                    ; $F7DD
  sta TrackDesign,x            ; $F7DF
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
  sta z:InputLatch             ; $F7F8
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
  sta TrackDesign,x            ; $F818
  inx                          ; $F81B
  stx z:$B7                    ; $F81C
  iny                          ; $F81E
  bne Loc_F812                 ; $F81F
Sub_F821:
  lda #$40                     ; $F821
  sta TrackDesign,x            ; $F823
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
