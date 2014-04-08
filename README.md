# remoteTransmission

Very simple client for Transmission's RPC API for iOS 7.

Work in progress.

Currently implemented:

- Login/logout.
- List of torrents.
- Torrents name, progress, and size.
- Current global download/upload speed.
- The user can limit the download/upload speed.
- Autoupdates the list of torrents and the speed every 5 seconds.

The communication with the server is implemented following the Transmission RPC specification, available in https://trac.transmissionbt.com/browser/trunk/extras/rpc-spec.txt. The server expects a POST request with a JSON object specifing the action and parameters in the request body. The communication with the server is implemented in CRTTransmissionController. Methods in this object usually expect a block called asynchronously when the request completes.

