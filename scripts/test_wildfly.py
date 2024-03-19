#!/usr/bin/env python3

# Copyright © End Point Corporation
# License: BSD 2-clause

import sys
import requests

# TODO: Maybe, grep these from /etc/apache2/sites-enabled/1-ksepitrax.org.conf
#SERVERS = [1, 3, 4, 5, 6]
SERVERS = ['127.0.0.1:8080']
URL = 'http://{server}/nedss/admin/rest/RestEJB/getWorkflows'

SERVER_COMMENT = """
        BalancerMember "http://127.0.0.1:8080/nedss" route=1 loadfactor=1
"""

def check_single_server(server):
    headers = {'UID': '9999'}
    #cookies = {'ROUTEID': '.{}'.format(num)}
    cookies = {}
    msgs = []

    # Requests says it should follow redirects
    # https://3.python-requests.org/user/quickstart/#redirection-and-history
    try:
        r = requests.get(URL.format(server=server), cookies=cookies, headers=headers, timeout=3)
    except requests.exceptions.ConnectionError as e:
        msgs.append(str(e))
        return msgs

    if r.status_code != 200:
        msgs.append('Wrong status code ({})'.format(r.status_code))
    #if 'ROUTEID=.{}'.format(num) not in r.headers['X-Route-Stuff']:
    #    msgs.append('Switched to another server. This server may be down.')
    elif '<nedssHealth>' not in r.text:
        msgs.append('Incorrect response data')

    return msgs

def check_servers(server_numbers):
    results = []
    error = False

    for num in server_numbers:
        server_results = check_single_server(num)
        if len(server_results) > 0:
            error = True
            results.append('Server {}: {}'.format(
                num,
                ', '.join(server_results)
            ))
        else:
            results.append('Server {}: OK'.format(
                num,
                ', '.join(server_results)
            ))

    print(', '.join(results))
    if error:
        sys.exit(1)

if __name__ == '__main__':
    check_servers(SERVERS)
