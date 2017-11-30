//
//  WDServer.swift
//  PresBrowser
//
//  Created by alex on 11/25/17.
//  Copyright © 2017 Oz Michaeli. All rights reserved.
//

import UIKit
import Swifter

@objc
protocol WDServerDelegate {
    var shouldScaleWithJavascript : Bool {get set}
    var shouldScaleWithWebkit : Bool {get set}
    var url : URL! {get}
    func navigate(url: URL)
    func refresh();
}

class WDServer  : NSObject, NetServiceDelegate {
    var service : NetService
    var name : String
    var delegate: WDServerDelegate
    
    let uuid = NSUUID.init()
    let server = HttpServer()
    let port = 4550

    public init(name: String, delegate: WDServerDelegate){
        self.name = name
        self.service = NetService(domain: "local", type: "_presbrowser._tcp.", name: name, port: Int32(port))
        self.delegate = delegate
        super.init()
        server["/"] = self.rootHandler
        server.post["/url"] = {r  in
            let data = r.parseUrlencodedForm()
            let maybeUrlString = data.first(where: {$0.0 == "url"})
            if let (_, urlString) = maybeUrlString, let url = URL(string:urlString) {
                self.delegate.navigate(url: url)
                return self.jsonResponse(data:["url": urlString])
            }else{
                return self.jsonResponse(data:["error": "no url given"], code:400, phrase:"Bad Request")
            }
        }
        service.delegate = self
    }
    
    public func start() throws {
        try server.start(UInt16(port), forceIPv4: true, priority: DispatchQoS.QoSClass.default)
        service.startMonitoring()
        service.publish()
    }
    
    private func rootHandler(req: HttpRequest) -> HttpResponse{
        let body: [String:Any] = ["name": self.name,
                                  "uuid": self.uuid.uuidString,
                                  "url": self.delegate.url,
                                  "scale_webkit": self.delegate.shouldScaleWithWebkit,
                                  "scale_javascript": self.delegate.shouldScaleWithJavascript]
        return jsonResponse(data: body)
    }
    
    private func jsonResponse(data:[String: Any], code: Int = 200, phrase: String = "OK") -> HttpResponse{
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            return HttpResponse.raw(code, "", ["Content-Type": "application/json"], {w in try w.write(jsonData)})
        }catch{
            return .badRequest(.text("Error serializing \(data)"))
        }
    }
}
