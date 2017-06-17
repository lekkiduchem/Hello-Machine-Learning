# https://deeplearningcourses.com/c/deep-reinforcement-learning-in-python
# https://www.udemy.com/deep-reinforcement-learning-in-python
from __future__ import print_function, division
from builtins import range
# Note: you may need to update your version of future
# sudo pip install -U future

import copy
import gym
import os
import sys
import random
import numpy as np
import tensorflow as tf
import matplotlib.pyplot as plt
from gym import wrappers
from datetime import datetime
from scipy.misc import imresize

if '../cartpole' not in sys.path:
  sys.path.append('../cartpole')
from q_learning_bins import plot_running_avg

# constants
IM_WIDTH = 80
IM_HEIGHT = 80

# globals
global_step = 0


class ConvLayer:
  def __init__(self, mi, mo, filtersz=5, stride=2, f=tf.nn.relu):
    # mi = input feature map size
    # mo = output feature map size
    self.W = tf.Variable(tf.random_normal(shape=(filtersz, filtersz, mi, mo)))
    b0 = np.zeros(mo, dtype=np.float32)
    self.b = tf.Variable(b0)
    self.f = f
    self.stride = stride
    self.params = [self.W, self.b]

  def forward(self, X):
    conv_out = tf.nn.conv2d(X, self.W, strides=[1, self.stride, self.stride, 1], padding='SAME')
    conv_out = tf.nn.bias_add(conv_out, self.b)
    return self.f(conv_out)


def downsample_image(A):
  B = A[31:195] # select the important parts of the image
  # B = B / 255.0 # scale to 0..1
  B = B.mean(axis=2) # convert to grayscale

  # downsample image
  # changing aspect ratio doesn't significantly distort the image
  # nearest neighbor interpolation produces a much sharper image
  # than default bilinear
  B = imresize(B, size=(IM_HEIGHT, IM_WIDTH), interp='nearest')
  return B


# a version of HiddenLayer that keeps track of params
class HiddenLayer:
  def __init__(self, M1, M2, f=tf.nn.relu, use_bias=True):
    # print("M1:", M1)
    self.W = tf.Variable(tf.random_normal(shape=(M1, M2)))
    self.params = [self.W]
    self.use_bias = use_bias
    if use_bias:
      self.b = tf.Variable(np.zeros(M2).astype(np.float32))
      self.params.append(self.b)
    self.f = f

  def forward(self, X):
    if self.use_bias:
      a = tf.matmul(X, self.W) + self.b
    else:
      a = tf.matmul(X, self.W)
    return self.f(a)


