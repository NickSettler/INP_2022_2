; Autor reseni: Nikita Moiseev xmoise01

; Projekt 2 - INP 2022
; Vernamova sifra na architekture MIPS64

; DATA SEGMENT
                .data
login:          .asciiz "xmoise01"
cipher:         .space  17  ; misto pro zapis sifrovaneho loginu

params_sys5:    .space  8   ; misto pro ulozeni adresy pocatku
                            ; retezce pro vypis pomoci syscall 5
                            ; (viz nize "funkce" print_string)

; CODE SEGMENT
                .text

                ; ZDE NAHRADTE KOD VASIM RESENIM
                ; xmoise01-r2-r16-r15-r23-r0-r4
main:
                ; r0    stores constant 0
                ; r2    stores result of comparing instructions (slt / sltu / slti / sltui).
                ; r4    stores pointer to login string or pointer to it.
                ; r15   stores constant numbers for comparing with login character.
                ;       used to check if character is letter or number.
                ; r16   stores index of current character in login string
                ; r23   stores 'm' and 'o' symbols to add or substract them from login character
                daddi   r16, r16, 0
                lbu     r4, 0(r16)   ; read first login character

                daddi   r15, r0, 0x0D
                sb      r15, 16(r0)  ; save character 'm' to memory
                daddi   r15, r0, 0x0F
                sb      r15, 17(r0)  ; save character 'o' to memory

                xor     r15, r15, r15

                ; begin while(*login[r4] < 97)
                start_while:
                daddi   r15, r0, 0x61
                sltu    r2, r4, r15  ; *login[r4] < 97
                bnez    r2, end_while
                ; begin loop instructions
                    ; begin if(r16 % 2 == 0) symbol_plus(); else symbol_minus();
                    daddi   r23, r0, 0x02
                    div     r16, r23
                    mfhi    r15
                    beqz    r15, symbol_plus
                    bnez    r15, symbol_minus
                    b       end_if

                    symbol_plus:
                        xor     r15, r15, r15
                        ; *login[r4] += 'm';
                        lb      r23, 16(r0)
                        add     r4, r4, r23
                        ; if(*login[r4] > 122) *login[r4] -= 26;
                        daddi   r15, r0, 0x7A
                        sltu    r2, r15, r4
                        bnez    r2, symbol_minus_26
                        b       end_if
                        symbol_minus_26:
                            daddi   r15, r0, 0x1A
                            sub     r4, r4, r15
                        b       end_if
                    symbol_minus:
                        xor     r15, r15, r15
                        ; *login[r4] -= 'o';
                        lb      r23, 17(r0)
                        sub     r4, r4, r23
                        ; if(*login[r4] < 97) *login[r4] += 26;
                        daddi   r15, r0, 0x61
                        sltu    r2, r4, r15
                        bnez    r2, symbol_plus_26
                        b       end_if
                        symbol_plus_26:
                            daddi   r15, r0, 0x1A
                            add     r4, r4, r15
                        b       end_if
                    end_if:

                    sb      r4, 0(r16)
                    daddi   r16, r16, 1   ; login[r4] = login[r4] + 8

                    lbu     r4, 0(r16)    ; reading next character
                    b start_while
                ; end loop instructions
                end_while:

                daddi   r4, r0, login
                jal     print_string
                syscall 0   ; halt

print_string:   ; adresa retezce se ocekava v r4
                sw      r4, params_sys5(r0)
                daddi   r14, r0, params_sys5    ; adr pro syscall 5 musi do r14
                syscall 5   ; systemova procedura - vypis retezce na terminal
                jr      r31 ; return - r31 je urcen na return address
