# cudabmm
block matrix multiplication with CUDA

A and B are “float” matrices of size N × N, where N = 2^M. We would like to calculate C = A × B.
Parameter M should be a command line argument to the main() function.
This code works for M = 10 to 13

Rectangular tiles have been employed instead of square ones to give us one more freedom degree 
in calculating output blocks.
