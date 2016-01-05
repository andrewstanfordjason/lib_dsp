// Copyright (c) 2016, XMOS Ltd, All rights reserved

#ifndef LIB_DSP_MATRIX
#define LIB_DSP_MATRIX

/** Matrix negation: ``R[i][j] = -X[i][j]``
 * 
 *  Each negated element is computed by twos-compliment negation therefore
 *  the minimum negative fixed-point value can not be negated to generate its
 *  corresponding maximum positive fixed-point value. For example: -Q28(-8.0)
 *  will not result in a fixed-point value representing +8.0.
 * 
 *  Example:
 * 
 *  \code
 *  int samples[8][32];
 *  int result[8][32];  
 *  lib_dsp_matrix_negate( samples, result, 8, 32 );
 *  \endcode
 * 
 *  \param  input_matrix_X   Pointer/reference to source data.
 *  \param  result_matrix_R  Pointer to the resulting 2-dimensional data array.
 *  \param  row_count        Number of rows in input matrix.
 *  \param  column_count     Number of columns in input matrix.
 */

void lib_dsp_matrix_negate
(
    const int input_matrix_X[],
    int       result_matrix_R[],
    int       row_count,
    int       column_count
);

/** Matrix / scalar addition: ``R[i][j] = X[i][j] + A``
 * 
 *  32-bit addition is used to compute the scaler plus matrix element result.
 *  Therefore fixed-point value overflow conditions should be observed.  The
 *  resulting values are not saturated.
 * 
 *  Example:
 * 
 *  \code
 *  int input_matrix_X[8][32];
 *  int input_scalar_A = Q28( 0.333 );
 *  int result_vector_R[8][32];  
 *  lib_dsp_matrix_adds( input_matrix_X, scalar_matrix_A, result_matrix_R, 8, 32 );
 *  \endcode
 * 
 *  \param  input_matrix_X   Pointer/reference to source data.
 *  \param  input_scalar_A   Scalar value to add to each input element.
 *  \param  result_matrix_R  Pointer to the resulting 2-dimensional data array.
 *  \param  row_count        Number of rows in input and output matrices.
 *  \param  column_count     Number of columns in input and output matrices.
 */

void lib_dsp_matrix_adds
(
    const int input_matrix_X[],
    int       input_scalar_A,
    int       result_matrix_R[],
    int       row_count,
    int       column_count
);

/** Matrix / scalar multiplication: ``R[i][j] = X[i][j] * A``
 * 
 *  Each element of the input matrix is multiplied by a scalar value using a
 *  32bit multiply 64-bit accumulate function therefore fixed-point
 *  multiplication and q-format adjustment overflow behavior must be considered
 *  (see behavior for the function ``lib_dsp_math_multiply``).
 * 
 *  Example:
 * 
 *  \code
 *  int input_matrix_X[8][32];
 *  int input_scalar_A = Q28( 0.333 );
 *  int result_vector_R[8][32];  
 *  lib_dsp_matrix_muls( input_matrix_X, scalar_value_A, result_matrix_R, 256, 8, 32, 28 );
 *  \endcode
 * 
 *  \param  input_matrix_X   Pointer/reference to source data X.
 *  \param  input_scalar_A   Scalar value to multiply each element by.
 *  \param  result_matrix_R  Pointer to the resulting 2-dimensional data array.
 *  \param  row_count        Number of rows in input and output matrices.
 *  \param  column_count     Number of columns in input and output matrices.
 *  \param  q_format         Fixed point format (i.e. number of fractional bits).
 */

void lib_dsp_matrix_muls
(
    const int input_matrix_X[],
    int       input_scalar_A,
    int       result_matrix_R[],
    int       row_count,
    int       column_count,
    int       q_format
);

