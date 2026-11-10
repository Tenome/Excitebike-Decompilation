; Module tables: $C000-
.segment "PRG"

Data_C000:
  .addr StateTitleMenu, StateMenuChoice5, StateRaceFrame, StateSubStepDispatch, StateRaceEndWait, StateRaceFrame, StateSubStepDispatch, StateRaceEndWait, StateMenuChoice6, StateDesignFrame, StateRaceFrame, StateSubStepDispatch, StateDesignEnd, StateDesignSaveCheck  ; $C000 pointer table
Data_C01C:
  .incbin "prg_bank_0.bin", $001C, $E  ; $C01C
Data_C02A:
  .byte <(Data_C03C), <(Data_C040), <(Data_C046), <(Data_C052), <(Data_C05C), <(Data_C064), <(Data_C070), <(Data_C07A), <(Data_C076)  ; $C02A pointer table (low bytes)
Data_C033:
  .byte >(Data_C03C), >(Data_C040), >(Data_C046), >(Data_C052), >(Data_C05C), >(Data_C064), >(Data_C070), >(Data_C07A), >(Data_C076)  ; $C033 pointer table (high bytes)
Data_C03C:
  .incbin "prg_bank_0.bin", $003C, $4  ; $C03C
Data_C040:
  .incbin "prg_bank_0.bin", $0040, $6  ; $C040
Data_C046:
  .incbin "prg_bank_0.bin", $0046, $C  ; $C046
Data_C052:
  .incbin "prg_bank_0.bin", $0052, $A  ; $C052
Data_C05C:
  .incbin "prg_bank_0.bin", $005C, $8  ; $C05C
Data_C064:
  .incbin "prg_bank_0.bin", $0064, $C  ; $C064
Data_C070:
  .incbin "prg_bank_0.bin", $0070, $6  ; $C070
Data_C076:
  .incbin "prg_bank_0.bin", $0076, $4  ; $C076
Data_C07A:
  .incbin "prg_bank_0.bin", $007A, $6  ; $C07A
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
  .byte <(ResultsStepInit), <(ResultsStepDrawText), <(ResultsStepWait), <(ResultsStepFinish)  ; $C12C pointer table (low bytes)
Data_C130:
  .byte >(ResultsStepInit), >(ResultsStepDrawText), >(ResultsStepWait), >(ResultsStepFinish)  ; $C130 pointer table (high bytes)
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
