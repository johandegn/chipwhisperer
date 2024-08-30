.syntax unified
.thumb

.global pipeline_test1
pipeline_test1: // LEAK STM32F415
    push    {r4, r5, lr}
    eor     r2, r2, r0
    eor     r3, r3, r1
    pop     {r4, r5, pc}

.global pipeline_test2
pipeline_test2: // LEAK STM32F415
    push    {r4, r5, lr}
    eor     r2, r0, r2
    eor     r3, r1, r3
    pop     {r4, r5, pc}

.global pipeline_test3
pipeline_test3: // LEAK STM32F415
    push    {r4, r5, lr}
    eor     r2, r0, r2
    eor     r3, r3, r1
    pop     {r4, r5, pc}

.global pipeline_test4
pipeline_test4: // NO LEAK STM32F415
    push    {r4, r5, lr}
    eor     r2, r2, r0
    eor     r3, r1, r3
    pop     {r4, r5, pc}

