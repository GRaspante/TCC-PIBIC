/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xaxidma.h"
#include "xparameters.h"
#include "xil_printf.h"
#include "xil_cache.h"
#include "xil_io.h"
/*#include "conv4_file.h"*/
#include "sample_file.h"
#include "xscugic.h"
#include "xil_exception.h"
#include <stdlib.h>
#include <math.h>

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

float out_data[conv4_input_length] = {0};
XAxiDma_Config *DMA_config;
XAxiDma	DMA;


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
				for(int k=0; k<thirdFilterLength; k++)
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

static int DMA_setup(XAxiDma_Config *DMA_config, XAxiDma *DMA){
	int status;
	float in_data[conv4_input_length];
	int j = 0;
	int k = 0;

for(int l = 0; l < 32; l++){
	for (int i = 0; i < 30; i++){
		in_data[j] = thirdConvOutput[l][i];
		j++;
	}
}
	DMA_config = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);

	status = XAxiDma_CfgInitialize(DMA, DMA_config);
	if(status != XST_SUCCESS){
		print("Inicializacao DMA falhou.\n");
		return -1;
	}
	//print("Inicializacao DMA.\n");

	XAxiDma_IntrDisable(DMA, XAXIDMA_IRQ_ALL_MASK,	XAXIDMA_DEVICE_TO_DMA);
	xil_printf("sem intr do DMA\r\n");
	XAxiDma_IntrDisable(DMA, XAXIDMA_IRQ_ALL_MASK,	XAXIDMA_DMA_TO_DEVICE);

	if(XAxiDma_HasSg(DMA)){
		xil_printf("DMA no modo SG \r\n");
		return XST_FAILURE;
	}
	//xil_printf("DMA no modo simples \r\n");

	Xil_DCacheFlushRange((u32)in_data, 960*sizeof(float)); /*Libera os arquivos de cache*/
	Xil_DCacheInvalidateRange((u32)out_data, 960*sizeof(float));

	status = XAxiDma_SimpleTransfer(DMA, (u32)out_data, 960*sizeof(float), XAXIDMA_DEVICE_TO_DMA);
	if(status != XST_SUCCESS){
			print("Transferencia da conv4 falhou.\n");
			return -1;
		}
	status = XAxiDma_SimpleTransfer(DMA, (u32)in_data, 960*sizeof(float), XAXIDMA_DMA_TO_DEVICE);
	if(status != XST_SUCCESS){
			print("Transferencia para conv4 falhou.\n");
			return -1;
		}
	while(XAxiDma_Busy(DMA, XAXIDMA_DMA_TO_DEVICE) || XAxiDma_Busy(DMA, XAXIDMA_DEVICE_TO_DMA));

	print("Transferencia conv4 finalizada.\n");

	for(int l = 0; l < 32; l++){
		for (int i = 0; i < 30; i++){
			fourthConvOutput[l][i] = out_data[k];
			k++;
		}
	}

	return XST_SUCCESS;
}

/*void conv4()
{
//	FILE *fptr;
//	fptr = fopen("fourthConv_out.txt","w");
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
				for(int k=0; k<fourthFilterLength; k++)
				{
					fourthConvOutput[l][i] += (thirdConvOutput[j][i+k]*fourthConvFilter[l][j][k]);
				}
				// printf("%d\t", secondLayerOutput[j][i]);
			}
			fourthConvOutput[l][i] += fourthConvBias[l];
			fourthConvOutput[l][i] = RELU(fourthConvOutput[l][i]);
			//fprintf(fptr,"%f, ",fourthConvOutput[l][i]);
			// printf("%f\t", fourthConvOutput[l][i]);
		}
		// printf("\n");
	}
	// printf("\n");
//fclose(fptr);
}*/


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

int main()
{
	u32 status;

	adjust_input(sample);

	conv1();

	maxpooling();

	adjustSecondConvInput(maxpoolingOutput);

	conv2();

	adjustThirdConvInput(secondConvOutput);

	conv3();

	// Not necessary to adjust the sample, for the filterLenght in the fourth conv layer is 1

	//void conv4();
	status = DMA_setup(DMA_config, &DMA);
	if(status != XST_SUCCESS){
		print("Setup DMA falhou.\n");
		return -1;
	}
//	print("Setup DMA....\n");

	flatten();

	fully1();

	fully2();

	outputLayer();

    return 0;
}


