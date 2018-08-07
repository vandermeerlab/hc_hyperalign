import numpy as np
import nept

task_times = dict()
task_times['on_track'] = nept.Epoch(np.array([2766.9, 5174.5]))

experiment_times = dict()
experiment_times['left_trials'] = nept.Epoch(np.array([[2870.8, 2883.2],
                                                       [3011.3, 3035.5],
                                                       [3143.5, 3151.0],
                                                       [3257.7, 3268.2],
                                                       [3395.7, 3403.8],
                                                       [3532.6, 3539.9],
                                                       [3637.8, 3646.8],
                                                       [3982.8, 3989.8],
                                                       [4098.6, 4110.9],
                                                       [4215.5, 4227.1],
                                                       [4329.2, 4336.0],
                                                       [4750.3, 4758.1],
                                                       [4870.6, 4880.0],
                                                       [4992.3, 5011.6],
                                                       [5110.5, 5121.8]]))

experiment_times['right_trials'] = nept.Epoch(np.array([[2768.0, 2787.1],
                                                        [3751.3, 3779.2],
                                                        [3877.2, 3900.6],
                                                        [4477.4, 4553.1],
                                                        [4644.5, 4660.4]]))
