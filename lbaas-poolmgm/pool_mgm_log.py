import calendar
from datetime import datetime

def parse_mgm(logger, line):

    date, sep, data = line.rpartition(':')

    date = datetime.strptime(date, '%Y-%m-%d %H:%M:%S,%f')
    date = calendar.timegm(date.timetuple())

    if 'ERROR' in line:
        return ('Node build errors', date, 1, {'metric_type': 'gauge', 'unit': 'errors'})

    if 'Adding node' in line:
        return ('Node build errors', date, 0, {'metric_type': 'gauge', 'unit': 'errors'})

    if 'No new nodes required' in line:
        metric_value = 0
        metric_name = 'Nodes required'
        metric_attr = {'metric_type': 'gauge', 'unit': 'nodes'}
        return (metric_name, date, metric_value, metric_attr)

    if 'attempting to build' not in line:
        return None

    data_parts = data.split()
    metric_value = int(data_parts[11])
    metric_name = 'Nodes required'
    metric_attr = {'metric_type': 'gauge', 'unit': 'nodes'}

    return (metric_name, date, metric_value, metric_attr)


def test():
    # Set up the test logger
    import logging
    logging.basicConfig(level=logging.DEBUG)

    # Set up the test input and expected output
    test_input = "2013-03-04 21:02:04,581: libra_mgm - INFO - 1 nodes already building, attempting to build 5 more"
    expected = (
        "Nodes required",
        1362430924,
        5,
        {"metric_type": "gauge",
         "unit":        "nodes" }
    )

    # Call the parse function
    actual = parse_mgm(logging, test_input)

    # Validate the results
    assert expected == actual, "%s != %s" % (expected, actual)

    test_input = "2013-03-05 15:38:37,322: libra_mgm - ERROR - Error creating node, exception <class 'novaclient.exceptions.OverLimit'>, node bdfd8e2e-85aa-11e2-9ac7-02163e75a432"
    expected = (
        "Node build errors",
        1362497917,
        1,
        {"metric_type": "gauge",
         "unit":        "errors" }
    )
    actual = parse_mgm(logging, test_input)

    # Validate the results
    assert expected == actual, "%s != %s" % (expected, actual)

    print 'test passes'


if __name__ == '__main__':
    # For local testing, callable as "python /path/to/parsers.py"
    test()

