#!/usr/bin/env python3

import time
import datetime
import logging
import subprocess


logger = logging.Logger(__name__)


class Webcam():

    def __init__(self):

        self.snapshot_path = '/srv/home-assistant/tmp/webcam-snapshot.jpg'
        self.snapshot_width = 800
        self.snapshot_height = 600
        self.snapshot_delay = 5.0

        self.start_time = datetime.datetime.utcnow()
        self.terminate = False
        self.timer = 300.0

    def elapsed_time(self):
        return (datetime.datetime.utcnow() - self.start_time).total_seconds()

    def snapshot(self):
        logger.debug("Taking snapshot (path: %s)" % (self.snapshot_path))
        resolution = "%dx%d" % (self.snapshot_width, self.snapshot_height)
        subprocess.call(["fswebcam", "-r", resolution, self.snapshot_path])

    def start(self):

        while not self.terminate:

            self.snapshot()

            if self.elapsed_time() + self.snapshot_delay > self.timer:
                self.terminate = True
            else:
                time.sleep(self.snapshot_delay)


if __name__ == "__main__":
    ds = Webcam()
    ds.start()
