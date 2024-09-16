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
    push    {r4, lr}
    sub     sp, #8
    mov     r4, r1
    add     r1, sp, #4
    bl      bf8_inv_masked

    ldrb    r0, [sp]                // CLEAR

    ldrb    r0, [sp, #4]
    bl      affine_incomplete
    strb    r0, [r4, #0]
    
    ldrb    r0, [sp]                // CLEAR

    ldrb    r0, [sp, #5]
    bl      affine
    strb    r0, [r4, #1]

    ldrb    r0, [sp]                // CLEAR

    add     sp, #8
    pop     {r4, pc}


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
    ldrb    r2, [r4, #1]!
    strb    r2, [sp]
    ldrb    r1, [sp, #4]                // CLEAR
    ldrb    r3, [r5, #1]!
    add     r1, sp, #4
    mov     r0, sp
    strb    r3, [sp, #1]
    ldrb    r1, [sp, #5]                // CLEAR
    strh    r6, [sp, #4]
    bl      compute_sbox_masked
    mov     r2, r6                      // CLEAR
    mov     r3, r6                      // CLEAR
    strh    r6, [sp]                    // CLEAR
    ldrb    r2, [sp, #4]
    strb    r2, [r4, #0]
    ldrb    r1, [sp, #1]                // CLEAR
    ldrb    r3, [sp, #5]
    cmp     r4, r7
    strb    r3, [r5, #0]
    ldrb    r1, [sp, #0]                // CLEAR
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
    ldrb    r2, [r4], #1
    strb    r2, [sp]
    ldrb    r1, [sp, #4]                // CLEAR
    ldrb    r3, [r4, #31]
    strb    r3, [sp, #1]
    strh    r6, [sp, #4]
    ldrb    r1, [sp, #5]                // CLEAR
    add     r1, sp, #4
    mov     r0, sp
    strh    r6, [sp, #4]
    bl      compute_sbox_masked
    mov     r2, r6                      // CLEAR
    mov     r3, r6                      // CLEAR
    strb    r6, [sp]                    // CLEAR
    ldrb    r2, [sp, #4]
    strb    r2, [r4, #-1]
    strb    r1, [sp, #1]                // CLEAR
    cmp     r4, r5
    ldrb    r3, [sp, #5]
    strb    r3, [r4, #31]
    bne.n   sub_bytes_masked_inner
    adds    r7, #1
    cmp     r8, r7
    add.w   r5, r5, #4
    bne.n   sub_bytes_masked_outer
    add     sp, #8
    ldmia.w sp!, {r4, r5, r6, r7, r8, pc}


.global expand_128key_masked
expand_128key_masked:
    stmdb   sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
    sub     sp, #12
    mov     r5, r3
    ldr     r4, [sp, #48]   @ 0x30
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
    mla     sl, r4, r5, r5
    cmp     r7, sl
    bcs.n   expand_128key_masked_l3
    ldr.w   r8, =0x080028a0
    mov     r4, r7
    add.w   r9, r6, #480    @ 0x1e0
    b.n     expand_128key_masked_l4
expand_128key_masked_l5:
    subs    r3, r4, r7
    udiv    r1, r3, r5
    mls     r3, r5, r1, r3
    add.w   r3, r3, r1, lsl #3
    ldrb.w  r0, [sp, #1]
    ldrb.w  lr, [sp, #2]
    udiv    ip, r4, r5
    movs    r1, #0
    bfi     r1, r2, #0, #8
    bfi     r1, r0, #8, #8
    bfi     r1, lr, #16, #8
    ldrb.w  lr, [sp, #3]
    ldr.w   r2, [r6, r3, lsl #2]
    mls     r0, r5, ip, r4
    add.w   r0, r0, ip, lsl #3
    bfi     r1, lr, #24, #8
    eors    r1, r2
    str.w   r1, [r6, r0, lsl #2]
    ldr     r2, [sp, #4]
    ldr.w   r3, [r9, r3, lsl #2]
    adds    r4, #1
    eors    r3, r2
    cmp     r4, sl
    str.w   r3, [r9, r0, lsl #2]
    beq.n   expand_128key_masked_l3
expand_128key_masked_l4:
    udiv    fp, r4, r7
    subs    r3, r4, #1
    udiv    r2, r3, r5
    mls     r3, r5, r2, r3
    add.w   r3, r3, r2, lsl #3
    add.w   r2, r6, r3, lsl #2
    ldr.w   r3, [r6, r3, lsl #2]
    str     r3, [sp]
    mov     ip, #7                      // CLEAR
    str     ip, [sp]                    // CLEAR
    ldr     ip, [sp]                    // CLEAR
    ldr.w   r0, [r2, #480]  @ 0x1e0
    str     r0, [sp, #4]
    mls     r1, r7, fp, r4
    //strd    r3, r0, [sp]
    uxtb    r2, r3
    cmp     r1, #0
    bne.n   expand_128key_masked_l5
    ubfx    lr, r3, #8, #8
    mov     ip, r1
    bfi     ip, lr, #0, #8
    ubfx    lr, r0, #8, #8
    bfi     r1, lr, #0, #8
    ubfx    lr, r3, #16, #8
    bfi     ip, lr, #8, #8
    lsrs    r3, r3, #24
    bfi     ip, r3, #16, #8
    ubfx    r3, r0, #16, #8
    bfi     r1, r3, #8, #8
    lsrs    r3, r0, #24
    bfi     r1, r3, #16, #8
    add     fp, r8
    bfi     ip, r2, #24, #8
    bfi     r1, r0, #24, #8
    mov     r0, sp
    str     ip, [sp]
    mov     ip, #7                      // CLEAR
    str     ip, [sp]                    // CLEAR
    ldr     ip, [sp]                    // CLEAR
    str     r1, [sp, #4]
    bl      sub_words_masked
    ldrb.w  r3, [sp]
    ldrb.w  r2, [fp, #511]  @ 0x1ff
    eors    r2, r3
    b.n     expand_128key_masked_l5
expand_128key_masked_l3:
    add     sp, #12
    ldmia.w sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
