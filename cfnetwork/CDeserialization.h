//
//  CDeserialization.h
//  cfnetwork
//
//  Created by KudoCC on 14-9-3.
//  Copyright (c) 2014年 KudoCC. All rights reserved.
//

#ifndef __cfnetwork__CDeserialization__
#define __cfnetwork__CDeserialization__

#include <iostream>

class CDeserialization
{
public:
    CDeserialization(const uint8_t *memory, uint32_t size) ;
public:
    void deSerialize(uint8_t &data) ;
    void deSerialize(uint16_t &data) ;
    void deSerialize(uint32_t &data) ;
    void deSerialize(uint64_t &data) ;
    void deSerialize(unsigned char *pData, uint32_t &len) ;
    // reset position
    void reset() ;
private:
    const uint8_t *pointer ;
    uint32_t memorySize ;
    uint32_t position ;
};

#endif /* defined(__cfnetwork__CDeserialization__) */
