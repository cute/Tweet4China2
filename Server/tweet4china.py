#!/usr/bin/env python


import web, base64 as b64, httplib, urlparse

class proxy(object):
    
    def GET(self):
        return 'TWProxy is Working!'
    
    def POST(self):
        req_parameters = web.input()
        method = req_parameters['method']
        url = b64.decodestring(req_parameters['encoded_path'])
        header = b64.decodestring(req_parameters['headers'])
        body = b64.decodestring(req_parameters['postdata'])
        
        (scm, netloc, path, params, query, fragment) = urlparse.urlparse(url)
        if scm == 'http':
            conn = httplib.HTTPConnection(netloc)
        else:
            conn = httplib.HTTPSConnection(netloc)
        
        uri = '/'
        parts = url.split('/')
        if len(parts) > 3:
            uri += '/'.join(parts[3:])
        
        headers = {}
        for line in header.splitlines():
            parts = line.split(':')
            if len(parts) > 1:
                name = parts[0]
                value = ':'.join(parts[1:])
            headers[name] = value
        
        conn.request(method, uri, body, headers)
        resp = conn.getresponse()
        resp_body = resp.read()
        output_body = b64.encodestring(resp_body)
        web.header('Content-Type', 'text/html')
        return output_body


web.config.debug = False

urls = (
    '/.*', 'proxy',
     )

app = web.application(urls, globals())

if __name__ == '__main__':
  app.run()
