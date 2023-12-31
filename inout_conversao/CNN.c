#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "sample_file.h"

#define numberOfFilters 32

#define	sampleLength 60
#define firstFilterLength 7
#define poolLength 2
#define secondFilterLength 5
#define thirdFilterLength 3
#define fourthFilterLength 1
#define flattenLenght numberOfFilters*(sampleLength/poolLength)
#define firstFullyLenght 128
#define secondFullyLenght 64

#define NEW_MAX(x,y) ((x) >= (y)) ? (x) : (y)
#define RELU(x)(x>0?x:0)
#define SIGMOID(x) (1.f / (1 + exp(-x)))


//Global Variables ============
//ALL DEFINED IN THE .H FILE
// float sample[sampleLength] = {0};

// The shape of the filters are the number of data in the last layer times the number of filters times the filter length
// float firstConvFilter[numberOfFilters][firstFilterLength] = {0};
// // float secondConvFilter[32][numberOfFilters][secondFilterLength] = {0};	
// float thirdConvFilter[32][numberOfFilters][thirdFilterLength] = {0};
// float fourthConvFilter[32][numberOfFilters][fourthFilterLength] = {0};
// // The shape of the parameters are the number or neurons in the layer times the size of the last layer
// float firstFullyParameters[firstFullyLenght][flattenLenght] = {0};
// float secondFullyParameters[secondFullyLenght][firstFullyLenght] = {0};
// float outputParameter[secondFullyLenght] = {0};

// // float firstConvBias[numberOfFilters] = {0};
// float secondConvBias[numberOfFilters] = {0};
// float thirdConvBias[numberOfFilters] = {0};
// float fourthConvBias[numberOfFilters] = {0};
// float firstFullyBias[firstFullyLenght] = {0};
// float secondFullyBias[secondFullyLenght] = {0};
// float outputBias = 0;

float firstConvOutput[numberOfFilters][sampleLength] =  {0};
float maxpoolingOutput[numberOfFilters][sampleLength/poolLength] =  {0};
float secondConvOutput[numberOfFilters][sampleLength/poolLength] =  {0};
float thirdConvOutput[numberOfFilters][sampleLength/poolLength] =  {0};
float fourthConvOutput[numberOfFilters][sampleLength/poolLength] =  {0};
float flattenOutput[flattenLenght] =  {0};
float firstFullyOutput[firstFullyLenght] = {0};
float secondFullyOutput[secondFullyLenght] = {0};
float output = 0;

float sampleAdjusted[sampleLength+(firstFilterLength-1)] = {0}; 
float secondConvInput[numberOfFilters][sampleLength/poolLength+(secondFilterLength-1)] = {0}; 
float thirdConvInput[numberOfFilters][sampleLength/poolLength+(thirdFilterLength-1)] = {0}; 


//Functions====================
void adjust_input(float samples[])
{	
	for (int i=0; i<sampleLength; i++)
	{
		sampleAdjusted[i+(firstFilterLength/2)] = samples[i];
		// printf("%.32f, ",sampleAdjusted[i+(firstFilterLength/2)] );
	}
	// printf("\n");
}

// SIPO (7 saidas paralelas)
void conv1()
{
	// j - number 
	for(int j=0; j<numberOfFilters; j++)
	{
		for(int i=0; i<sampleLength; i++)
		{
			for(int k=0; k<firstFilterLength; k++)
			{
				firstConvOutput[j][i] += (sampleAdjusted[i+k]*firstConvFilter[j][k]);
			}	
			firstConvOutput[j][i] += firstConvBias[j];
			firstConvOutput[j][i] = RELU(firstConvOutput[j][i]);
			// printf("%.32f, ", firstConvOutput[j][i]);
		}
		// printf("\n");
	}
	// printf("\n");
	// printf("1conv: %f\n",firstConvOutput[1][21]);
}


void maxpooling()
{
	for(int j=0; j<numberOfFilters; j++)
	{
		for(int i=0; i<sampleLength; i=i+poolLength)
		{
			maxpoolingOutput[j][i/poolLength] = NEW_MAX(firstConvOutput[j][i],firstConvOutput[j][i+1]);
			// printf("%f\t", maxpoolingOutput[j][i/2]);
		}
		// printf("\n");
	}
	// printf("\n");
	// printf("max: %f\n",maxpoolingOutput[1][10]);

}

void adjustSecondConvInput(float samples[numberOfFilters][sampleLength/poolLength])
{
	for(int j=0; j<numberOfFilters; j++)
	{
		for(int i=0; i<sampleLength/poolLength; i++)
		{
			secondConvInput[j][i+(secondFilterLength/2)] = samples[j][i];		    
		}
	}	
}


void conv2()
{
// l - the number of samples
	for(int l=0; l<32; l++)
	{
		//i - size of the samples
		for(int i=0; i<sampleLength/poolLength; i++)
		{
			//j - number of filters
			for(int j=0; j<numberOfFilters; j++)
			{
				//k - size of the filters
				for(int k=0; k<secondFilterLength; k++)
				{
					secondConvOutput[l][i] += (secondConvInput[j][i+k]*secondConvFilter[l][j][k]);
					//printf("%f\t", secondConvOutput[l][i]);
				}	
			}					
			secondConvOutput[l][i] += secondConvBias[l];
			secondConvOutput[l][i] = RELU(secondConvOutput[l][i]);
		
		}
		//printf("\n");
	}
	// printf("\n");
}

