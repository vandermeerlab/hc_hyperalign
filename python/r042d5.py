import numpy as np
import nept

task_times = dict()
task_times['on_track'] = nept.Epoch(np.array([2421.1, 4816.9]))

experiment_times = dict()
experiment_times['left_trials'] = nept.Epoch(np.array([[2436.3, 2487.4],
                                                       [3398.8, 3423.7],
                                                       [3538.1, 3570.7],
                                                       [3905.1, 3927.8],
                                                       [4209.9, 4225.9],
                                                       [4468.7, 4483.6]]))

experiment_times['right_trials'] = nept.Epoch(np.array([[2594.2, 2634.0],
                                                        [2771.2, 2818.5],
                                                        [2925.0, 2934.7],
                                                        [3040.2, 3098.0],
                                                        [3172.5, 3197.9],
                                                        [3280.0, 3294.4],
                                                        [3675.5, 3687.6],
                                                        [3779.4, 3789.3],
                                                        [4055.2, 4094.5],
                                                        [4321.1, 4364.6],
                                                        [4600.9, 4636.5]]))
