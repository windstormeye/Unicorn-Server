import Vapor
import FluentMySQL
import Authentication

/// 应用初始化完会被调用
public func configure(_ config: inout Config,
                      _ env: inout Environment,
                      _ services: inout Services) throws {
    var commands = CommandConfig.default()
    commands.useFluentCommands()
    services.register(commands)
    
    // 数据库
    try services.register(FluentMySQLProvider())
    // 权限认证
    try services.register(AuthenticationProvider())

    // 注册路由到路由器中进行管理
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // 注册中间件
    // 创建一个中间件配置文件
    var middlewares = MiddlewareConfig()
    // 错误中间件。捕获错误并转化到 HTTP 返回体中
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)
    // 配置 MySQL 数据库
    let mysql = MySQLDatabase(config: MySQLDatabaseConfig(hostname: "localhost", port: 3306, username: "unicorn", password: "unicorn_2019", database: "unicorn_db", capabilities: .default, characterSet: .utf8mb4_unicode_ci, transport: .unverifiedTLS))

    // 注册 SQLite 数据库配置文件到数据库配置中心
    var databases = DatabasesConfig()
    databases.add(database: mysql, as: .mysql)
    services.register(databases)

    // 配置迁移文件。相当于注册表
    var migrations = MigrationConfig()
    migrations.add(model: Sticker.self, database: .mysql)
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: Token.self, database: .mysql)
    
    migrations.add(migration: AddUserMss.self, database: .mysql)
    
    services.register(migrations)
}
