tcpClient
=========

iOS app using socket to interact with [simple echo server](https://github.com/kudocc/simpleServer) (support VoIP which means when application is suspended, it can receive the packet sended from server on VoIp socket)

Before build the project, you should config the server ip address.

You can send some text to echo server and receive the text from server. When we receive a packet from server, if app is in background, I present a local notification to notify user, I think it's a standard way for VoIP application.

There are two implementations on tcp client, one is using C socket, the other is using CFStream, but the C socket has a issue on supporting VoIP, it can't receive the packet from server a few minutes after app goes into background.

You can custom the protocol, all custom protocols are subclass from `BaseNetworkPacket` class. There is an example protocol named TextPacket, you can create another one like it. Two c++ class `CSerialization` and `CDeserialization` implement serialization and deserialization.

`KDConnection` class holds a tcp connection which is select mode, it is used in `KDClientSocketSelectViewController` view controller.

`KDCFNetworkConnection` class holds a tcp connection which supports VOIP (implement by CFNetWork.framework), it is used in `KDSocketCFNetworkViewController` view controller.
