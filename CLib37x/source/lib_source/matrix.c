#include "matrix.h"

Matrix44 *AllocMatrix44() {
	//Allocate memory for a Matrix44.
	return AllocMem(sizeof(Matrix44), MEMF_ANY|MEMF_CLEAR);
}

VOID FreeMatrix44( register __a0 Matrix44 *matrix) {
	//Return a Matrix44's memory to the allocation pool.
	FreeMem(matrix, sizeof(Matrix44));
}

VOID __saveds ASM InitMatrix44( register __a0 Matrix44 *matrix) {
	//Initialize a matrix to a null matrix.
	matrix->data[0][0] = 0.0f;
	matrix->data[0][1] = 0.0f;
	matrix->data[0][2] = 0.0f;
	matrix->data[0][3] = 0.0f;
	
	matrix->data[1][0] = 0.0f;
	matrix->data[1][1] = 0.0f;
	matrix->data[1][2] = 0.0f;
	matrix->data[1][3] = 0.0f;
	
	matrix->data[2][0] = 0.0f;
	matrix->data[2][1] = 0.0f;
	matrix->data[2][2] = 0.0f;
	matrix->data[2][3] = 0.0f;
	
	matrix->data[3][0] = 0.0f;
	matrix->data[3][1] = 0.0f;
	matrix->data[3][2] = 0.0f;
	matrix->data[3][3] = 0.0f;
}

VOID __saveds ASM AddMatrix44( register __a0 Matrix44 *left, register __a1 Matrix44 *right, register __a2 Matrix44 *destination ) {
	//Add two matrices together. For flexibility, the result will be stored in destination (which can point to either or neither matrix).
	UBYTE row, col;
	
	for(row = 0; row < 4; row++) 
	{
		for(col = 0; col < 4; col++)
		{
			destination->data[row][col] = left->data[row][col] + right->data[row][col];
		}
	}
	
}

VOID __saveds ASM SubMatrix44( register __a0 Matrix44 *left, register __a1 Matrix44 *right, register __a2 Matrix44 *destination ) {
	//Subtract two matrices. For flexibility, the result will be stored in destination (which can point to either or neither matrix).
	UBYTE row, col;
	
	for(row = 0; row < 4; row++) 
	{
		for(col = 0; col < 4; col++)
		{
			destination->data[row][col] = left->data[row][col] - right->data[row][col];
		}
	}
	
}

VOID __saveds ASM IdentityMatrix44( register __a0 Matrix44 *matrix ) {
	//Set a matrix to the identity matrix.
	
	matrix->data[0][0] = 1;
	matrix->data[0][1] = 0;
	matrix->data[0][2] = 0;
	matrix->data[0][3] = 0;
	
	matrix->data[1][0] = 0;
	matrix->data[1][1] = 1;
	matrix->data[1][2] = 0;
	matrix->data[1][3] = 0;
	
	matrix->data[2][0] = 0;
	matrix->data[2][1] = 0;
	matrix->data[2][2] = 1;
	matrix->data[2][3] = 0;
	
	matrix->data[3][0] = 0;
	matrix->data[3][1] = 0;
	matrix->data[3][2] = 0;
	matrix->data[3][3] = 1;
}
	