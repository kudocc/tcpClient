//
//  PacketMemoryManager.h
//  cfnetwork
//
//  Created by yuanrui on 14-8-12.
//  Copyright (c) 2014年 yuanrui. All rights reserved.
//

#ifndef __cfnetwork__PacketMemoryManager__
#define __cfnetwork__PacketMemoryManager__

#include <iostream>

class CPacketMemoryManager {
    unsigned char buffer[2048] ;
    unsigned char *pointer ;
    unsigned int bufferUseLength ;
    unsigned int bufferLength ;
public:
    CPacketMemoryManager() ;
    ~CPacketMemoryManager() ;
public:
    unsigned int getUseBufferLength() ;
    unsigned char * getBufferPointer() ;
    void addToBuffer(unsigned char *data, unsigned int len) ;
    void removeBuffer(unsigned int len) ;
};

#endif /* defined(__cfnetwork__PacketMemoryManager__) */
