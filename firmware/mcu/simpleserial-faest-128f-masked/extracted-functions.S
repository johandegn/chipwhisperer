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
    // Reordering to fix ldr-str leak
    ldrb    r2, [r4, #1]!
    strb    r2, [sp]
    strh    r6, [sp, #4]
    ldrh    r6, [sp, #4]            // CLEAR
    ldrb    r3, [r5, #1]!
    strb    r3, [sp, #1]
    add     r1, sp, #4
    mov     r0, sp
    bl      compute_sbox_masked
    mov     r2, r6
    mov     r3, r6
    strb    r4, [r4, #0]            // CLEAR
    ldrb    r2, [sp, #4]
    strb    r2, [r4, #0]
    cmp     r4, r7
    strb    r4, [r5, #0]            // CLEAR
    ldrb    r3, [sp, #5]
    strb    r3, [r5, #0]
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
