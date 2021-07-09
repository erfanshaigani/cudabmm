//ONLY MODIFY THIS FILE!
//YOU CAN MODIFY EVERYTHING IN THIS FILE!

#include "bmm.h"
#include <stdlib.h>
#include <stdio.h>

#define tx threadIdx.x
#define ty threadIdx.y
#define tz threadIdx.z

#define bx blockIdx.x
#define by blockIdx.y
#define bz blockIdx.z

// TILEX and TILEY are used to set the number of threads in a CUDA block 
#define TILEX 32
#define TILEY 16

// you may define other parameters here!
// you may define other macros here!
#define a 4
#if TILEX >= TILEY
	#define K TILEX / TILEY
	#define D (a * TILEX)
	#define BSLoop (a * K)
	#define ASLoop (a)
#else
	#define K TILEY / TILEX	
	#define D (a * TILEY)
	#define BSLoop (a)
	#define ASLoop (a * K)
#endif	
// you may define other functions here!

dim3 getDimGrid(const int m, const int n) {
	dim3 dimGrid(n/TILEX,n/TILEY);
	return dimGrid;
}
dim3 getDimBlock(const int m, const int n) {
	dim3 dimBlock(TILEX,TILEY);
	return dimBlock;
}
__global__ void kernelFunc(float* ad, float* bd, float* cd, const int m, const int n) {
	// write your GPU kernel function here
	__shared__ float as[TILEY][D];
	__shared__ float bs[D][TILEX];

	int i = TILEY * by + ty;
	int j = TILEX * bx + tx;
	//printf("%d",D);
	int s = 0;
	for(int p = 0; p < n / D; p++)
	{
		//as[ty][tx] = ad[i][p * TILEX + tx];
		//as[ty][tx] = ad[i * n + p * TILEX + tx];

		for(int q = 0; q < ASLoop; q++)
		{
			//as[ty][q * TILEX + tx] = ad[i][p * D + q * TILEX + tx];
			as[ty][q * TILEX + tx] = ad[i * n + p * D + q * TILEX + tx];
		}	

		for(int q = 0; q < BSLoop; q++)
		{
			//bs[q * TILEY + ty][tx] = bd[p * D + q * TILEY + ty][j];
			bs[q * TILEY + ty][tx] = bd[(p * D + q * TILEY + ty) * n + j];
		}
		__syncthreads();
		for (int k = 0; k < D; k++)
		{
			s += as[ty][k] * bs[k][tx];
		}
		__syncthreads();
	}
	//cd[i][j] = s;
	cd[i * n + j] = s;
}
