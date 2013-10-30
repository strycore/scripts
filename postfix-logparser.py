#!/usr/bin/python

"""
This scripts reads postfix logfile in /var/log/mail.info and stores the results
in a MySQL database.

Copyright: 2010, Mathieu Comandon <strycore@gmail.com>
License : GPL-V3

CREATE TABLE IF NOT EXISTS `mail_tracking` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `from_` varchar(255) NOT NULL,
      `to_` varchar(255) DEFAULT NULL,
      `relay` varchar(255) NOT NULL,
      `delay` varchar(10) NOT NULL,
      `delays` varchar(32) NOT NULL,
      `orig_to` varchar(255) DEFAULT NULL,
      `dsn` varchar(32) DEFAULT NULL,
      `message_id` varchar(127) NOT NULL,
      `size` int(11) DEFAULT NULL,
      `status_` varchar(1024) NOT NULL,
      `bounce_message` varchar(255) DEFAULT NULL,
      `timestamp` datetime DEFAULT NULL,
      `nrcpt` varchar(64) NOT NULL,
      `client` varchar(128) DEFAULT NULL,
      `sasl_method` varchar(128) DEFAULT NULL,
      `sasl_username` varchar(128) DEFAULT NULL,
      `conn_use` varchar(128) DEFAULT NULL,
      PRIMARY KEY (`id`)
    ) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

"""
import os
import sys
import datetime
import re
import MySQLdb
import logging
import stat

def get_inode(path):
    """
    Return the inode of a file
    """
    stat = os.stat(path)
    return stat.st_ino

LOG_PATH = sys.path[0]
LOGFILE = os.path.join(LOG_PATH, 'postfix-parse.log')
config_file = os.path.join(LOG_PATH, 'postfix-parse.cnf') #TODO : use this file to store mysql info
log_prefix = '/var/log'
postfix_log = os.path.join(log_prefix, 'mail.info.0')

logging.basicConfig(filename=LOGFILE, level=logging.DEBUG)
now = datetime.datetime.now()
logging.debug(
        'New analysis of postfix logs at %d:%d:%d' %
        (now.hour, now.minute, now.second)
    )

stat = os.stat(postfix_log)

logging.info('Filename: %s' % postfix_log)
logging.info('Inode: %s' % stat.st_ino)
logging.info(
        'Last modified: %s' % datetime.datetime.fromtimestamp(
            stat.st_mtime
        ).isoformat(' ')
    )
MYSQL_USER = 'mailing'
MYSQL_PASSWORD = 'mailinga2v'
MYSQL_DATABASE = MYSQL_USER
MYSQL_HOST = 'localhost'
MYSQL_TABLE = 'mail_tracking'

table_fields = ('id', 'from', 'to', 'relay', 'delay', 'delays',
        'orig_to', 'dsn', 'message_id', 'size', 'status', 'bounce_message',
        'timestamp', 'nrcpt', 'client', 'sasl_method', 'sasl_username',
        'conn_use', 'mailing_id', 'created_at', 'updated_at' )

