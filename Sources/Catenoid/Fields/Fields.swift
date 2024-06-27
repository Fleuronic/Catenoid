//
//  File.swift
//  
//
//  Created by Jordan Kay on 6/24/24.
//

import protocol Catena.Fields
import protocol PersistDB.ModelProjection

public protocol Fields: Catena.Fields, ModelProjection {}
