#include <xil_printf.h>
#include "xtime_l.h"
#include "Flexfft.h"
#include "W_coef.h"
#include "DataIn.h"
#include "DataOut_OK.h"

#define SAMPLES 512

int main()
{
	XTime Start;
	XTime_GetTime(&Start);

	sampleOutX_t outputData[FFT_LENGTH];
	FlexFFT(DataIn, outputData);

	XTime End;
	XTime_GetTime(&End);
    printf("El tiempo de procesamiento es: %.6f",  1.0 * (End - Start) / (COUNTS_PER_SECOND/1000000));

	//medir el error de la aproximación
    int i = 0;
    float error = 0;
    float errorRate = 0;
    float realFlexFft = 0;
    float realReference = 0;
    float imagFlexFft = 0;
    float imagReference = 0;

    for(i=0; i<SAMPLES; i++)
    {
    	realFlexFft = real(outputData[i]);
    	imagFlexFft = imag(outputData[i]);

    	realReference = real(DataOut_OK[i]);
    	imagReference= imag(DataOut_OK[i]);

    	if((realFlexFft - realReference)> 0.1||(imagFlexFft - imagReference)> 0.1 )
    		{
    			error = 1;
    		}
    }
    errorRate = error*100/SAMPLES;

	return 0;
}
