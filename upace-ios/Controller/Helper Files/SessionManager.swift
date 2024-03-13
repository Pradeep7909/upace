//
//  SessionManager.swift
//  upace-ios
//
//  Created by Qualwebs on 07/03/24.
//


import UIKit
import Alamofire

class SessionManager: NSObject {
    
    static var shared = SessionManager()
    
    func methodForApiCalling<T: Codable>(url: String, method: HTTPMethod, parameter: Parameters?, objectClass: T.Type, requestCode: String, completionHandler: @escaping (T?) -> Void) {
        print("URL: \(url)")
        print("METHOD: \(method)")
        print("PARAM: \(String(describing: parameter))")
        AF.sessionConfiguration.timeoutIntervalForRequest = 15
        AF.sessionConfiguration.timeoutIntervalForResource = 15
        AF.request(url, method: method, parameters: parameter, encoding: JSONEncoding.default, headers: getHeader(reqCode: requestCode), interceptor: nil)
            .responseString { (dataResponse) in
                let statusCode = dataResponse.response?.statusCode
                print("dataResponse: \(dataResponse)")
                switch dataResponse.result {
                case .success(_):
                    var object:T?
                    if(statusCode != 400){
                        object = self.convertDataToObject(response: dataResponse.data, T.self)
                    }else if(statusCode == 200){
                        object = self.convertDataToObject(response: dataResponse.data, T.self)
                    }
                    let errorObject = self.convertDataToObject(response: dataResponse.data, ErrorResponse.self)
                    if (statusCode == 200 || statusCode == 201) && object != nil{
                        completionHandler(object!)
                    } else {
                        completionHandler(nil)
                        print("statusCode : \(String(describing: statusCode))")
                        print("errorObject : \(String(describing: errorObject))")
                        ToastManager.shared.showToast(message: errorObject?.message ?? "Server Error", type: .error)
                    }
                    break
                case .failure(_):
                    completionHandler(nil)
                    LOG("🔴 failure")
                }
            }
    }
    
    //    private
    func convertDataToObject<T: Codable>(response inData: Data?, _ object: T.Type) -> T? {
        if let data = inData {
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(T.self, from: data)
                return decoded
            } catch {
                print("🔴 DATA PARSING ERROR : \(error)")
            }
        }
        return nil
    }
    
    func getHeader(reqCode: String) -> HTTPHeaders? {
        let token = UserDefaults.standard.value(forKey: UD_TOKEN) as? String
        if (token != nil){
            if(token == nil){
                return nil
            }else {
                return ["Authorization": "Bearer " + "\(token ?? "")"]
            }
        } else {
            return nil
        }
    }
}

