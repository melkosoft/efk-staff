from os import getenv
from os import path
from os import remove
from time import sleep
from subprocess import call
from requests import get


def main():
    '''Watch for termination notices on spot instance nodes on AWS'''
    print('Starting up')
    print("Restoring database from latest backup")
    command = "/home/user/restoreDatabase.sh"
    result = call(command)
    if result != 0:
       print('Restore failed!')
    node_name = getenv('NODE_NAME')
    print('Watching for termination notice on node %s' % node_name)
    counter = 0

    while True:
        if path.exists("/home/user/alert.txt"):
            remove("/home/user/alert.txt")
            command = "/home/user/dumpDatabase.sh"
            print("Backing up database on node: %s" % node_name)
            result = call(command)
            if result == 0:
                print('Backup was successful')
                break

        response = get(
            "http://169.254.169.254/latest/meta-data/spot/termination-time"
        )
        if response.status_code == 200:
            command = "/home/user/dumpDatabase.sh"
            print("Backing up database on node: %s" % node_name)
            result = call(command)
            if result == 0:
                print('Backup was successful')
                break

        else:
            if counter == 60:
                counter = 0
                print("Termination notice status: %s, on Node: %s" %
                      (response.status_code, node_name)
                      )
            counter += 5
            sleep(5)


if __name__ == '__main__':
    main()
