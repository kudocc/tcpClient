//
//  CSerialization.h
//  cfnetwork
//
//  Created by KudoCC on 14-9-2.
//  Copyright (c) 2014年 KudoCC. All rights reserved.
//

#ifndef __cfnetwork__CSerialization__
#define __cfnetwork__CSerialization__

#include "stdint.h"

class CSerialization
{
public:
    CSerialization(uint8_t *memory, uint32_t size) ;
public:
    void serialize(uint8_t data) ;
    void serialize(uint16_t data) ;
    void serialize(uint32_t data) ;
    void serialize(uint64_t data) ;
    void serialize(const unsigned char *pData, uint32_t len) ;
private:
    uint8_t *pointer ;
    uint32_t memorySize ;
    uint32_t position ;
};

#endif /* defined(__cfnetwork__CSerialization__) */
