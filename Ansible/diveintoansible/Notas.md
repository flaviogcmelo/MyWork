<<<<<<< HEAD
# Notas Curso Ansible
## Comando para validar as chaves geradas on hand shake e quando conectando por IP 

*'ssh-keygen -H -F unbutu1'* 


## Testar o funcionamento do Docker
-- sobe uma imagem do ubuntu apenas com o terminal. Ao final a imagem é excluída com -rm
docker run -it -rm ubuntu bash


sudo apt install sshpass

echo password > password.txt
```shell
for user in ansible root 
do
  for os in ubuntu centos 
  do
    for instance in 1 2 3 
    do
      sshpass -f password.txt ssh-copy-id -o StrictHostKeyChecking=no ${user}@${os}${instance}
    done
  done
done

ansible -i,ubuntu1,ubuntu2,ubuntu3,centos1,centos2,centos3 all -m ping
```
>>>>>>> 5fd0232988921f8d203ffb112ace48962854a9d9

rm .ssh/known_hosts
