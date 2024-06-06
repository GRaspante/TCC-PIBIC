#include <stdio.h>
#include <string.h>
#include <inttypes.h>
#include <stdlib.h>
#include "fourthConv_file.h"

int main(){
float f = 0;
uint32_t fbits[conv4_input_length];
uint32_t *fpointer;
int INDEX;

FILE *fptr;
fptr = fopen("teste_out.txt","w");

for (INDEX = 0; INDEX < conv4_input_length; INDEX++){
	f = conv4_input[INDEX];
	memcpy(&fbits[INDEX], &f, sizeof(uint32_t));
}
fpointer = fbits;

for (INDEX = 0; INDEX < conv4_input_length; INDEX++){
	fprintf(fptr, "0x%08x\t %f\n", fpointer[INDEX], conv4_input[INDEX]);
}

fclose(fptr);

return 0;
}
