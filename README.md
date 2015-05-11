# High Speed Tridion Publishing
When my employer decided to add an extra Tridion publication server located in China, to speed up website access for our Chinese customers, we quickly ran into problems with publishing from the content manager server (based in Europe) to the Chinese publication server. Publishing simply was too slow and unreliable. Publishing a single page would take 10 to 15 minutes. And larger publishing transactions would take more than half an hour or simply time out. This presented both a big problem with the initial first publish of the entire website, but would also present problems in production: Editors will not accept publishing wait times that long.

Initially Tridion had been configured to use HTTPS as the transport method. Searching the web for possible solutions I came accross a Stack Exchange question (http://tridion.stackexchange.com/questions/10943/http-deployer-displays-slow-transport-throughput-on-high-latency-networks) which suggested FTP might be a better solution. After setting up FTP transport and later SFTP (http://megipsy.blogspot.nl/2014/09/sdl-tridion-enabling-multiple-content.html), things sped up a little bit (about twice as fast), but still publishing was slow and unreliable. Tridion would go into a 'throttled' state for long periods and would not easily recover from that.

## UDP: The solution
After some more researching it became apperent that the problem was mainly caused by the high latency of about 350ms. Both HTTP and FTP are TCP connections which require by design that every packet sent has to be acknowledged by the receiver. This slows things down a lot. So the solution was to find a reliable UDP based file transfer method.

Currently there are 3 major open source UDP based file transfer systems: UDT, Tsunami and UFTP. Only UFTP (http://uftp-multicast.sourceforge.net/) currently has precompiled Windows binaries. I therefore decided to give UFTP a try.

After setting everything up, UFTP immediately achieved speeds of over 20 Mbit/s. This was the solution we needed, but since UFTP is not simply plug and play with Tridion we needed to devise a method to make Tridion and UFTP work together.

## Tridion and UFTP setup
Tridion publishing uses (xml) files to communicate states between the publisher, transport and deployer process. Essentially what happens is that the publisher will create a .zip package of the transaction. The transporter will move that package to the incoming directory for the deployer. The deployer will unzip en commit the changes (and delete the zip file in the process) and write an xml file to communicate the state of the transaction (success, failed, etc).

Since UFTP does not feature a bi-directional sync out of the box, I created some scripts to mimic the behaviour of the deployer and publisher processes on both sides of the world. The final setup works as follows: 
  1. Tridion publishes to a local folder on the Content Manager Server. 
  2. The zip files are transported using UFTP to the incoming folder on the remote server (and deleted from the local server).
  3. On the remote server, the deployer will pickup the zip files and write an xml state file.
  4. These xml state files are sent back to the local server using UFTP.
  5. The xml state files are read by the publisher process on the local server, completing the process.
  
One thing I noticed is that the publiser not always picks up a 'success' state the first time it receives back the xml file from the remote server. Therefore I've created the sync scripts in such a way that it will keep and sync all xml files from the last 15 minutes, both on the local and remote servers. This ensures that eventually Tridion will read the correct state for all transactions.

This is the final setup I am currently using:

On the Content Management Server (local server):
  1. Setup Tridion to publish to the local file system on the server (in my case: D:\ftpchina\incoming)
  2. Download UFTP from http://uftp-multicast.sourceforge.net/ and unzip into any location (in my case: D:\uftp_exe_W7-4.6.1)
  3. Either start uftpd.exe with the start_receiver.bat script or setup the client as a Windows service as described in the Readme.txt file from the UFTP zip package.
  4. Open firewall port 1044/UDP
  5. Start the file server (sender) with start_transfer.bat (or create a scheduled task to do this automatically in the background. Once started the script will go into an infinite loop, so it only needs to be started once.

On the remote publishing server:
  1. Setup the Tridion deployer as a Windows service (see Tridion documentation) and make a note of the incoming directory you specify in the config files (in my case: C:\ftpupload\incoming)
  2. Download UFTP from http://uftp-multicast.sourceforge.net/ and unzip into any location (in my case: C:\uftp_exe_W7-4.6.1)
  3. Either start uftpd.exe with the start_receiver.bat script or setup the client as a Windows service as described in the Readme.txt file from the UFTP zip package.
  4. Open firewall port 1044/UDP
  5. Start the file server (sender) with start_transfer.bat (or create a scheduled task to do this automatically in the background. Once started the script will go into an infinite loop, so it only needs to be started once.

Please note that there is a differency between the start_transfer.bat for the local and remote servers. For the local server start_transfer.bat will:
  * Send all .zip files from the incoming directory to the remote server and delete these files after transfer is complete.
  * Remove any .xml state file form the incoming directory that is older than 15 minutes (using delete_old_files.vbs).

On the remote end, start_transfer.bat will:
  * Send all .xml files to the local server.
  * Remove any .xml state file form the incoming directory that is older than 15 minutes (using delete_old_files.vbs).

Also note, that you will need to transfer the meta.xml file manually from the remote to the local server the first time you start the sync process.

## Security
Also please make sure you pay attention to security! These scripts use encrypted transport by default and the clients are configured to only accept encrypted transfers. But since UFTP does not have an authentication scheme, you need to find a way to make sure unauthorized transfers are kept out. You can do that for example in your firewall by limiting access to port 1044/UDP only to the IP of of your own server.
