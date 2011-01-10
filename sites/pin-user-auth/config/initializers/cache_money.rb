# 针对user的email字段做缓存
User.index :email
# 针对organization的email字段做缓存
Organization.index :email
