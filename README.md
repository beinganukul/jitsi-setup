# azure ansible docker-compose traefik setup
i use this ansible playbook to quickly setup own jitsi server mainly for 1080p 30fps screen sharing with friends. This setup is IPv6 enabled. 

# requirements
- azure credit (i got mine from bkmc.tu.edu.np email address)
- domain name with cloudflare as authoritative DNS
# usage
one has to setup
```
~/.azure/credentials
```
to be able to create azure resources
```
/etc/ansible/hosts
```
to ssh on machine and run commands to bring jitsi server up and running

## starting ansible playbook
```
ansible-playbook main.yml
```
if everything goes smoothly jitsi would be up and running at https://jitsi.anukul.com.np
## removing/deleting azure resource group
```
ansible-playbook delete_rg.yml --extra-vars "name=<resource group name>"
```
# todo
- add support for csgo server
- write detailed blog post
