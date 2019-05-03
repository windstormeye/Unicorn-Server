//
//  UserController.swift
//  App
//
//  Created by PJHubs on 2019/4/30.
//

import Vapor
import Authentication

/// Sticker 增删改查操作控制器
final class UserController: RouteCollection {
    
    func boot(router: Router) throws {
        let userRouter = router.grouped("api", "user")
        
        // 正常路由
        let userController = UserController()
        router.post("register", use: userController.register)
        router.post("login", use: userController.login)
        
        // `tokenAuthMiddleware` 该中间件能够自行寻找当前 `HTTP header` 的 `Authorization` 字段中的值，并取出与该 `token` 对应的 `user`，并把结果缓存到请求缓存中供后续其它方法使用
        // 需要进行 `token` 鉴权的路由
        let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
        let authedRoutes = userRouter.grouped(tokenAuthenticationMiddleware)
        authedRoutes.get("profile", use: userController.profile)
        authedRoutes.get("logout", use: userController.logout)
        authedRoutes.get("", use: userController.all)
        authedRoutes.get("delete", use: userController.delete)
        authedRoutes.get("update", use: userController.update)
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
    
    func logout(_ req: Request) throws -> Future<HTTPResponse> {
        let user = try req.requireAuthenticated(User.self)
        return try Token
            .query(on: req)
            .filter(\Token.userId, .equal, user.requireID())
            .delete()
            .transform(to: HTTPResponse(status: .ok))
    }
    
    func profile(_ req: Request) throws -> Future<User.Public> {
        let user = try req.requireAuthenticated(User.self)
        return req.future(user.toPublic())
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
