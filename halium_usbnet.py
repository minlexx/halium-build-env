#!/usr/bin/python3
import argparse
import os
import re
from subprocess import run, PIPE, STDOUT
import sys
import time


def list_network_interfaces() -> list:
    devs = []
    basedir = '/sys/class/net'
    for f in os.listdir(basedir):
        path = basedir + '/' + f
        st = os.stat(path, follow_symlinks=False)
        if st.st_nlink == 1:
            devs.append(f)
    return devs


def find_usb_rndis_dev() -> str:
    net_interfaces = list_network_interfaces()
    rndis_candidates = []
    for d in net_interfaces:
        if d.startswith('enp'):
            if 'u' in d:
                rndis_candidates.append(d)
    if len(rndis_candidates) == 1:
        return rndis_candidates[0]
    if len(rndis_candidates) == 0:
        raise RuntimeError('Could not find USB RNDIS device \"enp*u*\" among: ' + str(net_interfaces))
    # cannot automatically select which device to use
    raise RuntimeError('Cannot automatically choose device between: ' + str(rndis_candidates))


def get_device_mac_address(dev: str) -> str:
    addr_fn = '/sys/class/net/{}/address'.format(dev)
    try:
        with open(addr_fn, 'rt') as f:
            mac = f.read()
            f.close()
            return mac.strip()
    except IOError:
        print('Failed to get {} mac address!'.format(dev), file=sys.stderr)
    return '00:00:00:00:00:00'


def main():
    parser = argparse.ArgumentParser(description='Halium network setup helper.')
    parser.add_argument('--usbrndis', action='store_true')
    parser.add_argument('--check_mac', action='store_true')
    parser.add_argument('--ssh', action='store', nargs='?', default='', choices=['halium', 'pmos'])
    parser.add_argument('--telnet', action='store', nargs='?', default='', choices=['halium', 'pmos'])

    # s = run('dmesg | tail', check=False, stdout=PIPE, stderr=PIPE, shell=True)
    # print(s.stdout)

    args = parser.parse_args()

    if args.usbrndis:
        print(find_usb_rndis_dev())

    mac_was_fixed = False
    if args.check_mac:
        dev = find_usb_rndis_dev()
        mac = get_device_mac_address(dev)
        print('Mac: {}'.format(mac))
        if mac == '00:00:00:00:00:00':
            print('Fixing...')
            os.system('sudo ip link set {} address 02:01:02:03:04:08'.format(dev))
            mac_was_fixed = True
            print('(waiting for 3 seconds for possible DHCP address assignment)')
            time.sleep(3)

    if args.ssh != '':
        if mac_was_fixed:
            time.sleep(2)
        if args.ssh == 'halium':
            os.system('ssh phablet@10.15.19.82')
        elif args.ssh == 'pmos':
            os.system('ssh user@172.16.42.1')
        sys.exit(0)

    if args.telnet != '':
        if mac_was_fixed:
            time.sleep(2)
        if args.telnet == 'halium':
            os.system('telnet 192.168.2.15')
        elif args.telnet == 'pmos':
            os.system('telnet 172.16.42.1')
        sys.exit(0)


if __name__ == '__main__':
    main()