class DQN:
  def __init__(self, K, conv_layer_sizes, hidden_layer_sizes, gamma, max_experiences=500000, min_experiences=50000, batch_sz=32):
    self.K = K

    # create the graph
    self.conv_layers = []
    num_input_filters = 4 # number of filters / color channels
    final_height = IM_HEIGHT
    final_width = IM_WIDTH
    for num_output_filters, filtersz, stride in conv_layer_sizes:
      layer = ConvLayer(num_input_filters, num_output_filters, filtersz, stride)
      self.conv_layers.append(layer)
      num_input_filters = num_output_filters

      # calculate final output size for input into fully connected layers
      old_height = final_height
      new_height = int(np.ceil(old_height / stride))
      print("new_height (%s) = old_height (%s) / stride (%s)" % (new_height, old_height, stride))
      final_height = int(np.ceil(final_height / stride))
      final_width = int(np.ceil(final_width / stride))

    self.layers = []
    flattened_ouput_size = final_height * final_width * num_input_filters
    M1 = flattened_ouput_size
    for M2 in hidden_layer_sizes:
      layer = HiddenLayer(M1, M2)
      self.layers.append(layer)
      M1 = M2

    # final layer
    layer = HiddenLayer(M1, K, lambda x: x)
    self.layers.append(layer)

    # collect params for copy
    self.params = []
    for layer in (self.conv_layers + self.layers):
      self.params += layer.params

    # inputs and targets
    self.X = tf.placeholder(tf.float32, shape=(None, 4, IM_HEIGHT, IM_WIDTH), name='X')
    # tensorflow convolution needs the order to be:
    # (num_samples, height, width, "color")
    # so we need to tranpose later
    self.G = tf.placeholder(tf.float32, shape=(None,), name='G')
    self.actions = tf.placeholder(tf.int32, shape=(None,), name='actions')

    # calculate output and cost
    Z = self.X / 255.0
    Z = tf.transpose(Z, [0, 2, 3, 1]) # TF wants the "color" channel to be last
    for layer in self.conv_layers:
      Z = layer.forward(Z)
    Z = tf.reshape(Z, [-1, flattened_ouput_size])
    for layer in self.layers:
      Z = layer.forward(Z)
    Y_hat = Z
    self.predict_op = Y_hat

    # selected_action_values = tf.reduce_sum(
    #   Y_hat * tf.one_hot(self.actions, K),
    #   reduction_indices=[1]
    # )

    # we would like to do this, but it doesn't work in TF:
    # selected_action_values = Y_hat[tf.range(batch_sz), self.actions]
    # instead we do:
    indices = tf.range(batch_sz) * tf.shape(Y_hat)[1] + self.actions
    selected_action_values = tf.gather(
      tf.reshape(Y_hat, [-1]), # flatten
      indices
    )

    cost = tf.reduce_mean(tf.square(self.G - selected_action_values))
    # self.train_op = tf.train.AdamOptimizer(10e-3).minimize(cost)
    # self.train_op = tf.train.AdagradOptimizer(10e-3).minimize(cost)
    self.train_op = tf.train.RMSPropOptimizer(0.00025, 0.99, 0.0, 1e-6).minimize(cost)
    # self.train_op = tf.train.MomentumOptimizer(10e-4, momentum=0.9).minimize(cost)
    # self.train_op = tf.train.GradientDescentOptimizer(10e-5).minimize(cost)

    # create replay memory
    self.experience = []
    self.max_experiences = max_experiences
    self.min_experiences = min_experiences
    self.batch_sz = batch_sz
    self.gamma = gamma

  def set_session(self, session):
    self.session = session

  def copy_from(self, other):
    # collect all the ops
    ops = []
    my_params = self.params
    other_params = other.params
    for p, q in zip(my_params, other_params):
      actual = self.session.run(q)
      op = p.assign(actual)
      ops.append(op)
    # now run them all
    self.session.run(ops)

  def predict(self, X):
    return self.session.run(self.predict_op, feed_dict={self.X: X})

  def is_training(self):
    return len(self.experience) >= self.min_experiences

  def train(self, target_network):
    # sample a random batch from buffer, do an iteration of GD
    if not self.is_training():
      # don't do anything if we don't have enough experience
      return

    # randomly select a batch
    sample = random.sample(self.experience, self.batch_sz)
    states, actions, rewards, next_states, dones = map(np.array, zip(*sample))
    next_Q = np.amax(target_network.predict(next_states), axis=1)
    # targets = [r + self.gamma*next_q if done is False else r for r, next_q, done in zip(rewards, next_Q, dones)]
    # equivalent
    targets = rewards + np.invert(dones) * self.gamma * next_Q

    # print("train start")
    # call optimizer
    self.session.run(
      self.train_op,
      feed_dict={
        self.X: states,
        self.G: targets,
        self.actions: actions
      }
    )
    # print("train end")

  def add_experience(self, s, a, r, s2, done):
    if len(self.experience) >= self.max_experiences:
      self.experience.pop(0)
    if len(s) != 4 or len(s2) != 4:
      print("BAD STATE")

    # make copies
    s = copy.copy(s)
    s2 = copy.copy(s2)

    self.experience.append((s, a, r, s2, done))

  def sample_action(self, x, eps):
    if np.random.random() < eps:
      return np.random.choice(self.K)
    else:
      return np.argmax(self.predict([x])[0])

  def print_var_sizes(self):
    # print all variable sizes
    mine = self.session.run(self.params)
    for v in mine:
      print(v.shape)


