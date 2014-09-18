//
//  CDeserialization.cpp
//  cfnetwork
//
//  Created by yuanrui on 14-9-3.
//  Copyright (c) 2014年 yuanrui. All rights reserved.
//

#include "CDeserialization.h"

CDeserialization::CDeserialization(const uint8_t *memory, uint32_t size)
{
    pointer = memory ;
    memorySize = size ;
    position = 0 ;
}

void CDeserialization::deSerialize(uint8_t &data)
{
    memcpy(&data, pointer+position, sizeof(data)) ;
    position += sizeof(data) ;
}

void CDeserialization::deSerialize(uint16_t &data)
{
    memcpy(&data, pointer+position, sizeof(data)) ;
    position += sizeof(data) ;
}

void CDeserialization::deSerialize(uint32_t &data)
{
    memcpy(&data, pointer+position, sizeof(data)) ;
    position += sizeof(data) ;
}

void CDeserialization::deSerialize(uint64_t &data)
{
    memcpy(&data, pointer+position, sizeof(data)) ;
    position += sizeof(data) ;
}

void CDeserialization::deSerialize(unsigned char *pData, uint32_t &len)
{
    memcpy(&len, pointer+position, sizeof(len)) ;
    position += sizeof(len) ;
    memcpy(pData, pointer+position, len) ;
    position += len ;
}

void CDeserialization::reset()
{
    position = 0 ;
}