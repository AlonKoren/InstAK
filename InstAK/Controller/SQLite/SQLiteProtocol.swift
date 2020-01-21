//
//  SQLiteProtocol.swift
//  Insta
//
//  Created by gil yermiyah on 28/01/2019.
//  Copyright © 2019 Gil Yermiyah. All rights reserved.
//

import Foundation

protocol SQLiteProtocol {
    associatedtype myType
    
    static var TableName: String { get }
    
    static func createTable(database: OpaquePointer?)
    static func drop(database: OpaquePointer?)
    static func getAll(database: OpaquePointer?)->[myType]
    static func addNew(database: OpaquePointer?, data:myType)
    static func get(database: OpaquePointer?, byId:String)->myType?
    
    static func getLastUpdateDate(database: OpaquePointer?)->Double
    static func setLastUpdateDate(database: OpaquePointer?, date:Double)
    
    static func getTypeByStmt(sqlite3_stmt: OpaquePointer?)->myType
}
extension SQLiteProtocol{
    
    
    static func drop(database: OpaquePointer?) {
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "DROP TABLE \(TableName);", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
    }
    
    static func getAll(database: OpaquePointer?) -> [myType] {
        var sqlite3_stmt: OpaquePointer? = nil
        var data = [myType]()
        if (sqlite3_prepare_v2(database,"SELECT * from \(TableName);",-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                data.append(getTypeByStmt(sqlite3_stmt: sqlite3_stmt))
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return data
    }
    
    static func getLastUpdateDate(database: OpaquePointer?)->Double{
        return LastUpdateDates.get(database: database, tabeName: TableName)
    }
    
    static func setLastUpdateDate(database: OpaquePointer?, date:Double){
        LastUpdateDates.set(database: database, tabeName: TableName, date: date);
    }
}
