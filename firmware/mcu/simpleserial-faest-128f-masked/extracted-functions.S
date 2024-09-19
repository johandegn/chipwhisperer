.syntax unified
.thumb

.global clean_call
clean_call:
    push    {r4, r5, r6, r7, r8, r9, r10, lr}
    mov     r0, #0
    mov     r1, #0
    mov     r2, #0
    mov     r3, #0
    mov     r4, #0
    mov     r5, #0
    mov     r6, #0
    mov     r7, #0
    mov     r8, #0
    mov     r9, #0
    mov     r10, #0

    mov     r1, #5000
    mov     r3, sp
clean_call_loop:
    str     r0, [r3, #-4]!
    subs    r1, r1, #1
    bne     clean_call_loop

    mov     r1, #0
    mov     r3, #0

    bl      sign

    mov    r0, #0
    pop    {r4, r5, r6, r7, r8, r9, r10, pc}


.global compute_sbox_masked
compute_sbox_masked:
    push    {r4, r5, lr}
    sub     sp, #8
    mov     r5, #0
    mov     r4, r1
    strh    r5, [sp, #4]
    add     r1, sp, #4
    bl      bf8_inv_masked

    strh    r5, [sp]                // CLEAR
    mov     r3, #0                  // CLEAR
    mov     r0, r5                  // CLEAR
    ldrb    r1, [sp]                // CLEAR

    ldrb    r0, [sp, #4]
    bl      affine_incomplete
    strb    r0, [r4, #0]
    
    strh    r5, [sp]                // CLEAR
    mov     r3, #0                  // CLEAR
    mov     r0, r5                  // CLEAR
    ldrb    r1, [sp]                // CLEAR

    ldrb    r0, [sp, #5]
    bl      affine
    strb    r0, [r4, #1]

    ldrb    r1, [sp]                // CLEAR

    add     sp, #8
    pop     {r4, r5, pc}

.global sub_words_masked
sub_words_masked:
    push    {r4, r5, r6, r7, lr}
    adds    r5, r0, #3
    sub     sp, #12
    subs    r4, r0, #1
    mov     r7, r5
    movs    r6, #0
sub_words_masked_loop:
    strh    r6, [sp, #4]                // CLEAR
    ldrb    r1, [sp, #5]                // CLEAR
    ldrb    r2, [r4, #1]!
    strb    r2, [sp]
    strh    r6, [sp, #5]                // CLEAR
    ldrb    r1, [sp, #4]                // CLEAR
    ldrb    r3, [r5, #1]!
    strb    r3, [sp, #1]
    strh    r6, [sp, #4]                // CLEAR
    ldrb    r1, [sp, #5]                // CLEAR
    mov     r0, sp
    add     r1, sp, #4
    strh    r6, [sp, #4]
    bl      compute_sbox_masked
    mov     r2, r6                      // CLEAR
    mov     r3, r6                      // CLEAR
    strh    r6, [sp]                    // CLEAR
    ldrb    r1, [sp, #1]                // CLEAR
    ldrb    r2, [sp, #4]
    strb    r2, [r4, #0]
    strh    r6, [sp, #1]                // CLEAR
    ldrb    r1, [sp, #0]                // CLEAR
    ldrb    r3, [sp, #5]
    cmp     r4, r7
    strb    r3, [r5, #0]
    strh    r6, [sp]                    // CLEAR
    ldrb    r1, [sp, #1]                // CLEAR
    bne     sub_words_masked_loop
    add     sp, #12
    pop     {r4, r5, r6, r7, pc}


.global sub_bytes_masked
sub_bytes_masked:
    cbnz    r1, sub_bytes_masked_run
    bx      lr
sub_bytes_masked_run:
    stmdb   sp!, {r4, r5, r6, r7, r8, lr}
    movs    r7, #0
    sub     sp, #8
    mov     r8, r1
    adds    r5, r0, #4
    mov     r6, r7
sub_bytes_masked_outer:
    subs    r4, r5, #4
sub_bytes_masked_inner:
    strb    r6, [sp, #4]                // CLEAR
    ldrb    r1, [sp, #5]                // CLEAR
    ldrb    r2, [r4], #1
    strb    r2, [sp]
    strb    r6, [sp, #5]                // CLEAR
    ldrb    r1, [sp, #4]                // CLEAR
    ldrb    r3, [r4, #31]
    strb    r3, [sp, #1]
    strh    r6, [sp, #4]
    ldrb    r1, [sp, #4]                // CLEAR
    add     r1, sp, #4
    mov     r0, sp
    strh    r6, [sp, #4]
    bl      compute_sbox_masked
    mov     r2, r6                      // CLEAR
    mov     r3, r6                      // CLEAR
    strb    r6, [sp]                    // CLEAR
    ldrb    r1, [sp, #1]                // CLEAR
    ldrb    r2, [sp, #4]
    strb    r2, [r4, #-1]
    strb    r6, [sp, #1]                // CLEAR
    ldrb    r1, [sp]                    // CLEAR
    cmp     r4, r5
    ldrb    r3, [sp, #5]
    strb    r3, [r4, #31]
    strb    r6, [sp]                    // CLEAR
    ldrb    r1, [sp, #1]                // CLEAR
    bne.n   sub_bytes_masked_inner
    adds    r7, #1
    cmp     r8, r7
    add.w   r5, r5, #4
    bne.n   sub_bytes_masked_outer
    add     sp, #8
    ldmia.w sp!, {r4, r5, r6, r7, r8, pc}



.global expand_128key_masked
expand_128key_masked:
    stmdb   sp!, {r4, r5, r6, r7, r8, r9, sl, lr}
    sub     sp, #8
    mov     r5, r3
    ldr     r4, [sp, #40]   @ 0x28
    mov     r6, r0
    mov     r7, r2
    movs    r3, #0
    cbz     r2, expand_128key_masked_l1
expand_128key_masked_l2:
    udiv    r2, r3, r5
    mls     ip, r5, r2, r3
    add.w   ip, ip, r2, lsl #3
    ldrb    r2, [r1, #0]
    strb.w  r2, [r6, ip, lsl #2]
    add.w   ip, r6, ip, lsl #2
    ldrb    r2, [r1, #1]
    strb.w  r2, [ip, #1]
    ldrb    r2, [r1, #2]
    strb.w  r2, [ip, #2]
    ldrb    r2, [r1, #3]
    strb.w  r2, [ip, #3]
    ldrb.w  r2, [r1, #32]
    strb.w  r2, [ip, #480]  @ 0x1e0
    ldrb.w  r2, [r1, #33]   @ 0x21
    strb.w  r2, [ip, #481]  @ 0x1e1
    ldrb.w  r2, [r1, #34]   @ 0x22
    strb.w  r2, [ip, #482]  @ 0x1e2
    adds    r3, #1
    ldrb.w  r2, [r1, #35]   @ 0x23
    strb.w  r2, [ip, #483]  @ 0x1e3
    cmp     r7, r3
    add.w   r1, r1, #4
    bne.n   expand_128key_masked_l2
expand_128key_masked_l1:
    mla     r9, r4, r5, r5
    cmp     r7, r9
    bcs.n   expand_128key_masked_l3
    mov     r4, r7
    add.w   r8, r6, #480    @ 0x1e0
    b.n     expand_128key_masked_l4
expand_128key_masked_l5:
    subs    r3, r4, r7
    movs    r1, #0
    udiv    r0, r3, r5
    bfi     r1, r2, #0, #8
    mls     r3, r5, r0, r3
    ldrb.w  r2, [sp, #1]
    ldrb.w  lr, [sp, #3]
    add.w   r3, r3, r0, lsl #3
    ldrb.w  r0, [sp, #2]
    ldr.w   ip, [r6, r3, lsl #2]
    bfi     r1, r2, #8, #8
    bfi     r1, r0, #16, #8
    udiv    r2, r4, r5
    mls     r0, r5, r2, r4
    add.w   r0, r0, r2, lsl #3
    bfi     r1, lr, #24, #8
    eor.w   r1, r1, ip
    str.w   r1, [r6, r0, lsl #2]
    ldr     r2, [sp, #4]
    ldr.w   r3, [r8, r3, lsl #2]
    adds    r4, #1
    eors    r3, r2
    cmp     r4, r9
    str.w   r3, [r8, r0, lsl #2]
    beq.n   expand_128key_masked_l3
expand_128key_masked_l4:
    udiv    sl, r4, r7
    subs    r3, r4, #1
    udiv    r2, r3, r5
    mls     r3, r5, r2, r3
    add.w   r3, r3, r2, lsl #3
    add.w   r2, r6, r3, lsl #2
    ldr.w   r3, [r6, r3, lsl #2]
    str     r3, [sp]
    mov     ip, #7                      // CLEAR
    str     ip, [sp, #4]                // CLEAR
    ldr     ip, [sp, #4]                // CLEAR
    ldr.w   r1, [r2, #480]  @ 0x1e0
    str     r1, [sp, #4]
    mls     r0, r7, sl, r4
    //strd    r3, r1, [sp]
    uxtb    r2, r3
    cmp     r0, #0
    bne.n   expand_128key_masked_l5
    mov     ip, r0
    mov     lr, r0
    ubfx    r0, r3, #8, #8
    bfi     ip, r0, #0, #8
    ubfx    r0, r1, #8, #8
    bfi     lr, r0, #0, #8
    ubfx    r0, r3, #16, #8
    bfi     ip, r0, #8, #8
    lsrs    r3, r3, #24
    bfi     ip, r3, #16, #8
    ubfx    r3, r1, #16, #8
    bfi     lr, r3, #8, #8
    lsrs    r3, r1, #24
    bfi     lr, r3, #16, #8
    bfi     ip, r2, #24, #8
    bfi     lr, r1, #24, #8
    mov     r0, sp
    str     ip, [sp]
    mov     ip, #7                      // CLEAR
    str     ip, [sp, #4]                // CLEAR
    ldr     ip, [sp, #4]                // CLEAR
    str     lr, [sp, #4]
    //strd    ip, lr, [sp]
    bl      sub_words_masked
    add.w   r0, sl, #4294967295     @ 0xffffffff
    uxtb    r0, r0
    bl      round_constants
    ldrb.w  r3, [sp]
    eor.w   r2, r0, r3
    uxtb    r2, r2
    b.n     expand_128key_masked_l5
expand_128key_masked_l3:
    add     sp, #8
    ldmia.w sp!, {r4, r5, r6, r7, r8, r9, sl, pc}


.global aes_encrypt_round_masked
aes_encrypt_round_masked:
    stmdb   sp!, {r3, r4, r5, r6, r7, r8, r9, sl, fp, lr}
    mov     r8, r1
    ldrd    r9, sl, [sp, #40]       @ 0x28
    mov     r5, r0
    mov     r4, r2
    mov     fp, r3
    add.w   r7, r5, #32
    bl      sub_bytes_masked
    mov     r1, r8
    mov     r0, r5
    bl      shift_row
    mov     r1, r8
    mov     r0, r7
    bl      shift_row
    ldr.w   r2, [r9]
    ldr.w   r3, [fp]
    movs.w  r6, r8, lsl #2
    sub.w   r1, r2, sl
    beq.n   aes_encrypt_round_masked_l1
    add     r3, r1
    mov     ip, r3
    adds    r0, r6, r3
aes_encrypt_round_masked_l2:
    sub.w   r2, r3, ip
    bic.w   r1, r2, #3
    add     r1, r5
    and.w   r2, r2, #3
    ldrb    r2, [r1, r2]
    strb.w  r2, [r3], #1
    cmp     r3, r0
    bne.n   aes_encrypt_round_masked_l2
    ldr.w   r3, [r9]
    ldr.w   r2, [fp, #4]
    sub.w   r3, r3, sl
    add     r2, r3
    mov     ip, r2
    adds    r0, r6, r2

    ldr     r3, [sp, #36]   // CLEAR
    mov     r1, #0          // CLEAR
    str     r1, [sp, #36]   // CLEAR
    str     r3,  [sp, #36]   // CLEAR
aes_encrypt_round_masked_l3:
    sub.w   r3, r2, ip
    bic.w   r1, r3, #3
    add     r1, r7
    and.w   r3, r3, #3
    ldrb    r3, [r1, r3]
    strb.w  r3, [r2], #1
    cmp     r2, r0
    bne.n   aes_encrypt_round_masked_l3
    ldr.w   r2, [r9]
    add     r2, r6
aes_encrypt_round_masked_l1:
    mov     r1, r8
    mov     r0, r5
    str.w   r2, [r9]
    bl      mix_column
    mov     r1, r8
    mov     r0, r7
    bl      mix_column
    cmp.w   r8, #0
    beq.n   aes_encrypt_round_masked_l4
    ldr     r3, [sp, #48]   @ 0x30
    mov.w   r8, r3, lsl #5
    add.w   r2, r8, #4294967295     @ 0xffffffff
    adds    r7, r6, #3
    add     r2, r4
    add     r7, r5
    adds    r0, r5, #3
aes_encrypt_round_masked_l6:
    subs    r3, r0, #4
    mov     ip, r2
aes_encrypt_round_masked_l5:
    ldrb.w  r1, [r3, #1]!
    ldrb.w  lr, [ip, #1]!
    cmp     r3, r0
    eor.w   r1, r1, lr
    strb    r1, [r3, #0]
    bne.n   aes_encrypt_round_masked_l5
    adds    r0, r3, #4
    cmp     r0, r7
    add.w   r2, r2, #4
    bne.n   aes_encrypt_round_masked_l6
    addw    r8, r8, #479    @ 0x1df
    adds    r6, #35 @ 0x23
    add.w   lr, r5, #35     @ 0x23
    add     r4, r8
    add     r5, r6

    ldr     r3, [sp, #36]   // CLEAR
    mov     r1, #0          // CLEAR
    str     r1, [sp, #36]   // CLEAR
    str     r3,  [sp, #36]   // CLEAR
aes_encrypt_round_masked_l8:
    sub.w   r3, lr, #4
    mov     r0, r4
aes_encrypt_round_masked_l7:
    ldrb.w  r1, [r3, #1]!
    ldrb.w  ip, [r0, #1]!
    cmp     lr, r3
    eor.w   r1, r1, ip
    strb    r1, [r3, #0]
    bne.n   aes_encrypt_round_masked_l7
    add.w   lr, lr, #4
    cmp     r5, lr
    add.w   r4, r4, #4
    bne.n   aes_encrypt_round_masked_l8
aes_encrypt_round_masked_l4:
    ldmia.w sp!, {r3, r4, r5, r6, r7, r8, r9, sl, fp, pc}


.global aes_extend_witness_masked_output
aes_extend_witness_masked_output:
    adds    r2, #7
    lsrs    r2, r2, #3
    beq.n   aes_extend_witness_masked_output_early_return
    push    {r4, r5, lr}
    adds    r5, r0, r2
    add.w   ip, r0, #4294967295     @ 0xffffffff
    add.w   lr, r0, r2, lsl #1
    mov     r3, r5
aes_extend_witness_masked_output_loop:
    ldr     r4, [r1, #0]
    subs    r2, r3, r5
    ldrb    r4, [r4, r2]
    strb.w  r4, [ip, #1]!
    strb    r1, [r3]
    ldr     r4, [r1, #4]
    ldrb    r4, [r4, r2]
    strb.w  r4, [r3], #1
    cmp     r3, lr
    bne.n   aes_extend_witness_masked_output_loop
    mov     r4, #7
    pop     {r4, r5, pc}
aes_extend_witness_masked_output_early_return:
    bx      lr
