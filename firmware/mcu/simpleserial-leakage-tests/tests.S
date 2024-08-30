.syntax unified
.thumb

.global pipeline_test1
pipeline_test1: // LEAK STM32F415
    push    {lr}
    eor     r2, r2, r0
    eor     r3, r3, r1
    pop     {pc}

.global pipeline_test2
pipeline_test2: // LEAK STM32F415
    push    {lr}
    eor     r0, r0, r2
    eor     r1, r1, r3
    pop     {pc}

.global pipeline_test3
pipeline_test3: // LEAK STM32F415
    push    {lr}
    eor     r0, r0, r2
    eor     r3, r3, r1
    pop     {pc}

.global pipeline_test4
pipeline_test4: // LEAK STM32F415
    push    {lr}
    eor     r2, r2, r0
    eor     r1, r1, r3
    pop     {pc}

.global store_store_b_test
store_store_b_test: // NO LEAK STM32F415
    push    {lr}
    strb    r0, [r2, #0]
    strb    r1, [r3, #0]
    pop     {pc}

.global load_load_test
load_load_test: // NO LEAK STM32F415
    push    {r5, lr}
    ldr     r0, [r2, #0]
    ldr     r1, [r3, #0]
    pop     {r5, pc}

.global load_load_b_test
load_load_b_test: // NO LEAK STM32F415
    push    {lr}
    ldrb    r0, [r2, #0]
    ldrb    r1, [r3, #0]
    pop     {pc}

.global load_store_b_test
load_store_b_test: // NO LEAK STM32F415
    push    {lr}
    ldrb    r0, [r2, #0]
    strb    r1, [r3, #0]
    pop     {pc}

.global store_load_b_test
store_load_b_test: // LEAK STM32F415
    push    {lr}
    strb    r0, [r2, #0]
    ldrb    r1, [r3, #0]
    pop     {pc}
