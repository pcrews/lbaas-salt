import calendar
from datetime import datetime

def parse_admin_api(logger, line):

    date = line[:23]

    date = datetime.strptime(date, '%Y-%m-%d %H:%M:%S,%f')
    date = calendar.timegm(date.timetuple())

    if 'ERROR' in line:
        return ('lbaas.admin_api.error', date, 1, {'metric_type': 'counter', 'unit': 'errors'})

    if 'OFFLINE loadbalancers' in line:
        data_parts = line.split()
        if len(data_parts) < 6:
            return None
        try:
            offline = int(data_parts[6])
            failed = int(data_parts[10])
        except ValueError:
            return None
        metric_attr = {'metric_type': 'gauge', 'unit': 'devices'}
        ret = [
            (
                'lbaas.admin_api.offline_devices', date, offline,
                metric_attr
            ),
            (
                'lbaas.admin_api.offline_failed', date, failed,
                metric_attr
            )
        ]
        return ret
    if 'loadbalancers pinged' in line:
        data_parts = line.split()
        if len(data_parts) < 6:
            return None
        try:
            pinged = int(data_parts[6])
            failed = int(data_parts[9])
        except ValueError:
            return None
        metric_attr = {'metric_type': 'gauge', 'unit': 'loadbalancers'}
        ret = [
            (
                'lbaas.admin_api.loadbalancers_pinged', date, pinged,
                metric_attr
            ),
            (
                'lbaas.admin_api.loadbalancers_failed', date, failed,
                metric_attr
            )
        ]
        return ret


def test():
    # Set up the test logger
    import logging
    logging.basicConfig(level=logging.DEBUG)

    # Set up the test input and expected output
    test_input = '2013-11-14 05:45:50,865: root - INFO - 47 OFFLINE loadbalancers tested, 1 failed'
    expected = [
        (
            'lbaas.admin_api.offline_devices',
            1384407950,
            47,
            {
                'metric_type': 'gauge',
                'unit': 'devices'
            }
        ),
        (
            'lbaas.admin_api.offline_failed',
            1384407950,
            1,
            {
                'metric_type': 'gauge',
                'unit': 'devices'
            }
        )
    ] 

    # Call the parse function
    actual = parse_admin_api(logging, test_input)

    # Validate the results
    assert expected == actual, "%s != %s" % (expected, actual)

    test_input = '2013-11-14 05:45:17,628: root - INFO - 26 loadbalancers pinged, 0 failed'
    expected = [
        (
            'lbaas.admin_api.loadbalancers_pinged',
            1384407917,
            26,
            {
                'metric_type': 'gauge',
                'unit': 'loadbalancers'
            }
        ),
        (
            'lbaas.admin_api.loadbalancers_failed',
            1384407917,
            0,
            {
                'metric_type': 'gauge',
                'unit': 'loadbalancers'
            }
        )
    ]


    # Call the parse function
    actual = parse_admin_api(logging, test_input)

    # Validate the results
    assert expected == actual, "%s != %s" % (expected, actual)

    print 'test passes'

if __name__ == '__main__':
    # For local testing, callable as "python /path/to/parsers.py"
    test()

