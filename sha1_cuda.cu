#include <stdio.h>
#include <getopt.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>
#include <sys/time.h>

typedef unsigned int uint;
typedef unsigned long long ull;

__device__ uint LR(uint a, int x){
	return a << x | a >> 32-x;
}

__global__ void sha1_kernel(ull* res, ull IDX) {
	ull id = threadIdx.x | (ull)blockIdx.x << 10 | (ull)blockIdx.y << 20 | (ull)IDX << 32, idx = id;
	uint h0, h1, h2, h3, h4;
	h0 = 0x1b0a7bd1; h1 = 0x447cd35b; h2 = 0x521b5a11; h3 = 0x410602b0; h4 = 0x1896a106;

	uint w[16];
	for(int i = 0; i < 8; i++, idx >>= 16){
		w[i] = 0x40404040u | (idx&15) << 24 | (idx>>4&15) << 16 | (idx>>8&15) << 8 | (idx>>12&15);
	}
	w[8] = 0x0a800000;
	for(int i = 9; i < 15; i++) w[i] = 0;
	w[15] = 1800;

	uint a, b, c, d, e, f, k;
	a = h0; b = h1; c = h2; d = h3; e = h4;
	for(int i = 0; i < 16; i++){
		f = (b&c)|(~b&d);
		k = 0x5A827999;
		uint tmp = LR(a, 5) + f + e + k + w[i&15];
		e = d; d = c; c = LR(b, 30); b = a; a = tmp;
	}
	for(int i = 16; i < 20; i++){
		w[i&15] = LR(w[i-3&15]^w[i-8&15]^w[i-14&15]^w[i&15], 1);

		f = (b&c)|(~b&d);
		k = 0x5A827999;

		uint tmp = LR(a, 5) + f + e + k + w[i&15];
		e = d; d = c; c = LR(b, 30); b = a; a = tmp;
	}
	for(int i = 20; i < 40; i++){
		w[i&15] = LR(w[i-3&15]^w[i-8&15]^w[i-14&15]^w[i&15], 1);

		f = (b^c^d);
		k = 0x6ED9EBA1; 

		uint tmp = LR(a, 5) + f + e + k + w[i&15];
		e = d; d = c; c = LR(b, 30); b = a; a = tmp;
	}
	for(int i = 40; i < 60; i++){
		w[i&15] = LR(w[i-3&15]^w[i-8&15]^w[i-14&15]^w[i&15], 1);

		f = (b&c)|(b&d)|(c&d);
		k = 0x8F1BBCDC;

		uint tmp = LR(a, 5) + f + e + k + w[i&15];
		e = d; d = c; c = LR(b, 30); b = a; a = tmp;
	}
	for(int i = 60; i < 80; i++){
		w[i&15] = LR(w[i-3&15]^w[i-8&15]^w[i-14&15]^w[i&15], 1);

		f = b^c^d;
		k = 0xCA62C1D6;

		uint tmp = LR(a, 5) + f + e + k + w[i&15];
		e = d; d = c; c = LR(b, 30); b = a; a = tmp;
	}
	h0 = h0 + a;
	h1 = h1 + b;
	h2 = h2 + c;
	h3 = h3 + d;
	h4 = h4 + e;
	if(h0 == 0 && (h1 >> 16) == 0) *res = id;
}

const int SZ = 4096 * 4096;

ull *res;
ull res_copy;

int main()
{
	dim3 threadsPerBlock(1024, 1);
	dim3 numBlocks(1024, 4096);

	cudaMalloc(&res, sizeof(ull));

	for(int i = 0;; i++){
		printf("IDX : %d\n", i);
		sha1_kernel<<<numBlocks, threadsPerBlock>>>(res, i);

		cudaMemcpy(&res_copy, res, sizeof(ull), cudaMemcpyDeviceToHost);
		if(res_copy == 0) continue;
		for(int i = 0; i < 16; i++){
			printf("%c", 64 | res_copy&15);
			res_copy /= 16;
		}
		break;
	}
}
