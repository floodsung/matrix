import argparse
import mc_sdk_zsl_1_py
import time

def main():
    parser = argparse.ArgumentParser(description='Robot control demo')
    parser.add_argument('--local-ip', default='127.0.0.1', help='Local IP address')
    parser.add_argument('--local-port', type=int, default=25003, help='Local port')
    parser.add_argument('--dog-ip', default='127.0.0.1', help='Dog IP address')
    parser.add_argument('--dog-port', type=int, default=25004, help='Dog port')
    
    args = parser.parse_args()
    
    app = mc_sdk_zsl_1_py.HighLevel()
    app.initRobot(args.local_ip, args.local_port, args.dog_ip, args.dog_port)
    app.standUp()
    time.sleep(4)
    app.move(0.3, 0, 0)
    time.sleep(4)
    app.move(0.3, 0, 0.3)
    time.sleep(5)
    app.move(0.0, 0, 0)
    time.sleep(4)
    app.jump()
    time.sleep(4)
    app.frontJump()
    time.sleep(4)
    app.backflip()
    time.sleep(4)
    app.attitudeControl(0.1, 0.1, 0.1, 0.1)
    time.sleep(4)
    while True:
        time.sleep(2)

if __name__ == '__main__':
    main()
