# High Speed Tridion Publishing
When my employer decided to add an extra Tridion publication server located in China, to speed up website access for our Chinese customers, we quickly ran into problems with publishing from the content manager server (based in Europe) to the Chinese publication server. Publishing simply was too slow and unreliable. Publihsing a single page would take 10 to 15 minutes. And larger publihsing transactions would take more than half an hour or simply time out. This presented both a big problem with the initial first publish of the entire website, but would also present problems in production: Editors will not accept publishing wait times that long.

Initially Tridion had been configured to use HTTPS as the transport method. Searching the web for possible solutions I came accross a Stack Exchange question (http://tridion.stackexchange.com/questions/10943/http-deployer-displays-slow-transport-throughput-on-high-latency-networks) which suggested FTP might be a better solution. After setting up FTP transport and later SFTP (http://megipsy.blogspot.nl/2014/09/sdl-tridion-enabling-multiple-content.html), things sped up a little bit (about twice as fast), but still publishing was slow and unreliable. Tridion would go into a 'throttled' state for long periods and would not easily recover from that.

## UDP: The solution
After some more researching it became apperent that the problem was mainly caused by the high latency of about 350ms. Both HTTP and FTP are TCP connections which require by design that every packet sent has to be acknowledged by the receiver. This slows things down a lot. So the solution was to find a reliable UDP based file transfer method.

Currently there are 3 major open source UDP based file transfer systems: UDT, Tsunami and UFTP. Only UFTP (http://uftp-multicast.sourceforge.net/) currently has precompiled Windows binaries. I therefore decided to give UFTP a try.

After setting everything up, UFTP immediately achieved speeds of over 20 Mbit/s. This was the solution we needed, but since UFTP is not simply plug and play with Tridion we need to device a method to make Tridion and UFTP work together.

## Tridion and UFTP setup
This is the final setup I am currently using:

On the Content Management Server:
1. Setup Tridion to publish to the local file system on the server (in my case: D:\ftpchina\incoming)
2. asdfsaf
