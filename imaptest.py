#!/usr/bin/python

import imaplib
import getpass

#IMAP_SERVER='pop.free.fr'
IMAP_PORT=143
IMAP_SERVER = raw_input('Enter imap server: ')
IMAP_LOGIN = raw_input('Enter login: ')

IMAP_PASS = getpass.getpass('Enter password: ')

imap_cnx = imaplib.IMAP4(IMAP_SERVER, IMAP_PORT)
res = imap_cnx.login(IMAP_LOGIN, IMAP_PASS)
print res

