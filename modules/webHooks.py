#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Generic webHooks support with urllib2"""

import urllib

class webHooks(object):
    baseurl = None
    requesturl = "None"
    payload = None
    headers = None
    method = 'GET'

    def setBaseUrl(self, string):
        self.baseurl = string

    def setRequestUrl(self, string):
        self.requesturl = string

    def setPayload(self, payload):
        self.payload = payload

    def setHeaders(self, headers):
        self.headers = headers

    def setMethod(self, string):
        self.method = string

    def doRequest(self):
        if self.baseurl == None:
            return False

        if self.requesturl == None:
            return False

        request = urllib.urlopen(self.baseurl + self.requesturl, self.payload)
        response = request.read()

        return response
