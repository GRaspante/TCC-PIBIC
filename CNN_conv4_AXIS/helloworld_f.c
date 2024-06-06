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
#include "conv4_file.h"

int main()
{
	XAxiDma_Config *DMA_config;
	XAxiDma	DMA;
	u32 status;
	float in_data[conv4_input_length];
	float out_data[conv4_input_length];

	for (int i = 0; i < conv4_input_length; i++){
		in_data[i] = conv4_input[i];
	}

	DMA_config = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);
	status = XAxiDma_CfgInitialize(&DMA, DMA_config);

	if(status != XST_SUCCESS){
		print("Inicializacao DMA falhou.\n");
		return -1;
	}
	print("Inicializacao DMA.\n");


	XAxiDma_IntrDisable(&DMA, XAXIDMA_IRQ_ALL_MASK,	XAXIDMA_DEVICE_TO_DMA);
	xil_printf("sem intr \r\n");
	XAxiDma_IntrDisable(&DMA, XAXIDMA_IRQ_ALL_MASK,	XAXIDMA_DMA_TO_DEVICE);

	if(XAxiDma_HasSg(&DMA)){
		xil_printf("DMA no modo SG \r\n");
		return XST_FAILURE;
	}
	xil_printf("DMA no modo simples \r\n");



	Xil_DCacheFlushRange((u32)in_data, 960*sizeof(float)); /*Libera os arquivos de cache*/
	Xil_DCacheFlushRange((u32)out_data, 960*sizeof(float));

	status = XAxiDma_SimpleTransfer(&DMA, (u32)in_data, 960*sizeof(float), XAXIDMA_DMA_TO_DEVICE);
	if(status != XST_SUCCESS){
			print("Transferencia para conv4 falhou.\n");
			return -1;
		}

	while(XAxiDma_Busy(&DMA, XAXIDMA_DMA_TO_DEVICE)){

	}
	print("Transferencia para conv4 finalizada.\n");

	status = XAxiDma_SimpleTransfer(&DMA, (u32)out_data, 960*sizeof(float), XAXIDMA_DEVICE_TO_DMA);
		if(status != XST_SUCCESS){
				print("Transferencia da conv4 falhou.\n");
				return -1;
			}

		while(XAxiDma_Busy(&DMA, XAXIDMA_DEVICE_TO_DMA)){

		}
		print("Transferencia da conv4 finalizada.\n");


    return 0;
}
