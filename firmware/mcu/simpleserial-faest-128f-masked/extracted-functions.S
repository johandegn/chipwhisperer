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
    stmdb   sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
    sub     sp, #20
    mov     r7, r1
    add     r1, sp, #8
    str     r7, [sp, #4]
    bl      bf8_inv_masked
    add     r6, sp, #8
    // first iteration
    ldrb    r5, [sp, #4]            // CLEAR
    ldrb    r5, [r6, #0]
    and.w   r0, r5, #241    @ 0xf1
    bl      __paritysi2
    mov     r7, r0
    and.w   r0, r5, #227    @ 0xe3
    bl      __paritysi2
    str     r0, [sp, #0]
    and.w   r0, r5, #199    @ 0xc7
    bl      __paritysi2
    mov     r4, r0
    and.w   r0, r5, #143    @ 0x8f
    bl      __paritysi2
    mov     r8, r0
    and.w   r0, r5, #31
    bl      __paritysi2
    mov     fp, r0
    and.w   r0, r5, #62     @ 0x3e
    bl      __paritysi2
    mov     sl, r0
    and.w   r0, r5, #124    @ 0x7c
    bl      __paritysi2
    mov     r9, r0
    and.w   r0, r5, #248    @ 0xf8
    bl      __paritysi2
    ldr     r2, [sp, #0]
    mov     r3, #0          // str-str CLEAR
    strb    r3, [r6]        //
    lsls    r3, r4, #2
    eor.w   r3, r3, r2, lsl #1
    eors    r3, r7
    eor.w   r3, r3, r8, lsl #3
    eor.w   r3, r3, fp, lsl #4
    eor.w   r3, r3, sl, lsl #5
    eor.w   r3, r3, r9, lsl #6
    eor.w   r3, r3, r0, lsl #7
    strb.w  r3, [r6], #1
    // second iteration
    ldrb    r5, [sp, #4]            // CLEAR
    ldrb    r5, [r6, #0]
    and.w   r0, r5, #241    @ 0xf1
    bl      __paritysi2
    mov     r7, #0                  // CLEAR
    mov     r7, r0
    and.w   r0, r5, #227    @ 0xe3
    bl      __paritysi2
    str     r0, [sp, #0]
    and.w   r0, r5, #199    @ 0xc7
    bl      __paritysi2
    mov     r4, #0                  // CLEAR
    mov     r4, r0
    and.w   r0, r5, #143    @ 0x8f
    bl      __paritysi2
    mov     r8, #0                  // CLEAR
    mov     r8, r0
    and.w   r0, r5, #31
    bl      __paritysi2
    mov     fp, #0                  // CLEAR
    mov     fp, r0
    and.w   r0, r5, #62     @ 0x3e
    bl      __paritysi2
    mov     sl, #0                  // CLEAR
    mov     sl, r0
    and.w   r0, r5, #124    @ 0x7c
    bl      __paritysi2
    mov     r9, #0                  // CLEAR
    mov     r9, r0
    and.w   r0, r5, #248    @ 0xf8
    bl      __paritysi2
    ldr     r2, [sp, #0]
    mov     r3, #0          // str-str CLEAR
    strb    r3, [r6]        //
    lsls    r3, r4, #2
    eor.w   r3, r3, r2, lsl #1
    eors    r3, r7
    eor.w   r3, r3, r8, lsl #3
    eor.w   r3, r3, fp, lsl #4
    eor.w   r3, r3, sl, lsl #5
    eor.w   r3, r3, r9, lsl #6
    eor.w   r3, r3, r0, lsl #7
    strb.w  r3, [r6], #1
    // manual loop unrolling
    ldrb.w  r3, [sp, #9]
    ldr     r1, [sp, #4]
    ldrb.w  r2, [sp, #8]
    strb    r1, [sp, #4]            // CLEAR
    strb    r2, [r1, #0]
    strb    r1, [sp, #4]            // CLEAR
    eor.w   r3, r3, #99     @ 0x63
    strb    r3, [r1, #1]
    add     sp, #20
    ldmia.w sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}

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
    ldrb.w  r2, [r4, #1]!
    strb.w  r2, [sp]
    strh.w  r6, [sp, #4]
    ldrh    r6, [sp, #4]            // CLEAR
    ldrb.w  r3, [r5, #1]!
    strb.w  r3, [sp, #1]
    add     r1, sp, #4
    mov     r0, sp
    bl      compute_sbox_masked
    ldrb.w  r2, [lr, #0]            // CLEAR
    ldrb.w  r2, [sp, #4]
    strb    r2, [r4, #0]
    ldrb.w  r2, [lr, #0]            // CLEAR
    cmp     r4, r7
    strb    r4, [r5, #0]            // CLEAR
    ldrb.w  r3, [sp, #5]
    strb    r3, [r5, #0]
    bne.n   sub_words_masked_loop
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
    ldrb.w  r2, [r4], #1
    ldr     r1, [lr]                    // CLEAR
    strb.w  r2, [sp]
    strh    r6, [sp, #4]                // CLEAR
    ldrb    r3, [r4, #31]
    strb.w  r3, [sp, #1]
    add     r1, sp, #4
    mov     r0, sp
    strh.w  r6, [sp, #4]
    ldr     r2, [lr]                    // CLEAR
    bl      compute_sbox_masked
    ldr     r0, [lr, #4]                // CLEAR
    strh    r6, [sp, #4]                // CLEAR
    ldrb.w  r2, [sp, #4]
    ldr     r1, [lr]                    // CLEAR
    strb.w  r2, [r4, #-1]
    strh    r6, [sp, #4]                // CLEAR
    cmp     r4, r5
    ldrb.w  r3, [sp, #5]
    strb    r3, [r4, #31]
    bne.n   sub_bytes_masked_inner
    adds    r7, #1
    cmp     r8, r7
    add.w   r5, r5, #4
    bne.n   sub_bytes_masked_outer
    add     sp, #8
    ldmia.w sp!, {r4, r5, r6, r7, r8, pc}
