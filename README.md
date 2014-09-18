tcpClient
=========

iOS app using socket to interact with simple server (support voip)

You can custom the protocol, all custom protocols are a subclass of BaseNetworkPacket, there is an example protocol named TextPacket. Two c++ class CSerialization and CDeserialization implement serialization and deserialization.

KDConnection class is a tcp connection manager with select mode(implement by socket), you can test it in KDClientSocketSelectViewController class.

KDCFNetworkConnection class is a tcp connection manager support voip (implement by CFNetWork.framework), you can test it in KDSocketCFNetworkViewController class.
