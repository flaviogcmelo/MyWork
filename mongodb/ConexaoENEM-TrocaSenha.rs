
mongodb://enem_app:enem_app@172.29.16.214:27017,172.29.16.215:27017,172.29.16.218:27017/enem
mongodb://enem_administrador_app:enem_administrador_app@172.29.16.214:27017,172.29.16.215:27017,172.29.16.218:27017/enem


use enem
db.updateUser("enem_app",{pwd: passwordPrompt() })
db.updateUser("enem_administrador_app",{pwd:"enem_administrador_app"})