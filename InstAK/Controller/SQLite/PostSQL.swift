//
//  PostSQL.swift
//  Insta
//
//  Created by gil yermiyah on 28/01/2019.
//  Copyright © 2019 Gil Yermiyah. All rights reserved.
//

import Foundation

class PostSQL : SQLiteProtocol{

    typealias myType = Post

    static var TableName: String = "Posts";

    static let post_postId = "post_postId"
    static let post_caption = "post_caption"
    static let post_photoUrl = "post_photoUrl"
    static let post_uid = "post_uid"
    static let post_likeCount = "post_likeCount"
    static let post_ratio = "post_ratio"
    static let post_videoUrl = "post_videoUrl"
    static let post_timestamp = "post_timestamp"

    static func createTable(database: OpaquePointer?)  {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS \(TableName) (\(post_postId) TEXT PRIMARY KEY, \(post_caption) TEXT, \(post_photoUrl) TEXT, \(post_uid) TEXT, \(post_likeCount) TEXT, \(post_ratio) TEXT, \(post_videoUrl) TEXT, \(post_timestamp) TEXT)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
    }


    static func addNew(database: OpaquePointer?, data post:Post){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO \(TableName)(\(post_postId), \(post_caption), \(post_photoUrl), \(post_uid), \(post_likeCount), \(post_ratio), \(post_videoUrl), \(post_timestamp)) VALUES (?,?,?,?,?,?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            let postId      = post.postId.cString(using: .utf8)
            let caption     = post.caption?.cString(using: .utf8)
            let photoUrl    = post.photoUrl?.cString(using: .utf8)
            let uid         = post.uid.cString(using: .utf8)
            let likeCount   = String(post.likeCount ?? 0).cString(using: .utf8)
            let ratio       = "\(post.ratio ?? 1.0)".cString(using: .utf8)
            let videoUrl    = post.videoUrl?.cString(using: .utf8)
            let timestamp   = String(post.timestamp ?? 0).cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, postId       ,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, caption      ,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 3, photoUrl     ,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 4, uid          ,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 5, likeCount    ,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 6, ratio        ,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 7, videoUrl     ,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 8, timestamp    ,-1,nil);
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(sqlite3_stmt)
    }

    static func get(database: OpaquePointer?, byId:String)->Post?{
        var sqlite3_stmt: OpaquePointer? = nil
        var data :Post? = nil
        if (sqlite3_prepare_v2(database,"SELECT * from \(TableName) WHERE \(post_postId) = ?;",-1,&sqlite3_stmt,nil)
            == SQLITE_OK){

            guard sqlite3_bind_text(sqlite3_stmt, 1, byId,-1,nil) == SQLITE_OK else {
                return nil
            }
            if(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                data = getTypeByStmt(sqlite3_stmt: sqlite3_stmt)
            }
        }
        return data;
    }


    static func delete(database: OpaquePointer?, byId:String)->Void{
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"DELETE from \(TableName) WHERE \(post_postId) = ?;",-1,&sqlite3_stmt,nil)
            == SQLITE_OK){

            guard sqlite3_bind_text(sqlite3_stmt, 1, byId,-1,nil) == SQLITE_OK else {
                return
            }
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("Successfully deleted row.")
                return
            } else {
                print("could not delete row.")
                return
            }
        }
        print("Delete stattement could not be prepared.")
    }

    static func getTypeByStmt(sqlite3_stmt: OpaquePointer?)->Post?{
        guard let sqlite3_stmt = sqlite3_stmt else {
            return nil
        }
        let postId     : String = String(cString:sqlite3_column_text(sqlite3_stmt,0)!)
        let caption    : String = String(cString:sqlite3_column_text(sqlite3_stmt,1)!)
        let photoUrl   : String = String(cString:sqlite3_column_text(sqlite3_stmt,2)!)
        let uid        : String = String(cString:sqlite3_column_text(sqlite3_stmt,3)!)
        let likeCount  : Int = Int(String(cString:sqlite3_column_text(sqlite3_stmt,4)!))!
        let ratio      : CGFloat = String(cString:sqlite3_column_text(sqlite3_stmt,5)!).CGFloatValue()!
        let vid_url = sqlite3_column_text(sqlite3_stmt,6)
        let videoUrl   : String?
        if vid_url == nil{
            videoUrl   = nil
        }else{
             videoUrl = String(cString:vid_url!)
        }
        
        let timestamp  : Int = Int(String(cString:sqlite3_column_text(sqlite3_stmt,7)!))!

        let post :Post = Post(captionText: caption, photoUrlString: photoUrl, uid: uid, postId: postId, likeCount: likeCount, ratio: ratio, videoUrl: videoUrl, timestamp: timestamp)
        return post
    }

}
extension String {

  func CGFloatValue() -> CGFloat? {
    guard let doubleValue = Double(self) else {
      return nil
    }

    return CGFloat(doubleValue)
  }
}
