import tensorflow as tf

hello = tf.constant('Hello, TensorFlow!')
sess = tf.Session()
print(sess.run(hello))
#OUTPUT:
# b'Hello, TensorFlow!'

# PRINTING TENSORS
node1 = tf.constant(3.0, tf.float32)
node2 = tf.constant(4.0)
print(node1, node2)
#OUTPUT:
# Tensor("Const_2:0", shape=(), dtype=float32) Tensor("Const_3:0", shape=(), dtype=float32)
#
# Notice that printing the nodes does not output the values 3.0 and 4.0 as you might expect. Instead, they are nodes that,
#  when evaluated, would produce 3.0 and 4.0, respectively. To actually evaluate the nodes, we must run the computational
#  graph within a session. A session encapsulates the control and state of the TensorFlow runtime.
print(sess.run([node1, node2]))
#OUTPUT:
# [3.0, 4.0]

# ADDING TENSORS
node3 = tf.add(node1, node2)
print("node3: ", node3)
#OUTPUT:
# node3:  Tensor("Add:0", shape=(), dtype=float32)
print("sess.run(node3):", sess.run(node3))
#OUTPUT:
# sess.run(node3): 7.0

# PLACEHOLDERS
# A placeholder is a promise to provide a value later.
a = tf.placeholder(tf.float32)
b = tf.placeholder(tf.float32)
adder_node = a+b
print(sess.run(adder_node, {a: 3, b:4.5}))
#OUTPUT: 7.5
print(sess.run(adder_node, {a: [1,3], b:[2,4]}))
#OUTPUT: [ 3.  7.]

add_and_triple = adder_node * 3
print(sess.run(add_and_triple, {a: 3, b:4.5}))
#OUTPUT: 22.5

# VARIABLES
print("Variables example")

W = tf.Variable([.3], tf.float32)
b = tf.Variable([-.3], tf.float32)
x = tf.placeholder(tf.float32)
linear_model = W * x + b
init = tf.global_variables_initializer()
sess.run(init)
print(sess.run(linear_model, {x:[1,2,3,4]}))
# OUTPUT: [ 0.          0.30000001  0.60000002  0.90000004]

y = tf.placeholder(tf.float32)
squared_deltas = tf.square(linear_model - y)
loss = tf.reduce_sum(squared_deltas)
print(sess.run(loss, {x:[1,2,3,4], y:[0,-1,-2,-3]}))
# OUTPUT: 23.66

fixW = tf.assign(W, [-1.])
fixb = tf.assign(b, [1.])
sess.run([fixW, fixb])
# OUTPUT: [array([-1.], dtype=float32), array([ 1.], dtype=float32)]
print(sess.run(loss, {x:[1,2,3,4], y:[0,-1,-2,-3]}))
# OUTPUT: 0.0

# TRAIN
print("TRAIN")
optimizer = tf.train.GradientDescentOptimizer(0.01)
train = optimizer.minimize(loss)
sess.run(init) # reset values to incorrect defaults.
for i in range(1000):
  sess.run(train, {x:[1,2,3,4], y:[0,-1,-2,-3]})

print(sess.run([W, b]))
# OUTPUT: [array([-0.9999969], dtype=float32), array([ 0.99999082], dtype=float32)]
