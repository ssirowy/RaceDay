from flask import Flask

from flask import (flash, g, session, redirect, url_for, request, abort, make_response, 
                   current_app, jsonify, render_template, after_this_request)

import traceback
import os
import pprint

import datetime
import json

import requests

from datetime import timedelta
from functools import wraps, update_wrapper

application = app = Flask(__name__)

pp = pprint.PrettyPrinter()

def crossdomain(origin=None, methods=None, headers=None,
                max_age=21600, attach_to_all=True,
                automatic_options=True):
    '''
    Decorator that allows for CORS (Cross Origin Resource Sharing).

    Shamelessly copied from http://flask.pocoo.org/snippets/56/.
    '''
    if methods is not None:
        methods = ', '.join(sorted(x.upper() for x in methods))
    if headers is not None and not isinstance(headers, basestring):
        headers = ', '.join(x.upper() for x in headers)
    if not isinstance(origin, basestring):
        origin = ', '.join(origin)
    if isinstance(max_age, timedelta):
        max_age = max_age.total_seconds()

    def get_methods():
        if methods is not None:
            return methods

        options_resp = current_app.make_default_options_response()
        return options_resp.headers['allow']

    def decorator(f):
        def wrapped_function(*args, **kwargs):
            if automatic_options and request.method == 'OPTIONS':
                resp = current_app.make_default_options_response()
            else:
                resp = make_response(f(*args, **kwargs))
            if not attach_to_all and request.method != 'OPTIONS':
                return resp

            h = resp.headers

            h['Access-Control-Allow-Origin'] = origin
            h['Access-Control-Allow-Methods'] = get_methods()
            h['Access-Control-Max-Age'] = str(max_age)
            if headers is not None:
                h['Access-Control-Allow-Headers'] = headers
            return resp

        f.provide_automatic_options = False
        return update_wrapper(wrapped_function, f)
    return decorator

@app.route('/')
def home():
    
    # Get M2X data.
    r = requests.get('http://api-m2x.att.com/v2/devices/22e4f54c8e379e17f89e7adc2ecebf9e/streams',
                     headers={ 'X-M2X-KEY' : 'f778c23e3d8e5dec33674dd2fa21c5b1' })
    pp.pprint(r.json())

    
    r = requests.get('http://api-m2x.att.com/v2/devices/22e4f54c8e379e17f89e7adc2ecebf9e/streams/ssirowy_race4/stats',
                     headers={ 'X-M2X-KEY' : 'f778c23e3d8e5dec33674dd2fa21c5b1' })
    pp.pprint(r.json())
    
    return render_template('home.html')

@app.route('/race/<int:race_id>')
def get_race(race_id):
    race_id = str(race_id)

    couchbase_host = 'http://104.131.187.45:4984'
    m2x_host = 'http://api-m2x.att.com/v2/devices/22e4f54c8e379e17f89e7adc2ecebf9e'

    r = requests.get(couchbase_host + '/default/' + race_id)

    race = r.json()

    users = []
    for user in race['users']:
        r = requests.get(couchbase_host + '/default/' + user['email'])
        user_metadata = r.json()

        del user_metadata['password']

        users.append({ 'user' : user_metadata,
                       'data' : user['data'] })

    # Gather M2X info for each racer.
    

    return jsonify(users=users)

if __name__ == '__main__':
    port = os.getenv('VCAP_APP_PORT', '5000')
    app.run(debug=True, host='0.0.0.0', port=int(port))
    # app.run(host='0.0.0.0', port=int(port))