/** Matrix / matrix addition: ``R[i][j] = X[i][j] + Y[i][j]``
 * 
 *  32-bit addition is used to compute the result for each element.
 *  Therefore fixed-point value overflow conditions should be observed.
 *  The resulting values are not saturated.
 * 
 *  Example:
 * 
 *  \code
 *  int input_matrix_X [256];
 *  int input_matrix_Y [256];
 *  int result_matrix_R[256];  
 *  lib_dsp_matrix_addv( input_matrix_X, input_matrix_Y, result_matrix_R, 8, 32 );
 *  \endcode
 * 
 *  \param  input_matrix_X   Pointer to source data array X.
 *  \param  input_matrix_Y   Pointer to source data array Y.
 *  \param  result_matrix_R  Pointer to the resulting 2-dimensional data array.
 *  \param  row_count        Number of rows in input and output matrices.
 *  \param  column_count     Number of columns in input and output matrices.
 */

void lib_dsp_matrix_addm
(
    const int input_matrix_X[],
    const int input_matrix_Y[],
    int       result_matrix_R[],
    int       row_count,
    int       column_count
);

/** Matrix / matrix subtraction: ``R[i][j] = X[i][j] - Y[i][j]``
 * 
 *  32-bit subtraction is used to compute the result for each element.
 *  Therefore fixed-point value overflow conditions should be observed.
 *  The resulting values are not saturated.
 * 
 *  Example:
 * 
 *  \code
 *  int input_matrix_X [256];
 *  int input_matrix_Y [256];
 *  int result_matrix_R[256];  
 *  lib_dsp_matrix_addv( input_matrix_X, input_matrix_Y, result_matrix_R, 8, 32 );
 *  \endcode
 * 
 *  \param  input_matrix_X   Pointer to source data array X.
 *  \param  input_matrix_Y   Pointer to source data array Y.
 *  \param  result_matrix_R  Pointer to the resulting 2-dimensional data array.
 *  \param  row_count        Number of rows in input and output matrices.
 *  \param  column_count     Number of columns in input and output matrices.
 */

void lib_dsp_matrix_subm
(
    const int input_matrix_X[],
    const int input_matrix_Y[],
    int       result_matrix_R[],
    int       row_count,
    int       column_count
);

/** Matrix / matrix multiplication: ``R[i][j] = X[i][j] * Y[i][j]``
 * 
 *  Elements in each of the input matrices are multiplied together using a
 *  32bit multiply 64-bit accumulate function therefore fixed-point
 *  multiplication and q-format adjustment overflow behavior must be considered
 *  (see behavior for the function ``lib_dsp_math_multiply``).
 * 
 *  Example:
 * 
 *  \code
 *  int input_matrix_X[8][32];
 *  int input_matrix_Y[8][32];
 *  int result_vector_R[8][32];  
 *  lib_dsp_matrix_mulm( input_matrix_X, input_matrix_Y, result_matrix_R, 256, 8, 32, 28 );
 *  \endcode
 * 
 *  \param  input_matrix_X   Pointer to source data array X.
 *  \param  input_matrix_Y   Pointer to source data array Y.
 *  \param  result_matrix_R  Pointer to the resulting 2-dimensional data array.
 *  \param  row_count        Number of rows in input and output matrices.
 *  \param  column_count     Number of columns in input and output matrices.
 *  \param  q_format         Fixed point format (i.e. number of fractional bits).
 */

void lib_dsp_matrix_mulm
(
    const int input_matrix_X[],
    const int input_matrix_Y[],
    int       result_matrix_R[],
    int       row_count,
    int       column_count,
    int       q_format
);

/** Matrix transposition
 * 
 *  \param  input_matrix_X   Pointer/reference to source data.
 *  \param  result_matrix_R  Pointer/reference to the resulting data.
 *  \param  row_count        Number of rows in input and output matrices.
 *  \param  column_count     Number of columns in input and output matrices.
 *  \param  q_format         Fixed point format (i.e. number of fractional bits).
 */

void lib_dsp_matrix_transpose
(
    const int input_matrix_X[],
    int       result_matrix_R[],
    int       row_count,
    int       column_count,
    int       q_format
);

#endif
