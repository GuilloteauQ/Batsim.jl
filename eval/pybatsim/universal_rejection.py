
# from pybatsim.batsim.batsim import BatsimScheduler
from pybatsim.schedulers.fcfs import Fcfs


class FcfsQ(Fcfs):
    def __init__(self, options):
        super().__init__(options)
