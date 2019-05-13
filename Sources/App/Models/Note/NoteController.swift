//
//  NoteController.swift
//  App
//
//  Created by YiYi on 2019/5/10.
//

import Vapor
import MySQL


final class NoteController: RouteCollection {
    
    func boot(router: Router) throws {
        let noteRouter = router.grouped("api", "note")
        let noteController = NoteController()
    
        let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
        let authedRoutes = noteRouter.grouped(tokenAuthenticationMiddleware)
        authedRoutes.post("", use: noteController.create)
        authedRoutes.get("", use: noteController.index)
        authedRoutes.delete("", use: noteController.delete)
    }
    
    func index(_ req: Request) throws -> Future<[Note]> {
        guard let userId = req.query[Int.self, at: "userId"] else {
            throw Abort(.badRequest)
        }
        
        return Note.query(on: req).filter(\.userId, ._equal, userId).all()
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