def update_state(state, observation):
  # downsample and grayscale observation
  observation_small = downsample_image(observation)

  # list method
  # state.append(observation_small)
  # if len(state) > 4:
  #   state.pop(0)
  # return state

  # numpy method
  # expect state to be of shape (4,80,80)
  # print("state.shape:", state.shape)
  # B = np.expand_dims(observation_small, 0)
  # print("B.shape:", B.shape)
  return np.append(state[1:], np.expand_dims(observation_small, 0), axis=0)


def play_one(env, model, tmodel, eps, eps_step, gamma, copy_period):
  global global_step

  observation = env.reset()
  done = False
  totalreward = 0
  iters = 0
  # state = []
  # prev_state = []
  # update_state(state, observation) # add the first observation
  # state = np.array([downsample_image(observation)]*4)
  state = [downsample_image(observation)]*4
  prev_state = None

  total_time_training = 0
  n_training_steps = 0

  while not done and iters < 2000:
    # if we reach 2000, just quit, don't want this going forever
    # the 200 limit seems a bit early

    if len(state) < 4:
      # we can't choose an action based on model
      action = env.action_space.sample()
    else:
      action = model.sample_action(state, eps)

    # copy state to prev state
    # prev_state.append(state[-1])
    # if len(prev_state) > 4:
    #   prev_state.pop(0)
    prev_state = np.copy(state)

    # perform the action
    observation, reward, done, info = env.step(action)

    # add the new frame to the state
    state = update_state(state, observation)

    totalreward += reward

    # update the model
    if len(state) == 4 and len(prev_state) == 4:
      model.add_experience(prev_state, action, reward, state, done)

      t0 = datetime.now()
      model.train(tmodel)
      dt = (datetime.now() - t0).total_seconds()

      total_time_training += dt
      n_training_steps += 1

      if model.is_training():
        eps = max(eps - eps_step, 0.1)

    iters += 1

    if global_step % copy_period == 0:
      tmodel.copy_from(model)
    global_step += 1

  if n_training_steps > 0:
    print("Training time per step:", total_time_training / n_training_steps)

  return totalreward, eps, iters


def main():
  env = gym.make('Breakout-v0')
  gamma = 0.99
  copy_period = 10000

  D = len(env.observation_space.sample())
  K = 4 #env.action_space.n ### NO! returns 6 but only 4 valid actions
  conv_sizes = [(32, 8, 4), (64, 4, 2), (64, 3, 1)]
  hidden_sizes = [512]
  model = DQN(K, conv_sizes, hidden_sizes, gamma)
  tmodel = DQN(K, conv_sizes, hidden_sizes, gamma)
  init = tf.global_variables_initializer()
  session = tf.InteractiveSession()
  session.run(init)
  model.set_session(session)
  tmodel.set_session(session)

  model.print_var_sizes()

  if 'monitor' in sys.argv:
    filename = os.path.basename(__file__).split('.')[0]
    monitor_dir = './' + filename + '_' + str(datetime.now())
    env = wrappers.Monitor(env, monitor_dir)


  N = 100000
  totalrewards = np.empty(N)
  costs = np.empty(N)
  n_max = 500000 # last step to decrease epsilon
  eps_step = 0.9 / n_max
  eps = 1.0
  for n in range(N):
    t0 = datetime.now()
    totalreward, eps, num_steps = play_one(env, model, tmodel, eps, eps_step, gamma, copy_period)
    totalrewards[n] = totalreward
    if n % 1 == 0:
      print("episode:", n, "total reward:", totalreward, "eps:", "%.3f" % eps, "num steps:", num_steps, "episode duration:", (datetime.now() - t0), "avg reward (last 100):", "%.3f" % totalrewards[max(0, n-100):(n+1)].mean())

  print("avg reward for last 100 episodes:", totalrewards[-100:].mean())
  print("total steps:", totalrewards.sum())

  plt.plot(totalrewards)
  plt.title("Rewards")
  plt.show()

  plot_running_avg(totalrewards)


if __name__ == '__main__':
  main()


