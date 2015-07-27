// XMOS DSP Library - Adaptive Filtering Function Test Program
// Uses Q24 format

// Include files
#include <stdio.h>
#include <xs1.h>
#include <xmos_dsp_elements.h>

// Define constants

#define Q_M               8
#define Q_N               24

#define FIR_FILTER_LENGTH     128
#define SAMPLE_LENGTH         50
#define ECHO_PATH_LENGTH      128

// Declare global variables and arrays
int  Src[] = { Q24(.11), Q24(.12), Q24(.13), Q24(.14), Q24(.15), Q24(.16), Q24(.17), Q24(.18), Q24(.19), Q24(.20),
               Q24(.21), Q24(.22), Q24(.23), Q24(.24), Q24(.25), Q24(.26), Q24(.27), Q24(.28), Q24(.29), Q24(.30),
               Q24(.31), Q24(.32), Q24(.33), Q24(.34), Q24(.35), Q24(.36), Q24(.37), Q24(.38), Q24(.39), Q24(.40),
               Q24(.41), Q24(.42), Q24(.43), Q24(.44), Q24(.45), Q24(.46), Q24(.47), Q24(.48), Q24(.49), Q24(.50),
               Q24(.51), Q24(.52), Q24(.53), Q24(.54), Q24(.55), Q24(.56), Q24(.57), Q24(.58), Q24(.59), Q24(.60)};
int           Dst[SAMPLE_LENGTH];

int firCoeffs[FIR_FILTER_LENGTH];

const SLData_t  echoPathTaps[ECHO_PATH_LENGTH] = {
  Q24(-5.34E-4), Q24( 1.24E-3), Q24( 8.73E-4), Q24( 4.37E-4), Q24( 1.57E-3), Q24(-1.38E-3),
  Q24( 1.90E-4), Q24(-1.85E-3), Q24(-2.00E-3), Q24( 2.40E-4), Q24(-2.04E-3), Q24( 2.71E-3),
  Q24( 8.82E-4), Q24( 2.06E-3), Q24( 3.46E-3), Q24(-1.75E-3), Q24( 1.86E-3), Q24(-4.19E-3),
  Q24(-2.84E-3), Q24(-1.38E-3), Q24(-4.84E-3), Q24( 4.15E-3), Q24(-5.59E-4), Q24( 5.33E-3),
  Q24( 5.64E-3), Q24(-6.64E-4), Q24( 5.54E-3), Q24(-7.26E-3), Q24(-2.32E-3), Q24(-5.38E-3),
  Q24(-8.92E-3), Q24( 4.46E-3), Q24(-4.72E-3), Q24( 1.05E-2), Q24( 7.10E-3), Q24( 3.43E-3),
  Q24( 1.19E-2), Q24(-1.02E-2), Q24( 1.37E-3), Q24(-1.31E-2), Q24(-1.39E-2), Q24( 1.64E-3),
  Q24(-1.37E-2), Q24( 1.81E-2), Q24( 5.87E-3), Q24( 1.37E-2), Q24( 2.30E-2), Q24(-1.17E-2),
  Q24( 1.26E-2), Q24(-2.87E-2), Q24(-1.98E-2), Q24(-9.90E-3), Q24(-3.58E-2), Q24( 3.19E-2),
  Q24(-4.50E-3), Q24( 4.55E-2), Q24( 5.19E-2), Q24(-6.69E-3), Q24( 6.26E-2), Q24(-9.50E-2),
  Q24(-3.71E-2), Q24(-1.13E-1), Q24(-2.98E-1), Q24( 4.24E-1), Q24( 4.24E-1), Q24(-2.98E-1),
  Q24(-1.13E-1), Q24(-3.71E-2), Q24(-9.50E-2), Q24( 6.26E-2), Q24(-6.69E-3), Q24( 5.19E-2),
  Q24( 4.55E-2), Q24(-4.50E-3), Q24( 3.19E-2), Q24(-3.58E-2), Q24(-9.90E-3), Q24(-1.98E-2),
  Q24(-2.87E-2), Q24( 1.26E-2), Q24(-1.17E-2), Q24( 2.30E-2), Q24( 1.37E-2), Q24( 5.87E-3),
  Q24( 1.81E-2), Q24(-1.37E-2), Q24( 1.64E-3), Q24(-1.39E-2), Q24(-1.31E-2), Q24( 1.37E-3),
  Q24(-1.02E-2), Q24( 1.19E-2), Q24( 3.43E-3), Q24( 7.10E-3), Q24( 1.05E-2), Q24(-4.72E-3),
  Q24( 4.46E-3), Q24(-8.92E-3), Q24(-5.38E-3), Q24(-2.32E-3), Q24(-7.26E-3), Q24( 5.54E-3),
  Q24(-6.64E-4), Q24( 5.64E-3), Q24( 5.33E-3), Q24(-5.59E-4), Q24( 4.15E-3), Q24(-4.84E-3),
  Q24(-1.38E-3), Q24(-2.84E-3), Q24(-4.19E-3), Q24( 1.86E-3), Q24(-1.75E-3), Q24( 3.46E-3),
  Q24( 2.06E-3), Q24( 8.82E-4), Q24( 2.71E-3), Q24(-2.04E-3), Q24( 2.40E-4), Q24(-2.00E-3),
  Q24(-1.85E-3), Q24( 1.90E-4), Q24(-1.38E-3), Q24( 1.57E-3), Q24( 4.37E-4), Q24( 8.73E-4),
  Q24( 1.24E-3), Q24(-5.34E-4)
  };


int filterState[FIR_FILTER_LENGTH];


int main(void)
{
  int i;

                 // Initiaize FIR filter state array
  for (i = 0; i < FIR_FILTER_LENGTH; i++)
  {
    filterState[i] = 0;
  }

                // Apply FIR filter and store filtered data
  for (i = 0; i < SAMPLE_LENGTH; i++)
  {
    // data = Q24((((double)rand()) - ((double)(RAND_MAX / 2))) / ((double)(RAND_MAX / 2)));  /* Generate random data */

    Dst[i] =
      xmos_dsp_filters_fir (Src[i],                 // Input data sample to be filtered
                            firCoeffs,              // Pointer to filter coefficients
                            filterState,            // Pointer to filter state array
                            FIR_FILTER_LENGTH,      // Filter length
                            Q_N);                   // Q Format N
  }

  printf ("Adaptive Filter Results\n");
  for (i = 0; i < SAMPLE_LENGTH; i++)
  {
    printf ("Dst = %lf\n", F24 (Dst[i]));
  }

  return (0);
}