void adjustThirdConvInput(float samples[numberOfFilters][sampleLength/poolLength])
{
	for(int j=0; j<numberOfFilters; j++)
	{
		for(int i=0; i<sampleLength/poolLength; i++)
		{
			thirdConvInput[j][i+(thirdFilterLength/2)] = samples[j][i];
	    }
	}

}


void conv3()
{
	
	// l - is the number of samples
	for(int l=0; l<32; l++)
	{
		//i - size of the samples
		for(int i=0; i<sampleLength/poolLength; i++)
		{
			//j - number of filters
			for(int j=0; j<numberOfFilters; j++)
			{
				//k - size of the filters
				for(int k=0; k<secondFilterLength; k++)
				{
					thirdConvOutput[l][i] += (thirdConvInput[j][i+k]*thirdConvFilter[l][j][k]);
				}	
				// printf("%d\t", secondLayerOutput[j][i]);
			}
			thirdConvOutput[l][i] += thirdConvBias[l];
			thirdConvOutput[l][i] = RELU(thirdConvOutput[l][i]);
		
			// printf("%f\t", thirdConvOutput[l][i]);		
		}
		// printf("\n");
	}
	// printf("\n");

}


void conv4()
{
	FILE *fptr;
	fptr = fopen("fourthConv_out.txt","w");
	// l - is the number of samples
	for(int l=0; l<32; l++)
	{
		//i - size of the samples
		for(int i=0; i<sampleLength/poolLength; i++)
		{
			//j - number of filters
			for(int j=0; j<numberOfFilters; j++)
			{
				//k - size of the filters
				for(int k=0; k<secondFilterLength; k++)
				{
					fourthConvOutput[l][i] += (thirdConvOutput[j][i+k]*fourthConvFilter[l][j][k]);
				}	
				// printf("%d\t", secondLayerOutput[j][i]);
			}
			fourthConvOutput[l][i] += fourthConvBias[l];
			fourthConvOutput[l][i] = RELU(fourthConvOutput[l][i]);
			fprintf(fptr,"%f, ",fourthConvOutput[l][i]);
			// printf("%f\t", fourthConvOutput[l][i]);		
		}
		// printf("\n");
	}
	// printf("\n");
fclose(fptr);
}


void flatten()
{
	int count = 0;
	for(int j=0; j<numberOfFilters; j++)
	{
		for(int i=0; i<sampleLength/poolLength; i++)
		{
			flattenOutput[count] = fourthConvOutput[j][i];
			// printf("%d\n", flattenOutput[count]);
			count++;
		}	
	}
	// printf("flatten: %f\n",flattenOutput[1]);

}

void fully1()
{
	int offset = 0;
	// j - number of neurons in this layer
	for(int j=0; j<firstFullyLenght; j++)
	{
		// i - number of neurons in the last layer
		for (int i=0; i<flattenLenght; ++i)
		{
			offset = j * firstFullyLenght + i;
			firstFullyOutput[j] += (flattenOutput[i]*a[offset]);
		}
		firstFullyOutput[j] += firstFullyBias[j];
		firstFullyOutput[j] = RELU(firstFullyOutput[j]);
		// printf("%d\n", fully1Output[j]);
	}
	// printf("\n");
}

void fully2()
{
	int offset = 0;
	// j - number of neurons in this layer
	for(int j=0; j<secondFullyLenght; j++)
	{
		// i - number of neurons in the last layer
		for (int i=0; i<firstFullyLenght; ++i)
		{
			offset = j * firstFullyLenght + i;
			secondFullyOutput[j] += (firstFullyOutput[i]*secondFullyParameters[offset]);
		}
		secondFullyOutput[j] += secondFullyBias[j];
		secondFullyOutput[j] = RELU(secondFullyOutput[j]);
		// printf("%f\t", secondFullyOutput[j]);
	}
	// printf("\n");
}

void outputLayer()
{
	// i - numbert of neurons in the last layer
	for (int i=0; i<secondFullyLenght; ++i)
	{
		output += (secondFullyOutput[i]*outputParameter[i]);
	}
	
	output += outputBias;
	output = SIGMOID(output);
	printf("output: %f\n", output);
}


//Main ========================
int main()
{
	for (int i=0; i<1000; ++i)
	{
		
		adjust_input(sample);
	
	conv1();

	maxpooling();

		adjustSecondConvInput(maxpoolingOutput);
	
	conv2();
	
		adjustThirdConvInput(secondConvOutput);
	
	conv3();
	
		// Not necessary to adjust the sample, for the filterLenght in the fourth conv layer is 1

	conv4();
return 0;
	flatten();

	fully1();

	fully2();

	outputLayer();
	
	}

	return 0;

}


// ponteiro = fopen ("/Users/HumbertoJunior/Desktop/TCC2_CNN/CNN_AECG/dadosCNN_C.txt", "w");
	// Para escrever voc� ir� utilizar o "w", para ler "r", para alterar "a"


