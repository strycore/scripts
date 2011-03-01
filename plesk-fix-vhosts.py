#!/usr/bin/python
import re, shutil, os
import os.path

vhost_conf_list_path = "/opt/psa/admin/conf/vhosts_bootstrap.conf"
vhost_conf_list = open(vhost_conf_list_path, "r")
server_name_re = re.compile(".*?ServerName.*?\"(.*?):\d+\"")
server_alias_re = re.compile(".*?ServerAlias.*?")
vhost_conf_re = re.compile("Include '(.*?)'")

for vhost_conf in vhost_conf_list.readlines():
    num_server_name = 0
    num_server_alias = 0
    match =vhost_conf_re.match(vhost_conf)
    if match:
        vhost_conf_path = match.group(1)
    else:
        continue
    vhost_conf = open(vhost_conf_path, "r")
    vhost_contents = vhost_conf.readlines()
    vhost_conf.close()
    # Uncomment the following lines to make a backup of you vhosts
    #vhost_filename = os.path.basename(vhost_conf_path)
    #vhost_dir = os.path.dirname(vhost_conf_path)
    #domain = vhost_dir.split('/')[-2]
    #if domain == 'conf':
    #    continue
    #print domain
    #os.mkdir(os.path.join('/root/vhosts/', domain))
    #shutil.copyfile(vhost_conf_path, os.path.join('/root/vhosts', domain,  vhost_filename))
    #continue
    for vhost_line in vhost_contents:
        server_match = server_name_re.match(vhost_line)
        if server_match:
            hostname = server_match.group(1)
            num_server_name += 1
        alias_match = server_alias_re.match(vhost_line)
        if alias_match:
            num_server_alias += 1
    if num_server_alias == num_server_name:
        continue
    for index in range(len(vhost_contents) - 1):
        server_match = server_name_re.match(vhost_contents[index])
        alias_match = server_alias_re.match(vhost_contents[index + 1])
        if server_match and not alias_match:
            vhost_contents.insert(index + 1, "    ServerAlias www.%s\n" % hostname)
    vhost_conf = open(vhost_conf_path, "w")
    for line in vhost_contents:
        vhost_conf.write(line)
    vhost_conf.close()

