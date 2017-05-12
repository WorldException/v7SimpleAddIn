#coding: utf-8
from __future__ import unicode_literals
import chardet
import logging
logging.basicConfig(filename='test.log', level=logging.DEBUG)
print("start")
print("Привет".encode('cp1251'))
logging.info('starting')
#t = raw_input()
#print t
import sys
import locale
print('default enc:',sys.getdefaultencoding())
reload(sys)
sys.setdefaultencoding('utf-8')

while True:
    line = sys.stdin.readline().strip()
    logging.info(line.decode('cp1251'))
    print 'ret:', line, chardet.detect(line)

