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

#include "hal.h"
#include <stdint.h>
#include <stdlib.h>

#include "api.h"
#include "faest_128f.h"
#include "simpleserial.h"

unsigned char pk[CRYPTO_PUBLICKEYBYTES] = {0};
unsigned char sk[CRYPTO_SECRETKEYBYTES] = {0};
unsigned char sig[FAEST_128F_SIGNATURE_SIZE] = {0};

static uint8_t get_pk(uint8_t* m, uint8_t inputLen) {
    simpleserial_put('p', CRYPTO_PUBLICKEYBYTES, pk);
    return 0;
}

static uint8_t get_sk(uint8_t* m, uint8_t inputLen) {
    simpleserial_put('o', CRYPTO_SECRETKEYBYTES, sk);
    return 0;
}

static uint8_t key_gen(uint8_t *m, uint8_t len) {
    faest_128f_keygen(pk, sk);
    return 0;
}

static uint8_t sign(uint8_t *m, uint8_t len) {
    const size_t msg_size = 12;
    char msg[12] = {0};
    size_t sig_size;
    int res = faest_128f_sign(sk, msg, msg_size, sig, &sig_size);

    return 0;
}



int main(void) {
    key_gen(0, 0);
    // Kyber
    platform_init();
    init_uart();
    trigger_setup();

    simpleserial_init();

    simpleserial_addcmd('k', 0, key_gen);
    simpleserial_addcmd('p', 0, get_pk);
    simpleserial_addcmd('o', 0, get_sk);
    simpleserial_addcmd('s', 0, sign);
    /*
    //Reserved simpleserial commands: 'v', 'y', 'w'
    simpleserial_addcmd('e', 0, encrypt);
    simpleserial_addcmd('d', 0, decrypt);

    simpleserial_addcmd('r', 0, reset_counter);

    simpleserial_addcmd('c', 0, get_ct);
    simpleserial_addcmd('i', 0, get_plaintext_input);
    simpleserial_addcmd('o', 0, get_plaintext_output);
    */

    while (1)
        simpleserial_get();
}
