//
//  PacketMemoryManager.cpp
//  cfnetwork
//
//  Created by KudoCC on 14-8-12.
//  Copyright (c) 2014年 KudoCC. All rights reserved.
//

#include "PacketMemoryManager.h"
#include "assert.h"

CPacketMemoryManager::CPacketMemoryManager():pointer(NULL)
{
    memset(buffer, 0, sizeof(buffer)) ;
    bufferUseLength = 0 ;
    bufferLength = sizeof(buffer) ;
}

CPacketMemoryManager::~CPacketMemoryManager()
{
    if (pointer) {
        free(pointer) ;
    }
}

unsigned int CPacketMemoryManager::getUseBufferLength()
{
    return bufferUseLength ;
}

unsigned char * CPacketMemoryManager::getBufferPointer()
{
    if (pointer) {
        return pointer ;
    } else {
        return buffer ;
    }
}

void CPacketMemoryManager::addToBuffer(const unsigned char *data, unsigned int len)
{
    unsigned int originalLen = bufferUseLength ;
    bufferUseLength += len ;
    if (pointer) {
        unsigned char *p = (unsigned char *)malloc(bufferUseLength) ;
        memcpy(p, pointer, originalLen) ;
        memcpy(p+originalLen, data, len) ;
        free(pointer) ;
        pointer = p ;
        bufferLength = bufferUseLength ;
    } else {
        if (bufferUseLength > sizeof(buffer)) {
            unsigned char *p = (unsigned char *)malloc(bufferUseLength) ;
            memcpy(p, buffer, originalLen) ;
            memcpy(p+originalLen, data, len) ;
            pointer = p ;
            bufferLength = bufferUseLength ;
        } else {
            memcpy(buffer+originalLen, data, len) ;
        }
    }
}

void CPacketMemoryManager::removeBuffer(unsigned int len)
{
    unsigned int originalLen = bufferUseLength ;
    assert(originalLen >= len) ;
    bufferUseLength -= len ;
    unsigned char *p = NULL ;
    if (pointer) {
        p = pointer ;
    } else {
        p = buffer ;
    }
    memmove(p, p+len, originalLen-len) ;
}