#!/usr/bin/env python3

import sys
import argparse
import json

import apiai
import requests

def main():

    parser = argparse.ArgumentParser(description='Client for API.AI.')
    parser.add_argument('text', nargs='*', help="text")
    parser.add_argument('-a', '--access-token', dest='access_token', action='store', type=str, default=None, help='access token')
    parser.add_argument('-u', '--hass-url', dest='hass_url', action='store', type=str, default=None, help='callback url')
    parser.add_argument('-p', '--hass-password', dest='hass_password', action='store', type=str, default=None, help='callback password')

    args = parser.parse_args()

    if len(args.text) == 0:
        parser.print_usage()
        sys.exit(1)

    text = " ".join(args.text)

    print(">%s" % text)
    ai = apiai.ApiAI(args.access_token)

    request = ai.text_request()
    request.lang = 'es'  # default: 'en'
    request.session_id = "homeassistant"
    request.query = text

    response = request.getresponse()
    data = response.read().decode("utf-8")
    #print(data)

    result = json.loads(data)

    if result["status"]["code"] == 200:

        speech = ""

        for m in result["result"]["fulfillment"]["messages"]:
            speech = speech + m['speech'] + "\n\n"
            print(m['speech'])

            if args.hass_url:

                url = '%s/api/services/script/apiai_response' % args.hass_url
                headers = {'x-ha-access': args.hass_password,
                           'content-type': 'application/json'}
                data = { 'notify_text': speech }

                response = requests.post(url, headers=headers, data=json.dumps(data))

                #print("*%s" % response.text)

if __name__ == '__main__':
    main()

