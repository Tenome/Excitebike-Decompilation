; Module video_data: $D3D6-
.segment "PRG"

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
  .byte <(RiderState0Racing), <(RiderState1Gate), <(RiderState2MoveToLane), <(RiderState3Wait), <(RiderState4Release), <(RiderState5Finish)  ; $D8FF pointer table (low bytes)
Data_D905:
  .byte >(RiderState0Racing), >(RiderState1Gate), >(RiderState2MoveToLane), >(RiderState3Wait), >(RiderState4Release), >(RiderState5Finish)  ; $D905 pointer table (high bytes)
Data_D90B:
  .incbin "prg_bank_0.bin", $190B, $3  ; $D90B
Data_D90E:
  .incbin "prg_bank_0.bin", $190E, $5  ; $D90E
Data_D913:
  .incbin "prg_bank_0.bin", $1913, $5  ; $D913
