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

    sub     sp, #80
    str     r0, [sp, #0]
    str     r0, [sp, #4]
    str     r0, [sp, #8]
    str     r0, [sp, #12]
    str     r0, [sp, #16]
    str     r0, [sp, #20]
    str     r0, [sp, #24]
    str     r0, [sp, #28]
    str     r0, [sp, #32]
    str     r0, [sp, #36]
    str     r0, [sp, #40]
    str     r0, [sp, #44]
    str     r0, [sp, #48]
    str     r0, [sp, #52]
    str     r0, [sp, #56]
    str     r0, [sp, #60]
    str     r0, [sp, #64]
    str     r0, [sp, #68]
    str     r0, [sp, #72]
    str     r0, [sp, #76]
    add     sp, #80

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
sbox_masked_loop:
    mov     r5, #0
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
    lsls    r3, r4, #2
    eor.w   r3, r3, r2, lsl #1
    eors    r3, r7
    eor.w   r3, r3, r8, lsl #3
    eor.w   r3, r3, fp, lsl #4
    eor.w   r3, r3, sl, lsl #5
    eor.w   r3, r3, r9, lsl #6
    eor.w   r3, r3, r0, lsl #7
    strb.w  r3, [r6], #1
    add.w   r3, sp, #10
    cmp     r3, r6
    bne.n   sbox_masked_loop
    ldrb.w  r3, [sp, #9]
    ldr     r1, [sp, #4]
    ldrb.w  r2, [sp, #8]
    strb    r2, [r1, #0]
    eor.w   r3, r3, #99     @ 0x63
    strb    r3, [r1, #1]
    add     sp, #20
    ldmia.w sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
