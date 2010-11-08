#!/usr/bin/python

import poplib
import getpass

#POP_SERVER='pop.free.fr'
POP_PORT=110
POP_SERVER = raw_input('Enter pop server: ')
POP_LOGIN = raw_input('Enter login: ')

POP_PASS = getpass.getpass('Enter password: ')

pop_cnx = poplib.POP3(POP_SERVER, POP_PORT)
pop_cnx.user(POP_LOGIN)
try:
    res = pop_cnx.pass_(POP_PASS)
except poplib.error_proto:
    print "Auth failed"
else:
	print res

