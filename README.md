tcpClient
=========

iOS app using socket to interact with simple server (support voip)

You can custom the protocol, all custom protocols are subclass from `BaseNetworkPacket` class. There is an example protocol named TextPacket, you can create another one like it. Two c++ class `CSerialization` and `CDeserialization` implement serialization and deserialization.

`KDConnection` class holds a tcp connection which is select mode, it is used in `KDClientSocketSelectViewController` view controller.

`KDCFNetworkConnection` class holds a tcp connection which supports VOIP (implement by CFNetWork.framework), it is used in `KDSocketCFNetworkViewController` view controller.
