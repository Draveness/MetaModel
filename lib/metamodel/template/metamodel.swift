//
//  MetaModel.swift
//  MetaModel
//
//  Created by MetaModel.
//  Copyright © 2016 MetaModel. All rights reserved.
//

import Foundation

let path = NSSearchPathForDirectoriesInDomains(
    .DocumentDirectory, .UserDomainMask, true
).first! as String

let db =  try! Connection("\(path)/metamodel_db.sqlite3")

public class MetaModel {
    public static func initialize() {
        validateMetaModelTables()
        <% models.each do |model| %><%= "#{model.name}.initialize()" %>
        <% end %>
    }
    static func validateMetaModelTables() {
        createMetaModelTable()
        let infos = retrieveMetaModelTableInfos()
        <% models.each do |model| %><%= """if infos[#{model.name}.tableName] != \"#{model.hash_value}\" {
            updateMetaModelTableInfos(#{model.name}.tableName, hashValue: \"#{model.hash_value}\")
            #{model.name}.deinitialize()
        }""" %>
        <% end %>
    }
}

func executeSQL(sql: String, silent: Bool = false, success: (() -> ())? = nil) -> Statement? {
    defer { print("\n") }
    if !silent {
        print("-> Begin Transaction")
    }
    let startDate = NSDate()
    do {
        let result = try db.run(sql)
        let endDate = NSDate()
        let interval = endDate.timeIntervalSinceDate(startDate) * 1000

        if !silent {
            print("\tSQL (\(interval.format("0.2"))ms) \(sql)")
            print("-> Commit Transaction")
        }
        if let success = success {
            success()
        }

        return result
    } catch let error {
        let endDate = NSDate()
        let interval = endDate.timeIntervalSinceDate(startDate) * 1000
        if !silent {
            print("\tSQL (\(interval.format("0.2"))ms) \(sql)")
            print("\t\(error)")
            print("-> Rollback transaction")
        }
    }
    return nil
}

func executeScalarSQL(sql: String, silent: Bool = false, success: (() -> ())? = nil) -> Binding? {
    defer { print("\n") }
    if !silent {
        print("-> Begin Transaction")
    }
    let startDate = NSDate()
    let result = db.scalar(sql)
    let endDate = NSDate()
    let interval = endDate.timeIntervalSinceDate(startDate) * 1000
    if !silent {
        print("\tSQL (\(interval.format("0.2"))ms) \(sql)")
        print("-> Commit Transaction")
    }

    if let success = success {
        success()
    }

    return result
}
