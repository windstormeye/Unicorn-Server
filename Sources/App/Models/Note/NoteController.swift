//
//  NoteController.swift
//  App
//
//  Created by PJHubs on 2019/5/10.
//

import Vapor
import MySQL


/// Sticker 增删改查操作控制器
final class NoteController {
    
    func index(_ req: Request) throws -> Future<[Note]> {
        return Note.query(on: req).all()
    }

    func create(_ req: Request) throws -> Future<Note> {
        return try req.content.decode(Note.self).flatMap({
            return $0.save(on: req)
        })
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Note.self).flatMap {
            
            return $0.delete(on: req)
            }.transform(to: .ok)
    }
}
