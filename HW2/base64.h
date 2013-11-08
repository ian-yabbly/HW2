//
//  base64.h
//  HW2
//
//  Created by Ian Shafer on 11/7/13.
//  Copyright (c) 2013 Yabbly. All rights reserved.
//

#ifndef HW2_base64_h
#define HW2_base64_h

#include <sys/types.h>

extern int
b64_ntop(u_char const *src,
         size_t srclength,
         char *target,
         size_t targsize);

extern int
b64_pton(char const *src,
         u_char *target,
         size_t targsize);

#endif
