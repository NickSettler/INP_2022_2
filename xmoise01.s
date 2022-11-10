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
                ; xmoise01-r2-r16-r15-r23-r0-r4
                ; Raw stalls: 84 -> 83 -> 77 -> 65 -> 56 -> 45 -> 27
main:
                ; Intro
                ; Some code may look strange. For example, computing
                ; in the end of the while loop, or missing computings
                ; in the beginning of the loop. Such instructions location
                ; are made to achieve the best performance and lower CPI.
                ;
                ; Registers:
                ; r0    stores constant 0
                ; r2    stores result of comparing instructions (slt / sltu / slti / sltui).
                ; r4    stores pointer to login string or pointer to it.
                ; r15   stores constant numbers for comparing with login character.
                ;       used to check if character is letter or number.
                ; r16   stores index of current character in login string
                ; r23   stores 'm' and 'o' symbols to add or subtract them from login character
                daddi   r15, r0, cipher
                lbu     r4, 0(r0)   ; read first login character

                sb      r15, params_sys5(r0)
                xor     r15, r15, r15

                ; begin while(*login[r4] < 97)
                start_while:
                slti    r2, r4, 97  ; *login[r4] < 97
                movz    r23, r16, r0
                andi    r15, r16, 0x01
                bnez    r2, end_while
                daddi   r23, r23, 1
                ; begin loop instructions
                    ; begin if(r16 % 2 == 0) symbol_plus(); else symbol_minus();
                    beqz    r15, symbol_plus
                    bnez    r15, symbol_minus
                    b       end_if

                    symbol_plus:
                        ; *login[r4] += 'm';
                        daddi   r4, r4, 13
                        ; if(*login[r4] > 122) *login[r4] -= 26;
                        slti    r2, r4, 122
                        beqz    r2, symbol_minus_26
                        b       end_if
                        symbol_minus_26:
                            daddi     r4, r4, -26
                        b       end_if
                    symbol_minus:
                        ; *login[r4] -= 'o';
                        daddi     r4, r4, -15
                        ; if(*login[r4] < 97) *login[r4] += 26;
                        slti    r2, r4, 97
                        bnez    r2, symbol_plus_26
                        b       end_if
                        symbol_plus_26:
                            daddi     r4, r4, 26
                        b       end_if
                    end_if:
                    sb      r4, cipher(r16)

                    lbu     r4, login(r23)    ; reading next character
                    movz    r16, r23, r0
                    b start_while
                ; end loop instructions
                end_while:

                daddi   r4, r0, cipher
                jal     print_string
                syscall 0   ; halt

print_string:   ; adresa retezce se ocekava v r4
                sw      r4, params_sys5(r0)
                daddi   r14, r0, params_sys5    ; adr pro syscall 5 musi do r14
                syscall 5   ; systemova procedura - vypis retezce na terminal
                jr      r31 ; return - r31 je urcen na return address
