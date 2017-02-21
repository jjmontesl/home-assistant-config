#!/usr/bin/env python3

import sys
import argparse
import json

import apiai

def main():

    parser = argparse.ArgumentParser(description='Client for API.AI.')
    parser.add_argument('text', nargs='*', help="text")
    parser.add_argument('-a', '--access-token', dest='access_token', action='store', type=str, default=None, help='access token')

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

        for m in result["result"]["fulfillment"]["messages"]:
            print(m['speech'])

if __name__ == '__main__':
    main()

