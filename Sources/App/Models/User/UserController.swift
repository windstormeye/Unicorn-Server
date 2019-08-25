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
        // router.grouped 按顺序接在后面 例如：
        // http://localhost:8080/api/user/
        let userRouter = router.grouped("api", "user")
        
        // 正常路由。初始化需要用到的控制器。
        let userController = UserController()
        // 例如：此处就为 http://localhost:8080/api/user/register。浏览器就会访问registerd方法
        router.post("register", use: userController.register) //访问register用户注册方法
        router.post("login", use: userController.login) //访问登录方法
        
        // `tokenAuthMiddleware` 该中间件能够自行寻找当前 `HTTP header` 的 `Authorization` 字段中的值，并取出与该 `token` 对应的 `user`，并把结果缓存到请求缓存中供后续其它方法使用
        // 需要进行 `token` 鉴权的路由。
        let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
        let authedRoutes = userRouter.grouped(tokenAuthenticationMiddleware)
        // “profile”各种路由字段名
        authedRoutes.get("profile", use: userController.profile)//profile 简介
        authedRoutes.get("logout", use: userController.logout)
        // 空白： http://localhost:8080/api/user
        authedRoutes.get("", use: userController.all)
        authedRoutes.get("delete", use: userController.delete)
        authedRoutes.get("update", use: userController.update)
    }

    // 登入 路由处理方法
    func login(_ req: Request) throws -> Future<Token> {
        //  请求 内容 解码
        return try req.content.decode(User.self).flatMap { user in
            // 用户表.查询 判断phoneNumber是否等于传入的user的phoneNumber...
            //    注：filter取出的是个数组，取出的这个集合中的first。通过flatMap拿到编码完的值，拿到$0
            return User.query(on: req).filter(\.phoneNumber == user.phoneNumber).filter(\.password == user.password).first().flatMap {
                // 判空。直接用存在的User。existingUser
                guard let existingUser = $0 else {
                    // 调用系统notFond -> 系统显示为：Not Found
                    throw Abort(HTTPStatus.notFound)
                }
                
                // 覆盖。用户登录其他设备时“覆盖”上一个设备Token
                return try Token
                    .query(on: req)//查询
                    .filter(\Token.userId, .equal, existingUser.requireID())//对比是否有已存在的
                    .delete()//有已存在的，则删除
                    .flatMap {//创建一个新的token返回
                        // 用generate方法，生成随机字符串
                        let token = try Token.generate(for: existingUser)
                        // 保存 返回内容
                        return token.save(on: req)
                }
            }
        }
    }
    
    //退出登录
    func logout(_ req: Request) throws -> Future<HTTPResponse> {
        let user = try req.requireAuthenticated(User.self)
        return try Token
            .query(on: req)
            .filter(\Token.userId, .equal, user.requireID())
            .delete()
            .transform(to: HTTPResponse(status: .ok))
    }
    
    // 返回用户简介（需要用结构体包装用户信息）
    func profile(_ req: Request) throws -> Future<User.Public> {
        let user = try req.requireAuthenticated(User.self)
        return req.future(user.toPublic())
    }
    
    // 返回所有用户
    func all(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).decode(data: User.Public.self).all()
    }
    
    // 注册（把写入数据库的内容返回，则表示用户注册成功）
    func register(_ req: Request) throws -> Future<User.Public> {
        // 把当前的请求内容进行编码（编码的格式是通过User的格式完成的，id、phoneNumber等）。用flatMap才能使用$0
        return try req.content.decode(User.self).flatMap({
            // 取到$0 保存，调用toPublic方法，对用户信息作处理
            return $0.save(on: req).toPublic()
        })
    }
    
    //删除
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).flatMap {
            return $0.delete(on: req)
            }.transform(to: .ok)
    }
    
    //更新
    func update(_ req: Request) throws -> Future<User.Public> {
        return try flatMap(to: User.Public.self, req.parameters.next(User.self), req.content.decode(User.self)) { (user, updatedUser) in
            user.nickname = updatedUser.nickname
            user.password = updatedUser.password
            return user.save(on: req).toPublic()
        }
    }
}
