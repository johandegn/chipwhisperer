/*
    This file is part of the ChipWhisperer Example Targets
    Copyright (C) 2012-2017 NewAE Technology Inc.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "api.h"
#include "parameters.h"
#include "faest_128f.h"
#include "fields.h"
#include "hal.h"
#include "randomness.h"
#include "simpleserial.h"

unsigned char pk[CRYPTO_PUBLICKEYBYTES] = {0};
unsigned char sk[CRYPTO_SECRETKEYBYTES] = {0};
unsigned char sig[FAEST_128F_SIGNATURE_SIZE] = {0};
#define msg_size 16
unsigned char msg[msg_size] = {0};

static uint8_t get_pk(uint8_t* m, uint8_t inputLen) {
    simpleserial_put('p', CRYPTO_PUBLICKEYBYTES, pk);
    return 0;
}

static uint8_t get_sk(uint8_t* m, uint8_t inputLen) {
    simpleserial_put('k', CRYPTO_SECRETKEYBYTES, sk);
    return 0;
}

static uint8_t set_sk(uint8_t* m, uint8_t inputLen) {
    memcpy(sk, m, inputLen);
    return 0;
}

static uint8_t get_msg(uint8_t* m, uint8_t len) {
    simpleserial_put('m', msg_size, msg);
    return 0;
}

static uint8_t key_gen(uint8_t* m, uint8_t len) {
    int res = faest_128f_keygen(pk, sk);
    return res;
}

static uint8_t msg_gen(uint8_t* m, uint8_t len) {
    rand_bytes(msg, msg_size);
    return 0;
}

uint8_t sign(uint8_t* m, uint8_t len) {
    size_t sig_size = FAEST_128F_SIGNATURE_SIZE;
    int res = faest_128f_sign(sk, msg, msg_size, sig, &sig_size);
    return res;
}

int main(void) {
    platform_init();
    init_uart();
    trigger_setup();

    key_gen(0, 0);
    msg_gen(0, 0);

    simpleserial_init();

    simpleserial_addcmd('p', 0, get_pk);
    simpleserial_addcmd('k', 0, get_sk);
    simpleserial_addcmd('q', 32, set_sk);
    simpleserial_addcmd('m', 0, get_msg);

    simpleserial_addcmd('g', 0, key_gen);
    simpleserial_addcmd('r', 0, msg_gen);
    simpleserial_addcmd('s', 0, sign);

    while (1)
        simpleserial_get();
}
