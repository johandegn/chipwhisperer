.syntax unified
.thumb

.global bf8_square_masked
bf8_square_masked:
    push    {r3, r4, r5, r6, r7, lr}    // Save registers
    eors    r2, lr, lr
    eors    r3, lr, lr
    eors    r4, lr, lr
    eors    r5, lr, lr
    eors    r6, lr, lr
    eors    r7, lr, lr
    eors    r8, lr, lr

    ldrb    r7, [r0, #0]                // Load in_share[0] into r7
    mov     r4, r0                      // r4 = in_share_ptr
    mov     r6, r1                      // r6 = out_share_ptr
    mov     r0, r7                      // r0 = in_share[0]
    mov     r1, r7                      // r1 = in_share[0]
    bl      bf8_mul                     // r0 = in_share[0] * in_share[0]
    eors    r1, lr, lr                  // Clear r1
    eors    r0, lr, lr                  // Clear r0
    ldrb    r1, [r4, #1]                // Load in_share[1] into r1
    mov     r5, r0                      // r5 = in_share[0] * in_share[0]
    mov     r0, r7                      // r0 = in_share[0]
    bl      bf8_mul                     // r0 = in_share[0] * in_share[1]
    eors    r5, r0                      // Add prev two results
    strb    r5, [r6, #0]                // Store result in out_share[0]
    ldrb    r5, [r4, #1]                // Load in_share[1] into r5
    eors    r1, lr, lr                  // Clear r1
    eors    r0, lr, lr                  // Clear r0
    ldrb    r1, [r4, #0]                // Load in_share[0] into r1
    mov     r0, r5                      // r0 = in_share[1]
    bl      bf8_mul                     // r0 = in_share[1] * in_share[0]
    eors    r1, lr, lr                  // Clear r1
    eors    r0, lr, lr                  // Clear r0
    mov     r1, r5                      // r1 = in_share[1]
    mov     r4, r0                      // r4 = in_share[1] * in_share[0]
    mov     r0, r5                      // r0 = in_share[1]
    bl      bf8_mul                     // r0 = in_share[1] * in_share[1]
    eors    r4, r0                      // Add prev two results
    strb    r4, [r6, #1]                // Store result in out_share[1]

    eors    r0, lr, lr
    eors    r1, lr, lr
    eors    r2, lr, lr
    eors    r3, lr, lr
    eors    r4, lr, lr
    eors    r5, lr, lr
    eors    r6, lr, lr
    eors    r7, lr, lr
    eors    r8, lr, lr
    pop     {r3, r4, r5, r6, r7, pc}    // Return


.global bf8_mul_masked
bf8_mul_masked:
    stmdb   sp!, {r4, r5, r6, r7, r8, lr}
    eors    r3, lr, lr
    eors    r4, lr, lr
    eors    r5, lr, lr
    eors    r6, lr, lr
    eors    r7, lr, lr
    eors    r8, lr, lr

    ldrb.w  r8, [r0]                    // Load A[0] into r8
    mov     r4, r1                      // r4 = B_ptr
    mov     r7, r0                      // r7 = A_ptr
    ldrb    r1, [r1, #0]                // Load B[0] into r1
    mov     r0, r8                      // r0 = A[0]
    mov     r6, r2                      // r6 = out_ptr
    bl      bf8_mul                     // r0 = A[0] * B[0]
    eors    r1, lr, lr                  // Clear r1
    eors    r0, lr, lr                  // Clear r0
    ldrb    r1, [r4, #1]                // Load B[1] into r1
    mov     r5, r0                      // r5 = A[0] * B[0]
    mov     r0, r8                      // r0 = A[0]
    bl      bf8_mul                     // r0 = A[0] * B[1]
    eors    r5, r0                      // Add prev two results
    strb    r5, [r6, #0]                // Store result in out[0]
    ldrb    r7, [r7, #1]                // Load A[1] into r7
    eors    r1, lr, lr                  // Clear r1
    eors    r0, lr, lr                  // Clear r0
    ldrb    r1, [r4, #0]                // Load B[0] into r1
    mov     r0, r7                      // r0 = A[1]
    bl      bf8_mul                     // r0 = A[1] * B[0]
    eors    r1, lr, lr                  // Clear r1
    eors    r0, lr, lr                  // Clear r0
    ldrb    r1, [r4, #1]                // Load B[1] into r1
    mov     r5, r0                      // r5 = A[1] * B[0]
    mov     r0, r7                      // r0 = A[1]
    bl      bf8_mul                     // r0 = A[1] * B[1]
    eors    r5, r0                      // Add prev two results
    strb    r5, [r6, #1]                // Store result in out[1]
    
    eors    r0, lr, lr
    eors    r1, lr, lr
    eors    r2, lr, lr
    eors    r3, lr, lr
    eors    r4, lr, lr
    eors    r5, lr, lr
    eors    r6, lr, lr
    eors    r7, lr, lr
    eors    r8, lr, lr
    ldmia.w sp!, {r4, r5, r6, r7, r8, pc}

.global bf8_inv_masked
bf8_inv_masked:
    push {r4, r5, lr}
    eors    r2, lr, lr
    eors    r3, lr, lr
    eors    r4, lr, lr
    eors    r5, lr, lr

    sub     sp, #44 @ 0x2c
    movs    r3, #0
    mov     r5, r0
    mov     r4, r1
    mov     r1, sp
    str     r3, [sp]
    str     r3, [sp, #4]
    str     r3, [sp, #8]
    str     r3, [sp, #12]
    str     r3, [sp, #16]
    str     r3, [sp, #20]
    str     r3, [sp, #24]
    str     r3, [sp, #28]
    str     r3, [sp, #32]
    str     r3, [sp, #36]   @ 0x24
    bl      bf8_square_masked
    add     r2, sp, #4
    mov     r0, r5
    mov     r1, sp
    bl      bf8_mul_masked
    add     r2, sp, #8
    add     r0, sp, #4
    mov     r1, sp
    bl      bf8_mul_masked
    add     r2, sp, #12
    add     r0, sp, #8
    mov     r1, sp
    bl      bf8_mul_masked
    add     r1, sp, #16
    add     r0, sp, #12
    bl      bf8_square_masked
    add     r0, sp, #16
    add     r1, sp, #20
    bl      bf8_square_masked
    add     r0, sp, #20
    add     r1, sp, #24
    bl      bf8_square_masked
    add     r2, sp, #28
    add     r1, sp, #12
    add     r0, sp, #24
    bl      bf8_mul_masked
    add     r1, sp, #32
    add     r0, sp, #28
    bl      bf8_square_masked
    add     r1, sp, #36     @ 0x24
    add     r0, sp, #32
    bl      bf8_square_masked
    mov     r2, r4
    mov     r1, sp
    add     r0, sp, #36     @ 0x24
    bl      bf8_mul_masked
    add     sp, #44 @ 0x2c

    eors    r0, lr, lr
    eors    r1, lr, lr
    eors    r2, lr, lr
    eors    r3, lr, lr
    eors    r4, lr, lr
    eors    r5, lr, lr
    pop {r4, r5, pc}
    nop

.global compute_sbox_masked
compute_sbox_masked:
    stmdb   sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
    eors    r2, lr, lr
    eors    r3, lr, lr
    eors    r4, lr, lr
    eors    r5, lr, lr
    eors    r6, lr, lr
    eors    r7, lr, lr
    eors    r8, lr, lr
    eors    r9, lr, lr
    eors    sl, lr, lr
    eors    fp, lr, lr

    sub     sp, #20
    mov     r7, r1
    movs    r3, #0
    add     r1, sp, #12
    str     r7, [sp, #4]
    strh.w  r3, [sp, #12]
    bl      bf8_inv_masked
    add     r6, sp, #12
label_1:
    eors    r5, lr, lr                  // Clear
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
    add.w   r3, sp, #14
    cmp     r3, r6
    bne.n   label_1
    ldrb.w  r3, [sp, #13]
    ldr     r1, [sp, #4]
    ldrb.w  r2, [sp, #12]
    strb    r2, [r1, #0]
    eor.w   r3, r3, #99     @ 0x63
    strb    r3, [r1, #1]
    add     sp, #20

    eors    r0, lr, lr
    eors    r1, lr, lr
    eors    r2, lr, lr
    eors    r3, lr, lr
    eors    r4, lr, lr
    eors    r5, lr, lr
    eors    r6, lr, lr
    eors    r7, lr, lr
    eors    r8, lr, lr
    eors    r9, lr, lr
    eors    sl, lr, lr
    eors    fp, lr, lr
    ldmia.w sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
    nop

.global sub_bytes_masked
sub_bytes_masked:
    stmdb   sp!, {r4, r5, r6, r7, r8, lr}
    eors    r2, lr, lr
    eors    r3, lr, lr
    eors    r4, lr, lr
    eors    r5, lr, lr
    eors    r6, lr, lr
    eors    r7, lr, lr
    eors    r8, lr, lr

    movs    r7, #0
    sub     sp, #8
    mov     r8, r1
    adds    r5, r0, #4
    mov     r6, r7
loop_2:
    subs    r4, r5, #4
loop_1:
    eors    r2, lr, lr                  // Clear
    strb.w  r2, [sp]
    eors    r3, lr, lr                  // Clear
    strb.w  r3, [sp, #1]
    
    ldrb.w  r2, [r4], #1
    strb.w  r2, [sp]
    ldrb    r3, [r4, #31]
    strb.w  r3, [sp, #1]
    add     r1, sp, #4
    mov     r0, sp
    strh.w  r6, [sp, #4]
    eors    r2, lr, lr                  // Clear
    eors    r3, lr, lr                  // Clear
    bl      compute_sbox_masked
    eors    r2, lr, lr                  // Clear
    eors    r3, lr, lr                  // Clear
    ldrb.w  r2, [sp, #4]
    ldrb.w  r3, [sp, #5]
    strb.w  r2, [r4, #-1]
    cmp     r4, r5
    strb    r3, [r4, #31]
    bne.n   loop_1
    adds    r7, #1
    cmp     r8, r7
    add.w   r5, r5, #4
    bne.n   loop_2
    add     sp, #8

    eors    r0, lr, lr
    eors    r1, lr, lr
    eors    r2, lr, lr
    eors    r3, lr, lr
    eors    r4, lr, lr
    eors    r5, lr, lr
    eors    r6, lr, lr
    eors    r7, lr, lr
    eors    r8, lr, lr
    ldmia.w sp!, {r4, r5, r6, r7, r8, pc}
