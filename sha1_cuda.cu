#include<bits/stdc++.h>

using namespace std;

typedef unsigned int uint;
typedef unsigned long long ull;

const int PADDING = 16;

__device__ uint LR_dev(uint a, int x){
	return a << x | a >> 32-x;
}

__global__ void sha1_kernel(ull* res, ull IDX, uint h0, uint h1, uint h2, uint h3, uint h4) {
	ull id = threadIdx.x | (ull)blockIdx.x << 10 | (ull)blockIdx.y << 20 | (ull)IDX << 32, idx = id;

	uint w[16];
	for(int i = 0; i < PADDING/4; i++, idx >>= 16){
		w[i] = 0x40404040u | (idx&15) << 24 | (idx>>4&15) << 16 | (idx>>8&15) << 8 | (idx>>12&15);
	}
	w[PADDING/4] = 0x0a800000;
	for(int i = PADDING/4; i < 15; i++) w[i] = 0;
	w[15] = 1800;

	uint a, b, c, d, e, f, k;
	a = h0; b = h1; c = h2; d = h3; e = h4;
	for(int i = 0; i < 16; i++){
		f = (b&c)|(~b&d);
		k = 0x5A827999;
		uint tmp = LR_dev(a, 5) + f + e + k + w[i&15];
		e = d; d = c; c = LR_dev(b, 30); b = a; a = tmp;
	}
	for(int i = 16; i < 20; i++){
		w[i&15] = LR_dev(w[i-3&15]^w[i-8&15]^w[i-14&15]^w[i&15], 1);

		f = (b&c)|(~b&d);
		k = 0x5A827999;

		uint tmp = LR_dev(a, 5) + f + e + k + w[i&15];
		e = d; d = c; c = LR_dev(b, 30); b = a; a = tmp;
	}
	for(int i = 20; i < 40; i++){
		w[i&15] = LR_dev(w[i-3&15]^w[i-8&15]^w[i-14&15]^w[i&15], 1);

		f = (b^c^d);
		k = 0x6ED9EBA1; 

		uint tmp = LR_dev(a, 5) + f + e + k + w[i&15];
		e = d; d = c; c = LR_dev(b, 30); b = a; a = tmp;
	}
	for(int i = 40; i < 60; i++){
		w[i&15] = LR_dev(w[i-3&15]^w[i-8&15]^w[i-14&15]^w[i&15], 1);

		f = (b&c)|(b&d)|(c&d);
		k = 0x8F1BBCDC;

		uint tmp = LR_dev(a, 5) + f + e + k + w[i&15];
		e = d; d = c; c = LR_dev(b, 30); b = a; a = tmp;
	}
	for(int i = 60; i < 80; i++){
		w[i&15] = LR_dev(w[i-3&15]^w[i-8&15]^w[i-14&15]^w[i&15], 1);

		f = b^c^d;
		k = 0xCA62C1D6;

		uint tmp = LR_dev(a, 5) + f + e + k + w[i&15];
		e = d; d = c; c = LR_dev(b, 30); b = a; a = tmp;
	}
	h0 = h0 + a;
	h1 = h1 + b;
	h2 = h2 + c;
	h3 = h3 + d;
	h4 = h4 + e;
	if(h0 == 0 && (h1 >> 31) == 0) *res = id;
}

struct sha1{
	sha1(uint h0, uint h1, uint h2, uint h3, uint h4){}
	uint h0, h1, h2, h3, h4;
};

string modify_message()
{
	string log = "";
	char c;
	while(scanf("%c", &c) != EOF) log += c;
	while(log.size() % 64 == 0) log += " ";
	for(int t = 0; t < PADDING; t++) log += "@";
	log += '\0';

	int m = 1, l = log.size(), p;
	while(log.size() >= m*10) m *= 10;
	for(p = 7; m; p++, m /= 10) log[p] = l/m + '0', l %= m;
	cout << log << std::endl;

	if(log[p] != '\0'){
		printf("message length's digit is changed while modifying\n");
		printf("Please add or remove +- 50? letters \n");
		exit(-1);
	}
	cout << log << "\n";
	return log;
}

union block{
	uint v[16];
	char s[64];
};

uint h0, h1, h2, h3, h4;

uint LR(uint a, int x){
	return a << x | a >> 32-x;
}

sha1 get_hash(string log){
	block buf[10000] = {};
	h0 = 0x67452301;
	h1 = 0xEFCDAB89;
	h2 = 0x98BADCFE;
	h3 = 0x10325476;
	h4 = 0xC3D2E1F0;

	memcpy(buf, log.c_str(), log.size()*8);
	int len = log.size(), nbits = len * 8;
	buf[0].s[len++] = 0x80;

	uint nblock = (len+7)/64 + 1;
	buf[nblock-1].v[14] = 0;
	buf[nblock-1].v[15] = nbits;

	for(int t = 0; t+1 < nblock; t++){
		block cur = buf[t];
		for(int i = 0; i < 16; i++){
			if(t == nblock-1 && i == 15) continue;
			swap(cur.s[i*4+0], cur.s[i*4+3]);
			swap(cur.s[i*4+1], cur.s[i*4+2]);
		}
		uint w[16];
		for(int i = 0; i < 16; i++) w[i] = cur.v[i];

		uint a, b, c, d, e, f, k;
		a = h0; b = h1; c = h2; d = h3; e = h4;
		for(int i = 0; i < 80; i++){
			if(i >= 16) w[i%16] = LR(w[(i-3+16)%16]^w[(i-8+16)%16]^w[(i-14+16)%16]^w[(i-16+16)%16], 1);
			if(i <= 19){
				f = (b&c)|(~b&d);
				k = 0x5A827999;
			}
			else if(i <= 39){
				f = (b^c^d);
				k = 0x6ED9EBA1; 
			}
			else if(i <= 59){
				f = (b&c)|(b&d)|(c&d);
				k = 0x8F1BBCDC;
			}
			else if(i <= 79){
				f = b^c^d;
				k = 0xCA62C1D6;
			}
			uint tmp = LR(a, 5) + f + e + k + w[i%16];
			e = d; d = c; c = LR(b, 30); b = a; a = tmp;
		}
		h0 = h0 + a;
		h1 = h1 + b;
		h2 = h2 + c;
		h3 = h3 + d;
		h4 = h4 + e;
	}
	return sha1(h0, h1, h2, h3, h4);
}

void run_on_gpu(string log, sha1 hash){
	ull *res;
	ull res_copy;
	dim3 threadsPerBlock(256, 1);
	dim3 numBlocks(4096, 4096);

	cudaMalloc(&res, sizeof(ull));

	for(int i = 0;; i++){
		sha1_kernel<<<numBlocks, threadsPerBlock>>>(res, i, hash.h0, hash.h1, hash.h2, hash.h3, hash.h4);

		cudaMemcpy(&res_copy, res, sizeof(ull), cudaMemcpyDeviceToHost);
		if(res_copy) break;
	}
	cout << log.substr(0, (int)log.size() - PADDING);
	for(int i = 0; i < PADDING; i++){
		printf("%c", 64 | res_copy&15);
		res_copy /= 16;
	}
}

int main()
{
	string log = modify_message();
	sha1 hash = get_hash(log);
	run_on_gpu(log, hash);
}