maillog = open(postfix_log, 'r').readlines()
mailinfo = {}
for line in maillog:
    line_parsed = False
    line = line[:-1] #remove \n character

    #Separate the date and hostname from the rest
    while line.find('  ') != -1:
        line = line.replace('  ', ' ')
    elems = line.split(' ',4)
    year = datetime.datetime.now().year
    event_date_str = ("%i %s %s %s" % (year, elems[0], elems[1], elems[2]))
    event_date = str(datetime.datetime.strptime(event_date_str, "%Y %b %j %H:%M:%S"))

    hostname = elems[3]
    postfix_details = elems[4]
    postfix_event = postfix_details.split(':', 2)
    if len(postfix_event) != 3:
        #these events are not logged to database (connection information, etc..)
        pass
    else:
        command = postfix_event[0]
        queue_id = postfix_event[1].strip()
        details = postfix_event[2]

        if not re.match('[A-Z0-9]{10}', queue_id):
            #ignore events with an invalid queue_id
            #print "invalid queue id : " + queue_id
            continue

        # Create new key based on queue-id if it doesn't exists
        if not queue_id in mailinfo:
            mailinfo[queue_id] = {}
            mailinfo[queue_id]['timestamp'] = event_date

        if details.startswith(' message-id'):
            message_id = details[13:-1]
            mailinfo[queue_id]['message_id'] = message_id
            line_parsed = True
        if details.startswith(' from=') and command.startswith('postfix/qmgr'):
            (email_from, size, nrcpt) = details.split(',',3)
            mailinfo[queue_id]['from'] = email_from[6:]
            mailinfo[queue_id]['size'] = size[6:]
            mailinfo[queue_id]['nrcpt'] = nrcpt[7:]
            line_parsed = True


        #Ignore useless postfix commands
        if details.startswith(' removed') and command.startswith('postfix/qmgr'):
            pass #Ignore this line
            line_parsed = True
        if details.startswith(' uid') and command.startswith('postfix/pickup'):
            pass #Ignore this line
            line_parsed = True

        if command.startswith('postfix/smtp') or command.startswith('postfix/local'):
            elems = details.split(', ')
            if len(elems) > 1:
                for elem in elems:
                    index = elem.find('=')
                    key = elem[0:index].strip()
                    val = elem[index+1:].strip()
                    if key in table_fields:
                        mailinfo[queue_id][key] = val
                    else:
                        print 'invalid key : ' + key
            line_parsed = True
        if command.startswith("postfix/bounce"):
            mailinfo[queue_id]['bounce_message'] = details.strip()
            line_parsed = True

        #rename reserved mysql keywords
        if 'status' in  mailinfo[queue_id]:
            mailinfo[queue_id]['status_'] = mailinfo[queue_id]['status']
            del mailinfo[queue_id]['status']
        if 'from' in  mailinfo[queue_id]:
            mailinfo[queue_id]['from_'] = mailinfo[queue_id]['from']
            del mailinfo[queue_id]['from']
        if 'to' in  mailinfo[queue_id]:
            mailinfo[queue_id]['to_'] = mailinfo[queue_id]['to']
            del mailinfo[queue_id]['to']

        #print unparsed lines
        if not line_parsed:
            print postfix_event

conn = MySQLdb.connect(host=MYSQL_HOST,
                       user=MYSQL_USER,
                       passwd=MYSQL_PASSWORD,
                       db=MYSQL_DATABASE)
inserted = updated = 0

for queue_id in mailinfo:
    cursor = conn.cursor()
    usyn = lambda x : x + "=%s"

    if not 'message_id' in mailinfo[queue_id]:
        continue
    cursor.execute("SELECT message_id FROM mail_tracking WHERE `message_id` = %s",
                  mailinfo[queue_id]['message_id'])

    if cursor.rowcount == 0:
        #Creating new entry
        mailinfo[queue_id]['created_at'] = datetime.datetime.now().isoformat(' ')
        mailinfo[queue_id]['updated_at'] = datetime.datetime.now().isoformat(' ')
        keys = ", ".join(mailinfo[queue_id].keys())
        values = mailinfo[queue_id].values()
        s = []
        for i in range(len(values)):
            s.append('%s')
        q = r"""INSERT INTO mail_tracking (%s) VALUES (%s)""" % (keys, ", ".join(s))
        try:
            cursor.execute(q, tuple(values))
            conn.commit()
            inserted = inserted + 1
        except MySQLdb.ProgrammingError, e:
            logging.debug('Problem with : ')
            logging.debug(e, q , values)
        except TypeError,  e:
            logging.debug('Type error : ')
            logging.debug(e, q, values)
    elif cursor.rowcount == 1:
        #updating entry
        mailinfo[queue_id]['updated_at'] = datetime.datetime.now().isoformat(' ')

        q = """UPDATE %s SET %s WHERE `message_id` = %%s""" % (
                MYSQL_TABLE,
                ', '.join(map(lambda x: x + "=%s", mailinfo[queue_id]))
            )
        try:
            cursor.execute(
                    q,
                    tuple(mailinfo[queue_id].values())
                    + (mailinfo[queue_id]['message_id'],)
                )
            conn.commit()
        except:
            logging.debug('Problem updating this data ; ')
            logging.debug(mailinfo[queue_id])
        updated = updated + 1
print "entries inserted : %d " % inserted
print "entries updated : %d " % updated
conn.close()
