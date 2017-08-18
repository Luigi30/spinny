#pragma once

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/resident.h>
#include <exec/initializers.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <intuition/intuition.h>

#include "compiler.h"

typedef struct matrix44_t {
	FLOAT data[4][4];
} Matrix44;

extern Matrix44 __saveds ASM *AllocMatrix44();
extern VOID __saveds ASM InitMatrix44( register __a0 Matrix44 *matrix);
extern VOID __saveds ASM AddMatrix44( register __a0 Matrix44 *left, register __a1 Matrix44 *right, register __a2 Matrix44 *destination );
extern VOID __saveds ASM SubMatrix44( register __a0 Matrix44 *left, register __a1 Matrix44 *right, register __a2 Matrix44 *destination );
extern VOID __saveds ASM IdentityMatrix44( register __a0 Matrix44 *matrix );
