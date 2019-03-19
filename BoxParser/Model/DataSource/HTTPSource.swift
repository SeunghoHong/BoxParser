
import Foundation

class HTTPSource: NSObject, DataSource {
    let uri: String
    var size: UInt64 = 0

    let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)

    let data: NSMutableData = NSMutableData()
    var completed = false

    init?(uri: String) {
        guard let url = URL(string: uri) else {
            return nil
        }
        self.uri = uri
        super.init()

        // TODO: set timeout
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        print("\(request.allHTTPHeaderFields)")

        let configuration = URLSessionConfiguration.default
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
        let sessionTask = session.dataTask(with: request)
        sessionTask.resume()
        self.semaphore.wait()
    }

    func read(_ offset: inout UInt64, size: UInt32) throws -> Data! {
        do {
            let range = NSRange(location: Int(offset), length: Int(size))
            offset += UInt64(size)
            while offset > UInt64(data.length) {
                if self.completed {
                    // throw error
                    throw DataSourceError.ioError
                }
                self.semaphore.wait()
            }
            return try self.readInternal(range)
        } catch let error {
            throw error
        }
    }

    fileprivate func readInternal(_ range: NSRange) throws -> Data! {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        return self.data.subdata(with: range)
    }
}

extension HTTPSource: URLSessionDelegate {
    @objc func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            print("complete")
        }
        self.completed = true
        self.semaphore.signal()
    }

    func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceiveResponse response: URLResponse, completionHandler: (Foundation.URLSession.ResponseDisposition) -> Void) {
        let response = response as! HTTPURLResponse
        if let size = response.allHeaderFields["Content-Length"] as? String {
            self.size = UInt64(size) ?? 0
        }
        for (key, value) in response.allHeaderFields {
            print("\(key): \(value)")
        }
        completionHandler(.allow)
        self.semaphore.signal()
    }

    func URLSession(_ session: Foundation.URLSession, dataTask: URLSessionDataTask, didReceiveData data: Data) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        self.data.append(data)
        self.semaphore.signal()
    }
}
