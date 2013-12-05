import calendar
from datetime import datetime

def parse_api(logger, line):

    date = line[:23]

    date = datetime.strptime(date, '%Y-%m-%d %H:%M:%S,%f')
    date = calendar.timegm(date.timetuple())

    if 'ERROR' in line:
        return ('lbaas.api.error', date, 1, {'metric_type': 'counter', 'unit': 'errors'})

    data_parts = line.split()
    if len(data_parts) < 17:
        return None

    try:
        resp_code = int(data_parts[14])
        resp_time = float(data_parts[16])
    except ValueError:
        return None
    if resp_code >= 200 and resp_code <= 299:
        metric_name = 'lbaas.api.codes.2XX'
    if resp_code == 400:
        metric_name = 'lbaas.api.codes.400'
    if resp_code == 401:
        metric_name = 'lbaas.api.codes.401'
    if resp_code == 404:
        metric_name = 'lbaas.api.codes.404'
    if resp_code == 413:
        metric_name = 'lbaas.api.codes.413'
    if resp_code == 500:
        metric_name = 'lbaas.api.codes.500'
    metric_attr = {'metric_type': 'counter', 'unit': 'responses'}
    ret = [
        (metric_name, date, 1, metric_attr),
        (
            'lbaas.api.resp_time', date, resp_time,
            {'metric_type': 'gauge', 'unit': 'time'}
        )
    ]
    return ret


def test():
    # Set up the test logger
    import logging
    logging.basicConfig(level=logging.DEBUG)

    # Set up the test input and expected output
    test_input = '2013-07-29 07:18:42,873: root - INFO - 15.185.163.106 - - [29/Jul/2013 07:18:42] "DELETE /v1.1/loadbalancers/None HTTP/1.1" 404 197 0.085673'
    expected = [(
        "lbaas.api.codes.404",
        1375082322,
        1,
        {"metric_type": "counter",
         "unit":        "responses" }
    ),
    (
        "lbaas.api.resp_time",
        1375082322,
        0.085673,
        {"metric_type": "gauge",
         "unit":        "time"}
    )]

    # Call the parse function
    actual = parse_api(logging, test_input)

    # Validate the results
    assert expected == actual, "%s != %s" % (expected, actual)

    print 'test passes'

if __name__ == '__main__':
    # For local testing, callable as "python /path/to/parsers.py"
    test()
