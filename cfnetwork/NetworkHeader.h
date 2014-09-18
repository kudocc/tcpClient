//
//  NetworkHeader.h
//  cfnetwork
//
//  Created by yuanrui on 14-9-2.
//  Copyright (c) 2014年 yuanrui. All rights reserved.
//

#ifndef cfnetwork_NetworkHeader_h
#define cfnetwork_NetworkHeader_h

#import "PacketCmd.h"
#import "CSerialization.h"
#import "CDeserialization.h"

#pragma pack(1)

typedef struct structNetWorkHeader {
    uint32_t length ;   // length of the packet(including header)
    uint32_t transId ;  // transId
    uint32_t cmd ;      // command of packet
} NetWorkHeader ;

struct structBaseNetwork {
    
    NetWorkHeader header ;
    
public:
    structBaseNetwork() {
        header.length = packetLength() ;
        header.transId = 0 ;
        header.cmd = 0 ;
    }
    
    structBaseNetwork(const structBaseNetwork &baseNetwork) {
        header.length = baseNetwork.header.length ;
        header.transId = baseNetwork.header.transId ;
        header.cmd = baseNetwork.header.cmd ;
    }
    
    virtual uint32_t serialization(CSerialization *serial) {
        serial->serialize(header.length) ;
        serial->serialize(header.transId) ;
        serial->serialize(header.cmd) ;
        return packetLength() ;
    }
    
    virtual uint32_t deSerialization(CDeserialization *deSerial) {
        deSerial->deSerialize(header.length) ;
        deSerial->deSerialize(header.transId) ;
        deSerial->deSerialize(header.cmd) ;
        return packetLength() ;
    }
    
    virtual uint32_t packetLength() {
        return sizeof(header) ;
    }
} ;
typedef struct structBaseNetwork BaseNetworkPacket;

struct structTextSend : structBaseNetwork {
    
    uint32_t textLen ;
    char text[1024] ;
    
public:
    structTextSend() {
        header.cmd = Cmd_Text ;
        textLen = 0 ;
        memset(text, 0, 1024) ;
    }
    
    structTextSend(const structTextSend &textSend):BaseNetworkPacket(textSend) {
        textLen = textSend.textLen ;
        memcpy(text, textSend.text, textLen) ;
    }
    
    virtual uint32_t serialization(CSerialization *serial) {
        BaseNetworkPacket::serialization(serial) ;
        serial->serialize((const unsigned char *)text, textLen) ;
        return packetLength() ;
    }
    
    virtual uint32_t deSerialization(CDeserialization *deSerial) {
        BaseNetworkPacket::deSerialization(deSerial) ;
        deSerial->deSerialize((unsigned char *)text, textLen) ;
        return packetLength() ;
    }
    
    virtual uint32_t packetLength() {
        uint32_t len = BaseNetworkPacket::packetLength() ;
        len += sizeof(textLen) ;
        len += textLen ;
        return len ;
    }
} ;
typedef struct structTextSend TextPacket ;

#pragma pack()

#endif
