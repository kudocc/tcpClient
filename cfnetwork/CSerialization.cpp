//
//  CSerialization.cpp
//  cfnetwork
//
//  Created by KudoCC on 14-9-2.
//  Copyright (c) 2014年 KudoCC. All rights reserved.
//

#include "CSerialization.h"
#include <string.h>

CSerialization::CSerialization(uint8_t *memory, uint32_t size)
{
    pointer = memory ;
    memorySize = size ;
    position = 0 ;
}

void CSerialization::serialize(uint8_t data)
{
    memcpy(pointer+position, &data, sizeof(data)) ;
    position += sizeof(data) ;
}

void CSerialization::serialize(uint16_t data)
{
    memcpy(pointer+position, &data, sizeof(data)) ;
    position += sizeof(data) ;
}

void CSerialization::serialize(uint32_t data)
{
    memcpy(pointer+position, &data, sizeof(data)) ;
    position += sizeof(data) ;
}

void CSerialization::serialize(uint64_t data)
{
    memcpy(pointer+position, &data, sizeof(data)) ;
    position += sizeof(data) ;
}

void CSerialization::serialize(const unsigned char *pData, uint32_t len)
{
    memcpy(pointer+position, &len, sizeof(len)) ;
    position += sizeof(len) ;
    memcpy(pointer+position, pData, len) ;
    position += len ;
}