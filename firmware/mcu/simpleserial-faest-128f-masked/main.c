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

static uint8_t get_sig(uint8_t* m, uint8_t len) {
    simpleserial_put('o', msg_size, sig);
    return 0;
}

unsigned char sub_words_input[4] = {0};
unsigned char sub_words_mask[4] = {0};
unsigned char s_box_input[4] = {0,0,0,0};
unsigned char s_box_mask[4] = {0,0,0,0};
unsigned char super_s_box[25] = {0};
static uint8_t rnd_s_box(uint8_t* m, uint8_t len) {
    s_box_input[0] = 0;
    while(s_box_input[0] == 0){
        rand_bytes(s_box_input, 1);
    }
    //rand_bytes(s_box_mask, 1);
    //s_box_input[0] = s_box_input[0] ^ s_box_mask[0];

    sub_words_input[0] = 0;
    while(sub_words_input[0] == 0){
        rand_bytes(sub_words_input, 1);
    }
    sub_words_input[1] = 0;
    while(sub_words_input[1] == 0){
        rand_bytes(sub_words_input+1, 1);
    }
    sub_words_input[2] = 0;
    while(sub_words_input[2] == 0){
        rand_bytes(sub_words_input+2, 1);
    }
    sub_words_input[3] = 0;
    while(sub_words_input[3] == 0){
        rand_bytes(sub_words_input+3, 1);
    }
    return 0;
}

static uint8_t set_s_box(uint8_t* m, uint8_t len) {
    s_box_input[0] = 9;
   // rand_bytes(s_box_mask, 1);
    //s_box_input[0] = s_box_input[0] ^ s_box_mask[0];
    
    sub_words_input[0] = 0x01;
    sub_words_input[1] = 0xff;
    sub_words_input[2] = 0xaa;
    sub_words_input[3] = 0xb2;
    return 0;
}
bf8_t compute_sbox(bf8_t in);

uint8_t sign(uint8_t* m, uint8_t len) {

    /* sbox_masked
    trigger_high();
    //compute_sbox_masked(s_box_input, s_box_mask);
    compute_sbox(s_box_input[0]);
    trigger_low();

    // Stack based setup
    bf8_t tmp_share[2][AES_NR];
    for (int i = 0; i < AES_NR; i++) {
        rand_mask(tmp_share[0] + i, 1);
        tmp_share[1][i] = sub_words_input[i] ^ tmp_share[0][i];
    }
    //compute_sbox_masked(s_box_input, s_box_mask);
    rand_mask(s_box_mask, 1);
    trigger_high();
    //sub_words_masked(tmp_share);
    compute_sbox_masked(tmp_share[0], tmp_share[1]);
    trigger_low();
    */




    /* sign with randomness
    */
    size_t sig_size = FAEST_128F_SIGNATURE_SIZE;
    //trigger_high();
    int res = faest_128f_sign(sk, msg, msg_size, sig, &sig_size);
    //trigger_low();
    return res;

    /*
    size_t sig_size = FAEST_128F_SIGNATURE_SIZE;
    uint8_t rho[FAEST_128F_LAMBDA / 8];
    memset(rho, 0, sizeof(rho));
    int res = faest_128f_sign_with_randomness(sk, msg, msg_size, rho, sizeof(rho), sig, &sig_size);
    return res;
    */

    return 0;
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

    simpleserial_addcmd('a', 0, set_s_box);
    simpleserial_addcmd('b', 0, rnd_s_box);
    simpleserial_addcmd('c', 0, get_sig);
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
