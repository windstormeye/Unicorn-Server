//
//  UserController.swift
//  App
//
//  Created by PJHubs on 2019/4/30.
//

import Vapor
import Crypto
import Authentication

/// Sticker 增删改查操作控制器
final class UserController: RouteCollection {
    
    func boot(router: Router) throws {
//        let usersRoute = router.grouped("api", "user")
//
//        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
//        let guardAuthMiddleware = User.guardAuthMiddleware()
//
//        let basicProtected = usersRoute.grouped(basicAuthMiddleware, guardAuthMiddleware)
//        basicProtected.post("login", use: login)
//        basicProtected.post("create", use: create)
//
//        let tokenAuthMiddleware = User.tokenAuthMiddleware()
//        let tokenProtected = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
//        tokenProtected.get(use: all)
//        tokenProtected.get(User.parameter, use: index)
//        tokenProtected.put(User.parameter, use: update)
//        tokenProtected.delete(User.parameter, use: delete)
        
        let userController = UserController()
        router.post("register", use: userController.register)
        router.post("login", use: userController.login)
        
        let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
        let authedRoutes = router.grouped(tokenAuthenticationMiddleware)
        authedRoutes.get("profile", use: userController.profile)
//        authedRoutes.get("logout", use: userController.logout)
    }

    func login(_ req: Request) throws -> Future<Token> {
        return try req.content.decode(User.self).flatMap { user in
            return User.query(on: req).filter(\.phoneNumber == user.phoneNumber).filter(\.password == user.password).first().flatMap {
                guard let existingUser = $0 else {
                    throw Abort(HTTPStatus.notFound)
                }
                
                return try Token
                    .query(on: req)
                    .filter(\Token.userId, .equal, existingUser.requireID())
                    .delete()
                    .flatMap {
                        let token = try Token.generate(for: existingUser)
                        return token.save(on: req)
                }
            }
        }
    }
    
    func profile(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).toPublic()
    }
    
    func all(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    
    func register(_ req: Request) throws -> Future<User.Public> {
        return try req.content.decode(User.self).flatMap({
            return $0.save(on: req).toPublic()
        })
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap { todo in
            return todo.delete(on: req)
            }.transform(to: .ok)
    }
    
    func update(_ req: Request) throws -> Future<User.Public> {
        return try flatMap(to: User.Public.self, req.parameters.next(User.self), req.content.decode(User.self)) { (user, updatedUser) in
            user.nickname = updatedUser.nickname
            user.password = updatedUser.password
            return user.save(on: req).toPublic()
        }
    }
}
