#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 softtabstop=4

import os
import uuid
import struct
import time
import base64

def generate_auth_key():
    key = os.urandom(16)
    header = struct.pack('<hiih',
            1,  # le16 type: CEPH_CPYPTO_AES
            int(time.time()), # le32 created: seconds
            0,  # le32 created: nanoseconds,
            len(key), # le16: len(key)
            )
    return base64.b64encode(header + key)

def generate_uuid():
    return uuid.uuid1()

if __name__ == '__main__':
    print "auth_key:%s" % generate_auth_key()
    print "fsid:%s" % generate_uuid()
