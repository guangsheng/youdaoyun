#! /usr/bin/env python
# -*- coding: utf-8 -*-

import smtplib
import sys
from smtplib import SMTP_SSL
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email.utils import COMMASPACE , formatdate
from email import Encoders
import os


def send_mail(mail_to , mail_from , subject , text , server="smtp.hellobike.com"):
    try:
        assert type(mail_to) == list

        msg = MIMEMultipart()
        msg['From'] = mail_from
        msg['To'] = COMMASPACE.join(mail_to)
        msg['Date'] = formatdate(localtime=True)
        msg['Subject'] = subject
        msg.attach(MIMEText(text , _subtype='html', _charset='utf-8'))

        smtp = SMTP_SSL(server)
        smtp.set_debuglevel(0)

        smtp.ehlo(server)
        smtp.login('shiguangsheng@hellobike.com' ,'Favy4tJuzLsEHnM5')
        smtp.sendmail(mail_from , mail_to , msg.as_string())
        smtp.quit()
    except Exception , e:
        print e


if __name__ == '__main__':
    content = sys.argv[1]
    send_mail(['tangguochang@hellobike.com','pengshaowei@hellobike.com']
              , 'notify <shiguangsheng@hellobike.com>'
              , u'数据结构变更通知!'
              , content)
