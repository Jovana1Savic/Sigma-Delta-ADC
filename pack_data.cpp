
/*==========================================================
 * mexcpp.cpp - example in MATLAB External Interfaces
 *
 * Illustrates how to use some C++ language features in a MEX-file.
 *
 * The routine simply defines a class, constructs a simple object,
 * and displays the initial values of the internal variables. It
 * then sets the data members of the object based on the input given
 * to the MEX-file and displays the changed values.
 *
 * This file uses the extension .cpp. Other common C++ extensions such
 * as .C, .cc, and .cxx are also supported.
 *
 * The calling syntax is:
 *
 *              mexcpp( num1, num2 )
 *
 * This is a MEX-file for MATLAB.
 * Copyright 1984-2016 The MathWorks, Inc.
 *

 To build in Matlab: mex -R2018a pack_data.cpp
 *========================================================*/

#include <iostream>
#include <cstdint>
#include "mex.h"



/***********************************/

/* Creates, modifies and displays a MyData object */
int32_t mexcpp(uint8_t byte2, uint8_t byte1, uint8_t byte0) {
    int32_t result = 0;
    if (byte2 & 0x80){
      // This is a negative number.
      result |= 0xFF000000; // add leading zeros
    }
    result |= byte0 | (byte1 << 8) | (byte2 << 16);
    return result;
}

/* The gateway function. */ 
void mexFunction(int nlhs, mxArray* plhs[],
                 int nrhs, const mxArray* prhs[]) {

    /* Check for proper number of arguments */
    if(nrhs != 3) {
        mexErrMsgIdAndTxt("MATLAB:mexcpp:nargin",
                          "MEXCPP requires three input arguments.");
    }
    if(nlhs != 1) {
        mexErrMsgIdAndTxt("MATLAB:mexcpp:nargout",
                          "MEXCPP requires one output argument.");
    }

    /* Check if the input is of proper type */
    if(!mxIsUint8(prhs[0]) ||                                    // not double
       mxIsComplex(prhs[0]) ||                                   // or complex
       !mxIsScalar(prhs[0])) {                                  // or not scalar
        mexErrMsgIdAndTxt("MATLAB:mexcpp:typeargin",
                          "First argument has to be uint8.");
    }
    if(!mxIsUint8(prhs[1]) ||                                    // not double
       mxIsComplex(prhs[1]) ||                                   // or complex
       !mxIsScalar(prhs[1])) {                                  // or not scalar
        mexErrMsgIdAndTxt("MATLAB:mexcpp:typeargin",
                          "Second argument has to be uint8.");
    }
    if(!mxIsUint8(prhs[2]) ||                                    // not double
       mxIsComplex(prhs[2]) ||                                   // or complex
       !mxIsScalar(prhs[2])) {                                  // or not scalar
        mexErrMsgIdAndTxt("MATLAB:mexcpp:typeargin",
                          "Third argument has to be uint8.");
    }


    /* Acquire pointers to the input data */
    uint8_t* vin1 = mxGetUint8s(prhs[0]);
    uint8_t* vin2 = mxGetUint8s(prhs[1]);
    uint8_t* vin3 = mxGetUint8s(prhs[2]);


    plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
    int32_t* data = (int32_t*) mxGetData(plhs[0]); 
    *data = mexcpp(*vin1, *vin2, *vin3);
    return;

  }
