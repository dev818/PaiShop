//
//  AliyunUtil.swift
//  paishop
//
//  Created by SeniorCorder on 4/11/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation


class AliyunUtil {
    
    static let shared = AliyunUtil()
    
    let OSS_ACCESSKEY_ID = "LTAIiR3Ci0eyGdpt"
    let OSS_SECRETKEY_ID = "2FNLaucz6HuLYyWYRdbuGCCOk2sAUn"
    //let OSS_ENDPOINT = "http://oss-cn-beijing.aliyuncs.com"
    let OSS_ENDPOINT = "http://oss.pi-world.net/"
    
    var mClient: OSSClient!
    
    init() {
        let credential = OSSCustomSignerCredentialProvider { (cotentToSign, error) -> String? in
            let signature = OSSUtil.calBase64Sha1(withData: cotentToSign, withSecret: self.OSS_SECRETKEY_ID)
            if signature != nil {
                print("Success to get credential............")
                return "OSS " + self.OSS_ACCESSKEY_ID + ":" + signature!
            } else {
                print("Error to get credential.............")
                return nil
            }
        }
        
        if credential != nil {
            mClient = OSSClient(endpoint: OSS_ENDPOINT, credentialProvider: credential!)
        }
    }
    
    func putImage(_ image: UIImage, objectKey: String, completion: @escaping (Bool) -> Void) {
        let request = OSSPutObjectRequest()
        request.uploadingData = image.jpegData(compressionQuality: 0.3)!
        request.bucketName = Constants.OSS_BUCKET_NAME
        request.objectKey = objectKey
        request.uploadProgress = { (bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void in
            //print("bytesSent:\(bytesSent),totalBytesSent:\(totalBytesSent),totalBytesExpectedToSend:\(totalBytesExpectedToSend)");
        }
        
        let task = mClient.putObject(request)
        task.continue({ (t) -> Any? in
            self.showResult(task: t, completion: completion)
        }).waitUntilFinished()
        
    }
    
    func showResult(task: OSSTask<AnyObject>?, completion: @escaping (Bool) -> Void) -> Void {
        if task?.error != nil {
            //let error: NSError = (task?.error)! as NSError
            //print("Aliyun Task Error:", error.description)
            completion(false)
        } else {
            //let result = task?.result
            //print(result.debugDescription)
            completion(true)
        }
    }
    
    // send image or video
    func putImages(_ images: [UIImage], objectKeys: [String], imageUrls: [String], isImages: [Bool], completion: @escaping ([Bool]) -> Void) {
        var uploadResults: [Bool]
        uploadResults = [Bool](repeatElement(false, count: images.count))
        var uploadedCount = 0
        for i in 0..<images.count {
            let image = images[i]
            let objectKey = objectKeys[i]
            
            let request = OSSPutObjectRequest()
            
            if isImages[i] == true { // image
                request.uploadingData = image.jpegData(compressionQuality: 0.3)!
                
            } else { // video
                let videoUrl = URL(string: imageUrls[i])
                let videoData = try? Data(contentsOf: videoUrl!)
                request.uploadingData = videoData!
            }
            
            request.bucketName = Constants.OSS_BUCKET_NAME
            request.objectKey = objectKey
            request.uploadProgress = { (bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) -> Void in
            }
            
            let uploadTask = mClient.putObject(request)
            uploadTask.continue({
                (task) -> Any? in
                uploadedCount += 1
                uploadResults[i] = true
                if task.error != nil {
                    uploadResults[i] = false
                }
                self.showResult(task: task)
                if uploadedCount >= images.count {
                    completion(uploadResults)
                }
                return nil
            }).waitUntilFinished()
            
        }
        
    }
    
    func showResult(task: OSSTask<AnyObject>?) -> Void {
        if task?.error != nil {
            //let error: NSError = (task?.error)! as NSError
            //print("Aliyun Task Error:", error.description)
        } else {
            //let result = task?.result
            //print(result.debugDescription)
        }
    }
    
    func deleteImage(_ objectKey: String, completion: @escaping (Bool) -> Void) {
        let deleteRequest = OSSDeleteObjectRequest()
        deleteRequest.bucketName = Constants.OSS_BUCKET_NAME
        deleteRequest.objectKey = objectKey
        
        let deleteTask = mClient.deleteObject(deleteRequest)
        deleteTask.continue({
            (t) -> Any? in
            self.showResult(task: t, completion: completion)
        })
        
    }
    
    func deleteImages(_ objectKeys: [String], completion: @escaping ([Bool]) -> Void) {
        var deleteResults: [Bool]
        deleteResults = [Bool](repeatElement(false, count: objectKeys.count))
        var deletedCount = 0
        for i in 0..<objectKeys.count {
            let objectKey = objectKeys[i]
            
            let deleteRequest = OSSDeleteObjectRequest()
            deleteRequest.bucketName = Constants.OSS_BUCKET_NAME
            deleteRequest.objectKey = objectKey
            
            let deleteTask = mClient.deleteObject(deleteRequest)
            deleteTask.continue({
                (task) -> Any? in
                deletedCount += 1
                deleteResults[i] = true
                if task.error != nil {
                    deleteResults[i] = false
                }
                if deletedCount >= objectKeys.count {
                    completion(deleteResults)
                }
                self.showResult(task: task)
                return nil
            })
        }
    }
    
    
    
}

