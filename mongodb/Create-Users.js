use enem; 
db.createUser ({ user: "enem_app" , 
                  pwd: "*&n#B2AsU$nD9ExZ" , 
                roles: [ { role: "readWrite" , 
                             db: "enem" } ] });

db.createUser ({ user: "enem_administrador_app" , 
                  pwd: "7tvYW7@aRhV7A6s5",
                roles: [ { role: "readWrite" , 
                             db: "enem" } ] });