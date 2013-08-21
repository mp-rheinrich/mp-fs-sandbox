import subprocess

import settings
import common
import monitoring

class Benchmark(object):
    def __init__(self, config):
        self.config = config
        self.tmp_dir = "%s/%08d" % (settings.cluster.get('tmp_dir'), config.get('iteration'))
        self.archive_dir = "%s/%08d" % (settings.cluster.get('archive_dir'), config.get('iteration'))

    def getclass(self):
        return self.__class__.__name__

    def initialize(self):
        pass

    def run(self):
        pass

    def cleanup(self):
        pass

    def dropcaches(self):
        nodes = settings.getnodes('clients', 'servers') 

        common.pdsh(nodes, 'sync').communicate()
        common.pdsh(nodes, 'echo 3 | sudo tee /proc/sys/vm/drop_caches').communicate()

    def __str__(self):
        return str(self.config)
