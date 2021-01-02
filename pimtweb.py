#!/usr/bin/python
#
# -*- coding: UTF-8 -*-
#
# web.py
#
# pimt project
#
# simple web server for displaying infrastructure updates
#
# note: runs on network interface (0.0.0.0) by default
#
# deps
# > pip install flask flask-autoindex
#

import os
import sys
import argparse
from flask import Flask
from flask_autoindex import AutoIndex

DEFAULT_HOST = '0.0.0.0'
DATA_DIR = 'data'
#DIFF_DIR = DATA_DIR + '/' + 'diff'

app = Flask(__name__)
AutoIndex(app, browse_root=DATA_DIR)

class PimtWeb(object):
    def __init__(self, args):
        self.host = args.host
        self.port = args.port

    def run(self):
        os.environ['WERKZEUG_RUN_MAIN'] = 'true'

        result = app.run(host=self.host, port=self.port)

        return result

def arg_parse():
    parser = argparse.ArgumentParser(add_help=False)

    parser.add_argument("-h",
                        "--host",
                        type=str,
                        default=DEFAULT_HOST,
                        help="Listen on localhost or network/0.0.0.0 (default)")

    parser.add_argument("-p",
                        "--port",
                        type=int,
                        default=8080,
                        help="Port for incoming connections")

    args = parser.parse_args()

    return args

def main():
    args = arg_parse()

    pw = PimtWeb(args)

    result = pw.run()

    if(result == None):
        sys.exit(-1)

    return 0

if(__name__ == '__main__'):
    main()
